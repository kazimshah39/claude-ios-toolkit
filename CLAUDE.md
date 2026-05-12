# Claude Code Instructions for claude-ios-toolkit

This repository maintains reusable Claude Code skills and installer scripts for iOS app projects.

## Repository purpose

- Keep skills generic and portable across iOS apps.
- Put target-project instructions in `CLAUDE.project.md`, not this file.
- Install skills into target projects without hardcoding one app’s names, IDs, prices, URLs, or paths.

## Skill maintenance

- Keep each skill focused on its specific task.
- Prefer task-specific checklists, pitfalls, and audit guidance over broad abstractions.
- Remove duplicated shared rules if they are already covered by `CLAUDE.project.md`.
- Keep official documentation links when they help future agents verify current platform behavior.
- Do not add app-specific examples unless they are clearly placeholders and should not ship.

## Installer maintenance

- Keep installer behavior simple and predictable.
- Source target-project instructions from `CLAUDE.project.md`.
- Install target-project instructions into the target project’s `.claude/CLAUDE.md` inside the managed toolkit block.
- Install reusable skills into the target project’s `.claude/skills` directory.
- Since the toolkit is not live yet, prefer clean maintainable behavior over backward compatibility shims.
