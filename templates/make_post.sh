#!/bin/bash
# Usage: ./make_post.sh <spec.json> <output_png_name> [width] [height]
# width/height default to 1080x1350 (feed post). Pass 1080 1920 for a spec
# that sets "template": "reel" (IG Reels/Story canvas).
# Requires: `python -m http.server 8743` already running from the project root.
# Uses the pre-installed Playwright Chromium on Linux/cloud sessions
# ($PLAYWRIGHT_BROWSERS_PATH/chromium), falling back to local Windows Edge otherwise.
set -e
cd "$(dirname "$0")/.."
SPEC="$1"
OUT_NAME="$2"
W="${3:-1080}"
H="${4:-1350}"
PY="$(command -v python3 || command -v python)"
HTML_REL=$("$PY" templates/render_post.py "$SPEC")
HTML_URL="http://localhost:8743/$("$PY" -c "import sys,pathlib; print(pathlib.Path(sys.argv[1]).resolve().relative_to(pathlib.Path('.').resolve()).as_posix())" "$HTML_REL")"
mkdir -p output/graphics
OUT_PATH="$(pwd)/output/graphics/$OUT_NAME"
CACHE_BUST="$(date +%s%N)"

if [ -n "$PLAYWRIGHT_BROWSERS_PATH" ] && [ -x "$PLAYWRIGHT_BROWSERS_PATH/chromium" ]; then
  "$PLAYWRIGHT_BROWSERS_PATH/chromium" --headless=new --disable-gpu --no-sandbox \
    --screenshot="$OUT_PATH" \
    --window-size="$W,$H" --hide-scrollbars --force-device-scale-factor=1 \
    "$HTML_URL?v=$CACHE_BUST"
elif [ -f "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" ]; then
  "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless --disable-gpu --incognito --disk-cache-dir="C:\Windows\Temp\edgecache_${CACHE_BUST}" \
    --screenshot="$(cygpath -w "$OUT_PATH")" \
    --window-size="$W,$H" --hide-scrollbars --force-device-scale-factor=1 \
    "$HTML_URL?v=$CACHE_BUST" 2>&1 | grep "bytes written" || true
else
  echo "No supported headless browser found (checked \$PLAYWRIGHT_BROWSERS_PATH/chromium and local msedge.exe)." >&2
  exit 1
fi

echo "output/graphics/$OUT_NAME"
