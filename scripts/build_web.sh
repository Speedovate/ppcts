#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
"$FLUTTER_BIN" build web --release "$@"

for artifact in index.html flutter_bootstrap.js main.dart.js assets/AssetManifest.bin; do
  if [[ ! -s "build/web/$artifact" ]]; then
    echo "Missing web build artifact: $artifact" >&2
    exit 1
  fi
done

python3 ./scripts/prepare_image_cache.py

echo "Web release ready in build/web. Include it with the source changes in your commit."
