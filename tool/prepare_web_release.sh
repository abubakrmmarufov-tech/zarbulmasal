#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
web_dir="${1:-$repo_root/build/web}"
main_js="$web_dir/main.dart.js"
bootstrap="$web_dir/flutter_bootstrap.js"
worker="$web_dir/qalam_service_worker.js"
placeholder='__ZARBULMASAL_BUILD_ID__'

for required_file in "$main_js" "$bootstrap" "$worker"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing production web artifact: $required_file" >&2
    exit 1
  fi
done

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# Include every emitted artifact plus the two source templates. The emitted
# bootstrap and worker are excluded because their injected ID would make a
# repeated preparation self-referential; their source templates cover changes
# to that code. File names are included so renames also invalidate the cache.
release_manifest="$(mktemp)"
trap 'rm -f "$release_manifest"' EXIT
while IFS= read -r artifact; do
  relative_path="${artifact#"$web_dir"/}"
  if [[ "$relative_path" == 'flutter_bootstrap.js' ||
        "$relative_path" == 'qalam_service_worker.js' ]]; then
    continue
  fi
  printf '%s %s\n' "$(hash_file "$artifact")" "$relative_path" \
    >> "$release_manifest"
done < <(find "$web_dir" -type f -print | LC_ALL=C sort)

for source_template in \
  "$repo_root/web/flutter_bootstrap.js" \
  "$repo_root/web/qalam_service_worker.js"; do
  printf '%s source/%s\n' \
    "$(hash_file "$source_template")" "$(basename "$source_template")" \
    >> "$release_manifest"
done

build_id="$(hash_file "$release_manifest" | cut -c1-20)"

export ZARBULMASAL_BUILD_ID="$build_id"
for target in "$bootstrap" "$worker"; do
  perl -0pi -e 's/__ZARBULMASAL_BUILD_ID__/$ENV{ZARBULMASAL_BUILD_ID}/g' "$target"
done

if grep -R -F "$placeholder" "$bootstrap" "$worker" >/dev/null; then
  echo 'Offline cache build identifier replacement failed.' >&2
  exit 1
fi

echo "Prepared web release cache $build_id"
