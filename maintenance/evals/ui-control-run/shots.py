"""html/*.html を 1280px 幅で全ページ撮影し、幅 640px の JPEG に縮めて shots/ に置く。"""
import glob, os, pathlib, sys
from playwright.sync_api import sync_playwright
from PIL import Image

here = pathlib.Path(__file__).resolve().parent
src = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else here / "html"
out = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else here / "shots"
out.mkdir(exist_ok=True)
MAX_H = 4800  # 縮小後の高さの上限 (それ以上は切る)
with sync_playwright() as p:
    # インストール済みの Playwright と同梱ブラウザの版がずれている環境向けに、既存の Chromium を明示できるようにする
    exe = os.environ.get("CHROME") or next(iter(sorted(glob.glob(os.path.expanduser("~/.cache/ms-playwright/chromium-*/chrome-linux*/chrome")))[-1:]), None)
    b = p.chromium.launch(executable_path=exe)
    pg = b.new_page(viewport={"width": 1280, "height": 800})
    for f in sorted(src.glob("*.html")):
        pg.goto(f.as_uri(), wait_until="networkidle")
        pg.wait_for_timeout(800)
        tmp = out / (f.stem + ".png")
        pg.screenshot(path=str(tmp), full_page=True)
        im = Image.open(tmp).convert("RGB")
        im = im.resize((640, round(im.height * 640 / im.width)), Image.LANCZOS)
        if im.height > MAX_H:
            im = im.crop((0, 0, 640, MAX_H))
        im.save(out / (f.stem + ".jpg"), quality=72, optimize=True)
        tmp.unlink()
        print(f.stem, im.size)
    b.close()
