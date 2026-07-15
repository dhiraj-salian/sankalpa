#!/usr/bin/env bash
# Update every Sankalpa component submodule to the latest commit on its tracked
# branch, then leave the new pins staged for you to review and commit.
# The meta-repo pins specific commits on purpose, so advancing pins is deliberate.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Sankalpa meta-repo: $REPO_ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "!! Not a git repository. Run 'git init' in the meta-repo first." >&2
  exit 1
fi

echo "==> Pulling latest of each submodule's tracked branch..."
git submodule update --remote --recursive

echo
echo "==> New pins (staged if changed):"
git submodule status --recursive
git add -A

if git diff --cached --quiet; then
  echo "No component updates; pins unchanged."
else
  echo
  echo "Component pins updated and staged. Review, then commit:"
  echo "  git commit -m 'Update component pins'"
fi
