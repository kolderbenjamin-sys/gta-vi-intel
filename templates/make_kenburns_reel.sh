#!/bin/bash
# Usage: ./make_kenburns_reel.sh <input.png> <output.mp4> [duration_seconds]
# Input should be a 1080x1920 (9:16) PNG - i.e. rendered with "template": "reel"
# in make_post.sh - since this always outputs full-bleed 9:16 for Instagram Reels/Story.
set -e
cd "$(dirname "$0")/.."
IN="$1"
OUT="$2"
DUR="${3:-8}"
ffmpeg -y -loop 1 -i "$IN" \
  -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100" \
  -vf "scale=1080:1920,zoompan=z='min(zoom+0.0004,1.07)':d=200:s=1080x1920:fps=25" \
  -t "$DUR" -pix_fmt yuv420p -c:v libx264 -crf 20 -c:a aac -b:a 128k -shortest -movflags +faststart \
  "$OUT" 2>&1 | tail -3
echo "$OUT"
