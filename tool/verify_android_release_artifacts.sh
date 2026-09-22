#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bundle_path="${1:-$project_root/build/app/outputs/bundle/release/app-release.aab}"
mapping_path="$project_root/build/app/outputs/mapping/release/mapping.txt"
native_symbols_path="$project_root/build/app/outputs/native-debug-symbols/release/native-debug-symbols.zip"
dart_symbols_root="$project_root/build/symbols/android"

for required_file in "$bundle_path" "$mapping_path" "$native_symbols_path"; do
  if [[ ! -s "$required_file" ]]; then
    echo "Missing or empty Android release evidence: $required_file" >&2
    exit 1
  fi
done

if [[ ! -d "$dart_symbols_root" ]]; then
  echo "Missing Dart symbol directory: $dart_symbols_root" >&2
  exit 1
fi

symbol_count="$(find "$dart_symbols_root" -type f -name '*.symbols' -print | wc -l | tr -d ' ')"
if [[ "$symbol_count" -lt 1 ]]; then
  echo "No Dart symbol files found under $dart_symbols_root" >&2
  exit 1
fi

if ! unzip -t "$native_symbols_path" >/dev/null; then
  echo "Native debug-symbol archive is not a valid ZIP: $native_symbols_path" >&2
  exit 1
fi

native_symbol_count="$(unzip -Z1 "$native_symbols_path" | awk '/\.sym$/{count += 1} END {print count + 0}')"
if [[ "$native_symbol_count" -lt 1 ]]; then
  echo "Native debug-symbol archive contains no .sym files: $native_symbols_path" >&2
  exit 1
fi

"$project_root/tool/verify_android_bundle.sh" "$bundle_path"

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

echo "Verified Android release evidence:"
echo "  AAB: $(hash_file "$bundle_path")"
echo "  mapping.txt: $(hash_file "$mapping_path")"
echo "  native-debug-symbols.zip: $(hash_file "$native_symbols_path")"
echo "  Dart symbol files: $symbol_count"
echo "  Native symbol files: $native_symbol_count"
