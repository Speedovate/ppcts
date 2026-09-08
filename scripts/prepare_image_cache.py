#!/usr/bin/env python3
"""Version every bundled image so persistent cache entries cannot go stale."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
output = root / 'build/web'
extensions = {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.ico', '.avif'}
versions = {
    path.relative_to(output).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
    for path in sorted(output.rglob('*'))
    if path.is_file() and path.suffix.lower() in extensions
}
if not versions:
    raise SystemExit('No built images found; run flutter build web first.')
template = (root / 'web/image_cache_sw.js').read_text()
marker = '/* IMAGE_VERSIONS */ {}'
assert template.count(marker) == 1
(output / 'image_cache_sw.js').write_text(template.replace(marker, json.dumps(versions, sort_keys=True)))
print(f'Persistent cache manifest ready: {len(versions)} images.')
