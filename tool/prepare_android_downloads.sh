#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
apk_root="${1:-$project_root/build/app/outputs/flutter-apk}"
web_root="${2:-$project_root/build/web}"
download_root="$web_root/downloads"
android_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
build_tools_root="$android_sdk/build-tools"
expected_certificate="${EXPECTED_RELEASE_CERT_SHA256:-}"
if [[ ! "$expected_certificate" =~ ^[[:xdigit:]]{64}$ ]]; then
  echo "EXPECTED_RELEASE_CERT_SHA256 must be a 64-character SHA-256 certificate digest" >&2
  exit 1
fi
expected_certificate="$(printf '%s' "$expected_certificate" | tr '[:upper:]' '[:lower:]')"
expected_package="com.zarbulmasal.zarbulmasal"
version_parts="$(sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\)+\([0-9][0-9]*\)[[:space:]]*$/\1 \2/p' "$project_root/pubspec.yaml")"
read -r expected_version base_version_code <<< "$version_parts"

if [[ -z "$expected_version" || -z "$base_version_code" ]]; then
  echo "Could not read version and versionCode from pubspec.yaml" >&2
  exit 1
fi

declare -a source_files=(
  "$apk_root/app-arm64-v8a-release.apk"
  "$apk_root/app-armeabi-v7a-release.apk"
  "$apk_root/app-release.apk"
)

for source_file in "${source_files[@]}"; do
  if [[ ! -f "$source_file" ]]; then
    echo "Missing Android release artifact: $source_file" >&2
    exit 1
  fi
done

if [[ ! -d "$build_tools_root" ]]; then
  echo "Android build tools not found: $build_tools_root" >&2
  exit 1
fi

build_tools="$(find "$build_tools_root" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)"
apksigner="$build_tools/apksigner"
aapt="$build_tools/aapt"
zipalign="$build_tools/zipalign"

for tool in "$apksigner" "$aapt" "$zipalign"; do
  if [[ ! -x "$tool" ]]; then
    echo "Required Android release tool is unavailable: $tool" >&2
    exit 1
  fi
done

for source_file in "${source_files[@]}"; do
  badging="$("$aapt" dump badging "$source_file")"
  certificate_details="$("$apksigner" verify --print-certs "$source_file" 2>/dev/null)"
  certificate="$(printf '%s\n' "$certificate_details" \
    | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' \
    | tr '[:upper:]' '[:lower:]')"
  if [[ "$certificate" != "$expected_certificate" ]]; then
    echo "Signing certificate mismatch for $source_file" >&2
    exit 1
  fi
  if grep -qi 'CN=Android Debug' <<<"$certificate_details"; then
    echo "Development/debug signing certificate is not allowed for public downloads: $source_file" >&2
    exit 1
  fi

  version_code="$(printf '%s\n' "$badging" \
    | sed -n "s/.*versionCode='\\([0-9][0-9]*\\)'.*/\\1/p" \
    | head -n 1)"
  case "$(basename "$source_file")" in
    app-arm64-v8a-release.apk)
      expected_abi_version_code=$((base_version_code + 2000))
      ;;
    app-armeabi-v7a-release.apk)
      expected_abi_version_code=$((base_version_code + 1000))
      ;;
    app-release.apk)
      expected_abi_version_code="$base_version_code"
      ;;
  esac
  if [[ -z "$version_code" || "$version_code" -ne "$expected_abi_version_code" ]]; then
    echo "Android versionCode mismatch for $source_file: expected $expected_abi_version_code, got $version_code" >&2
    exit 1
  fi

  package_name="$(printf '%s\n' "$badging" \
    | sed -n "s/^package: name='\\([^']*\\)'.*/\\1/p" \
    | head -n 1)"
  if [[ "$package_name" != "$expected_package" ]]; then
    echo "Android package mismatch for $source_file: $package_name" >&2
    exit 1
  fi

  version_name="$(printf '%s\n' "$badging" \
    | sed -n "s/.*versionName='\\([^']*\\)'.*/\\1/p" \
    | head -n 1)"
  if [[ "$version_name" != "$expected_version" ]]; then
    echo "Android version mismatch for $source_file: $version_name" >&2
    exit 1
  fi

  native_code="$(printf '%s\n' "$badging" | sed -n 's/^native-code: //p')"
  case "$(basename "$source_file")" in
    app-arm64-v8a-release.apk)
      expected_native_code="'arm64-v8a'"
      ;;
    app-armeabi-v7a-release.apk)
      expected_native_code="'armeabi-v7a'"
      ;;
    app-release.apk)
      expected_native_code="'arm64-v8a' 'armeabi-v7a' 'x86_64'"
      ;;
  esac
  if [[ "$native_code" != "$expected_native_code" ]]; then
    echo "Android ABI mismatch for $source_file: $native_code" >&2
    exit 1
  fi

  "$zipalign" -c -P 16 -v 4 "$source_file" >/dev/null
done

if [[ -L "$download_root" ]]; then
  echo "Refusing to clean symlinked Android download output: $download_root" >&2
  exit 1
fi
if [[ -d "$download_root" ]]; then
  find "$download_root" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
fi
mkdir -p "$download_root"
cp "$apk_root/app-arm64-v8a-release.apk" "$download_root/zarbulmasal-arm64-v8a.apk"
cp "$apk_root/app-armeabi-v7a-release.apk" "$download_root/zarbulmasal-armeabi-v7a.apk"
cp "$apk_root/app-release.apk" "$download_root/zarbulmasal-universal.apk"

(
  cd "$download_root"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum ./*.apk > SHA256SUMS
  else
    shasum -a 256 ./*.apk > SHA256SUMS
  fi
)

echo "Prepared direct Android downloads in $download_root"
ls -lh "$download_root"/*.apk "$download_root/SHA256SUMS"
