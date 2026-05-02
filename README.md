# Claude iOS Toolkit

Reusable Claude Code instructions and skills for iOS app projects.

## What is included

```text
claude-ios-toolkit/
  CLAUDE.md                 # shared iOS Claude Code instructions
  install.sh                # project installer
  uninstall.sh              # project uninstaller
  bin/
    install-ios-claude-toolkit
  skills/                   # reusable iOS skills
    ios-app-rating-feedback/
    ios-debug-production-apps/
    ios-global-keyboard-dismiss/
    ios-settings-app-store-review/
    ios-subscription-system/
```

## Install the toolkit repo

Clone the repository once:

```bash
git clone <your-github-repo-url> ~/claude-ios-toolkit
```

Use any local path you prefer. The installer detects the toolkit location automatically.

## Install in an iOS app project

From an iOS app project root:

```bash
~/claude-ios-toolkit/install.sh
```

Or pass a project path:

```bash
~/claude-ios-toolkit/install.sh /path/to/MyApp
```

The installer copies toolkit content into the project. It does not use symlinks.

It will:

- create `.claude/CLAUDE.md` if missing
- copy the shared `CLAUDE.md` content into a managed block at the top of `.claude/CLAUDE.md`
- create `.claude/skills/` if missing
- copy each shared skill into `.claude/skills/<skill-name>`
- update previously copied toolkit skills
- skip existing project-specific skill folders

## Resulting project layout

```text
MyApp/
  .claude/
    CLAUDE.md                         # shared managed block + project-specific rules
    skills/
      ios-app-rating-feedback/
        SKILL.md
      ios-debug-production-apps/
        SKILL.md
      ios-global-keyboard-dismiss/
        SKILL.md
      ios-settings-app-store-review/
        SKILL.md
      ios-subscription-system/
        SKILL.md
      my-project-skill/
        SKILL.md                      # optional project-specific skill
```

## Project-specific rules and skills

Put app-specific instructions below the managed toolkit block in:

```text
MyApp/.claude/CLAUDE.md
```

Put app-specific skills beside the copied shared skills:

```text
MyApp/.claude/skills/<project-skill-name>/SKILL.md
```

The installer skips existing project-specific skill folders unless they were created by the toolkit installer.

## Update toolkit content in a project

First update your local toolkit clone, then run the installer again:

```bash
cd ~/claude-ios-toolkit
# update this repo with your normal Git workflow
./install.sh /path/to/MyApp
```

This refreshes the managed shared instructions block and copied toolkit skills.

## Uninstall from a project

```bash
~/claude-ios-toolkit/uninstall.sh /path/to/MyApp
```

The uninstaller removes only:

- the managed shared instructions block
- copied toolkit skills marked by the installer

It does not remove project-specific instructions or project-specific skills.

## Maintenance rules

- Keep shared skills app-agnostic.
- Do not hardcode one app’s name, bundle ID, App Store ID, prices, product IDs, legal URLs, webhook URLs, or paths.
- Put common behavior in `CLAUDE.md`; keep each skill focused on its task.
- Ask only for values that cannot be inferred or require legal, pricing, production URL, or business confirmation.
