#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bundle_path="${1:-$project_root/build/app/outputs/bundle/release/app-release.aab}"
expected_certificate="${EXPECTED_RELEASE_CERT_SHA256:-}"
if [[ ! "$expected_certificate" =~ ^[[:xdigit:]]{64}$ ]]; then
  echo "EXPECTED_RELEASE_CERT_SHA256 must be a 64-character SHA-256 certificate digest" >&2
  exit 1
fi
expected_certificate="$(printf '%s' "$expected_certificate" | tr '[:upper:]' '[:lower:]')"
expected_package="com.zarbulmasal.zarbulmasal"
version_parts="$(sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\)+\([0-9][0-9]*\)[[:space:]]*$/\1 \2/p' "$project_root/pubspec.yaml")"
read -r expected_version expected_version_code <<< "$version_parts"

if [[ -z "$expected_version" || -z "$expected_version_code" ]]; then
  echo "Could not read version and versionCode from pubspec.yaml" >&2
  exit 1
fi

if [[ ! -f "$bundle_path" ]]; then
  echo "Missing Android App Bundle: $bundle_path" >&2
  exit 1
fi

android_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
build_tools_root="$android_sdk/build-tools"
if [[ ! -d "$build_tools_root" ]]; then
  echo "Android build tools not found: $build_tools_root" >&2
  exit 1
fi
build_tools="$(find "$build_tools_root" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)"
aapt2="$build_tools/aapt2"

for tool in jarsigner keytool unzip zip python3 "$aapt2"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required Android bundle verification tool is unavailable: $tool" >&2
    exit 1
  fi
done

python3 "$project_root/tool/verify_android_bundle_alignment.py" "$bundle_path"

manifest_dir="$(mktemp -d)"
trap 'rm -rf "$manifest_dir"' EXIT

unzip -t "$bundle_path" >/dev/null
if ! jarsigner -verify -certs "$bundle_path" >/dev/null 2>&1; then
  echo "Android App Bundle signature verification failed" >&2
  exit 1
fi
bundle_listing="$(unzip -l "$bundle_path")"
for required_entry in \
  'base/manifest/AndroidManifest.xml' \
  'base/assets/flutter_assets/AssetManifest.bin'; do
  if ! grep -Fq "$required_entry" <<<"$bundle_listing"; then
    echo "Android App Bundle is missing required entry: $required_entry" >&2
    exit 1
  fi
done

unzip -q "$bundle_path" 'base/manifest/AndroidManifest.xml' -d "$manifest_dir"
(
  cd "$manifest_dir/base/manifest"
  zip -q "$manifest_dir/base-manifest.apk" AndroidManifest.xml
)
manifest_xml="$("$aapt2" dump xmltree "$manifest_dir/base-manifest.apk" --file AndroidManifest.xml)"
package_name="$(sed -n 's/.*A: package=.*Raw: "\([^"]*\)".*/\1/p' <<< "$manifest_xml" | head -n 1)"
version_name="$(sed -n 's/.*versionName.*Raw: "\([^"]*\)".*/\1/p' <<< "$manifest_xml" | head -n 1)"
version_code="$(sed -n 's/.*versionCode.*Raw: "\([0-9][0-9]*\)".*/\1/p' <<< "$manifest_xml" | head -n 1)"
if [[ "$package_name" != "$expected_package" ]]; then
  echo "Android App Bundle package mismatch: $package_name" >&2
  exit 1
fi
if [[ "$version_name" != "$expected_version" ]]; then
  echo "Android App Bundle version mismatch: $version_name" >&2
  exit 1
fi
if [[ "$version_code" != "$expected_version_code" ]]; then
  echo "Android App Bundle versionCode mismatch: $version_code" >&2
  exit 1
fi

certificate_details="$(keytool -printcert -jarfile "$bundle_path" 2>/dev/null)"
certificate="$(printf '%s\n' "$certificate_details" \
  | sed -n 's/^[[:space:]]*SHA256: //p' \
  | head -n 1 \
  | tr -d ':' \
  | tr '[:upper:]' '[:lower:]')"
if [[ -z "$certificate" ]]; then
  echo "Android App Bundle has no readable signing certificate" >&2
  exit 1
fi
if [[ "$certificate" != "$expected_certificate" ]]; then
  echo "Android App Bundle signing certificate mismatch" >&2
  exit 1
fi
if grep -qi 'CN=Android Debug' <<<"$certificate_details"; then
  echo "Development/debug signing certificate is not allowed for the Play App Bundle" >&2
  exit 1
fi

echo "Verified signed Android App Bundle: $bundle_path"
echo "Package: $package_name"
echo "Version: $version_name ($version_code)"
echo "Certificate: $certificate"
