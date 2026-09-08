# Committing web releases

This repository deploys the prebuilt Flutter bundle in `build/web`.
Source files in `web/` are build inputs; they are not the finished website.
Changing Dart code or assets and running `git add .` alone does not rebuild it.

## Build, commit, and push

Run from the repository:

```sh
./scripts/release_web.sh "Update flipbook"
```

The script builds a release, verifies its required files, stages all changes
(including deleted assets), commits source and `build/web` together, then pushes
the current branch to its configured upstream. It stops if building or committing
fails. It includes all working-tree changes, just like `git add -A`.

For review before committing:

```sh
./scripts/build_web.sh
git add -A
git diff --cached --stat
git commit -m "Update flipbook"
git push
```

Flutter must be on PATH, or set `FLUTTER_BIN` to its executable. The build script
accepts Flutter build arguments, for example `--base-href /ppcts/` when serving
under a subpath. Vercel serves at the domain root, so its build uses the default `/`.
Run `flutter analyze` and `flutter test` before releasing functional changes.

## What is tracked

`.gitignore` permits `build/web` but keeps other build directories, SDK caches,
`.DS_Store`, and the local `.last_build_id` ignored. No force-add is necessary.
The build command runs on your machine before committing, not inside a Git hook.
Use the release script for every website update; a plain commit can contain stale
build output if no build was run first.

`vercel.json` selects `build/web` as the static output and skips server-side
installation/building. Its rewrite supports opening app routes directly.
Connecting this GitHub repository to a Vercel project is a separate hosting setup.
Configuration reference: https://vercel.com/docs/project-configuration/vercel-json

## Comparison with the existing projects

Inspected the local repositories on September 8, 2026:

| Project | Build inclusion | Release workflow | Hosting configuration |
| --- | --- | --- | --- |
| `webapp` | `.gitignore` allows `build/web`; recent commits include `main.dart.js` and source changes | `scripts/deploy_web.zsh` builds, copies its custom install-page assets, stages, commits, and pushes | Vercel legacy static builder/routes |
| `website` | Same `build/web` exception; commits include both `web/index.html` and generated `build/web/index.html` | No tracked release script found | Vercel routes to the committed bundle |
| `supermarket` | Same `build/web` exception; recent commits include compiled JS and source | `scripts/release_web.sh` cleans/builds and injects its app-specific version markers; commit/push are separate | Vercel `outputDirectory` and SPA rewrite; Firebase Hosting also points at `build/web` |

The flipbook uses the common tracked-build approach and the webapp's release
sequence with the supermarket's simpler Vercel output configuration. It does not
need the webapp's install-page copies or the supermarket's custom version
injection because those inputs/runtime mechanisms do not exist here. Global
ignore rules are preserved rather than unignoring every generated file, which
would also admit `.DS_Store` files seen in the other repositories.

## Persistent image cache

The release script runs `scripts/prepare_image_cache.py` after Flutter builds. It
hashes every bundled image and inserts the manifest into `build/web/image_cache_sw.js`.
Always use `scripts/build_web.sh` or `scripts/release_web.sh` for deployable builds;
a plain Flutter build leaves the development worker's image manifest empty.
Python 3 is required for this preparation step.

The custom bootstrap registers the worker before starting Flutter (with a two-second
fallback so blocked storage or registration does not stall the app). Images are
cached on demand using browser Cache Storage. Cache hits avoid the network, including
after closing/reopening the browser. Unchanged images keep their cache entries
across releases; changed image bytes produce a new key and download. Deleted image
entries are removed on worker activation. Failed/non-image responses are not cached,
and storage failures fall back to network loading. Only same-origin bundled images
are intercepted; sponsor video URLs, API responses, and app navigation are not.

The existing in-memory Flutter raster cache still handles decoded pages during a
session. Persisted image bytes avoid downloads, but still need decoding on a new
session. This is image caching, not a guarantee that the complete app opens offline.
Browsers can clear cached data under storage pressure, in private mode, or when users
clear site data. Service workers require HTTPS (localhost also works).
See [MDN Cache](https://developer.mozilla.org/en-US/docs/Web/API/Cache) and
[Flutter web initialization](https://docs.flutter.dev/platform-integration/web/initialization).

To verify with an actual browser:

```sh
node scripts/test_image_cache.mjs
```

The check uses an isolated Chrome profile and local test server, verifies downloads
on the first request, reuse after browser restart, offline image reads, and selective
refresh after an image changes. Set `CHROME_BIN` if Chrome is installed elsewhere.
It does not access your normal browser profile or contact external services.
