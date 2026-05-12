---
name: ios-app-rating-feedback
description: Build or audit a portable iOS app rating and private feedback system with a sentiment gate, StoreKit review prompt, consented feedback submission, eligibility rules, debug testing, and iCloud KVS persistence
trigger: /ios-app-rating-feedback
---

# /ios-app-rating-feedback

Build or audit an iOS app rating and private feedback system that asks at positive “wow moments,” routes happy users to Apple’s review prompt, routes users who need help to private feedback, and persists prompt eligibility across reinstalls with iCloud Key-Value Store.

This skill is based on a proven pattern:

```text
Positive milestone → sentiment gate
  Love it!   → native StoreKit review prompt
  Need help  → private feedback form + explicit consent + webhook/email submission
  Not now    → dismiss + cooldown
```

## Modes

Use the user’s wording to choose the mode:

- **Audit mode**: inspect the current app and report gaps. Do not edit unless the user asks.
- **Implementation mode**: add or update the rating/feedback system using existing project patterns.
- **Rewrite/maintenance mode**: update this skill or related reusable toolkit files while keeping them generic.

Follow the shared infer-first rules in `CLAUDE.md`.

## Goal

At configured positive moments, show a lightweight sentiment gate:

```text
How’s your experience?

Love it!   Need help   Not now
```

- `Love it!` records the prompt attempt for this version and calls Apple’s review API.
- `Need help` dismisses the gate, then opens a private feedback form.
- `Not now` records a decline and suppresses future prompts for the cooldown window.

Never show the prompt during negative moments, such as trial expiry, failed purchases, errors, crashes, rejected imports, cancellation flows, hard paywalls, support flows, or other frustration states.

## Discover before asking

Inspect the app first and infer values from trusted project files when available:

- App name, bundle identifier, version, build number, app target, and scheme.
- Existing Settings, support, rating, privacy, subscription, analytics, URL-opening, haptics, and keyboard helper patterns.
- Existing App Store ID or App Store review URL.
- Existing feedback transport: webhook, backend endpoint, mailto link, support URL, CRM integration, or contact form.
- Existing privacy/consent wording and data-sharing controls.
- Existing milestone/event definitions and where successful workflows complete.
- Existing iCloud KVS/UserDefaults conventions.

Ask only when the value is missing, ambiguous, sensitive, or a business/legal decision.

## Values to confirm

Confirm these before implementation if they cannot be safely inferred:

- Which user actions count as entries for the `20+ entries` rule.
- Which positive “wow moments” should trigger eligibility checks.
- The production destination for private feedback.
- Whether the destination is a FluentCRM webhook, app backend, support email, or another system.
- Any app-specific feedback categories, routing, support ownership, or privacy/legal wording.
- App Store ID if no trusted source exists and a Settings review link is requested.

Always ask for the private feedback webhook URL before adding or changing webhook submission code, unless the user already provided the URL in the current request. If the app already contains a webhook URL, show the discovered URL to the user and ask whether to reuse or replace it.

Do **not** silently send production user feedback to a webhook copied from another app. If a webhook is present in the current app, reuse it only after verifying it belongs to this app or the user confirms it.

## Official Apple references

When web access is available and the work is release-facing, check Apple’s current docs:

- [Requesting App Store reviews](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews)
- [RequestReviewAction](https://developer.apple.com/documentation/storekit/requestreviewaction)
- [SKStoreReviewController](https://developer.apple.com/documentation/storekit/skstorereviewcontroller)
- [NSUbiquitousKeyValueStore](https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)

If Apple’s current docs conflict with this skill, follow Apple’s docs and update this skill.

## Recommended architecture

Prefer a small app-specific service plus SwiftUI views. Do not create a large analytics, routing, networking, or feedback abstraction unless the app already has one.

A typical shape:

```swift
@Observable
@MainActor
final class AppRatingService {
    static let shared = AppRatingService()

    var shouldShowSentimentGate = false
    var shouldShowFeedbackForm = false

    func recordEntry()
    func triggerIfEligible(source: FeedbackSource, isNegativeMoment: Bool)
    func userLovesIt()
    func userNeedsHelp()
    func userDismissed()
    func dismissFeedback()
    func sendFeedback(email: String?, message: String, feedbackType: String, feedbackSource: String) async -> Bool
}
```

Use app naming that matches the project. If the app already uses dependency injection or environment objects, follow that pattern instead of adding a singleton.

## Eligibility rules

A user is eligible only when all are true:

- At least 30 days since first launch.
- At least 20 entries, where the app defines what an entry means.
- At least 90 days since the last rating/feedback prompt attempt.
- At least 90 days since the last decline.
- The current app version has not already been prompted/rated through this system.
- User is not in a negative moment.
- Subscription/trial state is not negative, e.g. do not prompt during expired-trial or hard-blocking paywall states.

Persist rating/feedback prompt state with `NSUbiquitousKeyValueStore` so eligibility, declines, app-version prompt history, first launch date, and entry count survive reinstall and sync across devices. Use `UserDefaults` as a local fallback for iCloud sync delays, not as the only source of truth.

Recommended persisted keys:

- `{appKey}_rating_first_launch_date`
- `{appKey}_rating_entry_count`
- `{appKey}_rating_last_prompt_date`
- `{appKey}_rating_last_decline_date`
- `{appKey}_rating_last_prompted_version`
- `{appKey}_rating_last_rated_version`

Use the current app’s stable key prefix, usually derived from the bundle ID or product name. Do not copy another app’s key prefix.

## Wow moments

Trigger eligibility checks only after positive milestones, such as:

- User successfully creates, imports, scans, saves, or completes meaningful content.
- User reaches a meaningful learning, creation, productivity, or workflow milestone.
- User successfully exports, shares, publishes, or completes a valuable result.
- User completes onboarding successfully.
- User completes a purchase or successful restore.
- User completes a key workflow without errors.

Call entry tracking at durable success points only. Do not increment entries for failed attempts, canceled flows, previews, validation errors, or duplicate events.

Do not show the gate immediately at launch. If a milestone completes during navigation or sheet dismissal, delay briefly so the rating sheet does not fight another presentation.

## Sentiment gate UI

Keep the UI lightweight and respectful:

- Title: `How’s your experience?`
- Optional subtitle: one short sentence tied to the app’s value.
- Actions:
  - `Love it!`
  - `Need help`
  - `Not now`

Behavior:

- `Love it!` dismisses the gate, records the current version as prompted/rated-through-system, and calls Apple’s review prompt.
- `Need help` dismisses the gate and opens the feedback form after a short delay if needed for sheet transitions.
- `Not now` dismisses the gate and records a decline date.

Prefer SwiftUI’s `@Environment(\.requestReview)` inside views when practical:

```swift
@Environment(\.requestReview) private var requestReview

requestReview()
```

If the project centralizes review requests in a service, use `AppStore.requestReview(in:)` with the active foreground `UIWindowScene`.

Apple may or may not show the system rating UI. Never assume the prompt appeared, and never gate rewards, features, or content on review submission.

## Feedback form UI

The private feedback form should collect only what support needs:

- Optional email.
- Feedback type.
- Message.
- Explicit consent before sending data externally.

Recommended feedback types:

- `bug`
- `feature`
- `question`
- `other`

Use project-specific categories only if they already exist or the user confirms them.

Recommended sources:

- `sentiment_gate`
- `milestone`
- `export`
- `purchase`
- `manual_settings`
- `settings_debug`

The send button should require:

- Non-empty message.
- Not currently sending.
- Consent granted when data leaves the app or goes to a third-party service.

On success, thank the user and close the form. On failure, show a clear retryable error. Do not block the main thread.

## Feedback destination

Prefer the app’s existing support destination if one exists. The production destination may be one of:

- A FluentCRM webhook.
- An app backend endpoint.
- A support email or mailto fallback.
- A helpdesk/contact form URL.

For webhook-based feedback, always ask the user for the webhook URL before implementation, even if the app appears to have one. If a URL already exists in the app, present it as the default to confirm. If the app has no private feedback destination, ask the user what to use. Do not invent or reuse a webhook from another app.

### FluentCRM/webhook payload

For a confirmed FluentCRM webhook or compatible JSON endpoint, send a POST request over HTTPS with JSON. Recommended fields:

- `email`
- `app_name`
- `app_id`
- `app_version`
- `device_model`
- `os_version`
- `feedback_message`
- `feedback_type`
- `feedback_source`
- `subscription_status`
- `feedback_date`

Use ISO-8601 for `feedback_date`.

Set `Content-Type: application/json`, use a reasonable timeout, treat only 2xx responses as success, and surface failures to the user.

Recommended anonymous email generation when the backend requires an email:

```swift
private func generateEmail(from email: String?) -> String {
    let trimmed = email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    if trimmed.isEmpty || !trimmed.contains("@") {
        let uuid = UUID().uuidString.prefix(8).lowercased()
        return "cf_\(uuid)@example.com"
    }

    return trimmed
}
```

If the destination does not require email, prefer omitting email over generating one, unless the existing backend expects this placeholder convention.

## Consent and privacy

Private feedback submission must be explicit:

- Do not send feedback without the user tapping Send on the feedback form.
- Require a consent toggle when sending feedback to a third party, CRM, analytics system, or external backend.
- Make email optional unless the user confirms support requires it.
- Clearly allow anonymous feedback when supported.
- Disclose what is sent: message, optional email, app version, subscription status if included, device model, and OS version.
- Show or name the destination in user-facing copy when practical, e.g. support domain or company name.
- Ensure the app’s Privacy Policy/App Store privacy details cover feedback data collection.

Avoid unnecessary personal data. Do not include document contents, user-generated content unrelated to the feedback message, precise location, contacts, photos, identifiers for advertisers, or analytics profiles unless the user explicitly confirms a compliant reason.

## Device/app metadata

Collect only practical support metadata:

- App name: configured display name/product name.
- App ID: bundle identifier.
- App version: `CFBundleShortVersionString`, optionally build number.
- Device model: machine identifier or readable fallback.
- OS version: `UIDevice.current.systemName` + `UIDevice.current.systemVersion`.
- Subscription status: `pro`, `trial_active`, `trial_expired`, `free`, or `unknown`.

If the app has a subscription service, derive subscription status from it. Otherwise use `unknown`.

## Settings integration

If the app has Settings or About screens, integrate lightly:

- Add or reuse a “Rate on App Store” row if the App Store ID is known.
- Add or reuse a “Send Feedback” row using the app’s support destination.
- Add a privacy/consent row only if the app already has a privacy section or the feedback form needs persistent consent.

A manual Settings feedback row can use the same feedback form with source `manual_settings`. A mailto link is acceptable as a fallback when no webhook/backend is available.

Do not expose debug-only controls in Release builds.

## Debug testing

Add debug-only controls under `#if DEBUG` when implementing:

- Trigger Sentiment Gate.
- Trigger Feedback Form.
- Reset Rating Prompt State, if useful.
- Set Eligible Rating State, if useful.

Use source `settings_debug` for debug submissions.

Never expose debug reset/force-prompt controls in Release builds.

## iCloud KVS persistence

Use `NSUbiquitousKeyValueStore.default`:

- Call `synchronize()` when loading.
- Write prompt state to iCloud KVS.
- Mirror important values to `UserDefaults` as fallback.
- Prefer the newest or most conservative value when resolving KVS/UserDefaults differences.
- Avoid resetting state during normal app updates.

State should persist across reinstall and across devices signed into the same Apple ID when iCloud KVS is available.

## Audit checklist

When auditing an existing app, inspect:

- Rating/feedback service and state ownership.
- Sentiment gate UI and sheet presentation behavior.
- Wow-moment trigger points.
- Negative-moment suppression.
- Eligibility thresholds and cooldown logic.
- Current-version prompt/rated tracking.
- iCloud KVS/UserDefaults persistence.
- Feedback form fields and validation.
- Consent and privacy disclosure.
- Feedback destination and payload.
- Settings support/rating rows.
- Debug Settings controls and Release separation.
- App Store review link and StoreKit usage.

Report findings in this order:

1. Critical release/privacy blockers.
2. App Store compliance issues.
3. Eligibility or prompt-frequency bugs.
4. Feedback delivery/payload gaps.
5. Debug/release separation issues.
6. UX improvements.

## Testing checklist

Test or instruct the user to test:

- First launch date initializes correctly.
- Entry count increments only on successful milestones.
- Prompt does not appear before 30 days.
- Prompt does not appear before 20 entries.
- Prompt does not appear within 90 days of prompt/decline.
- Prompt appears at a configured wow moment once eligible.
- Prompt does not appear during negative moments or expired trial hard paywall.
- `Love it!` triggers StoreKit review request and records version state.
- `Need help` opens feedback form after the gate closes.
- `Not now` records decline and suppresses prompts for 90 days.
- Feedback cannot send without a message and required consent.
- Feedback POST includes the confirmed required fields.
- Missing/invalid email is omitted or converted according to backend requirements.
- Network failure shows a user-visible retryable error.
- Prompt state persists through app relaunch and, where practical, reinstall/iCloud sync.
- Debug controls work only in DEBUG builds.
- Release build does not expose debug force/reset controls.

For Claude Code in iOS projects: after significant code changes, list available simulators, choose a valid simulator, build with `xcodebuild`, and fix build errors. For UI changes, visually verify the flow when practical.

## Common pitfalls

Avoid:

- Prompting at launch.
- Prompting during negative moments.
- Prompting after trial expiry or hard paywall.
- Asking unhappy users for App Store reviews.
- Sending private feedback without explicit user submission.
- Sending feedback to a webhook copied from another app.
- Hiding the feedback destination or data payload from the user.
- UserDefaults-only state that resets on reinstall.
- Ignoring Apple’s system-controlled review prompt limits.
- Showing debug trigger/reset controls in Release.
- Re-prompting every version without the 90-day cooldown.
- Storing or sending unnecessary personal data.
- Creating a broad support/analytics abstraction for a small rating flow.
