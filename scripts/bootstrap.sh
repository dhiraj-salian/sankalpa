#!/usr/bin/env bash
# Bootstrap the Sankalpa project: initialize and update all component submodules.
# Safe to run repeatedly. Run from anywhere; resolves the meta-repo root itself.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Sankalpa meta-repo: $REPO_ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "!! Not a git repository. Run 'git init' in the meta-repo first." >&2
  exit 1
fi

echo "==> Initializing and updating submodules (recursive)..."
git submodule update --init --recursive

echo "==> Component status:"
git submodule status --recursive

echo
echo "Done. Each component lives in its own directory and is an independent repo."
echo "See COMPONENTS.md for the component map and per-component setup."
