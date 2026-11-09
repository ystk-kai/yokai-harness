# 結果: UI 系スキルの control run 試験 (2026-11-09)

条件と手順は [README.md](README.md) にある。生成 12 回、採点 1 回で、実費は合計 $9.13 (生成 $8.67、採点 $0.46)。

## 結論

**2 スキルは、3 本の brief すべてで control から見た目を動かした。** 盲検の採点では、どの brief でも skill 条件の 2 枚が上位 2 位を、control の 2 枚が下位 2 位を占めた。同じ条件の 2 回はほぼ同じ型になり、ぶれより条件の差のほうがずっと大きい。

ただし、動いた先も 1 つの型にまとまっている。skill 条件 6 枚のうち 5 枚が「濃い緑 (oklch H 150〜160) + 黄の面」、書体はシステムの書体スタックに BIZ UDPGothic か Zen Kaku Gothic New、罫線で区切る左見出し・右本文の 2 段組みで、brief が違っても同じだった。control の既定値から外れはしたが、内容ではなく参照資料から決まる別の既定値に移っている。visual-slop-review 自身が「AI の型を反 AI の型に替えない」と戒めている形に近い。

## 盲検採点

採点者は別プロセスの `claude-opus-5-5`。条件名を伏せた乱数 ID のスクリーンショットと HTML (コメントを除去) を見て、`visual-slop-review/references/web-ui.md` を観点に、5 項目 × 0〜2 で付けた (数値が小さいほど AI っぽくない)。プロンプトは [blind/score-prompt.md](blind/score-prompt.md)、回答の原文は [blind/scores.md](blind/scores.md)、ID と run の対応は [blind/mapping.tsv](blind/mapping.tsv)。

| brief | control (2 回) | skill (2 回) | 採点者の順位 (左ほど AI っぽくない) |
|---|---|---|---|
| a-saas-lp | 9, 8 | 2, 4 | skill-1 → skill-2 → control-2 → control-1 |
| b-admin | 4, 7 | 1, 0 | skill-2 → skill-1 → control-1 → control-2 |
| c-event | 9, 10 | 3, 4 | skill-1 → skill-2 → control-1 → control-2 |
| 平均 | 7.8 | 2.3 | |

採点者は条件を知らないまま、各 brief で 4 枚を「2 系統」に分け、その分け方が条件と完全に一致した。また、a と c の skill 条件 4 枚で配色の定義 (oklch の緑 + 黄) が共通していると自分から指摘した。

## 何が変わったか

スクリーンショットは `shots/<brief>-<条件>-<回>.jpg`、機械的に抜いた特徴は [features.tsv](features.tsv) にある。

| 観点 | control | skill |
|---|---|---|
| 配色 | a: teal + 橙。b: 紺または鮮やかな青の primary、費目ごとの色タグ。c: 黒に近い地 + 銅色・橙の光 + cream の地。色の数は 38〜57 | a・c と b-1: 濃い緑 + 黄の面。b-2 だけ暖色の無彩色 + 朱。色の数は 15〜21 で、全て oklch のトークン |
| 書体 | Noto Sans JP (a は Inter と併用、c は JetBrains Mono と併用)。c は `// ABOUT` のような monospace の eyebrow ラベル | `-apple-system` から始まるシステムの書体スタック。a・c は BIZ UDPGothic か Zen Kaku Gothic New を Web フォントで足し、b は Web フォントを使わない |
| レイアウトの型 | a: hero + スマホの mockup → 悩みのカード 3 列 → 4 機能の 2×2 カード → 数値の帯 → 01/02/03 の手順 → 料金カード → FAQ → フォーム。c: hero → 情報カード → 縦の時間軸 → おすすめカード 3 列 → 会場カード | a: 機能ごとに実物の画面例 (予約枠・CSV の表・SMS・キャンセル待ちの列) を左右に並べる。c: 左見出し・右本文の 2 段組みと罫線、時刻表、LT 4 枠の点線、駅から会場までの点線 |
| カードの並び | 同じ寸法のカード列が各所にある (a のアイコン入りカード、b の KPI カード 4 枚、c の情報カード 4 枚) | ほぼ無い。b は KPI カード列をやめ、予算のメーター 1 つと表だけにした |
| AI っぽい既定値 | 角丸 999px のピル型ボタン (6 枚すべて)、`box-shadow` 6〜12 か所、グラデーション 2〜12 か所、a・c に `backdrop-filter`、b-2 に頭文字入りの色違いアバター。絵文字は 0 | 角丸は最大 2〜34px、影は 0〜6 か所、グラデーション 0〜4 か所 (主に進捗バーの斜線)。絵文字 0 |
| 日本語の組版 | 折り返しの指定はほぼ無い (c-2 の `word-break: break-all` だけ)。a-1 は見出しの一部を `<em>` で色替え | 6 枚とも `line-break: strict`、`overflow-wrap: anywhere`、見出しに `word-break: auto-phrase`。c-2 は傍点 (`text-emphasis`) を使い、見出しの改行位置が「問／いません」と崩れた |

brief 別に見ると、差が最も大きいのは LP (a) とイベント (c)。管理画面 (b) は control も表を主役にしていて差は小さめだが、control の KPI カード 4 枚・ピル型のフィルタ・色タグが skill 側では消えている。

## ぶれ

同じ条件の 2 回は、どの brief でもほぼ同じ型になった (a の control は 2 回とも teal + 橙 + スマホの mockup、c の control は 2 回とも黒 + 橙 + 基板の挿絵)。条件の差に比べてぶれは小さい。skill 条件は brief をまたいでも型がそろっていて、ぶれの小ささは brief を越えた収束でもある。

## 費用と手間

| | 平均の費用 | ターン数 | 読んだもの |
|---|---|---|---|
| control | $0.53 | 1 | なし |
| skill | $0.92 | 9〜12 | 6 回とも 2 つの SKILL.md と蒸留版 5 本 (color-chroma, hallmark, japanese-web-typography, web-ui, prescriptions)。原典は 1 回だけ (hallmark の anatomy.md と patterns.md) |

詳細は [runs.tsv](runs.tsv)。

## この試験の限界

- 採点の観点 (web-ui.md) は skill 条件が生成前に読んだ資料そのものなので、採点は skill 条件に有利に偏る。「control から動いたか」はスクリーンショットだけでも明らかだが、「良くなったか」はこの採点では言えない
- 採点者が 1 人で、生成と同じモデルの系列。人による評価はしていない
- 各条件 2 回、モデル 1 種。skill 条件はスキルを Skill ツールで発火させたのではなく、プロンプトで読むよう指示している。実運用で自動発火したときの効果は測っていない
- skill 条件ではプロンプトに「スキルに従ってデザインを決める」という 1 文が加わる。この文だけで見た目が動く分は切り分けていない
- ツールは Read / Glob / Grep だけで、`chroma-check.py` などのスクリプトは動かせない

## スキルを直す案 (この試験では直していない)

1. **緑 + 黄への収束 (color-chroma.md)**: 計算例が「H 145 の緑」と「黄 `#ffd600` の面に ink を載せる」で、skill 条件の 5/6 がこの組み合わせになった。題材と関係なく、Rust の勉強会でも control が題材から取っていた橙を捨てて緑にしている。計算例の色相を複数に散らすか、「色相はブランド・題材から決め、ここの計算例の色相を流用しない」と明記する
2. **brief をまたいだ収束を tell に足す (visual-slop-review)**: 「同じ作り手の別案件が同じ配色・書体・組みになる」こと自体を構造の tell として web-ui.md か prescriptions.md に足す。単発のレビューでは見えないので、複数案件をまとめて見るときの観点として書く
3. **左見出し・右本文の 2 段組みの多用**: 採点者は skill 条件の a・c でも「同じ並びの繰り返しは既定寄り」と付けた。hallmark の構造選択が 1 つの型に寄っていないか、蒸留版の書き方を確かめる
4. **傍点の扱い (japanese-web-typography.md)**: 傍点は見出しの一部に付けると改行位置が崩れた。使う場面と、付けた語を `auto-phrase` の文節の境界にそろえる注意を足す
5. **再試験の採点**: 生成側が読まない観点 (人の評価、または AgentCraft の試験と同じ指標) で採点し直すと、「良くなったか」まで言える
