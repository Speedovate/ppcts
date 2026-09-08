#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if [[ $# -ne 1 || -z "$1" ]]; then
  echo 'Usage: ./scripts/release_web.sh "Describe the update"' >&2
  exit 1
fi

bash ./scripts/build_web.sh
git add -A

if ! git diff --cached --quiet; then
  git commit -m "$1"
else
  echo "No changes to commit."
fi

# Also retries a previous push if its commit succeeded but the network failed.
git push
