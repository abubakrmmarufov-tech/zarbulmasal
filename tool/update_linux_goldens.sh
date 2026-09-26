#!/usr/bin/env bash
# Replaces the Linux golden images with what CI rendered.
#
# Usage: bash tool/update_linux_goldens.sh <run id>
#
# CI uploads the diff images of failing goldens as the `golden-failures`
# artifact. Look at each *_isolatedDiff.png first: only intended changes may
# be copied. The macOS images are updated locally with
# `flutter test --update-goldens test/golden`.
set -euo pipefail

run_id="${1:?usage: bash tool/update_linux_goldens.sh <run id>}"
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$project_root/test/golden/goldens/linux"
download="$(mktemp -d)"
trap 'rm -rf "$download"' EXIT

gh run download "$run_id" --name golden-failures --dir "$download"
shopt -s nullglob
images=("$download"/*_testImage.png)
if ((${#images[@]} == 0)); then
  echo "Run $run_id uploaded no failing goldens." >&2
  exit 1
fi
for image in "${images[@]}"; do
  name="$(basename "$image" _testImage.png)"
  cp "$image" "$target/$name.png"
  echo "updated goldens/linux/$name.png"
done
