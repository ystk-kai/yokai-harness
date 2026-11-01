---
tracking: review
reviewed_at: 2026-09-16
review_interval_days: 90
---
# 日本語を含む図解をコードで出す — 描出事故の回避

Mermaid / Graphviz / PlantUML / D2 / 手書き SVG で日本語ラベルを出すときに固有で起きる、
**パースエラー・豆腐 (□) 化・ラベルはみ出し**の事故集。図の内容ではなく描出が壊れる問題を扱う。
既定フォント・既定レンダラがすべて欧文前提なので、英語で通る図解コードがそのまま日本語で壊れる。

図の**構造**の質 (関係性を 1 つ選ぶ / 要素過多 / 矢印の文法エラー / 一枚 raster を生成しない) は
`visual-slop-review/references/slides-diagrams.md` が担当する。ここでは繰り返さない。
本文テキストの組版は姉妹ファイル [japanese-web-typography.md](japanese-web-typography.md)。

確度: **[仕様]** 構文仕様・SVG/CSS/Unicode 標準 / **[Issue]** 上流の未解決 Issue・実装バグ (最も腐りやすい) /
**[論文]** 査読論文・プレプリント / **[通説]** 複数の実務記事で一致 / **[経験則]** 一次出典なし /
**[不在確認]** 探した上で「規定が存在しない」ことを確認したもの。

## Contents

[まず押さえる](#まず押さえる) · [Mermaid](#mermaid-構文とレンダラ) · [フォント指定](#ツール別のフォント指定) ·
[手書き SVG](#手書き-svg-に日本語を置く) · [ラベル幅](#ラベル幅は推定せず測る) ·
[検証ゲート](#検証ゲート) · [棚卸しの当たり先](#棚卸しの当たり先) · [この文書の範囲外](#この文書の範囲外)

## まず押さえる

1. **全角括弧ではなく半角括弧が構文を壊す**。Mermaid のノードラベル中の `(` `)` は形状トークン
   (parallelogram 等) として食われる。`A[処理(Gzip)]` はパースエラー。**ラベルは常にクォートする**
   (`A["処理 (Gzip)"]`) [仕様]
2. **図解ツールの既定フォントに CJK グリフは 1 つも無い**。Mermaid は
   `"trebuchet ms", verdana, arial, sans-serif`、D2 は Source Sans Pro、Graphviz は Times 系。
   何も指定しなければ環境のフォールバック任せで、CI や Docker では豆腐になる [仕様]
3. **フォント指定は「全ロールに」当てる**。Graphviz は `graph` / `node` / `edge` の 3 つ全部、
   D2 は `--font-regular` / `--font-bold` / `--font-italic` / `--font-semibold` 全部。
   一部だけ指定すると残りが fallback して同じ図の中で豆腐が混ざる [仕様]
4. **SVG はフォントを埋め込まない**。`<text>` は font-family を**参照として持つだけ**なので、
   SVG 出力は閲覧環境依存。PlantUML は PNG ならフォント指定が効くが **SVG は効かない** [仕様]
5. **ラベル幅は推定しない。レンダリングして測る**。日本語は文字数がむしろ減るのに表示幅は増えるので、
   文字数ベースの見積もりは必ず外れる (→ [ラベル幅](#ラベル幅は推定せず測る))
6. **レンダラのバージョンで挙動が変わる**。GitHub / GitLab / VS Code 拡張 / mermaid-cli は
   それぞれ別バージョンを載せている。**最小公倍数の構文で書く** [Issue]
   <https://gitlab.com/gitlab-org/gitlab/-/work_items/554889>
7. **図解を 1 枚の画像として生成させない** — 禁止の根拠は `slides-diagrams.md` が持つ。
   日本語で特に確実である理由 (汎用 T2I は正当な CJK 文字を生成できない) だけここに置く [論文]
   <https://arxiv.org/pdf/2404.05212> / <https://arxiv.org/html/2406.10208>

## Mermaid: 構文とレンダラ

- **クォートが基本形**。`A["処理 (Gzip)"]`。クォート内にさらに `"` や `#` を出すときは
  **Mermaid 独自のエンティティ記法 `#quot;` / `#35;`** を使う。**`&quot;` / `&#35;` は Mermaid の
  エスケープ構文ではない** (公式は "Numbers given are base 10, so `#` can be encoded as `#35;`" と
  規定する。HTML エンティティが通って見えることがあるのは htmlLabels 経由の偶然で、仕様ではない)
  [仕様] <https://mermaid.js.org/syntax/flowchart.html>
- **ただしエンティティ回避は万能ではない**。前処理層に先に解釈されて別のエラーになることがある
  (VS Code の markdown-mermaid が `&lpar;` を先に処理する報告) [Issue]
  <https://github.com/mjbvz/vscode-markdown-mermaid/issues/273>
  → **エンティティに頼るより、括弧を全角 `（）` にするか、ラベルから括弧を外すほうが移植性が高い**
- **改行は `<br/>`**。10.x は `\n` を改行として扱うが 11.x は literal。Markdown String 記法も
  10.x / 11.x で非互換。`<br/>` だけがバージョン差を跨ぐ [Issue]
  <https://gitlab.com/gitlab-org/gitlab/-/work_items/554889>
- **CJK の幅計算が壊れている**。2023-10 起票・現在も Open (Status: Triage のまま停滞) [Issue]
  <https://github.com/mermaid-js/mermaid/issues/4950>
- **長いラベルがノードから切れる**。foreignObject の幅がラベルに追従しない報告があり (v11.5.0 / Chrome、
  Open)、区切りの無い長い連続文字列で顕在化する。**日本語は分かち書きが無いぶん全体が 1 語相当**に
  なりやすく、この条件を踏みやすい [Issue] <https://github.com/mermaid-js/mermaid/issues/6424>
- **Web フォント読み込み前にレンダリングされると fallback 幅でノードサイズが確定し、
  差し替え後に溢れる**。Web フォントを使うなら `document.fonts.ready` の後に初期化する
  [経験則] (一次出典なし。症状から逆算した回避策)
- **`htmlLabels` は出力経路で選ぶ** — 既定の `true` は HTML ラベルを `<foreignObject>` で描くため
  ブラウザでは折り返しが効く一方、**ラスタライザの多くが foreignObject 未対応**で PNG 化すると
  ラベルが消える。**ブラウザ表示なら `true` のまま、PNG 化を経由するなら `false` + `fontFamily` の
  明示**、と経路で切り替える。`false` 側は生の SVG `<text>` になるので CJK フォント指定が必須
  [経験則] (下の「手書き SVG」節の foreignObject の項と同じ機序)
- **mermaid-cli / Docker で日本語が消える**のは実行環境の同梱フォント不足。CJK フォントの追加は
  Issue #93 → PR #132 で入った経緯があるが、**使うイメージに実際に入っているかは毎回確認する**
  (`fc-list | grep -i cjk`)。バージョンで変わる [Issue]
  <https://github.com/mermaid-js/mermaid-cli/issues/93>

## ツール別のフォント指定

| ツール | 指定 | 落とし穴 |
|---|---|---|
| Mermaid | config の `fontFamily` に CJK 書体を追加 | 既定は CJK グリフ皆無。`htmlLabels: false` にしない |
| Graphviz | UTF-8 保存 + `charset="UTF-8"`、`graph`/`node`/`edge` の 3 つに `fontname="Noto Sans CJK JP"` | `node` だけだとエッジ・グラフのラベルが豆腐。fontname にコロン不可 (空白で修飾)。代替 IPAexGothic |
| PlantUML | `skinparam defaultFontName "Noto Sans CJK JP"`、CLI は `java -Dfile.encoding=UTF-8 -jar plantuml.jar -charset UTF-8` | **PNG では効くが SVG では効かない** — font-family 名が text に埋まるだけで閲覧環境依存 |
| D2 | `--font-regular` / `--font-bold` / `--font-italic` / `--font-semibold` すべてに CJK ttf | 一部だけ渡すと残りのウェイトが fallback |

出典: <https://graphviz.org/faq/font/> / <https://mseeeen.msen.jp/plantuml-server-svg-japanese-font-issue/> /
<https://d2lang.com/tour/fonts/> [すべて仕様・公式ドキュメント]

**配布形態**: 図の**ソースはテキスト記法のまま保つ** (`slides-diagrams.md` の「最終版は editable
vector + 通常のテキストレンダリング」と同じ立場。ラスタに焼くと検索性とアクセシビリティを失う)。
そのうえで、**閲覧環境のフォントを自分で握れない配布先**では SVG の `<text>` が化けるので、
`@font-face` + base64 data URI を**サブセット化して埋めた SVG** を既定にする。
埋め込みができない経路に限って PNG に落とす。text-to-path は確実だが編集性・検索性・
アクセシビリティを失うので最後の手段。

## 手書き SVG に日本語を置く

LLM が SVG を直書きするときに最も壊れる領域。

- **自動折り返しが無い** [仕様]。SVG 1.1 の `<text>` に wrapping は無く、content area 未指定は
  「無限幅の矩形」扱いなので、長いラベルはそのまま溢れる。SVG 2 の `inline-size` / `shape-inside` は
  実装が乏しい <https://svgwg.org/svg2-draft/text.html>
  → **改行は自分で `<tspan>` に分けて書く**。Mermaid の `<br/>` も同じ。日本語は分かち書きが無く
  自動処理では助詞の途中で折れるので、**切る位置は文節の境界**にする。実務則: 「〜のは」「〜ので」
  「〜には」のような接続部は上の行に残す / 最終行を 1〜2 文字にしない [通説]
  <https://tsutawarudesign.com/yomiyasuku5.html>
  (CSS が効く HTML 本文側の折り返しは japanese-web-typography.md の「組版 CSS」。
  `<tspan>` と `<br/>` の手切りには CSS の禁則が効かないので、この節が受け持つ)
- **`textLength` を日本語に使わない** [仕様]。wrapping area 未定義時のみ適用され、字間を強制的に
  伸縮するので字送りが崩れる
- **`foreignObject` は避ける**。bbox が positioning rectangle なので内容が溢れうる上、ラスタライザの
  未対応が多い。Mermaid の foreignObject ラベルが一部 Windows / Linux で誤計測し、ノード間が
  数千 px 離れる報告がある [Issue] <https://github.com/jgraph/drawio/issues/3350>
- **PNG 化で日本語が黙って消える**。cairosvg 等はフォント解決に失敗しても警告を出さずに fallback する
  [Issue] <https://github.com/Kozea/CairoSVG/issues/324> → **resvg / resvg-js のほうが堅い**

## ラベル幅は推定せず測る

英語圏の直感が逆向きに外れる箇所なので、前提から直す。

- **誤**: 「日本語はラベルが長いから幅を食う」。実際は**文字数はむしろ 20〜40% 減る** [通説]
- **正**: 1 文字あたりの前進幅が大きい (全角 ≒ 1em ≒ 欧文小文字の約 2 倍) ため、**文字数が減っても
  表示幅は増える**。UAX #11 が Wide (W) を "All other characters that are *always* wide" と定義し、
  §1 Overview が「東アジアの**固定ピッチ**フォントでは全角か半角のいずれか」とする
  <https://www.unicode.org/reports/tr11/>
  ただし **UAX #11 が規定するのは幅の分類であって「1em」や「2 倍」という寸法ではない**。
  固定ピッチ前提の近似として使う [通説]
- **短いラベルほど相対伸長が大きい** [通説] (W3C i18n の解説記事。規格ではない)
  <https://www.w3.org/International/articles/article-text-size.en>
  W3C の伸長率表は原文 10 字以下で 200〜300%、70 字超で 130%。
  → **ノード内ラベル・ボタン・凡例という短い要素が最も溢れる**。長い説明文ではない
- **実務ルール**: 全角文字数 × font-size を**保守的な下限見積もり**としてだけ使い、
  レイアウトの可否はレンダリング結果で判定する。日英専用の伸長率表は W3C に存在しない [不在確認]

## 検証ゲート

コードを読むだけではレイアウトバグを検出できない。**レンダリングして画像を見る**のが最低条件 [通説]。

1. **本番と同じレンダラを実行し、非ゼロ終了を不合格にする** (`mmdc` / `dot` / `plantuml` / `d2`)。
   自前の正規表現バリデータは本番レンダラと必ず乖離するので作らない
2. **出力 PNG に豆腐 (U+FFFD / .notdef) が無いか**を確認する。フォント解決の失敗は無言で起きる
3. **テキストがノード矩形に収まっているか**を目視または bbox で確認する
4. 図の意味の検証 (要素の過不足・関係の向き) は、レンダリング画像を VLM に渡して批評させる
   [経験則] (生成 → レンダリング → 批評 → 修正を回す形。記号的レンダリングが raster 直生成に
   優越することは DiagrammerGPT が示すが、この批評ループ自体の出典ではない
   <https://arxiv.org/abs/2310.12128>)

1 と 2 は決定論的なので自動ゲートにできる。3・4 は判断が要るので助言に留める。

## 棚卸しの当たり先

期限が来たら、腐りやすいこの 5 点だけ再検証する。仕様に根ざす記述 (括弧のトークン衝突 / SVG が
フォントを埋め込まないこと / SVG 1.1 に自動折り返しが無いこと / 既定フォントに CJK が無いこと /
T2I が CJK を出せないこと) は据え置いてよい。腐りやすい半分が Mermaid の未解決 Issue と
レンダラのバージョン別挙動に依存するため、間隔は 90 日とする。

1. mermaid CJK 幅計算 Issue #4950 が Close したか <https://github.com/mermaid-js/mermaid/issues/4950>
2. 長いラベルの切れ Issue #6424 が Close したか / 3. mermaid の改行記法 (`\n` / `<br/>` / Markdown String) の
   バージョン別挙動 — GitHub / GitLab が載せている mermaid のバージョン
4. mermaid-cli / Docker イメージの同梱フォント (fonts-takao) が維持されているか
5. SVG 2 の `inline-size` / `shape-inside` のブラウザ・ラスタライザ実装状況 (MDN / caniuse)

## この文書の範囲外

- **図の構造・内容の質** (関係性の選択、要素過多、矢印の意味、一枚 raster の禁止) —
  `visual-slop-review/references/slides-diagrams.md`
- **本文テキストの組版** (明朝化・合成斜体・折り返し・行高・Web フォント配信) —
  [japanese-web-typography.md](japanese-web-typography.md)
- **チャートの配色・軸・凡例の設計** — built-in の `dataviz` スキル
- **紙面組版の規格** (JIS X 4051 / JIS Z 8301 / JLREQ の図版配置) — いずれも版面とページを持つ
  書籍・規格票が適用対象で、Mermaid / SVG には版面が無い。持ち込まない
- **学会投稿規定の図中文字サイズ** — 規定を置く学会は 7〜8pt に集中するが、規定を持たない学会も多く
  横断的な統一値は存在しない。媒体ローカルの要求として都度確認する
