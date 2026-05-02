---
name: ios-app-rating-feedback
description: Build or audit an iOS app rating and private feedback system with sentiment gate, requestReview, FluentCRM webhook, eligibility rules, debug testing, and iCloud KVS persistence
trigger: /ios-app-rating-feedback
---

# /ios-app-rating-feedback

Build or audit an iOS app rating and private feedback system that asks at positive “wow moments,” routes happy users to Apple’s in-app rating prompt, routes unhappy users to private feedback, and persists prompt eligibility across reinstalls with iCloud Key-Value Store.

## Goal

At key positive moments, show a sentiment gate:

```text
How’s your experience?

Love it!   Need help   Not now
```

- `Love it!` → trigger iOS `requestReview()`.
- `Need help` → open a private feedback form and send it to FluentCRM.
- `Not now` → dismiss and record a decline.

Never show the prompt during negative moments, such as trial expiry, failed purchases, errors, crashes, rejected imports, or other frustration states.

## Values to confirm

Follow the shared infer-first rules in `CLAUDE.md`. For this skill, confirm only the task-specific values that cannot be safely inferred:

- What counts as an entry for the `20+ entries` rule.
- Which positive “wow moments” should trigger eligibility checks.
- Whether the known FluentCRM webhook URL is correct for the current app before sending production feedback there.
- Any app-specific feedback categories, support routing, or privacy/legal wording decisions.

Known FluentCRM webhook URL if the user confirms this destination is correct for the current app:

```text
https://wp.toolsforfree.com/?fluentcrm=1&route=contact&hash=79d6fe90-e645-4189-b771-0010f78e1347
```

Do not silently send production user feedback to any webhook unless the user confirms the destination is correct for the current app.

## Official Apple references

When web access is available and the work is release-facing, check Apple’s current docs:

- [Requesting App Store reviews](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews)
- [RequestReviewAction](https://developer.apple.com/documentation/storekit/requestreviewaction)
- [SKStoreReviewController](https://developer.apple.com/documentation/storekit/skstorereviewcontroller)
- [NSUbiquitousKeyValueStore](https://developer.apple.com/documentation/foundation/nsubiquitouskeyvaluestore)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)

If Apple’s current docs conflict with this skill, follow Apple’s docs and update this skill.

## Eligibility rules

A user is eligible only when all are true:

- At least 30 days since first launch.
- At least 20 entries, where the app defines what an entry means.
- At least 90 days since the last rating/feedback prompt attempt.
- At least 90 days since the last decline.
- Prompt has not already been shown for the current app version.
- User has not already rated through this system.
- User is not in a negative moment.
- Subscription/trial state is not negative, e.g. do not prompt when trial is expired or paywall is hard-blocking.

Persist all rating/feedback prompt state with `NSUbiquitousKeyValueStore` so eligibility, declines, rating state, app-version prompt history, first launch date, and entry count survive reinstalls and sync across devices. Use `UserDefaults` only as a local fallback for iCloud sync delays.

Recommended persisted keys:

- `{appKey}_rating_first_launch_date`
- `{appKey}_rating_last_prompt_date`
- `{appKey}_rating_last_decline_date`
- `{appKey}_rating_last_prompted_version`
- `{appKey}_rating_has_rated`
- `{appKey}_rating_entry_count`

## Architecture

Create or update a small rating service, for example:

```swift
@Observable
@MainActor
final class AppRatingService {
    static let shared = AppRatingService()

    var isShowingSentimentGate = false
    var isShowingFeedbackForm = false

    func recordEntry()
    func considerPrompt(source: FeedbackSource, isNegativeMoment: Bool)
    func chooseLoveIt(requestReview: RequestReviewAction)
    func chooseNeedHelp()
    func chooseNotNow()
    func submitFeedback(message: String, email: String?, type: FeedbackType, source: FeedbackSource) async
}
```

Keep it focused. Do not build a large analytics abstraction unless one already exists.

## Wow moments

Trigger `considerPrompt(...)` only after positive milestones, such as:

- User reaches a meaningful learning, creation, productivity, or workflow milestone.
- User creates enough entries/content/items to show commitment.
- User successfully exports, saves, completes, or shares a valuable result.
- User completes onboarding successfully.
- User finishes a purchase or successful restore.
- User completes a key workflow without errors.

Do not show immediately at launch. Do not show during error recovery, cancellation, hard paywall, trial expiry, or support flows.

## Sentiment gate UI

The UI should be lightweight and respectful:

- Title: `How’s your experience?`
- Optional subtitle: one short sentence tied to the app’s value.
- Actions:
  - `Love it!`
  - `Need help`
  - `Not now`

Behavior:

- `Love it!` records prompt/rated state and calls Apple’s review prompt.
- `Need help` opens feedback form instead of Apple review prompt.
- `Not now` records decline and suppresses prompts for 90 days.

Use SwiftUI’s `@Environment(\.requestReview)` where practical:

```swift
@Environment(\.requestReview) private var requestReview
```

Then call:

```swift
requestReview()
```

Apple may or may not show the system rating UI; do not assume the prompt appeared.

## Feedback form

The private feedback form should collect:

- Optional email
- Feedback type
- Message

Keep it short. Do not ask for unnecessary personal data.

Feedback types can be simple, for example:

- `help`
- `bug`
- `feature_request`
- `other`

Feedback source should identify where the gate appeared, for example:

- `milestone`
- `export`
- `purchase`
- `settings_debug`
- `manual_settings`

## FluentCRM webhook payload

After the user submits the feedback form, send a POST request to the confirmed FluentCRM webhook URL with these exact fields:

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

Recommended email generation:

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

Use HTTPS. Set a reasonable timeout. Handle failures gracefully with a user-visible retry/error message. Do not block the main thread.

## Device/app metadata

Collect only practical support metadata:

- App name: configured app display name
- App ID: bundle identifier
- App version: `CFBundleShortVersionString`, optionally build number too
- Device model: current device model identifier or readable fallback
- OS version: `UIDevice.current.systemVersion`
- Subscription status: e.g. `pro`, `trial_active`, `trial_expired`, `free`, or `unknown`

If the app has a subscription service, derive subscription status from it. Otherwise use `unknown`.

## Debug testing

Add a debug-only Settings option under `#if DEBUG` to trigger the sentiment gate manually.

Recommended debug controls:

- Show Rating Sentiment Gate
- Reset Rating Prompt State
- Set Eligible Rating State, if useful

The debug source should be `settings_debug`.

Never expose debug reset/force-prompt controls in release builds.

## iCloud KVS persistence

Use `NSUbiquitousKeyValueStore.default`:

- Call `synchronize()` when loading.
- Write prompt state to iCloud KVS.
- Mirror key values to `UserDefaults` as a fallback.
- Prefer iCloud values when available.

State must persist across reinstall and across user devices signed into the same Apple ID.

## Privacy and App Store notes

- Do not send feedback without user action on the feedback form.
- Disclose feedback collection in the app’s Privacy Policy.
- If email is optional, clearly allow anonymous feedback.
- If no valid email exists, generate an anonymous `cf_<uuid>@example.com` email.
- Do not use the sentiment gate to manipulate reviews or pressure users.
- Do not repeatedly prompt users who decline or already rated.
- Respect Apple’s limits: `requestReview()` is system-controlled and may not show every time.

## Testing checklist

Test or instruct the user to test:

- First launch date initializes correctly.
- Entry count reaches eligibility threshold.
- Prompt does not appear before 30 days.
- Prompt does not appear before 20 entries.
- Prompt does not appear within 90 days of prompt/decline.
- Prompt appears at a configured wow moment once eligible.
- Prompt does not appear during negative moments or expired trial hard paywall.
- `Love it!` triggers `requestReview()` and records rated/prompted state.
- `Need help` opens feedback form.
- Feedback POST includes all required FluentCRM fields.
- Invalid/missing email generates `cf_<uuid>@example.com`.
- `Not now` records decline and suppresses for 90 days.
- Prompt appears only once per app version.
- KVS state persists across reinstall/real device where practical.
- Debug Settings trigger works only in DEBUG builds.

For Claude Code in iOS projects: after significant changes, list available simulators, choose a valid simulator, build with `xcodebuild`, and fix build errors. For UI changes, visually verify the flow when practical.

## Audit mode

When auditing an existing app, inspect:

- Rating/feedback service
- Sentiment gate UI
- Wow-moment trigger points
- Eligibility rules
- KVS/UserDefaults persistence
- Feedback form
- FluentCRM webhook payload
- Debug Settings controls
- Privacy disclosures and user consent
- Negative-moment suppression

Report:

1. Critical release/privacy blockers
2. Eligibility behavior correctness
3. Missing payload fields or metadata
4. Debug/release separation issues
5. Recommended UX improvements

## Common pitfalls

Avoid:

- Prompting at launch
- Prompting during negative moments
- Prompting after trial expiry/hard paywall
- Asking for App Store reviews from unhappy users
- Sending private feedback without explicit user submission
- Forgetting anonymous email generation
- UserDefaults-only state that resets on reinstall
- Ignoring Apple’s system-controlled review prompt limits
- Showing debug trigger/reset controls in Release
- Re-prompting every version without the 90-day delay
- Storing or sending unnecessary personal data
