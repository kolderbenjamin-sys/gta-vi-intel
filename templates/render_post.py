"""Fill a post template with content. Usage: called with a JSON spec file.

spec.json fields: bg_image (path, forward slashes), tag, tag_color (cyan|pink|yellow),
kicker, headline, subtext, footer, out (output html path),
template (optional: "feed" [default, 1080x1350] or "reel" [1080x1920, IG-UI-safe]).
"""
import json
import sys
from pathlib import Path

TEMPLATES = {
    "feed": Path(__file__).parent / "news_template.html",
    "reel": Path(__file__).parent / "reel_template.html",
}

PROJECT_ROOT = Path(__file__).parent.parent


def render(spec_path: str):
    spec = json.loads(Path(spec_path).read_text(encoding="utf-8"))
    template_path = TEMPLATES[spec.get("template", "feed")]
    html = template_path.read_text(encoding="utf-8")

    # site-root-relative URL so it loads over the local http server (file:// is blocked as mixed content)
    bg_path = Path(spec["bg_image"]).resolve()
    bg = "/" + bg_path.relative_to(PROJECT_ROOT).as_posix()

    replacements = {
        "{{BG_IMAGE}}": bg,
        "{{TAG}}": spec.get("tag", "NEWS"),
        "{{TAG_COLOR}}": spec.get("tag_color", ""),
        "{{KICKER}}": spec.get("kicker", "GTA 6 INTEL"),
        "{{HEADLINE}}": spec.get("headline", ""),
        "{{SUBTEXT}}": spec.get("subtext", ""),
        "{{FOOTER}}": spec.get("footer", "SWIPE FOR MORE · GTA.VI.INTEL"),
    }
    for k, v in replacements.items():
        html = html.replace(k, v)

    out_path = Path(spec["out"])
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(html, encoding="utf-8")
    print(str(out_path.resolve()))


if __name__ == "__main__":
    render(sys.argv[1])
