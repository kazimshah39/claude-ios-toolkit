---
name: ios-global-keyboard-dismiss
description: Add or audit a reusable SwiftUI keyboard dismiss modifier with a Done toolbar button and global application across text-entry screens
trigger: /ios-global-keyboard-dismiss
---

# /ios-global-keyboard-dismiss

Add or audit a reusable SwiftUI keyboard dismissal helper that provides a `Done` button above the keyboard and enables interactive keyboard dismiss on scroll.

## Goal

Create a reusable View extension like:

```swift
extension View {
    /// Adds a "Done" button above the keyboard and enables interactive dismiss on scroll
    func keyboardDismissible() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
```

Then apply `.keyboardDismissible()` consistently across text-entry screens so the user can dismiss the keyboard everywhere practical.

## Values to confirm

Follow the shared infer-first rules in `CLAUDE.md`. For this skill, confirm only the task-specific values that cannot be safely inferred:

- Where to place the helper if the project has no clear shared UI/extensions location.
- Whether the button label should differ from `Done`.
- Whether any specific screen should intentionally keep the keyboard visible.
- Whether to localize the button immediately if the project does not already use localization.

Do not create duplicate keyboard helpers if a suitable one already exists; update or reuse it.

## Recommended implementation

Prefer a small reusable modifier:

```swift
import SwiftUI

struct KeyboardDismissModifier: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
    }
}

extension View {
    /// Adds a "Done" button above the keyboard and enables interactive dismiss on scroll
    func keyboardDismissible() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
```

If the project already manages focus with screen-specific `@FocusState`, avoid breaking that focus logic. In that case, prefer a helper that dismisses through UIKit:

```swift
struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                }
            }
    }
}
```

Choose the implementation that fits the project’s existing focus management. Do not introduce a large keyboard-management abstraction.

## Where to apply

Apply `.keyboardDismissible()` to screens or containers that contain keyboard input, such as:

- Forms with `TextField` or `TextEditor`.
- Search/edit screens.
- Feedback/support forms.
- Chat or prompt input screens.
- Notes, transcript, lesson, task, or content editing screens.
- Settings screens with editable fields.

Apply it at the container level where the toolbar will reliably appear, commonly on a `NavigationStack`, `Form`, `List`, `ScrollView`, or root screen view.

Do not apply it blindly to every view file. Apply it where keyboard input exists or where a parent container intentionally covers child text-entry views.

## UX requirements

- The keyboard toolbar should show a trailing `Done` button.
- Scrollable text-entry screens should support interactive keyboard dismissal when scrolling.
- The modifier should not change layout, navigation, or validation behavior.
- The modifier should not hide Save/Cancel/Submit actions or replace screen-specific focus behavior.
- The button should be accessible and follow the app’s style/localization conventions where applicable.

## Compatibility notes

- `.toolbar(placement: .keyboard)` is available on iOS 15+.
- `.scrollDismissesKeyboard(.interactively)` is available on iOS 16+.
- If the app supports older iOS versions, guard or adapt the implementation instead of raising the deployment target without user approval.
- If a view is not scrollable, the `Done` toolbar button still provides a dismissal path.

## Verification checklist

After implementing, verify:

- There is a single shared `keyboardDismissible()` extension or one clearly preferred implementation.
- Text-entry screens have `.keyboardDismissible()` applied where practical.
- The keyboard shows a `Done` button above it.
- Tapping `Done` dismisses the keyboard.
- Scrolling dismisses the keyboard interactively on supported iOS versions.
- Existing custom `@FocusState` behavior still works.
- Forms still submit/save correctly.
- No duplicate keyboard toolbar buttons appear on the same screen.
- No non-input screens were modified unnecessarily.

For Claude Code in iOS projects: after significant changes, list available simulators, choose a valid simulator, build with `xcodebuild`, and fix build errors. For UI changes, visually verify at least one representative text-entry screen when practical.

## Audit mode

When auditing an existing app, inspect:

- Shared keyboard dismissal helper or View extension.
- All major text-entry screens.
- Screens with existing custom focus handling.
- Duplicate `.toolbar(placement: .keyboard)` definitions.
- Deployment target compatibility.
- Whether `Done` dismissal and scroll dismissal work in practice.

Report:

1. Whether a reusable helper exists.
2. Which important text-entry screens already use it.
3. Which important text-entry screens are missing it.
4. Any duplicate toolbar or focus conflicts.
5. Recommended fixes.

## Common pitfalls

Avoid:

- Adding separate keyboard toolbar code to every screen instead of using a shared modifier.
- Applying the modifier blindly to every view in the app.
- Creating duplicate `Done` buttons when a screen already has a keyboard toolbar.
- Breaking existing `@FocusState` flows.
- Raising the minimum iOS version just to use `.scrollDismissesKeyboard`.
- Hiding or replacing important screen actions.
- Adding comments beyond the short extension comment if the code is self-explanatory.
