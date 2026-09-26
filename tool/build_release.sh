#!/usr/bin/env bash
# Builds the signed Play bundle and the split-per-ABI APKs, verifies the
# bundle, and copies everything to the release folder.
#
# Usage:
#   ZARBULMASAL_KEY_ENV=~/zarbulmasal-upload-key/upload-key.env \
#     bash tool/build_release.sh
#
# Environment:
#   ZARBULMASAL_KEY_ENV   (required) path to the env file that exports
#                         KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS,
#                         KEY_PASSWORD and EXPECTED_RELEASE_CERT_SHA256.
#                         It stays outside the repository; nothing from it
#                         is printed.
#   RELEASE_DIR           output folder (default ~/Desktop/Zarbulmasal-release).
#   SYMBOLS_DIR           Dart debug symbols (default $RELEASE_DIR/debug-symbols,
#                         outside git).
#   KEEP_BUILD            set to 1 to keep build/app afterwards (it is
#                         removed by default to save disk).
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

key_env="${ZARBULMASAL_KEY_ENV:-}"
if [[ -z "$key_env" || ! -f "$key_env" ]]; then
  echo "Set ZARBULMASAL_KEY_ENV to the upload-key env file." >&2
  exit 1
fi
case "$(cd "$(dirname "$key_env")" && pwd)/" in
  "$project_root"/*)
    echo "The key env file must live outside the repository." >&2
    exit 1
    ;;
esac

# shellcheck disable=SC1090
source "$key_env"
for name in KEYSTORE_PATH KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD \
  EXPECTED_RELEASE_CERT_SHA256; do
  if [[ -z "${!name:-}" ]]; then
    echo "$name is not set by $key_env" >&2
    exit 1
  fi
done
export KEYSTORE_PATH KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD \
  EXPECTED_RELEASE_CERT_SHA256
unset ZARBULMASAL_PREVIEW_DEBUG_SIGNING

release_dir="${RELEASE_DIR:-$HOME/Desktop/Zarbulmasal-release}"
symbols_dir="${SYMBOLS_DIR:-$release_dir/debug-symbols}"
case "$(mkdir -p "$symbols_dir" && cd "$symbols_dir" && pwd)/" in
  "$project_root"/*)
    echo "SYMBOLS_DIR must be outside the repository." >&2
    exit 1
    ;;
esac

version_parts="$(sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\)+\([0-9][0-9]*\)[[:space:]]*$/\1 \2/p' pubspec.yaml)"
read -r version version_code <<<"$version_parts"
if [[ -z "$version" || -z "$version_code" ]]; then
  echo "Could not read the version from pubspec.yaml" >&2
  exit 1
fi

bash tool/verify_android_signing_material.sh

common=(--release --obfuscate "--split-debug-info=$symbols_dir")
flutter build appbundle "${common[@]}"
flutter build apk "${common[@]}" --split-per-abi

bundle=build/app/outputs/bundle/release/app-release.aab
bash tool/verify_android_bundle.sh "$bundle"

mkdir -p "$release_dir"
cp "$bundle" "$release_dir/zarbulmasal-$version-$version_code.aab"
for abi in arm64-v8a armeabi-v7a x86_64; do
  cp "build/app/outputs/flutter-apk/app-$abi-release.apk" \
    "$release_dir/zarbulmasal-$version-$abi.apk"
done
mapping=build/app/outputs/mapping/release/mapping.txt
if [[ -f "$mapping" ]]; then
  cp "$mapping" "$symbols_dir/mapping.txt"
fi
native_symbols=build/app/outputs/native-debug-symbols/release/native-debug-symbols.zip
if [[ -f "$native_symbols" ]]; then
  cp "$native_symbols" "$symbols_dir/native-debug-symbols.zip"
fi

printf '\n%s %s (%s) in %s:\n' "Zarbulmasal" "$version" "$version_code" "$release_dir"
ls -l "$release_dir" | sed -n '2,$p'

if [[ "${KEEP_BUILD:-0}" != 1 ]]; then
  rm -rf build/app
fi
