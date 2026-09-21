#!/usr/bin/env bash
set -euo pipefail

expected_certificate="${EXPECTED_RELEASE_CERT_SHA256:-}"
if [[ ! "$expected_certificate" =~ ^[[:xdigit:]]{64}$ ]]; then
  echo "EXPECTED_RELEASE_CERT_SHA256 must be a 64-character SHA-256 certificate digest" >&2
  exit 1
fi
expected_certificate="$(printf '%s' "$expected_certificate" | tr '[:upper:]' '[:lower:]')"

for required_name in KEYSTORE_PATH KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD; do
  if [[ -z "${!required_name-}" ]]; then
    echo "Missing Android signing variable: $required_name" >&2
    exit 1
  fi
done

if [[ ! -f "$KEYSTORE_PATH" || ! -s "$KEYSTORE_PATH" ]]; then
  echo "Android keystore is missing or empty: $KEYSTORE_PATH" >&2
  exit 1
fi

if ! command -v keytool >/dev/null 2>&1; then
  echo "Required Android signing verification tool is unavailable: keytool" >&2
  exit 1
fi

if ! certificate_details="$(
  keytool -list -v \
    -keystore "$KEYSTORE_PATH" \
    -storepass "$KEYSTORE_PASSWORD" \
    -alias "$KEY_ALIAS" \
    2>/dev/null
)"; then
  echo "Android keystore, store password, or key alias could not be opened" >&2
  exit 1
fi

if ! grep -Fq 'Entry type: PrivateKeyEntry' <<<"$certificate_details"; then
  echo "Configured Android signing alias is not a private-key entry" >&2
  exit 1
fi

certificate="$(printf '%s\n' "$certificate_details" \
  | sed -n 's/^[[:space:]]*SHA256: //p' \
  | head -n 1 \
  | tr -d ':' \
  | tr '[:upper:]' '[:lower:]')"
if [[ -z "$certificate" ]]; then
  echo "Android signing certificate could not be read from the configured alias" >&2
  exit 1
fi

if [[ "$certificate" != "$expected_certificate" ]]; then
  echo "Android signing certificate mismatch before release build" >&2
  exit 1
fi

if grep -qi 'CN=Android Debug' <<<"$certificate_details"; then
  echo "Development/debug signing certificate is not allowed for public release" >&2
  exit 1
fi

echo "Verified production Android signing material for the configured alias"
