---
name: ios-app-store-screenshots
description: Analyze an iOS app and recommend five App Store screenshots with copy-ready caption text
trigger: /ios-app-store-screenshots
---

# /ios-app-store-screenshots

Analyze an iOS app’s screens and recommend five App Store submission screenshots, then provide copy-ready text for each screenshot directly in chat.

Use this when the user wants to know which app screens to capture for App Store screenshots and what text to place on each screenshot.

Do not implement UI changes unless the user explicitly asks. This skill is for screenshot planning and copywriting.

## Required behavior

Read and understand the app before suggesting screenshots.

Inspect available project sources to identify:

- App name and core purpose.
- Main user flow.
- Onboarding screens.
- Home/dashboard screen.
- Primary feature screens.
- Creation, editing, tracking, analysis, history, export, or result screens.
- Paywall or Pro feature screens, if relevant.
- Settings or account screens only when they communicate important value.
- Existing App Store metadata or screenshots, if present in trusted project files.
- Existing UI style, tone, terminology, and feature names.

Then output exactly five screenshot recommendations unless the user asks for a different number.

For each screenshot, include:

1. Which screen to capture.
2. Why that screen should be included.
3. Copy-ready screenshot text.
4. Any capture notes needed to make the screenshot look good.

The screenshot text must be provided directly in chat with clear copy boundaries so the user can copy and paste it.

## Output format

Use this structure:

```text
Screenshot 1 — {screen name}
Capture: {what screen/state to screenshot}
Why: {short reason}

========== COPY START: SCREENSHOT 1 TEXT ==========
Title: {max 3 words}
Description: {max 8–10 words}
========== COPY END: SCREENSHOT 1 TEXT ==========

Capture notes: {short practical notes}
```

Repeat for screenshots 2 through 5.

Do not wrap the final copy blocks in Markdown code fences unless the user explicitly asks. The boundary lines should be visible and easy to select.

## Screenshot selection strategy

Prefer screenshots that tell a complete story in five frames:

1. The app’s main promise or outcome.
2. The primary feature users will care about most.
3. A secondary differentiating feature.
4. Results, progress, history, insights, saved content, or proof of value.
5. Pro, customization, privacy, convenience, or another conversion-supporting feature.

Adapt the order to the app. The first screenshot should usually show the strongest value proposition, not Settings or a generic empty state.

Good screenshot candidates:

- A populated home/dashboard with meaningful sample data.
- The app’s main creation or action screen.
- A screen showing the best result/output.
- A screen showing progress, saved history, insights, reminders, streaks, or organization.
- A premium/paywall-adjacent feature only if it helps explain value and is App Store-safe.
- A clean onboarding or welcome screen only if it communicates the app’s core promise better than the home screen.

Weak screenshot candidates:

- Empty states unless the app’s first-run experience is the product.
- Settings screens, unless a specific Settings feature is a major selling point.
- Login, signup, permissions, legal, debug, error, or loading screens.
- Screens with placeholder text, fake pricing, debug badges, simulator overlays, API keys, or personal data.
- Paywalls as the first screenshot unless the app is specifically a subscription management app.

## Screenshot text rules

Keep screenshot text short, clear, and benefit-focused.

Required style:

- Title: maximum 3 words.
- Description: maximum 8–10 words.
- Always provide both `Title:` and `Description:` lines.
- Use the app’s own terminology.
- Prefer benefits over feature labels.
- Use active, specific language.
- Avoid hype, unverifiable claims, and absolute promises.
- Avoid mentioning prices unless verified and appropriate.
- Avoid saying `free`, `best`, `#1`, `guaranteed`, or other claims that may require proof.
- Avoid medical, financial, legal, or safety claims unless the app and metadata support them.
- Do not write misleading copy for features that are not visible in the screenshot.

Examples of good copy patterns:

```text
Title: Plan Today
Description: Stay focused on what matters most
```

```text
Title: Track Habits
Description: See your progress build over time
```

```text
Title: Create Faster
Description: Turn ideas into polished results
```

```text
Title: Stay Organized
Description: Find saved work when you need it
```

## Infer first, ask only when needed

Follow the shared infer-first rules in `CLAUDE.md`.

Infer from the current project whenever possible:

- App display name.
- Target audience.
- Main workflows.
- Feature names.
- Premium features.
- Visual style and tone.
- Existing localized strings.
- Existing sample/demo data patterns.

Ask only when missing or ambiguous:

- Which audience to optimize for if the app serves multiple distinct audiences.
- Which feature is most important for marketing if the code does not make it clear.
- Whether to include subscription/Pro messaging.
- Whether screenshot text should be in a language other than English.
- Whether the app should use a specific tone, such as playful, professional, minimal, or bold.

Do not ask for values that can be safely inferred from the project.

## Capture guidance

When giving capture notes, be practical and specific:

- Use realistic populated data.
- Avoid personal or sensitive data.
- Hide debug-only UI.
- Use a clean state with no errors, loading spinners, permission prompts, or empty placeholders.
- Prefer the same device size across all five screenshots.
- Make sure the UI state matches the overlay text.
- If the app supports subscriptions, ensure subscription-gated features are shown truthfully.

If UI verification is practical and the user asks you to capture screenshots, follow the project verification rules for iOS UI work. For planning-only work, do not build or run the app unless needed to understand screens.

## App Store review and compliance notes

Make recommendations App Store-safe:

- Do not imply Apple endorsement.
- Do not include App Store badges or Apple logos in overlay text.
- Do not include unsupported ranking or comparison claims.
- Do not show external purchase calls to action for digital goods unless the app is entitled to do so.
- Do not present subscription-only features as free.
- Do not show private user data, contacts, messages, API keys, or account credentials.
- If showing AI features, avoid overpromising accuracy or guaranteed outcomes.

## If the app has too many screens

Choose the five that best communicate value to a first-time App Store visitor.

Prioritize:

1. Screens that show the app doing its main job.
2. Screens with visible, understandable outcomes.
3. Screens that differentiate the app from generic alternatives.
4. Screens likely to improve install conversion.
5. Screens that look polished with minimal setup.

Briefly mention 1–3 alternate screens only after the five main recommendations, if useful.

## If the app has too few discoverable screens

If only limited screens can be found, still provide five recommendations when possible by using different states of the same core flow, such as:

- Empty state.
- Populated state.
- Creation state.
- Result state.
- Settings/customization state.

If five meaningful screenshots are not possible, say so and explain what screens or sample data are needed.

## Audit mode

When auditing existing screenshot plans, report:

1. Whether the five screens tell a clear App Store story.
2. Which screenshots to keep, replace, or reorder.
3. Corrected copy-ready text for each screenshot using the boundary format.
4. Any App Store safety or clarity concerns.

## Common pitfalls

Avoid:

- Suggesting screenshots without reading the app.
- Choosing five random screens instead of a coherent story.
- Writing long text that will not fit on screenshot artwork.
- Using generic claims that could apply to any app.
- Recommending login, permission, legal, error, loading, or debug screens.
- Showing empty screens when populated screens are available.
- Making claims not visible in the screenshot.
- Mixing multiple tones across the five screenshots.
