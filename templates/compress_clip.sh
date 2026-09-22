#!/bin/bash
# Usage: ./compress_clip.sh <input.mp4> <output.mp4>
# Re-encodes a source clip for social delivery. The 43 source clips are raw
# AI-video-generator output at ~7Mbps, far more than IG needs (it re-compresses
# on upload anyway) - crf 28 cuts file size ~65-70% with no visible quality
# loss, which matters directly for Cloudinary bandwidth/storage credits.
set -e
cd "$(dirname "$0")/.."
IN="$1"
OUT="$2"
ffmpeg -y -i "$IN" -c:v libx264 -crf 28 -preset medium -c:a aac -b:a 96k "$OUT" 2>&1 | tail -3
echo "$OUT"
