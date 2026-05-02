#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/kazimshah39/claude-ios-toolkit.git"
PROJECT_DIR="$PWD"

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required to install claude-ios-toolkit." >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

echo "Downloading claude-ios-toolkit..."
git clone --depth 1 "$REPO_URL" "$tmp_dir/claude-ios-toolkit"

"$tmp_dir/claude-ios-toolkit/bin/install-ios-claude-toolkit" "$PROJECT_DIR"
