#!/usr/bin/env bash
set -e

mkdir -p tool/www/zarbulmasal
rsync -av --delete build/web/ tool/www/zarbulmasal/
cd tool/www
echo "Starting local server at http://localhost:8080/zarbulmasal/"
python3 -m http.server 8080
