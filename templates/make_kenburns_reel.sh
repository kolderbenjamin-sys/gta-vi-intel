#!/bin/bash
# Usage: ./make_kenburns_reel.sh <input.png> <output.mp4> [duration_seconds] [music_file]
# Input should be a 1080x1920 (9:16) PNG - i.e. rendered with "template": "reel"
# in make_post.sh - since this always outputs full-bleed 9:16 for Instagram Reels/Story.
#
# Background music: if music_file is omitted, a random track from assets/music/*.mp3
# is picked (royalty-free, Content-ID-clear tracks only - see assets/music/SOURCES.md).
# A random start offset is used each time so repeated posts using the same track don't
# all open on the same bar. Falls back to silent audio if assets/music/ is empty -
# Instagram Reels reject video-only (no audio stream) files, so never drop -c:a entirely.
set -e
cd "$(dirname "$0")/.."
IN="$1"
OUT="$2"
DUR="${3:-8}"
MUSIC="$4"

if [ -z "$MUSIC" ]; then
  MUSIC=$(ls assets/music/*.mp3 2>/dev/null | shuf -n 1 || true)
fi

if [ -n "$MUSIC" ] && [ -f "$MUSIC" ]; then
  TRACK_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$MUSIC")
  MAX_START=$(python3 -c "print(max(0, int($TRACK_DUR - $DUR - 1)))" 2>/dev/null || echo 0)
  START=$(( RANDOM % (MAX_START + 1) ))
  ffmpeg -y -loop 1 -i "$IN" -ss "$START" -i "$MUSIC" \
    -filter_complex "[0:v]scale=1080:1920,zoompan=z='min(zoom+0.0004,1.07)':d=200:s=1080x1920:fps=25[v];[1:a]afade=t=in:st=0:d=0.5,afade=t=out:st=$((DUR - 1)):d=1,volume=0.85[a]" \
    -map "[v]" -map "[a]" \
    -t "$DUR" -pix_fmt yuv420p -c:v libx264 -crf 20 -c:a aac -b:a 128k -movflags +faststart \
    "$OUT" 2>&1 | tail -3
else
  ffmpeg -y -loop 1 -i "$IN" \
    -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100" \
    -vf "scale=1080:1920,zoompan=z='min(zoom+0.0004,1.07)':d=200:s=1080x1920:fps=25" \
    -t "$DUR" -pix_fmt yuv420p -c:v libx264 -crf 20 -c:a aac -b:a 128k -shortest -movflags +faststart \
    "$OUT" 2>&1 | tail -3
fi
echo "$OUT"
