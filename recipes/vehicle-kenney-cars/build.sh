#!/usr/bin/env bash
# recipes/vehicle-kenney-cars/build.sh -- guard only. Data packages are packed
# with `cvcpkg pack vehicle-kenney-cars --from-prefix <dir> --platform any`;
# this script just verifies the payload was staged.
set -euo pipefail
: "${CVC_INSTALL_DIR:?CVC_INSTALL_DIR must be set}"
d="share/cvc-scenes/shared/kenney-cars"
n=$(ls "$CVC_INSTALL_DIR/$d"/*.glb 2>/dev/null | wc -l)
if [[ "$n" -lt 50 || ! -f "$CVC_INSTALL_DIR/$d/LICENSE.txt" ]]; then
  echo "vehicle-kenney-cars: expected >=50 .glb + LICENSE.txt under $d, found $n glb" >&2
  echo "Stage the kit into a prefix and run:" >&2
  echo "  cvcpkg pack vehicle-kenney-cars --from-prefix <dir> --platform any --output-dir dist/" >&2
  exit 1
fi
echo "vehicle-kenney-cars: OK ($n glb)"
