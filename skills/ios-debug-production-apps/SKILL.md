---
name: ios-debug-production-apps
description: Configure an iOS Xcode project so Debug installs as a separate .dev app with its own bundle identifier and display name while Release remains App Store-safe
trigger: /ios-debug-production-apps
---

# /ios-debug-production-apps

Configure an iOS Xcode project so the Debug build installs as a separate app on the device instead of overwriting the App Store/Release app.

The goal is:

- Debug app bundle identifier: `{releaseBundleID}.dev`
- Debug display name: `{AppName} Dev`
- Release bundle identifier: unchanged
- Release display name: `{AppName}`

This protects the App Store app and its data while allowing development builds to install side-by-side.

## When to use

Use this skill when the user wants:

- Debug and production iOS apps installed side-by-side
- Xcode Run/Debug builds to install as `AppName Dev`
- App Store/TestFlight/Archive builds to keep the production bundle identifier
- Development app data to be separate from production app data

Do not use this for unrelated app renames, target duplication, scheme creation, provisioning setup, or App Store Connect product changes unless the user explicitly asks.

## Values to confirm

Follow the shared infer-first rules in `CLAUDE.md`. For this skill, confirm only the task-specific values that cannot be safely inferred:

- Which target to change if multiple app targets are plausible.
- Whether to use a non-default debug display suffix or bundle identifier suffix.
- How to handle bundle identifiers or display names defined through `.xcconfig` files or build-setting variables when final values cannot be safely resolved.

Do not guess across multiple plausible app targets.

## File to edit

Edit only:

```text
{ProjectName}.xcodeproj/project.pbxproj
```

Prefer direct file edits. Do not use Xcode GUI instructions unless editing the pbxproj is not possible.

## How to locate the correct build settings

Search for `PRODUCT_BUNDLE_IDENTIFIER` in the pbxproj file.

In a simple single-target app there are usually two relevant `XCBuildConfiguration` blocks:

```text
SOMEID /* Debug */ = {
    isa = XCBuildConfiguration;
    buildSettings = {
        ...
        PRODUCT_BUNDLE_IDENTIFIER = com.team.AppName;
        ...
    };
    name = Debug;
};

SOMEID /* Release */ = {
    isa = XCBuildConfiguration;
    buildSettings = {
        ...
        PRODUCT_BUNDLE_IDENTIFIER = com.team.AppName;
        ...
    };
    name = Release;
};
```

Important: the comment `/* Debug */` or `/* Release */` near the block ID is helpful, but the authoritative marker is the block’s final `name = Debug;` or `name = Release;`.

## Required changes

### 1. Debug bundle identifier only

In the target’s **Debug** `XCBuildConfiguration` block, change:

```text
PRODUCT_BUNDLE_IDENTIFIER = com.team.AppName;
```

to:

```text
PRODUCT_BUNDLE_IDENTIFIER = com.team.AppName.dev;
```

Use the project’s actual Release bundle identifier and append the configured suffix.

Do **not** change the Release bundle identifier.

### 2. Display names in both configs

In the Debug block’s `buildSettings`, add or update:

```text
INFOPLIST_KEY_CFBundleDisplayName = "AppName Dev";
```

In the Release block’s `buildSettings`, add or update:

```text
INFOPLIST_KEY_CFBundleDisplayName = AppName;
```

Place these near other `INFOPLIST_KEY_*` settings to keep the pbxproj organized.

Quote the display name if it contains spaces. Existing Xcode project files often quote values with spaces and leave single-word values unquoted.

## Safety rules

- Change Debug bundle identifier only.
- Never append `.dev` to Release.
- Never change unrelated targets without user confirmation.
- Preserve existing Release App Store bundle identifier exactly.
- Preserve existing formatting as much as possible.
- If `INFOPLIST_KEY_CFBundleDisplayName` already exists, update it instead of adding a duplicate.
- If the project uses `.xcconfig` files for these settings, update the correct `.xcconfig` instead of fighting generated pbxproj values.
- If bundle identifiers use build setting variables like `$(PRODUCT_BUNDLE_IDENTIFIER)` or `$(APP_IDENTIFIER_PREFIX)`, stop and explain the variable setup before editing.
- If the project has Debug, Release, Staging, AdHoc, or custom configurations, only apply this to the intended Debug/Release pair unless the user asks otherwise.

## Verification checklist

After editing, verify:

- Debug `PRODUCT_BUNDLE_IDENTIFIER` ends with `.dev`.
- Release `PRODUCT_BUNDLE_IDENTIFIER` is unchanged.
- Debug has `INFOPLIST_KEY_CFBundleDisplayName = "AppName Dev";`.
- Release has `INFOPLIST_KEY_CFBundleDisplayName = AppName;` or quoted equivalent.
- No duplicate `INFOPLIST_KEY_CFBundleDisplayName` entries exist in the same build settings block.
- No unrelated target or configuration was changed.

For iOS projects, after significant changes:

1. List available simulators.
2. Select a valid simulator.
3. Build with `xcodebuild`.
4. Fix build errors before reporting completion.

## Expected result

Running from Xcode using Debug installs a separate app named:

```text
AppName Dev
```

Its bundle identifier is:

```text
com.team.AppName.dev
```

The App Store/Release app remains:

```text
AppName
com.team.AppName
```

Archive/App Store builds normally use Release and keep the production bundle identifier.

## Audit mode

If the user asks to check whether a project is already configured, inspect the target’s Debug and Release build configurations and report:

- Debug bundle identifier
- Release bundle identifier
- Debug display name
- Release display name
- Whether Debug can install side-by-side with Release
- Any risks, such as duplicated display-name keys, multiple targets, variables, or `.xcconfig` overrides

## Common pitfalls

Avoid:

- Changing the Release bundle identifier
- Adding `.dev` to every configuration
- Adding duplicate `INFOPLIST_KEY_CFBundleDisplayName` lines
- Editing the wrong app target in projects with extensions/widgets/watch apps
- Forgetting that app extensions may need compatible bundle IDs, but should not be changed unless required
- Assuming TestFlight uses Debug; Archive normally uses Release
- Using the same display name for Debug and Release, making the apps hard to distinguish
