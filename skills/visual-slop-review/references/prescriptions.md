---
tracking: review
reviewed_at: 2026-07-12
review_interval_days: 180
---
# 処方箋 — slop を避けて「意図のあるデザイン」にする

3 系統の調査 (計測研究・デザイナーの一次記事・学術ソース) で一致した実践。フェーズ順に適用する。個別の tell への対応は web-ui.md / slides-diagrams.md / images.md を参照。

## 1. 生成前 — 制約を先に固定する

- **productive friction を置く** — 対象・audience・地域文化・その画面の単一目的を文章化し、対照的な複数 moodboard から方向を選んでから生成する。参照は Behance/Dribbble だけでなく書籍・映画・建築・material culture からも集める (distributional convergence への対抗)
- **brand context と design tokens を先に渡す** — palette 4-6 色、display/body などの type role、spacing scale、radius と shadow の用途を明文化してから生成する。shadcn を使うなら color token・radius・shadow depth を改造し、非デフォルト variant を使う
- **明示的なネガティブ制約** — 「Inter/Roboto/Arial 禁止」「白背景に紫グラデ禁止」「3 boxes with icons 禁止」のように、避けたいデフォルトを prompt に書く
- **アクセシビリティを明示** — 「WCAG AA を満たせ」(通常文字 4.5:1、大文字 3:1) を指示に含める。比が足りない色は彩度を削らず明度で直す (色相別の上限は `ui-design` の `references/color-chroma.md`)
- **plan → review の 2 パス** — 実装前に token 案 (色 4-6 個の hex・書体の役割・layout 案・原則) を書き、brief と突き合わせる。似た依頼でも同じ案になる部分は既定値なので直し、何をなぜ変えたかを書いてからコードに入る (Anthropic frontend-design 2026-09 改訂)

## 2. 設計中 — 判断を content に接続する

- **書体は名前でなく役割で選ぶ** — 実コピーで display と body の組み合わせを比較し、サイズ・ウェイト・spacing の明確な階層を作る。Inter を禁止するのではなく body 用など意図した role に限定する。行長は既定で 80 文字未満 (欧文の目安。serif の本文は少し長くてよく、行送りを sans より広めに)
- **色は少数の意味ある role へ** — dominant / secondary / accent に配分し、accent は主要 CTA 等に限定。decorative gradient text は外す
- **layout は content から導く** — generic slogan ではなく「具体的 claim + proof」で hero を組む。情報の関係はまず proximity・余白・typography で示し、card は独立した操作/比較単位だけに使う (nested cards は平坦化)
- **非対称を意図的に使う** — AI は均等・対称に寄るため、視覚重量を重要度に合わせて崩すだけで「意図」が出る。ただし 1 つの layout primitive にコミットして反復する (スタイル混在はしない)
- **icon と motion に採用理由を要求する** — icon は単一 family。絵文字は brand voice と一致する場合のみ。animation は状態変化・連続性・注意誘導のどれを担うか説明できなければ削除
- **記号より構造** — 紫グラデ等の「記号としての AI っぽさ」を消しても、意味の薄さ・文脈無視という「構造としての AI っぽさ」は残る。言語化されていないこだわりの言語化が本体

## 3. 生成後 — 評価を分離する

- **生成と評価を別工程にする** — 5-second test (第一印象と brand 整合)、first-click test (行動)、preference test (2-3 案比較)。比較時は layout・palette・typography のうち一度に一変数だけ変える
- **2 ステップ法** — まず「AI っぽさ全開で」作らせてから「その要素を全部排除して作り直せ」と指示する。悪い要素が言語化されるため精度が上がる
- **チェッカーの併用** — Web UI は ai-design-checker (Krebs) のような決定的 DOM チェックで機械検査できる

## 適用の注意 (ja-slop-review と同じ原則)

- 「アンチ AI テンプレ」に乗り換えない。非対称も個性的フォントも、uniformity を壊す手段であって目的ではない
- 文書種別・媒体の予算内で崩す。ブランドガイドラインが既にあるなら、それへの帰属が最優先の処方 (Material / Apple HIG / 自社規範)
- slop パターンは「悪」ではなく「無意図」の指標。意図して選んだ紫グラデは slop ではない

## 出典

- https://arxiv.org/html/2603.13036 (productive friction / 均質化研究)
- https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md / https://claude.com/blog/improving-frontend-design-through-skills (tokens 先行・役割ベースの選定)
- https://www.smashingmagazine.com/2022/10/typographic-hierarchies/ / https://www.smashingmagazine.com/2025/08/automating-design-systems-tips-resources/
- https://www.nngroup.com/articles/color-enhance-design/ / https://www.w3.org/WAI/WCAG22/Techniques/general/G18 / https://www.nngroup.com/articles/animation-usability/ / https://www.nngroup.com/articles/testing-visual-design/
- https://buildtaste.com/how-to-make-ai-generated-websites-look-designed (content-driven layout)
- https://www.creativebloq.com/ai/everything-looks-the-same-now-what (参照の多様化)
- https://www.adriankrebs.ch/blog/design-slop/ (1 primitive へのコミット) / https://github.com/AdrianKrebs/ai-design-checker
- https://www.developersdigest.tech/blog/ai-design-slop-and-how-to-spot-it (shadcn トークン改造) / https://www.925studios.co/blog/ai-slop-web-design-guide (実コンテンツ駆動)
- 日本語: https://note.com/sakamototakuma/n/n0cf7bad2d9a8 (紙面モード・極端なトーンへのコミット) / https://qiita.com/kenimo49/items/8aaa2bf0d25c704637ae (非対称) / https://zenn.dev/tokium_dev/articles/design-ai-datsu-ai-poi (記号より構造) / https://note.com/hiramatsu_ai/n/n0dcba22e5c39 (2 ステップ法)
