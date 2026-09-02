# graphics-assets

Cvcpkg recipes for graphics/scene/vehicle asset bundles used by cvcgl demos
(scene bundles, textured vehicle models, and future terrain/prop packs).
Publishes to [cvcpkg.org](https://cvcpkg.org) under the `cvc` organisation
via the on-demand `publish` GitHub Action, which runs on the cy-pca
self-hosted `catx-03` runner (the only host with the source data staged at
`/opt/cvc-wasm/scenes/`). The publishing identity is the repository secret
`CVCPKG_PUBLISHER_TOKEN`, which must be a member of the `cvc` org on
cvcpkg.org (`cvcpkg org add-member cvc --name <token-name>`); the runner
itself holds no credentials.

This repository is the single home for asset recipes. `transfix/libcvc-deps`
no longer carries copies.

## Layout

    recipes/<pkg>/recipe.yaml   -- cvcpkg recipe (data-only: source: none)
    recipes/<pkg>/build.sh      -- guard script (data packages are packed
                                   via cvcpkg pack --from-prefix)

## Publishing

The `publish` workflow (see `.github/workflows/publish.yml`) is manual
dispatch only. It stages each recipe's payload from the well-known
`/opt/cvc-wasm/scenes/` mirror on catx-03, runs `cvcpkg pack
--from-prefix`, publishes the bundle to cvcpkg.org with `--org cvc`, and
pushes the recipe metadata (`cvcpkg recipe push --org cvc`) so the package
pages track this repo. To publish a new revision of an existing package,
bump `cvc_revision` in its `recipe.yaml`, push, then dispatch `publish`
with that recipe name. The server rejects a name/version/variant that is
already published, even under a different org, so a republish always
needs a bump.

`cvcpkg pack --from-prefix` does not run `build.sh` and does not enforce
`package.files`; the guard scripts only matter for `cvcpkg build`. What
lands in a bundle is exactly what the recipe's `case` in `publish.yml`
stages, so keep the two in step.

Validate a recipe locally with `cvcpkg validate recipes/<name>`; this needs
a cvcpkg whose schema accepts `source.type: none` (libcvc-deps#550 or
later).

## Current packages

| Recipe                    | Size    | Contents |
|---------------------------|---------|----------|
| `scene-austin-south`      | ~117 MB | Full 3km Austin: terrain, buildings, satellite, foliage/nav/road/water masks, hi-res LODs |
| `scene-austin-south-web`  | ~10 MB  | Same footprint, downscaled satellite + inline Humvee.glb, for wasm --preload-file |
| `vehicle-humvee`          | ~180 KB | HMMWV (M1097) glb, ships to share/cvc-scenes/shared/ |
| `vehicle-kenney-cars`     | ~1 MB   | Kenney Car Kit 3.1 (CC0): 50 low-poly vehicle, wheel and debris glbs + LICENSE.txt, ships to share/cvc-scenes/shared/kenney-cars/ |

Sizes are compressed archive sizes; the recipe descriptions quote the
installed (uncompressed) payload.

## Adding a new asset

1. Scaffold `recipes/<name>/{recipe.yaml, build.sh}` (copy from
   `vehicle-humvee` or `scene-austin-south`).
2. Stage the payload on catx-03 under `/opt/cvc-wasm/scenes/<name>/`
   (vehicles: `/opt/cvc-wasm/scenes/shared/<name>/`) with the exact file
   layout the recipe's `package: files` says. The tree is owned by
   `github-runner`; install files with
   `sudo install -o github-runner -g github-runner`.
3. Add a `case <name>)` block to `.github/workflows/publish.yml` that copies
   the staged files into `stage/<name>/share/cvc-scenes/...`, and add the
   name to the workflow's `recipes` input default. The workflow refuses
   names it has no case for.
4. Dispatch the `publish` workflow with your recipe name; it packs from
   the staged tree and publishes to cvcpkg.org under `cvc`.
