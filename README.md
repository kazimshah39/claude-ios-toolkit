# Claude iOS Toolkit

Reusable Claude Code project instructions and skills for iOS app projects.

## Install

Run this from the root of your iOS app project:

```bash
curl -fsSL https://raw.githubusercontent.com/kazimshah39/claude-ios-toolkit/main/install.sh | bash
```

The installer downloads this toolkit into a temporary folder, installs shared iOS project instructions and skills into the current project, then removes the temporary folder.

## What it installs

```text
CLAUDE.md
.claude/
  skills/
    ios-app-rating-feedback/
      SKILL.md
    ios-app-store-screenshots/
      SKILL.md
    ios-debug-production-apps/
      SKILL.md
    ios-global-keyboard-dismiss/
      SKILL.md
    ios-iap-review-information/
      SKILL.md
    ios-settings-app-store-review/
      SKILL.md
    ios-subscription-system/
      SKILL.md
```

Project instructions are sourced from this toolkit’s `CLAUDE.project.md` and installed into a managed block at the top of the target project’s root `CLAUDE.md`:

```text
<!-- claude-ios-toolkit:start -->
...
<!-- claude-ios-toolkit:end -->
```

Add project-specific instructions outside that block.

## Project-specific skills

Add app-only skills beside the toolkit skills:

```text
.claude/skills/my-project-skill/SKILL.md
```

The installer skips existing project-specific skill folders. Toolkit-installed skills are marked internally so they can be refreshed safely when you run the installer again.

## Update

Run the same command again from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/kazimshah39/claude-ios-toolkit/main/install.sh | bash
```

This refreshes the managed project instructions block and toolkit-installed skills.

## Uninstall

Run this from the root of your iOS app project:

```bash
curl -fsSL https://raw.githubusercontent.com/kazimshah39/claude-ios-toolkit/main/uninstall.sh | bash
```

The uninstaller removes only the managed toolkit block and toolkit-installed skills. It does not remove project-specific instructions or skills.

## Toolkit contents

```text
claude-ios-toolkit/
  CLAUDE.md
  CLAUDE.project.md
  install.sh
  uninstall.sh
  bin/
    install-ios-claude-toolkit
  skills/
    ios-app-rating-feedback/
    ios-app-store-screenshots/
    ios-debug-production-apps/
    ios-global-keyboard-dismiss/
    ios-iap-review-information/
    ios-settings-app-store-review/
    ios-subscription-system/
```

## Maintenance rules

- Keep reusable skills generic across iOS apps.
- Put target-project guidance in `CLAUDE.project.md`.
- Keep toolkit-repository guidance in `CLAUDE.md`.
- Keep each skill focused on one task.
- Do not hardcode one app’s name, bundle ID, App Store ID, prices, product IDs, legal URLs, webhook URLs, or paths.
