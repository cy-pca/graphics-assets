# graphics-assets

Cvcpkg recipes for graphics/scene/vehicle asset bundles used by cvcgl demos
(scene bundles, textured vehicle models, and future terrain/prop packs).
Publishes to [cvcpkg.org](https://cvcpkg.org) via the on-demand `publish`
GitHub Action, which runs on the cy-pca self-hosted `catx-03` runner (the
only host with the source data staged at `/opt/cvc-wasm/scenes/` and a
publisher token in its cvcpkg config).

## Layout

    recipes/<pkg>/recipe.yaml   -- cvcpkg recipe (data-only: source: none)
    recipes/<pkg>/build.sh      -- guard script (data packages are packed
                                   via cvcpkg pack --from-prefix)

## Publishing

The `publish` workflow (see `.github/workflows/publish.yml`) is manual
dispatch only. It stages each recipe's payload from the well-known
`/opt/cvc-wasm/scenes/` mirror on catx-03, runs `cvcpkg pack
--from-prefix`, and publishes to cvcpkg.org. To publish a new revision
of an existing package, bump `cvc_revision` in its `recipe.yaml`, push,
then dispatch `publish` with that recipe name.

## Current packages

| Recipe                    | Size    | Contents |
|---------------------------|---------|----------|
| `scene-austin-south`      | ~117 MB | Full 3km Austin: terrain, buildings, satellite, foliage/nav/road/water masks, hi-res LODs |
| `scene-austin-south-web`  | ~10 MB  | Same footprint, downscaled satellite + inline Humvee.glb, for wasm --preload-file |
| `vehicle-humvee`          | ~180 KB | HMMWV (M1097) glb, ships to share/cvc-scenes/shared/ |

## Adding a new asset

1. Scaffold `recipes/<name>/{recipe.yaml, build.sh}` (copy from
   `vehicle-humvee` or `scene-austin-south`).
2. Stage the payload on catx-03 under `/opt/cvc-wasm/scenes/<name>/`
   with the exact file layout the recipe's `package: files` says.
3. Dispatch the `publish` workflow with your recipe name; it packs from
   the staged tree and publishes to cvcpkg.org.
