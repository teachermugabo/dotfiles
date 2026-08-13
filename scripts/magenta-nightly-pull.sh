#!/usr/bin/env bash
# Nightly fast-forward of main for ~/src/magenta.nvim.
# Refuses to touch a dirty tree. If a non-main branch is checked out,
# fast-forwards the local main ref without switching.
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin"

REPO="$HOME/src/magenta.nvim"
LOG="$HOME/.local/state/magenta-nightly-pull.log"

mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1

echo "=== $(date '+%Y-%m-%d %H:%M:%S %z') ==="
cd "$REPO"

current="$(git symbolic-ref --quiet --short HEAD || echo detached)"

if [ "$current" = "main" ]; then
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "on main but working tree is dirty — skipping"
        exit 0
    fi
    git pull --ff-only origin main
else
    echo "on branch '$current' — fast-forwarding local main without switching"
    git fetch origin main:main
fi

echo "done"
