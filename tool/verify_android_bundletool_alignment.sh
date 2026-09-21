#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bundle_path="${1:-$project_root/build/app/outputs/bundle/release/app-release.aab}"
bundletool_jar="${2:-${BUNDLETOOL_JAR:-}}"

# Keep the toolchain input reproducible. The URL and digest are for the
# official google/bundletool 1.18.3 release asset.
bundletool_version="1.18.3"
expected_bundletool_sha256="a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29"

if [[ -z "$bundletool_jar" || ! -f "$bundletool_jar" ]]; then
  echo "Missing pinned bundletool jar; pass it as the second argument or set BUNDLETOOL_JAR" >&2
  exit 1
fi
if [[ ! -f "$bundle_path" ]]; then
  echo "Missing Android App Bundle: $bundle_path" >&2
  exit 1
fi
if ! command -v java >/dev/null 2>&1; then
  echo "Required Android bundle verification tool is unavailable: java" >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  actual_bundletool_sha256="$(sha256sum "$bundletool_jar" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  actual_bundletool_sha256="$(shasum -a 256 "$bundletool_jar" | awk '{print $1}')"
else
  echo "Required checksum tool is unavailable: sha256sum or shasum" >&2
  exit 1
fi
if [[ "$actual_bundletool_sha256" != "$expected_bundletool_sha256" ]]; then
  echo "bundletool $bundletool_version checksum mismatch" >&2
  exit 1
fi

config_output="$(java -jar "$bundletool_jar" dump config --bundle="$bundle_path")"
if ! grep -Fq 'PAGE_ALIGNMENT_16K' <<< "$config_output"; then
  echo "bundletool did not report PAGE_ALIGNMENT_16K for the Android App Bundle" >&2
  echo "$config_output" >&2
  exit 1
fi

echo "Verified bundletool $bundletool_version reports PAGE_ALIGNMENT_16K: $bundle_path"
