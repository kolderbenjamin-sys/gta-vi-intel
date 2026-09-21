#!/bin/bash
# Usage: ./make_post.sh <spec.json> <output_png_name>
# Requires: `python -m http.server 8743` already running from the project root.
set -e
cd "$(dirname "$0")/.."
SPEC="$1"
OUT_NAME="$2"
HTML_REL=$(python templates/render_post.py "$SPEC")
HTML_URL="http://localhost:8743/$(python -c "import sys,pathlib; print(pathlib.Path(sys.argv[1]).resolve().relative_to(pathlib.Path('.').resolve()).as_posix())" "$HTML_REL")"
"/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless --disable-gpu --incognito --disk-cache-dir="C:\Windows\Temp\edgecache_$(date +%s%N)" \
  --screenshot="$(cygpath -w "$(pwd)/output/graphics/$OUT_NAME")" \
  --window-size=1080,1350 --hide-scrollbars --force-device-scale-factor=1 \
  "$HTML_URL?v=$(date +%s%N)" 2>&1 | grep "bytes written" || true
echo "output/graphics/$OUT_NAME"
