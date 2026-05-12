#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$PWD"
PROJECT_CLAUDE="$PROJECT_DIR/CLAUDE.md"
PROJECT_SKILLS_DIR="$PROJECT_DIR/.claude/skills"
SHARED_BLOCK_START="<!-- claude-ios-toolkit:start -->"
SHARED_BLOCK_END="<!-- claude-ios-toolkit:end -->"
removed_count=0

if [[ -f "$PROJECT_CLAUDE" ]] && grep -Fq "$SHARED_BLOCK_START" "$PROJECT_CLAUDE" && grep -Fq "$SHARED_BLOCK_END" "$PROJECT_CLAUDE"; then
  tmp_file="$(mktemp)"
  python3 - "$PROJECT_CLAUDE" "$SHARED_BLOCK_START" "$SHARED_BLOCK_END" > "$tmp_file" <<'PY'
import sys
project_path, start, end = sys.argv[1:]
project = open(project_path, encoding="utf-8").read()
start_index = project.index(start)
end_index = project.index(end, start_index) + len(end)
updated = project[:start_index] + project[end_index:]
updated = updated.lstrip("\n")
print(updated, end="")
PY
  mv "$tmp_file" "$PROJECT_CLAUDE"
  echo "Removed shared iOS project instructions block from CLAUDE.md."
fi

if [[ -d "$PROJECT_SKILLS_DIR" ]]; then
  for skill_dir in "$PROJECT_SKILLS_DIR"/*; do
    [[ -d "$skill_dir" ]] || continue
    if [[ -f "$skill_dir/.ios-claude-toolkit-skill" ]]; then
      rm -rf "$skill_dir"
      echo "Removed toolkit skill: $(basename "$skill_dir")"
      removed_count=$((removed_count + 1))
    fi
  done
fi

echo
echo "Uninstalled Claude iOS Toolkit from: $PROJECT_DIR"
echo "Removed skills: $removed_count"
