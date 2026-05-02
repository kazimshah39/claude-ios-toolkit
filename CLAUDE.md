# Claude Code Instructions for Reusable iOS Skills

These instructions apply to reusable Claude Code skills for iOS app projects. Keep all guidance generic and portable across apps.

## Skill design

- Write skills so they can be copied into any iOS app project.
- Keep skills focused on their specific task; put shared behavior in this file instead of repeating it in every skill.
- Do not hardcode one app’s name, bundle identifier, App Store ID, prices, webhook URL, legal URLs, product IDs, or project paths unless the skill explicitly says to confirm or replace them.
- Use placeholders only when they are clearly marked as placeholders and should not ship.
- Prefer editing existing project patterns over introducing new architecture.
- Avoid large abstractions unless the app already has that pattern.

## Infer first, ask only when needed

Before implementing or auditing, inspect the current iOS project and infer values that are already available.

Infer when possible:

- App display name from build settings, Info.plist values, product name, or app metadata.
- Bundle identifier from the app target’s Release build configuration.
- Xcode project, app target, schemes, and build configurations from project files.
- Existing service, Settings, paywall, feedback, rating, analytics, URL-opening, or keyboard-helper patterns.
- Existing StoreKit configuration, product IDs, prices, subscription groups, and product display names.
- Existing legal links, App Store IDs, support URLs, webhook config, and metadata from trusted project files.
- Existing UI styling, section placement, SF Symbols, accessibility, and localization conventions.
- Minimum iOS deployment target before using version-specific APIs.

Ask only for values that are missing, ambiguous, sensitive, or product/legal/business decisions, such as:

- Prices when no trusted StoreKit/App Store config exists.
- App-specific Privacy Policy or Terms URLs when missing or placeholder.
- Production webhook URLs or confirmation before sending user data externally.
- App Store ID when it cannot be found in trusted project files.
- Which app target to edit when multiple targets are plausible.
- Which workflows count as milestones, entries, Pro features, or other business rules.
- Whether to use non-default labels, suffixes, URLs, or UX copy.

Do not ask for values that can be safely derived from the current project.

## iOS implementation rules

- Keep implementation small, direct, and App Store-safe.
- Respect SwiftUI, StoreKit, privacy, and App Store Review requirements.
- Do not gate features, rewards, support, or content on reviews or unrelated permissions.
- Do not expose debug-only tools in Release builds.
- Use `#if DEBUG` only for debug/test controls, not for normal user-facing Settings rows unless requested.
- Use `NSUbiquitousKeyValueStore` where a skill requires state to survive reinstall or sync across devices.
- Prefer Apple-provided localized StoreKit display values for production-visible pricing.
- Do not create analytics, routing, keyboard, subscription, or feedback abstractions unless the app already has them or the user asks.

## Verification rules

After significant iOS code changes:

1. List available simulators.
2. Select a valid simulator.
3. Build with `xcodebuild`.
4. Fix build errors before reporting completion.

For UI changes, visually verify the changed flow when practical. If visual verification is not practical, say so clearly.

For audit-only work, report findings without editing unless the user asks to implement fixes.

## Skill maintenance

When updating skills:

- Keep them generic; remove app-specific examples unless they are clearly placeholders.
- Remove duplicated shared rules if they are already covered here.
- Keep official documentation links when they help future agents verify current platform behavior.
- Preserve task-specific checklists, pitfalls, and audit guidance.
