#!/usr/bin/env bash
set -euo pipefail

# Deploy the prepared site to gh-pages. Android downloads are verified by
# default; pass --web-only only when intentionally publishing a web-only site.
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
web_only=false
if [[ "${1:-}" == "--web-only" ]]; then
  web_only=true
fi

bash "$project_root/tool/prepare_web_release.sh"
test -s "$project_root/build/web/privacy.html"
grep -Fq "Zarbulmasal Privacy Policy" "$project_root/build/web/privacy.html"

privacy_url="https://abubakrmmarufov-tech.github.io/zarbulmasal/privacy.html"
verify_published_privacy() {
  for attempt in {1..12}; do
    if curl --fail --silent --show-error --location --max-time 20 "$privacy_url" \
      | grep -Fq 'Zarbulmasal Privacy Policy'; then
      echo "Published privacy policy verified at $privacy_url"
      return 0
    fi
    echo "Waiting for GitHub Pages to publish privacy policy (attempt $attempt/12)..."
    sleep 5
  done
  echo "Published privacy policy was not available at $privacy_url" >&2
  return 1
}

if [[ "$web_only" != true ]]; then
  bundle_path="$project_root/build/app/outputs/bundle/release/app-release.aab"
  apk_root="$project_root/build/app/outputs/flutter-apk"
  if [[ ! -f "$bundle_path" ]]; then
    echo "Refusing Pages deployment without a verified signed App Bundle." >&2
    echo "Use --web-only only for an explicitly non-Android deployment." >&2
    exit 1
  fi
  bash "$project_root/tool/verify_android_bundle.sh" "$bundle_path"
  bash "$project_root/tool/prepare_android_downloads.sh" "$apk_root" "$project_root/build/web"
else
  # A web-only publish must never carry stale Android binaries or a portal
  # copied from an earlier signed build.
  rm -rf "$project_root/build/web/android" "$project_root/build/web/downloads"
fi

deployment_dir="$project_root/build/gh-pages"
mkdir -p "$deployment_dir"
cd "$deployment_dir"
deployment_repo=false
if [[ -e "$deployment_dir/.git" ]]; then
  deployment_toplevel="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ "$deployment_toplevel" == "$deployment_dir" ]]; then
    deployment_repo=true
  fi
fi
if [[ "$deployment_repo" == true ]]; then
  # A separately registered deployment worktree may already have the local
  # gh-pages branch checked out. A detached checkout still gives this
  # one-shot publisher the history it needs without stealing that branch.
  if ! git checkout -B gh-pages; then
    echo "gh-pages is checked out elsewhere; using a detached deployment checkout."
    git checkout --detach
  fi
else
  git init
  git checkout -b gh-pages
fi
# Reuse an existing local deployment checkout without accumulating remotes.
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin https://github.com/abubakrmmarufov-tech/zarbulmasal.git
else
  git remote add origin https://github.com/abubakrmmarufov-tech/zarbulmasal.git
fi

# Copy new build
find "$deployment_dir" -mindepth 1 -maxdepth 1 \
  ! -name .git -exec rm -rf -- {} +
# Copy every emitted entry, including dotfiles, but never copy Git metadata
# from a locally cached/generated artifact into the public Pages checkout.
find "$project_root/build/web" -mindepth 1 -maxdepth 1 \
  ! -name .git -exec cp -R {} . \;

# Refresh the remote before deciding that this deployment is a no-op. Without
# this check, an external gh-pages update could be silently ignored because
# the local deployment checkout still matched the local build.
remote_branch_sha=""
if ! git fetch origin gh-pages >/dev/null 2>&1; then
  if git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
    echo "Refusing Pages deployment because origin/gh-pages could not be refreshed." >&2
    exit 1
  fi
fi
if git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
  remote_branch_sha="$(git rev-parse refs/remotes/origin/gh-pages)"
fi

# Commit and push
git add .
if git diff --cached --quiet; then
  if [[ -n "$remote_branch_sha" && "$(git rev-parse HEAD)" == "$remote_branch_sha" ]]; then
    echo "gh-pages already matches this build."
    verify_published_privacy
    exit 0
  fi
  echo "Refusing to overwrite a changed gh-pages branch without a new local deployment commit." >&2
  exit 1
fi
git commit -m "Deploy audited version with CSP fix"
if [[ -n "$remote_branch_sha" ]]; then
  git push --force-with-lease="refs/heads/gh-pages:$remote_branch_sha" origin HEAD:gh-pages
else
  git push origin HEAD:gh-pages
fi

verify_published_privacy
