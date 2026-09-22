# gta.vi.intel content pipeline

Source material and rendering pipeline for the [@gta.vi.intel](https://www.instagram.com/gta.vi.intel/) Instagram account - a fan-run English-language news/concept account about GTA VI (Grand Theft Auto 6).

## Contents

- `*.mp4` - 43 AI-generated concept clips (9:16, Vice City/Leonida), made in Google Labs Flow / Gemini. Fan-made visualizations, not official Rockstar footage.
- `CAPTIONS.md` - captions for each numbered clip.
- `templates/` - HTML/CSS graphic template + render pipeline (`render_post.py`, `make_post.sh`, `make_kenburns_reel.sh`), self-hosted fonts.
- `assets/stills/` - video stills extracted for use as graphic backgrounds.

## Pipeline

1. `python -m http.server 8743` from the repo root (needed for the template renderer to load local images/fonts).
2. `python templates/render_post.py templates/<spec>.json` fills the HTML template (`"template": "feed"` [default] or `"reel"` in the spec picks the canvas - see below).
3. `bash templates/make_post.sh <spec>.json <output>.png [width height]` renders it to a PNG via a headless browser - the pre-installed Playwright Chromium on Linux/cloud sessions (`$PLAYWRIGHT_BROWSERS_PATH/chromium`), or local Windows Edge otherwise. Defaults to 1080x1350 (feed); pass `1080 1920` for a `"template": "reel"` spec.
4. `bash templates/make_kenburns_reel.sh <input>.png <output>.mp4` turns a 1080x1920 graphic into an 8s Ken-Burns zoom reel via ffmpeg. Input should always be the `reel` template output - Reels/Stories need full 9:16, not the 4:5 feed-post ratio.
5. Upload to Cloudinary (`sign-upload`/`upload-asset` MCP tools) and schedule via Buffer's MCP tools.

Posting is otherwise operated by Claude Code (locally and via a daily cloud routine) - see the project's Claude memory for the full operating rules, brand voice, and current campaign status.

## Instagram resolutions & UI-safe zones

Two different canvases, picked via the spec's `"template"` field:

| Use | Canvas | Template | `make_post.sh` size |
|---|---|---|---|
| Feed post (static image) | 1080x1350 (4:5) | `news_template.html` (`"template": "feed"`, default) | `1080 1350` |
| Reel / Story (video or image) | 1080x1920 (9:16) | `reel_template.html` (`"template": "reel"`) | `1080 1920` |

**Never render a Reel/Story at 4:5 and let Instagram pillarbox it** - always use the `reel` template so the output is native 9:16.

The `reel` template keeps all text/logo content inside a safe zone clear of Instagram's own app UI, which overlays the video and would otherwise cover it:

- **Top ~140px**: mute/audio icon area.
- **Bottom ~340px**: caption text, username, audio ticker, "..." menu.
- **Right ~180-236px**: like/comment/share/remix/more icon column.

These margins are based on Instagram's published Reels/Story design guidance and were verified by rendering `templates/test_reel_spec.json` end-to-end (both the static frame and the worst-case last frame of a Ken-Burns zoom at max 1.07x) - text and watermark stay fully clear of all three zones in both cases. They have not been checked against a live post inside the actual Instagram app; if something looks off there, tighten the margins in `templates/reel_template.html` (`.brand`, `.tag`, `.content` positions) rather than the feed template, which uses different, unconstrained margins since feed posts have no persistent overlay UI.
