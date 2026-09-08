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
