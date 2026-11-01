#!/usr/bin/env python3
"""assets/src/*.svg に日本語フォントのサブセットを埋め込み、assets/*.svg を書き出す。

SVG の <text> はフォントを参照するだけで、GitHub の閲覧者の環境に日本語フォントがあるとは限らない。
そこで図に出てくる字だけを Noto Sans JP (SIL OFL 1.1) から切り出し、@font-face に WOFF で埋める。
フォント本体 (約 10MB) はリポジトリに置かない。取得元と使い方:

    curl -L -o NotoSansJP.ttf 'https://github.com/google/fonts/raw/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf'
    python3 assets/build.py NotoSansJP.ttf

fontTools が要る (pip install fonttools)。ライセンスは assets/fonts/OFL.txt。
"""
import base64
import io
import pathlib
import re
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

HERE = pathlib.Path(__file__).resolve().parent
WEIGHTS = (400, 700)


def text_chars(svg: str) -> set[str]:
    # <text> と <tspan> の中身だけを拾う (属性やコメントの字は含めない)
    chars = set()
    for m in re.finditer(r"<(?:text|tspan)[^>]*>([^<]*)", svg):
        body = m.group(1).replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
        chars.update(body)
    return chars


def woff_subset(font_path: str, weight: int, chars: set[str]) -> str:
    font = TTFont(font_path)
    font = instancer.instantiateVariableFont(font, {"wght": weight})
    opts = subset.Options()
    opts.flavor = "woff"
    opts.layout_features = ["*"]
    opts.name_IDs = ["*"]  # ライセンス表記 (name table) を残す
    sub = subset.Subsetter(opts)
    sub.populate(text="".join(sorted(chars)))
    sub.subset(font)
    buf = io.BytesIO()
    font.flavor = "woff"
    font.save(buf)
    return base64.b64encode(buf.getvalue()).decode()


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    for src in sorted((HERE / "src").glob("*.svg")):
        svg = src.read_text(encoding="utf-8")
        chars = text_chars(svg)
        faces = "\n".join(
            f'    @font-face {{ font-family: "YokaiJP"; font-weight: {w}; '
            f'src: url(data:font/woff;base64,{woff_subset(sys.argv[1], w, chars)}) format("woff"); }}'
            for w in WEIGHTS
        )
        out = HERE / src.name
        out.write_text(svg.replace("/*@FONTS@*/", faces.lstrip()), encoding="utf-8")
        print(f"{out.relative_to(HERE.parent)}: {len(chars)} 字, {out.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
