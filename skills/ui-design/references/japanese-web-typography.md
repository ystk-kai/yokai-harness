---
tracking: review
reviewed_at: 2026-10-23
review_interval_days: 90
---
# 日本語 Web タイポグラフィ — 英語圏デザインを持ち込むときの補正

このスキルが索引する原典 4 本 (`awesome-design-md` / `hallmark` / `community-group` / `design.md`) は
すべて英語圏の成果物で、日本語組版を前提にしていない (原典 clone 全文を `japan|CJK|明朝|日本語` で
grep した実測。hallmark で当たるのは写真ライブラリの題 1 件だけで、組版規則の記述は無い。gate 66 が回転した縦書きを装飾として挙げるのみ)。
そのまま日本語 UI に適用すると、本文が明朝になる・強調が合成斜体で崩れる、といった
日本語圏でしか出ない事故を起こす。
日本語を含む UI を生成・改修するときは、雛形や生成規律より**先に**この文書を当てる。

`hallmark` との関係 (原典 clone で確認済み):

- **衝突は 1 点だけ: editorial genre の italic 許容範囲**。`skills/hallmark/references/genres/editorial.md` の
  § Allowed here が "italic inside running body copy" を挙げ、**本文中の italic を明示的に許可している**
  (見出しの 1 語だけ italic は gate 38i で Floor、1 語を色・太さで立てるのは 38iii で Reflex。どちらも禁止)。
  日本語ではこれが合成斜体になるので、**日本語本文ではこの許可を使わない**
- **合成を切る規則は同じ向き** — hallmark の `references/fonts.md` は "Never synthesise bold or italic:
  `font-synthesis: none`" とする。italic 側はこの文書の対策と一致する。ただし一括の `none` は太字の合成も切るので、
  日本語の Bold フェイスを配信しないなら強調が消える (→ 症状 3)。`theme.mjs scaffold` の base.css は `h1, h2, h3` に一括の
  `font-synthesis: none` を書くので、scaffold を使うなら日本語見出しの 700 を配信するか、`:lang(ja)` で `font-synthesis-weight: auto` に戻す
- **「2 書体 + outlier 1 / 3 書体が上限」は衝突しない** — `craft.md` § 1 は display と body の 2 family に
  役目 1 つの outlier を足すまでとし、gate 37 は 4 family 以上を落とす。日本語書体を同一ロールの
  フォールバックとして重ねる限り family の数は増えない。日本語専用の display 書体を立てるときだけ枠を消費する
- **gate 48 (Floor。token block の外の色・`font-family` 直書きの禁止) も衝突しない** — このスタックは
  `--font-body` 等の**トークン定義の中身**として書き、利用側は `font-family: var(--font-body)` で参照すればよい

確度: **[仕様]** CSS 仕様・MDN / **[公的]** デジタル庁 DADS 等 / **[通説]** 複数の実務記事で一致。

## Contents

[まず押さえる](#まず押さえる) · [症状 1: 明朝体になる](#症状-1-日本語だけ明朝体になる) · [症状 2: 斜体になる](#症状-2-日本語が斜体になる) · [症状 3: 偽ボールド](#症状-3-偽ボールド游ゴシックのかすれ) ·
[フォントスタック](#フォントスタックの組み方) · [組版 CSS](#組版-css-改行禁則アキ) · [寸法](#寸法-サイズ行高字間) · [Web フォント配信](#web-フォント配信の制約) ·
[英語圏の型が壊れる箇所](#英語圏の型をそのまま持ち込むと壊れるもの) · [チェックリスト](#出力前チェックリスト) · [棚卸しの当たり先](#棚卸しの当たり先) · [範囲外](#この文書の範囲外)

## まず押さえる

1. **総称フォント名は日本語にも効く**。`font-family: Georgia, serif` は日本語だけ総称 `serif` に落ち、
   OS の明朝になる。英語圏の serif 指定を写すと本文が明朝化するのはこれが原因 (→ 症状 1) [仕様]
2. **日本語フォントにイタリック字形はほぼ無い**。`font-style: italic` は合成斜体になり字形が破綻する。
   `font-synthesis` の初期値は全合成 ON なので、明示的に切る (→ 症状 2) [仕様]
3. 日本語には**単語の区切りが無い**ので、英語前提の折り返し既定値では意味の切れ目で改行されない。
   `line-break: strict` / `word-break: normal` / `overflow-wrap: anywhere` の 3 点が実務の基礎 [通説]
4. 日本語は同じ本文サイズでも字面が大きく画数が多い。**16px 未満は使わない、行高は 150〜175%**
   (英語圏の 1.4〜1.5 は日本語には詰まる) [公的: デジタル庁 DADS]
5. 日本語 Web フォントは Latin と桁が違う。Noto Sans JP は未サブセットの原本で
   Regular 約 4.5MB / 可変フォント版 約 9.6MB。「好きな書体を読み込む」前提が成立しない [通説]
6. 強調は italic ではなく **`<strong>` / 色 / サイズ / 傍点 (`text-emphasis`)** で作る。
   傍点は日本語の正統な強調手段で、Latin の italic に対応する [仕様]
7. `text-transform: uppercase`・small-caps・drop cap は日本語に対して無効か無意味。
   英語圏 LP の定番である "tiny uppercase tracked eyebrow" は日本語化した時点で機能を失う

## 症状 1: 日本語だけ明朝体になる

**原因**

- `font-family: "Instrument Serif", Georgia, serif` 型の指定。日本語グリフを持つのは末尾の総称だけなので、
  日本語は必ず明朝に落ちる
- Tailwind の `font-serif` ユーティリティ、`@tailwindcss/typography` の `prose` 既定
- 「hero だけ serif」という英語圏の定番構成を日本語見出しにそのまま適用する

**対策**

- **`<html lang="ja">` を必ず入れる**。lang は `:lang()` のマッチだけでなく**漢字の字形選択を決める** —
  Noto Sans CJK 系にフォールバックする環境 (Android / ChromeOS / Linux) では `lang="en"` のままだと
  「直」「骨」「令」等が中国語字形で出る。LLM のボイラープレートは `lang="en"` 残置が主因
- セリフ調を日本語でもやるなら**日本語明朝を明示的にスタックへ入れる**:
  `"Noto Serif JP", "Hiragino Mincho ProN", "Yu Mincho", serif`。
  ただし **Android に明朝は標準搭載されていない**ので Web フォント配信が前提
- Latin だけ serif にするなら、Latin 書体を `@font-face` + `unicode-range: U+0000-00FF` で限定し日本語を明示指定する
- 判定法: スタック中に日本語グリフを持つ書体が 1 つも無ければ、総称が実効フォントになっている

## 症状 2: 日本語が斜体になる

**原因**

- `font-style: italic` / `<em>` / `<i>` / Tailwind の `italic` クラス。日本語フォントに italic フェイスが
  無いため、ブラウザが平体を機械的に傾けた合成斜体を描く
- 英語圏 LP の「見出しの 1 単語だけ serif italic」型をそのまま日本語に当てる
  (`hallmark` gate 38i が Floor で禁じる型と重なる)

**対策**

```css
/* 斜体の合成だけを止める。まずこれ */
:lang(ja) { font-synthesis-style: none; }
```

- `:lang(ja)` は `lang` 属性が実際に付いていることが前提 (症状 1 参照)。無い可能性があるなら対象要素に直接当てる
- `font-synthesis: none` (一括) は太字の合成も切る。Bold 未配信だと強調が消える (症状 3)
- 強調は `<strong>` (ウェイト)、色、サイズ、傍点、背景で作る。傍点は `text-emphasis: filled` を既定に
  (形状の既定は横書き = 黒丸 / 縦書き = ゴマ点。`filled sesame` は横書きでの意図的な選択)。
  横書きでは行の上に出るので `line-height` に余裕がないと隣接行に食い込む・切れる
- Latin だけ italic を許すなら要素を分けて適用範囲を切る。`transform: skewX()` で傾ける手法は使わない

## 症状 3: 偽ボールド・游ゴシックのかすれ

- Regular だけ読み込んで `font-weight: 700` を当てると合成太字で画数の多い漢字が潰れる。
  正解は **Bold フェイスを実際に配信する**こと。`font-synthesis-weight: none` は**単独で使わない** —
  Regular しか無い状態で切ると `<strong>` が地の文と同じになり強調が消える。配信できないなら色・サイズで作る
- Windows の游ゴシック (Yu Gothic) は 400 が細く字画がかすれる。回避は
  `"Yu Gothic Medium", YuGothic` をスタックに名指しする。`font-weight: 500` で太らせる手も流通しているが、
  **他のフォントに落ちたとき不要に太る**副作用があるため名指しの方が事故が少ない [通説]
- 日本語フォントの中間ウェイトは配信コストが高い。**400 / 700 の 2 段**を基本にする [公的]

## フォントスタックの組み方

```css
/* ゴシック (本文・UI の既定) */
font-family:
  -apple-system, "Segoe UI",
  "Hiragino Sans", "Hiragino Kaku Gothic ProN",
  "Yu Gothic Medium", YuGothic, Meiryo,
  "Noto Sans JP", sans-serif;
```

- 総称は必ず末尾。かつ**総称の選び方が日本語の書体を決める**ことを忘れない (症状 1)
- **`system-ui` を先頭に置かない**。Windows では日本語が Yu Gothic UI に解決されて細くなり、
  後ろの `"Yu Gothic Medium"` に到達しない (フォールバックはグリフ単位で決まるため)。
  使うなら Latin 用の別トークンに分ける
- `monospace` で日本語を出すと等幅日本語書体が無い環境で行が揃わない。コード中の日本語コメントに注意
- **フォーム要素はフォントを継承しない**。`button, input, select, textarea { font: inherit }` を必ず入れる
  (無いと Windows で Yu Gothic UI に落ちて本文と食い違う)。また **iOS Safari は入力欄が 16px 未満だと
  フォーカス時に自動ズーム**するので 16px を下回らせない
- アクセシビリティ要件が強い場面は UD フォント (BIZ UDPGothic / BIZ UDGothic) を検討。
  Windows 10 1809 以降に標準搭載で、日本語ゴシック UD 書体では唯一 Google Fonts にある [通説]

## 組版 CSS (改行・禁則・アキ)

```css
.prose {
  line-break: strict;       /* 小書き仮名・長音符の行頭を禁止。normal は書かない */
  word-break: normal;       /* 英単語を途中で割らない */
  overflow-wrap: anywhere;  /* 長い URL 等でレイアウトを壊さない */
}
pre, code { text-autospace: no-autospace; }  /* 和欧間アキは既定で入るので、切る側だけ書く */
```

- **`text-autospace` の初期値は `normal`** (Baseline 2025-11)。和欧間・和数字間のアキは何も書かなくても
  入るので `normal` と書くのは no-op。書く価値があるのは `no-autospace` で切る側 (コード・等幅表示) だけ
- **日本語本文には `line-break: strict` を書き、`normal` は書かない**。行頭の句読点・閉じ括弧の禁則は
  どの値でも効くので、`strict` の役目はそこではない。ICU 系実装 (Chromium / WebKit) では
  無指定の `auto` と `strict` が同じ規則で、小書き仮名 (ゃゅょっ) と長音符「ー」の行頭が既に禁止されている。
  一方 **`normal` を明示すると ICU が CJ 文字を ID 扱いに緩め、行頭に「ー」「っ」が出るようになる**
  (`line_normal.txt`)。CSS Text 3 は "forbidden for normal and strict, allowed in loose" と規定するが
  同時に「厳密な規則は UA 依存」とも言っており、実装は仕様どおりではない。
  `strict` の明示は `auto` に対して失うものがなく、エンジン差も塞ぐ
- `overflow-wrap: anywhere` は flex/grid の子では `min-width: 0` を併記する。また `anywhere` は
  min-content 幅を縮めて grid 列が細くなることがある (`break-word` にはこの副作用が無い)。崩れたら `break-word`
- **`word-break: break-all` を全体に当てない**。英単語まで割れる。日本語の折り返しは既定で可能なので不要
- `word-break: auto-phrase` (Chrome 119+) は BudouX 由来の文節改行。**見出し・短いコピー限定**で、
  推定を外すことがあり非対応ブラウザもある。長い本文には使わない
- 改行位置を決め打ちするなら `<wbr>` + `word-break: keep-all`。ただし **`keep-all` は日本語の改行を
  全面的に禁じる**ので、`<wbr>` を全候補に打った短い見出し専用。本文に当てると折り返せず溢れる
- `text-spacing-trim` (括弧・句読点の字面アキ詰め) はまだ Baseline ではない。
  `@supports` 付きの progressive enhancement として足す
- `font-feature-settings: "palt"` は**見出しで有効、本文全体には掛けない** (掛けるなら `letter-spacing` で戻す)。
  フォントが palt テーブルを持たないと無効

## 寸法 (サイズ・行高・字間)

デジタル庁デザインシステム (DADS) の規定を実務の下限として使う [公的]。

| 項目 | 値 |
|---|---|
| 本文・UI の最小サイズ | 16px。狭所に限り 14px まで、**14px 未満は使わない** |
| 本文の行高 | 150% 最小 (DADS アクセシビリティ「フォントサイズの 1.5 倍以上」)、160〜175% が読みやすい |
| 見出し (Display 48〜64px) | 行高 140% |
| 密なデータ表示 (14〜17px) | 行高 120〜130% |
| UI の単行ラベル | 行高 100% |
| letter-spacing | 0 / 0.01em / 0.02em の 3 値。**サイズが大きいほど詰める** |
| ウェイト | 400 / 700 の 2 段 |

- 1 行は全角 30〜40 字が上限の目安 (DADS アクセシビリティも「半角 80 = 全角 40 字程度」)。
  英語の 60〜75 字 (`max-w-prose` 系) を流用すると日本語では長すぎる

## Web フォント配信の制約

- Noto Sans JP の未サブセット原本 (実測): Regular の OTF 約 4.5MB / Regular+Bold で約 9.2MB /
  可変フォント版 約 9.6MB。full を woff2 化しても 1.5〜2MB 程度。
  Google Fonts 経由で実際に落ちる `unicode-range` サブセットはこれより桁違いに小さいが、
  自前ホストで原本をそのまま置くとこの数字が転送量になる
- Google Fonts の日本語は `unicode-range` で 120 前後の `@font-face` に分割され、
  その CSS 自体が gzip 後 約 30kB ある (**CSS 待ちで FCP が遅れる**)
- 実務順: 使うウェイトを絞る → サブセット化 → self-host → `font-display: swap` (`preload` は 1〜2 本まで)
- **日本語 UI での費用対効果の既定解: 本文はシステムフォント、見出しだけ Web フォント。**
  英語圏の雛形が前提にする「全文をブランド書体で通す」は日本語では成立しにくい

## 英語圏の型をそのまま持ち込むと壊れるもの

| 英語圏の型 | 日本語での結果 | 置き換え |
|---|---|---|
| serif hero / `font-serif` | 本文・見出しが明朝、OS ごとに別書体 | 日本語明朝を明示 or ゴシック固定 |
| 1 単語だけ italic 強調 | 合成斜体で字形が破綻 | `<strong>` / 色 / 傍点 |
| tracking-tight (`-0.02em` 等) | 字面が大きい日本語では潰れる | 0 〜 +0.02em 側で調整 |
| ALL CAPS の eyebrow ラベル | 日本語に大文字が無く機能しない | ウェイト・色・サイズで階層を作る |
| drop cap / 頭文字装飾 | 漢字では成立しない | 削る |
| `max-w-prose` (60〜75 字) | 1 行が長すぎる | 30〜40 字相当に絞る |
| 英語ラベル前提のボタン幅 | 文字数は減るのに 1 字の前進幅が大きく表示幅は増える。**短いラベルほど相対伸長が大きい** (原文 10 字以下で 200〜300%) | `min-width` とラベル最大長を先に決める |
| `word-break: break-all` を保険で全体に | 英単語まで割れる | `overflow-wrap: anywhere` |
| Latin 前提の行高 1.4〜1.5 | 詰まって読みにくい | 1.5〜1.75 |

## 出力前チェックリスト

- [ ] スタックの末尾の総称 (`serif`/`sans-serif`/`monospace`) が、日本語で出したい書体と一致している
- [ ] `italic` / `<em>` / `font-style` が日本語テキストに掛かっていない。掛かるなら `font-synthesis-style: none`
- [ ] 700 を使う箇所で Bold フェイスが実際に配信されている (でなければ色・サイズで強調する。`font-synthesis-weight: none` を単独で当てない)
- [ ] 本文 16px 以上、行高 1.5 以上、1 行 30〜40 字前後
- [ ] `line-break: strict` / `word-break: normal` / `overflow-wrap: anywhere` が本文コンテナに入っている
      (`line-break: normal` と `word-break: keep-all` を本文に書いていない)
- [ ] `word-break: break-all` を広域に当てていない
- [ ] `text-transform: uppercase` / small-caps が日本語に掛かっていない
- [ ] `<html lang="ja">` がある。フォーム要素に `font: inherit`、入力欄は 16px 以上
- [ ] 日本語 Web フォントの総量を確認した (ウェイト数 × サブセット)。本文システムフォントの選択肢を検討した
- [ ] 320〜1920px の範囲 (特に 320 / 375 / 414 / 768) で禁則・折り返しを確認した。
      **ボタン・ナビ・CTA のラベルが 2 行に折れていない** (hallmark gate 49a はボタンと主ナビのラベルの折れを Floor、49b は footer のリンク・タブ・パンくずの折れを Reflex で落とす。横スクロールは gate 34。日本語ラベルは英語の約 2 倍幅で最も折れやすい)
- [ ] コードブロックに `text-autospace: no-autospace` を当てた

## この文書の範囲外

- **縦書き** (`writing-mode`)・ルビ (`<ruby>`)・段組み・印刷組版の詳細。
  必要になったら CSS Writing Modes と JLREQ (W3C 日本語組版処理の要件) を直接当たる
- **IME 変換確定の Enter による誤送信**。組版ではなく入力処理だが、「Enter で送信」する日本語 UI では
  必ず `KeyboardEvent.isComposing` でガードする
- 日本語の**文章そのもの**の品質 (AI っぽい文体・語彙) は姉妹スキル `ja-slop-review` が担当する
- 中国語・韓国語の組版。CJK と一括りにせず対応言語を個別に確認する (`auto-phrase` は現状 日本語のみ)

## 棚卸しの当たり先

期限が来たら、腐りやすいこの 5 点だけ再検証する。ここが動いていなければ残りは機構に根ざすので据え置く。

1. `text-autospace` の初期値 `normal` と Baseline 状況 / 2. `text-spacing-trim` の Baseline 昇格 (MDN)
3. `word-break: auto-phrase` の対応ブラウザ・対応言語 (現状 日本語のみ。MDN / chromestatus)
4. DADS のタイポグラフィ数値の改定 (design.digital.go.jp) / 5. Noto Sans JP の配布サイズ (notofonts/noto-cjk)

## 参考

- MDN: `font-synthesis` / `text-autospace` / `text-spacing-trim` / `word-break` / `text-emphasis` の各ページ
- W3C: https://www.w3.org/TR/css-text-3/#line-break-property (CJ の禁則) /
  https://www.w3.org/International/articles/styling/inline-space (和欧間アキ)
- ICU の実装差: `icu4c/source/data/brkitr/rules/line.txt` と `line_normal.txt` (CJ の扱いが値で逆転する根拠)
- https://developer.chrome.com/blog/css-i18n-features — `word-break: auto-phrase` / BudouX の根拠。
  同記事の `text-autospace` 記述は古く「フラグ付き」とあるが、現況は MDN を正とする
- DADS: https://design.digital.go.jp/dads/foundations/typography/ (+ `/accessibility/`) /
  https://smarthr.design/basics/typography/
- 実務: https://officetakec.com/css_2026/ (組版) /
  https://qiita.com/debiru/items/0a349bee3669b776d8e2 (auto-phrase の限界と keep-all) /
  https://hyper-text.org/archives/2016/06/windows_yu_gothic_font/ (游ゴシック) /
  https://zenn.dev/ivry/articles/f214469e05e427 (配信) / https://and-ha.com/design/biz-ud-gothic/ (UD)
- ラベル幅: https://www.unicode.org/reports/tr11/ (UAX #11 §1 — 全角保証は固定ピッチ限定) /
  https://www.w3.org/International/articles/article-text-size.en (原文長別の伸長率表)
