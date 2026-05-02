---
name: ios-settings-app-store-review
description: Add or audit an iOS Settings row that opens the App Store write-review page for the current app
trigger: /ios-settings-app-store-review
---

# /ios-settings-app-store-review

Add or audit a simple Settings row that lets users manually open the App Store review composer for the app.

This is separate from an in-app rating prompt. Use this when the user wants a persistent Settings option such as `Rate on App Store` that opens the App Store listing with `action=write-review`.

## Goal

Add a Settings row/button similar to:

```swift
private func openAppStoreReview() {
    let appStoreID = "xyz"
    if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
        UIApplication.shared.open(url)
    }
}
```

Expected behavior:

- User taps `Rate on App Store` in Settings.
- The app opens the App Store write-review URL for the current app.
- The feature is available in Release builds, unlike debug-only review testing controls.

## Values to confirm

Follow the shared infer-first rules in `CLAUDE.md`. For this skill, confirm only the task-specific values that cannot be safely inferred:

- App Store ID if it cannot be found in trusted project files.
- Whether the row label should differ from `Rate on App Store`.
- Where to place the row if Settings has multiple plausible sections.
- Whether the app should use a region-specific App Store URL.

Do not invent an App Store ID. A placeholder is acceptable only for local development when clearly marked as needing replacement before release.

## Recommended implementation

Prefer SwiftUI’s `openURL` environment when adding code inside SwiftUI views:

```swift
@Environment(\.openURL) private var openURL

private func openAppStoreReview() {
    let appStoreID = "xyz"
    if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
        openURL(url)
    }
}
```

Using `UIApplication.shared.open(url)` is also acceptable when it matches the app’s existing style:

```swift
private func openAppStoreReview() {
    let appStoreID = "xyz"
    if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
        UIApplication.shared.open(url)
    }
}
```

Keep the implementation small. Do not create a navigation/router abstraction just for this row.

## Settings UI

Add a normal Release-visible Settings row, for example:

```swift
Button {
    openAppStoreReview()
} label: {
    Label("Rate on App Store", systemImage: "star.fill")
}
```

Adapt to the project’s existing Settings style. Good labels include:

- `Rate on App Store`
- `Rate This App`
- `Write a Review`

Use an appropriate SF Symbol, commonly:

- `star.fill`
- `star.bubble.fill`
- `square.and.pencil`

## Release/debug behavior

- This Settings row should usually be visible in Release builds.
- Do not wrap it in `#if DEBUG` unless the user explicitly wants it debug-only.
- Do not confuse this row with debug-only controls for testing `requestReview()` or sentiment gates.
- If the App Store ID is a placeholder, clearly prevent shipping or warn that it must be replaced before release.

## Relationship to in-app rating prompts

This skill is for a manual App Store review link. It does not replace StoreKit’s in-app review prompt.

Use `requestReview()` for respectful in-app rating prompts at positive moments. Use this App Store URL row for users who intentionally choose to review from Settings.

## Privacy and App Store notes

- Do not gate features, rewards, content, or support access on leaving a rating or review.
- Do not pressure users or imply they must leave a positive review.
- Do not prefill or manipulate review content.
- Keep the row neutral and user-initiated.

## Verification checklist

After implementing, verify:

- The App Store ID is correct for the current app.
- The generated URL is exactly `https://apps.apple.com/app/id{APP_STORE_ID}?action=write-review` unless the app intentionally uses a region-specific variant.
- The row appears in Settings in Release-visible code.
- Tapping the row opens the App Store review page on a real device where practical.
- Simulator behavior is acceptable or documented if the App Store cannot open there.
- The row matches existing Settings styling.
- No debug-only review testing controls were exposed in Release by accident.

For Claude Code in iOS projects: after significant changes, list available simulators, choose a valid simulator, build with `xcodebuild`, and fix build errors. For UI changes, visually verify the Settings row when practical.

## Audit mode

When auditing an existing app, inspect:

- Settings row presence and placement.
- App Store ID source and correctness.
- URL format.
- Whether the row is visible in Release builds.
- Whether debug-only review/test controls are properly separated.
- Whether the implementation matches project style and avoids unnecessary abstractions.

Report:

1. Whether the Settings row exists.
2. Whether the App Store ID and URL are correct.
3. Whether Release/debug visibility is correct.
4. Any App Store policy or UX concerns.
5. Recommended fixes, if any.

## Common pitfalls

Avoid:

- Guessing the App Store ID.
- Shipping `xyz` or another placeholder ID.
- Wrapping the normal Settings review row in `#if DEBUG` by mistake.
- Exposing debug-only prompt reset/test controls in Release.
- Using `requestReview()` for a manual Settings row when the user asked to open the App Store review page.
- Creating a large URL routing abstraction for one Settings action.
- Rewarding, pressuring, or manipulating users into leaving reviews.
