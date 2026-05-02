---
name: ios-subscription-system
description: Build or audit a StoreKit 2 iOS subscription system with a 60-day trial, iCloud KVS anti-cheat, App Store-compliant paywall, StoreKit config, and local expiry notifications
trigger: /ios-subscription-system
---

# /ios-subscription-system

Build or audit a reusable iOS subscription system using StoreKit 2, a 60-day no-card trial, iCloud Key-Value Store anti-cheat, monthly/yearly/lifetime products, local expiry notifications, debug tools, and an App Store-compliant paywall.

Use this for any iOS app. Adapt naming, product IDs, features, pricing, legal URLs, and project paths to the current app.

## Check current Apple docs first

When web access is available and the work is release-facing, check Apple’s current docs before making compliance decisions:

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/)
- [Offering, completing, and restoring in-app purchases](https://developer.apple.com/documentation/storekit/offering-completing-and-restoring-in-app-purchases)
- [Product](https://developer.apple.com/documentation/storekit/product)
- [Transaction](https://developer.apple.com/documentation/storekit/transaction)
- [StoreKit testing in Xcode](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)
- [App Store Connect: in-app purchases](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/overview-for-configuring-in-app-purchases/)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- [UserNotifications](https://developer.apple.com/documentation/usernotifications)

If Apple’s current docs conflict with this skill, follow Apple’s docs and update this skill.

## Values to confirm

Follow the shared infer-first rules in `CLAUDE.md`. For this skill, confirm only the task-specific values that cannot be safely inferred:

- Monthly, yearly, or lifetime prices when no trusted StoreKit/App Store config defines them.
- App-specific Privacy Policy URL when missing or placeholder.
- Terms of Use URL, or permission to temporarily use Apple’s Standard EULA during development, when no app-specific terms exist.
- Which features should be Pro-only when the current code does not clearly define the business model.
- Any ambiguous app target, bundle namespace, subscription group, or account/data-sharing policy.

If legal URLs are unavailable and the app is still in development, use placeholders only with a clear warning that the app-specific Privacy Policy URL must be replaced before App Store submission.

## Core product strategy

Default product IDs:

```swift
static let monthlyProductID = "{bundleNamespace}.pro.monthly"
static let yearlyProductID = "{bundleNamespace}.pro.yearly"
static let lifetimeProductID = "{bundleNamespace}.pro.lifetime"
static let allProductIDs: Set<String> = [monthlyProductID, yearlyProductID, lifetimeProductID]
```

Products:

- Monthly auto-renewable subscription, 1 month
- Yearly auto-renewable subscription, 1 year, default selected, badge `BEST VALUE`
- Lifetime non-consumable purchase, badge `PAY ONCE`

App Store Connect:

- Put monthly and yearly in the same subscription group, usually `{AppName} Pro`, so upgrades/downgrades are seamless.
- Use the user-provided prices.
- Add localized display names and descriptions for all products.
- Ensure App Store Connect product IDs exactly match the app code and StoreKit config.

Apple requirements to preserve:

- Digital features/content must use Apple In-App Purchase unless a specific Apple entitlement/regional rule allows otherwise.
- Auto-renewable subscriptions must last at least 7 days, provide ongoing value, and work across all user devices where the app is available.
- Users must receive paid access without unrelated tasks such as social posting, repeated check-ins, or granting unrelated permissions.

## Expected files

Adapt paths to the project:

- `Services/SubscriptionService.swift`
- `Views/PaywallView.swift`
- `Views/TrialExpiryBanner.swift`
- `Configuration.storekit`
- Main app file for hard paywall integration
- Main/library content view for near-expiry banner
- Settings view for subscription status and debug tools
- Entitlements file for iCloud KVS

## SubscriptionService requirements

Create or update a singleton observable StoreKit 2 service.

Required state:

```swift
@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    static let monthlyProductID = "{bundleNamespace}.pro.monthly"
    static let yearlyProductID = "{bundleNamespace}.pro.yearly"
    static let lifetimeProductID = "{bundleNamespace}.pro.lifetime"
    static let allProductIDs: Set<String> = [monthlyProductID, yearlyProductID, lifetimeProductID]

    static let trialDurationDays = 60
    static let expiryWarningDays = 7
    private static let trialStartKey = "{appKey}_trial_start_date"

    var products: [Product] = []
    var isProUser = false
    var isLoading = false
    var errorMessage: String?
    private(set) var isStatusLoaded = false

    private var trialStartDate: Date?
    private var transactionListener: Task<Void, Error>?

    var daysRemaining: Int { /* from trialStartDate */ }
    var trialActive: Bool { !isTrialExpired && !isProUser }
    var isTrialExpired: Bool { isStatusLoaded && daysRemaining <= 0 && !isProUser }
    var isTrialNearExpiry: Bool { isStatusLoaded && daysRemaining > 0 && daysRemaining <= Self.expiryWarningDays && !isProUser }
    var hasFullAccess: Bool { isProUser || (trialActive && !isTrialExpired) }
}
```

Implementation requirements:

- In `init()`: load trial start date, start transaction listener, load products, update entitlement status, set `isStatusLoaded = true`, schedule expiry notifications.
- Trial start date:
  - Prefer `NSUbiquitousKeyValueStore` so reinstalling cannot reset the trial.
  - Also write `UserDefaults` as a local fallback for iCloud sync delays.
- StoreKit:
  - Load products with `Product.products(for:)` and sort consistently; display auto-renewable subscriptions before lifetime where it improves readability.
  - Purchase through `product.purchase()`.
  - Handle `.userCancelled`, `.pending`, and `@unknown default` purchase results without treating them as successful purchases.
  - Verify `VerificationResult`.
  - Finish successful transactions.
  - Restore with `AppStore.sync()`, then re-check entitlements.
  - Listen to `Transaction.updates`.
  - Read `Transaction.currentEntitlements`.
- Entitlement status must count only verified transactions whose `productID` is in `allProductIDs`:

```swift
@MainActor
func updateSubscriptionStatus() async {
    var hasActive = false
    for await result in Transaction.currentEntitlements {
        guard let transaction = try? checkVerified(result) else { continue }
        if Self.allProductIDs.contains(transaction.productID) {
            hasActive = true
            break
        }
    }
    isProUser = hasActive
}
```

## Paywall requirements

The paywall must clearly show before purchase:

- App icon/title
- What the user receives for the price
- Trial state:
  - During trial: days remaining
  - Expired: `Trial Ended`
- Paywall appearance should log `InitiatedCheckout` if analytics exists.
- Paywall should auto-dismiss when `isProUser` becomes true after purchase or restore.
- Product cards with localized StoreKit values:
  - `product.displayName`
  - `product.displayPrice`
  - billing period (`per month`, `per year`)
  - monthly/yearly auto-renew language
  - lifetime one-time purchase language
  - yearly `BEST VALUE` badge
  - lifetime `PAY ONCE` badge
- Sticky primary purchase button for selected product
- Visible restore action
- Visible privacy link
- Visible terms/subscription terms access
- Apple Account charge and auto-renewal disclosure

Use StoreKit localized display values in the UI. Do not hardcode production-visible prices except in StoreKit config/test setup.

### Compact legal pattern

Keep the main paywall clean:

```text
Payment is charged to your Apple Account. Subscriptions auto-renew until canceled.
```

Footer links:

- `Restore`
- `Subscription Terms`
- `Privacy`

`Subscription Terms` opens a sheet with:

```text
Payment will be charged to your Apple Account at confirmation of purchase.

Monthly and yearly subscriptions automatically renew unless canceled at least 24 hours before the end of the current period.

You can manage or cancel subscriptions in your Apple Account settings.

Lifetime is a one-time purchase and does not renew.
```

The sheet must include Terms of Use, Privacy Policy, and Done. If the app has a model named `Section`, use `SwiftUI.Section` in the sheet.

### Dismissal behavior

- Soft paywall during trial: dismissible, e.g. `Not now`.
- Hard paywall after trial expiry: no dismiss button and `.interactiveDismissDisabled(true)`.
- Do not keep temporary hard-paywall kill switches unless the user explicitly asks.

## App integration

Main app pattern:

```swift
@State private var subscriptionService = SubscriptionService.shared

WindowGroup {
    if subscriptionService.isStatusLoaded {
        MainContentView()
            .fullScreenCover(isPresented: .constant(subscriptionService.isTrialExpired)) {
                PaywallView()
            }
    } else {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

Trial near-expiry banner:

- Show when `subscriptionService.isTrialNearExpiry`.
- Text: `Trial ends in X day(s)`.
- Subtext: `Subscribe to keep all features`.
- Action opens soft paywall.
- Do not show behind/inside the hard paywall.

Settings:

- Pro users: show Pro status and `Manage Subscription` opening `https://apps.apple.com/account/subscriptions`.
- Non-Pro users: show `Upgrade to Pro`; show trial days remaining when active.
- Debug-only section under `#if DEBUG`:
  - trial active/expired
  - days remaining
  - Pro yes/no
  - set trial to 5 days left
  - set trial to 1 day left
  - expire trial now
  - reset trial
  - simulate free/Pro

## StoreKit config, capabilities, and notifications

Create/update `Configuration.storekit`:

- Lifetime non-consumable: `{bundleNamespace}.pro.lifetime`, user-provided lifetime price
- Subscription group: `{AppName} Pro`
- Monthly subscription: `{bundleNamespace}.pro.monthly`, 1 month, user-provided monthly price
- Yearly subscription: `{bundleNamespace}.pro.yearly`, 1 year, user-provided yearly price
- Use local StoreKit testing before App Store submission; no special Info.plist keys are required for StoreKit 2.

Enable/verify Xcode capabilities:

- In-App Purchase
- iCloud → Key-Value Storage

KVS entitlement should include:

```xml
<key>com.apple.developer.ubiquity-kvstore-identifier</key>
<string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
```

Schedule local notifications:

- 7 days before trial expiry
- On expiry day

Request notification permission thoughtfully. Paid/core access must not depend on notification permission.

## App Store readiness checklist

Before calling the system release-ready, verify:

- Product name, price, duration, renewal terms, and included benefits are visible before purchase.
- Restore Purchases is visible.
- Privacy Policy link is app-specific, visible in-app, and present in App Store Connect metadata.
- Terms/Subscription Terms are visible before purchase.
- Lifetime is clearly non-renewing.
- No external purchase links/calls to action exist unless Apple entitlement/regional rules allow them.
- Paid access does not depend on unrelated permissions or tasks.
- Third-party data sharing, including AI services, is disclosed and consented to where required.
- If accounts can be created, account deletion exists in-app.
- Monthly/yearly subscriptions are in the same subscription group.
- IAP products are complete, current, visible, functional, and reviewable.
- Review notes explain where to find IAPs if needed.
- App Store screenshots/descriptions/previews disclose subscription-gated functionality when featured.
- App Privacy metadata accurately declares purchase history and collected data.

## Analytics

If analytics already exists, log:

- `StartTrial` with `trial_duration: "60_days"`
- `InitiatedCheckout` on paywall appear
- `Purchase` after successful purchase with amount, currency, product ID
- Optional `TrialExpiry`

Do not create a large analytics system just for this unless requested.

## Testing checklist

Test or instruct the user to test:

- New user starts with the expected trial length.
- Trial countdown is correct.
- Trial persists across reinstall via iCloud KVS on a real device.
- Local fallback works when iCloud sync is delayed.
- Near-expiry banner appears at threshold.
- Expired trial shows hard non-dismissible paywall.
- Monthly, yearly, and lifetime purchases work.
- Restore works.
- Purchase updates unlock without app restart.
- StoreKit local config loads all products.
- Transactions verify successfully and can be cleared in Xcode Transaction Manager during local testing.
- Debug buttons simulate states correctly.
- Subscription status persists across app restarts.
- Sandbox/TestFlight purchases work on real devices.
- Subscription auto-renewal, cancellation, and refunds are handled correctly.
- Subscription works across all supported devices.

For Claude Code in iOS projects: after significant changes, list available simulators, choose a valid one, build with `xcodebuild`, and fix build errors. For UI changes, visually verify the paywall when practical.

## Audit mode

When auditing an existing app, inspect:

- Subscription service and entitlement filtering
- Paywall UI/disclosures
- Hard paywall integration
- Trial near-expiry banner
- Settings subscription/debug section
- StoreKit config
- Entitlements/capabilities
- Product ID consistency
- App-specific privacy/terms URLs
- App Store metadata/review readiness if available
- Account deletion if accounts exist
- Permission-gated paid features or third-party data sharing risks

Report:

1. Critical release blockers
2. Compliant items
3. Recommended improvements
4. Missing user-provided values, especially prices and legal URLs

## Maintenance notes

- Monitor subscription metrics in App Store Connect and analytics.
- Price changes are usually made in App Store Connect, not hardcoded in the app.
- New product tiers must be added to `allProductIDs`, StoreKit config, and App Store Connect.
- Trial duration changes require updating the app constant and retesting expiry logic.
- Feature changes should update the paywall benefits and App Store metadata.

## Common pitfalls

Avoid:

- UserDefaults-only trial tracking
- Missing `isStatusLoaded`
- Hard-paywall kill switches in release path
- Counting any verified entitlement without checking product ID
- Forgetting `transaction.finish()`
- Missing transaction listener
- Missing restore purchases
- Hiding all legal terms without a pre-purchase link
- Using Apple’s privacy policy as the final app privacy policy
- Hardcoding visible production prices instead of StoreKit localized prices
- Wrong subscription groups causing duplicate active subscriptions
- Gating paid access on push notifications, tracking, location, contacts, social posting, or other unrelated tasks
- Forgetting account deletion when account creation exists
- Debug controls outside `#if DEBUG`
- Backwards-compatibility shims in pre-release apps
