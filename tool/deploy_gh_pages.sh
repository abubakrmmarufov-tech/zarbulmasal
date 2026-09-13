#!/usr/bin/env bash
set -e

# Deploy script to push build/web to gh-pages branch locally

# 1. Run prepare script
bash tool/prepare_web_release.sh

# 2. Add worktree for gh-pages if not exists, or just use a temp dir
mkdir -p build/gh-pages
cd build/gh-pages
git init
git checkout -b gh-pages
# Add remote origin
git remote add origin https://github.com/abubakrmmarufov-tech/zarbulmasal.git

# Copy new build
rm -rf *
cp -R ../web/* .

# Commit and push
git add .
git commit -m "Deploy audited version with CSP fix"
git push -f origin gh-pages
