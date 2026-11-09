"""HTML から見た目の既定値に関わる特徴を機械的に抜く。出力は TSV。"""
import pathlib, re, sys, unicodedata

here = pathlib.Path(__file__).resolve().parent
src = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else here / "html"

def hexes(css):
    return set(h.lower() for h in re.findall(r"#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b", css))

def colors(css):
    # hex に加えて oklch() / rgb() / hsl() の色指定も数える
    fn = set(re.sub(r"\s+", " ", m).lower() for m in re.findall(r"(?:oklch|oklab|rgba?|hsla?)\([^)]*\)", css))
    return len(hexes(css)) + len(fn)

def oklch_purple_blue(css):
    n = 0
    for l, c, h in re.findall(r"oklch\(\s*([\d.]+%?)\s+([\d.]+)\s+([\d.]+)", css):
        if float(c) >= 0.08 and 255 <= float(h) <= 310: n += 1
    return n

def is_emoji(ch):
    o = ord(ch)
    return (0x1F300 <= o <= 0x1FAFF) or (0x2600 <= o <= 0x27BF and unicodedata.category(ch) == "So")

def purple_blue(css):
    # 色相 230〜290 度で彩度のある色の数
    n = 0
    for h in hexes(css):
        h = h[1:]
        if len(h) == 3: h = "".join(c * 2 for c in h)
        r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
        mx, mn = max(r, g, b), min(r, g, b)
        if mx - mn < 0.2: continue
        if mx == r: hue = (60 * ((g - b) / (mx - mn))) % 360
        elif mx == g: hue = 60 * ((b - r) / (mx - mn)) + 120
        else: hue = 60 * ((r - g) / (mx - mn)) + 240
        if 230 <= hue <= 290: n += 1
    return n

cols = ["file", "bytes", "fonts", "gfonts", "colors", "purple_blue", "gradients", "emoji",
        "radius_max_px", "box_shadow", "backdrop_blur", "italic", "serif_jp", "palt/feature", "line_break_rule", "grid_repeat3"]
print("\t".join(cols))
for f in sorted(src.glob("*.html")):
    t = f.read_text(encoding="utf-8")
    css = " ".join(re.findall(r"<style[^>]*>(.*?)</style>", t, re.S)) + " ".join(re.findall(r'style="([^"]*)"', t))
    body = re.sub(r"<style.*?</style>|<script.*?</script>|<[^>]+>", " ", t, flags=re.S)
    fams = re.findall(r"font-family\s*:\s*([^;}]+)", css)
    fams += [v for _, v in re.findall(r"--(font[\w-]*)\s*:\s*([^;}]+)", css)]
    first = sorted(set(x.split(",")[0].strip().strip("'\"") for x in fams if not x.strip().startswith("var(")))
    gf = re.findall(r"fonts\.googleapis\.com/css2?\?([^\"']+)", t)
    gfam = sorted(set(m.replace("+", " ") for g in gf for m in re.findall(r"family=([^:&]+)", g)))
    radii = [float(x) for x in re.findall(r"border-radius\s*:\s*([\d.]+)px", css)]
    row = [f.stem, str(len(t.encode())), "|".join(first), "|".join(gfam), str(colors(css)), str(purple_blue(css) + oklch_purple_blue(css)),
           str(len(re.findall(r"(?:linear|radial|conic)-gradient", css))),
           str(sum(1 for ch in body if is_emoji(ch))),
           str(max(radii) if radii else 0), str(len(re.findall(r"box-shadow", css))),
           str(len(re.findall(r"backdrop-filter", css))), str(len(re.findall(r"font-style\s*:\s*italic|<em>|<i>", t))),
           str(len(re.findall(r"Mincho|明朝|Serif JP|serif", css))),
           str(len(re.findall(r"font-feature-settings|palt", css))),
           str(len(re.findall(r"line-break|word-break|overflow-wrap|text-wrap|auto-phrase", css))),
           str(len(re.findall(r"repeat\(\s*3\s*,", css)))]
    print("\t".join(row))
