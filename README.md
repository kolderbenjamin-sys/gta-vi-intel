# gta.vi.intel content pipeline

Source material and rendering pipeline for the [@gta.vi.intel](https://www.instagram.com/gta.vi.intel/) Instagram account - a fan-run English-language news/concept account about GTA VI (Grand Theft Auto 6).

## Contents

- `*.mp4` - 43 AI-generated concept clips (9:16, Vice City/Leonida), made in Google Labs Flow / Gemini. Fan-made visualizations, not official Rockstar footage.
- `CAPTIONS.md` - captions for each numbered clip.
- `templates/` - HTML/CSS graphic template + render pipeline (`render_post.py`, `make_post.sh`, `make_kenburns_reel.sh`), self-hosted fonts.
- `assets/stills/` - video stills extracted for use as graphic backgrounds.

## Pipeline

1. `python -m http.server 8743` from the repo root (needed for the template renderer to load local images/fonts).
2. `python templates/render_post.py templates/<spec>.json` fills the HTML template.
3. `bash templates/make_post.sh <spec>.json <output>.png` renders it to a 1080x1350 PNG via headless Edge.
4. `bash templates/make_kenburns_reel.sh <input>.png <output>.mp4` turns a graphic into an 8s Ken-Burns zoom reel via ffmpeg.
5. Upload to Cloudinary (`sign-upload` MCP tool + curl direct upload) and schedule via Buffer's MCP tools.

Posting is otherwise operated by Claude Code (locally and via a daily cloud routine) - see the project's Claude memory for the full operating rules, brand voice, and current campaign status.
