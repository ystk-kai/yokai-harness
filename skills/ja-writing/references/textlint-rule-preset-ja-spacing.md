---
source: https://github.com/textlint-ja/textlint-rule-preset-ja-spacing
distilled_commit: bc6fb68d859eb16c5caa38c6d7f894dad0285978
distilled_at: 2026-11-16
---

# textlint-rule-preset-ja-spacing 蒸留版

日本語文中の「スペースを入れるか入れないか」だけを扱う textlint ルール 11 本と、それを束ねるプリセットの monorepo (textlint-ja 製、各パッケージ v3.1.0)。原典の自己規定は「日本語周りにおけるスペースの有無を決定するtextlintルールプリセット」(README.md)。**この蒸留版は「和欧間・全角同士・記号まわり・Markdown 要素まわりのスペース規則と、その選び方」の索引**であり、textlint の導入手順やルール実装の書き方は扱わない。

ルールは README だけでなく `src/index.js` も読んで確認した。README の説明より実装の判定範囲が狭いルールがあるので、そうしたルールには「実装上」と書いてある。

## Contents

- まず押さえる
- ルール別早見表
- 索引テーブル
- 蒸留の範囲外

## まず押さえる

1. **プリセットの既定は「和欧間に入れない派」**。中心ルール `ja-space-between-half-and-full-width` の既定は `space: "never"` で、`OK: これはUnicode` / `NG: これは Unicode` (packages/textlint-rule-ja-space-between-half-and-full-width/README.md)。インラインコード・リンクの前後も既定はスペースなし。全体として「全角と半角の間を詰める」方向にそろえてある (README.md § デフォルト設定)。

2. **「入れる派 / 入れない派」は 1 つのオプションで切り替える**。`space` は `"always"` / `"never"` / 配列 (`["alphabets", "numbers", "punctuation"]` の部分集合) を取る。原典はどちらが正しいかを論じず、オプションとして選ばせるだけ。入れる派はプリセット内でこのルールを `{"space": "always"}` に上書きする (packages/textlint-rule-ja-space-between-half-and-full-width/README.md § Options)。

3. **ただし和欧間の設定は Markdown 要素側と連動しない**。`ja-space-around-code` / `-link` / `-emphasis` / `-strong` はそれぞれ別の `before` / `after` (既定 `false`) を持つ。入れる派が `space: "always"` だけ変えても、`` `code` と`` や `[README](README.md) と` は既定のままエラーになる。入れる派なら、プリセットで有効な `ja-space-around-code` / `-link` の 2 ルールの `before` / `after` も `true` にそろえる必要がある。emphasis / strong はプリセットで無効なので、有効化しない限り触らなくてよい (各 packages/textlint-rule-ja-space-around-*/README.md § Options、packages/textlint-rule-preset-ja-spacing/src/index.js)。

4. **「半角文字」は英字と数字だけ、「全角文字」は漢字・かな・句読点だけ**。実装上の文字クラスは半角が `[A-Za-z0-9]`、全角が漢字 (CJK 統合漢字・拡張 A・互換漢字・サロゲートペア) + `[ぁ-んァ-ヶ]` + `[、。]`。記号 (`(` `/` `-` 等) や長音 `ー` の隣接は判定しない。テストでは `これはstruct / enumです。` が never で valid (packages/textlint-rule-ja-space-between-half-and-full-width/src/index.js, test/index-test.js)。

5. **never は半角・全角どちらのスペースも咎め、always は「無いこと」だけを咎める**。never は英数字と和文の間の `[ 　]` を報告して削除する。always は英数字と和文が直接隣接している箇所に半角スペースを挿入する (同 src/index.js)。

6. **句読点は既定で例外扱い**。`これも、Unicode。` は never で OK。配列指定で `"punctuation"` を含めなければ句読点との間は判定しない。旧オプション `exceptPunctuation` (既定 `true`) は非推奨で、代替は `space: ["alphabets", "numbers"]`。配列に `"alphabets"` か `"numbers"` を含めると「列挙した種別だけスペースを必須にし、列挙しない種別は判定しない」動作になる (`["numbers", "punctuation"]` なら `最新のversionは 1.2.3 です。` が valid)。`"punctuation"` は英字か数字と組み合わせたときだけ必須側に効く。**`["punctuation"]` 単独は never 扱いで、句読点の隣も含めてスペースを禁止する** (`exceptPunctuation: false` 付きの never と同じ。src/index.js の `noSpace` 判定と句読点フィルタ)。空配列 `[]` は never 相当 (同 README.md, test/index-test.js)。

7. **固有表記の例外は `allows` で逃がす**。`allows: ["Eコマース"]` のように文字列 (RegExp-like String も可) を列挙すると、always でもスペースなしを許す。`lintStyledNode` (既定 `false`) を `true` にするとリンクテキストや画像キャプションも対象になる (同 README.md § Options)。

8. **全角同士の間には半角スペースを入れない。例外はカタカナ複合語**。`NG: これは ダメ`。実装上は和文字・半角スペース・和文字の並びだけを検出し、両側がカタカナ (`[ァ-ヶ]`) なら許す。全角スペースは判定しない (packages/textlint-rule-ja-no-space-between-full-width/src/index.js)。

9. **カタカナ語の区切りは中黒か半角スペース。全角スペースは不可**。`OK: インターフェース・ブラウザ` / `NG: インターフェース　ブラウザ`。このルールだけは自動修正 (`--fix`) に対応していない (packages/textlint-rule-ja-nakaguro-or-halfwidth-space-between-katakana/README.md, src/index.js)。

10. **かっこの内側にも外側にもスペースを入れない。対象は全角かっこと半角 `[]`**。README は対象として `[]（）［］「」『』` を挙げ、実装も同じ 10 文字だけを見る。**半角の `(` `)` は対象外**なので、`foo (bar)` 型の半角丸かっこ表記はこのルールでは咎められない。v3.0.4 から、リスト項目の継続行の行頭インデント (半角スペース・タブ) は開きかっこ前のスペースとみなさない (`- 箇条書きの文を\n  （括弧）で続ける。` が valid)。継続行でも文中の `続けて （括弧）` や閉じかっこ後の `（括弧） で` は従来どおり報告する (packages/textlint-rule-ja-no-space-around-parentheses/README.md, src/index.js の `isIndentation`, test/index-test.js)。

11. **スラッシュの前後にはスペースを入れない**。`OK: struct/enum` / `NG: struct / enum`。和文・英文を問わず、プレーン文字列中の `/` の前後にある半角・全角スペースをすべて報告する (packages/textlint-rule-ja-no-space-around-slash/README.md, src/index.js)。

12. **全角の ！ ？ が文末にあって次の文が続くなら、直後は全角スペース**。`OK: 驚きの速さ！　これが…` / `NG: 驚きの速さ！ これが…`。文中の ？ には入れない (`どう操作したらよいのか？というユーザーの疑問`)。実装上は全角 `！` / `？` の直後の半角スペースだけを検出して全角スペースに置き換える。半角の `!` `?` は対象外 (packages/textlint-rule-ja-space-after-exclamation/, packages/textlint-rule-ja-space-after-question/)。

13. **Markdown 要素の 4 ルールは「隣が日本語のときだけ」判定する**。code / link / emphasis / strong は前後 1 文字が和文字 (漢字・かな) のときだけスペースの有無を見る。隣が英数字や記号なら何も言わない (packages/textlint-rule-ja-space-around-code/src/index.js。link / emphasis / strong も同じ実装構造)。

14. **強調 (`*em*`) と強い強調 (`**strong**`) はプリセットで無効。v3.1.0 から、削除すると強調が壊れるスペースは咎めない**。無効化 (38aac28) の理由だった「スペースを削除すると強調として解析されなくなる」問題に、v3.1.0 (bb158a9) が実装で対処した。プリセットの既定は無効のまま。`before` / `after` が `false` でも次の 2 つはエラーにせず、スペースを残す。(a) `_` / `__` 区切り: 前後が文字の `_` は CommonMark でも markdown-cjk-friendly でも強調にならないので、常に残す。(b) `*` 区切りで内側の端が約物: `**文章で:** 後半` や `前半 **「強調」** 後半` を詰めると CommonMark / GFM では `**` がそのまま表示されるので残す。約物の判定は CommonMark の定義どおり Unicode の P / S カテゴリ (`/^[\p{P}\p{S}]$/u`)。`before` / `after` が `true` 側 (スペースを挿入する側) の判定は変わっていない (packages/textlint-rule-ja-space-around-{emphasis,strong}/README.md § 例外, src/index.js の `canRemoveBeforeSpace` / `canRemoveAfterSpace`)。

15. **markdown-cjk-friendly で表示する文書なら `cjkFriendlyEmphasis: true`**。v3.1.0 で emphasis / strong に追加されたオプション (既定 `false`)。`true` にすると (b) の約物の例外を外し、`前半 **「強調」** 後半` を `前半**「強調」**後半` に修正する。`_` の例外 (a) は `true` でも残る。原典の指定は、VitePress や Rspress のように markdown-cjk-friendly で表示する文書では textlint の Markdown プラグイン (`@textlint/textlint-plugin-markdown`、textlint 16 以降) とこのルールの**両方**で `cjkFriendlyEmphasis` を `true` にする (プラグインのオプションはルールに伝わらないため)。GitHub のように CommonMark / GFM で表示する文書では両方 `false` のまま。プリセット経由なら `"preset-ja-spacing": { "ja-space-around-strong": { "cjkFriendlyEmphasis": true } }` のようにオブジェクトで渡すと、既定無効のルールが有効になる (同 README.md § textlintのMarkdownプラグインの設定)。

16. **JTF-style とは大部分が重複する**。原典の記述は「JTFスタイルガイドに含まれているルールと大部分は共通しています」「以下のプリセットを利用している場合は重複するルールがあります」で、`textlint-rule-preset-JTF-style` を挙げる。どのルールが重複するか、併用時にどちらを切るかは書かれていない (README.md § 関連)。

## ルール別早見表

「プリセット」列はプリセットの `rulesConfig` での既定 (packages/textlint-rule-preset-ja-spacing/src/index.js)。fix は `textlint --fix` 対応の有無。

| ルール | 規定 (OK / NG) | オプションと既定値 | プリセット | fix |
|---|---|---|---|---|
| `ja-space-between-half-and-full-width` | 英数字と和文の間。既定は入れない (`これはUnicode` / `これは Unicode`) | `space`: `"never"` (既定) / `"always"` / 配列。`lintStyledNode`: `false`。`allows`: `[]`。`exceptPunctuation`: `true` (非推奨) | 有効 (`space: "never"`) | 可 |
| `ja-no-space-between-full-width` | 和文同士の間に半角スペースを入れない (`これは大丈夫。` / `これは ダメ`)。カタカナ同士は除外 | なし | 有効 | 可 |
| `ja-nakaguro-or-halfwidth-space-between-katakana` | カタカナ語間は中黒か半角スペース (`インターフェース・ブラウザ` / 全角スペース区切り) | なし | 有効 | 不可 |
| `ja-no-space-around-parentheses` | `[]（）［］「」『』` の内外にスペースを入れない (`「良いですね」` / `「 ダメですね 」`)。リスト継続行の行頭インデントは除外 (v3.0.4〜) | なし | 有効 | 可 |
| `ja-no-space-around-slash` | `/` の前後にスペースを入れない (`struct/enum` / `struct / enum`) | なし | 有効 | 可 |
| `ja-space-after-exclamation` | 文末 `！` の後に文が続くなら全角スペース。文中は入れない | なし | 有効 | 可 |
| `ja-space-after-question` | 文末 `？` の後に文が続くなら全角スペース。文中は入れない | なし | 有効 | 可 |
| `ja-space-around-code` | インラインコードの前後が日本語のときのスペース。既定は入れない | `before`: `false` / `after`: `false` | 有効 (既定値) | 可 |
| `ja-space-around-link` | リンクの前後が日本語のときのスペース。既定は入れない | `before`: `false` / `after`: `false` | 有効 (既定値) | 可 |
| `ja-space-around-emphasis` | `*emphasis*` の前後が日本語のときのスペース。削除で強調が壊れる箇所は除外 (v3.1.0〜) | `before`: `false` / `after`: `false` / `cjkFriendlyEmphasis`: `false` | **無効** | 可 |
| `ja-space-around-strong` | `**strong**` の前後が日本語のときのスペース。削除で強調が壊れる箇所は除外 (v3.1.0〜) | `before`: `false` / `after`: `false` / `cjkFriendlyEmphasis`: `false` | **無効** | 可 |

入れる派の設定例 (原典の各 Options 節を組み合わせたもの。この組み合わせ自体は原典に載っていない):

```json
{
  "rules": {
    "preset-ja-spacing": {
      "ja-space-between-half-and-full-width": { "space": "always" },
      "ja-space-around-code": { "before": true, "after": true },
      "ja-space-around-link": { "before": true, "after": true }
    }
  }
}
```

## 索引テーブル

| トピック | 原典パス | 一行説明 |
|---|---|---|
| ルール一覧・既定設定・JTF-style との関係 | README.md | 11 ルールの一行説明、プリセット既定の JSON、§ 関連 |
| プリセット本体 (有効 / 無効の正) | packages/textlint-rule-preset-ja-spacing/src/index.js | `rules` と `rulesConfig`。README の既定 JSON と同内容 |
| 和欧間スペースのオプション全仕様 | packages/textlint-rule-ja-space-between-half-and-full-width/README.md | `space` / `lintStyledNode` / `allows` / `exceptPunctuation` と設定例 3 つ |
| 和欧間の文字クラス・判定ロジック | packages/textlint-rule-ja-space-between-half-and-full-width/src/index.js | `ZenRegExpStr`、never と always の分岐、句読点フィルタ |
| 和欧間のオプション別挙動の実例 | packages/textlint-rule-ja-space-between-half-and-full-width/test/index-test.js | valid / invalid の対。配列指定・`allows`・見出しの扱いが読める |
| 全角同士・カタカナ複合語の例外 | packages/textlint-rule-ja-no-space-between-full-width/src/index.js | 和文字の正規表現とカタカナ除外 |
| カタカナ語の区切り | packages/textlint-rule-ja-nakaguro-or-halfwidth-space-between-katakana/src/index.js | 全角スペースだけを報告。fixer なし |
| かっこの対象文字 | packages/textlint-rule-ja-no-space-around-parentheses/src/index.js | `brackets` 配列 (半角 `()` を含まない)、継続行インデント除外の `isIndentation` |
| スラッシュ | packages/textlint-rule-ja-no-space-around-slash/src/index.js | `/` 前後の `[ 　]{0,10}` を除去 |
| 感嘆符 / 疑問符 | packages/textlint-rule-ja-space-after-exclamation/README.md, packages/textlint-rule-ja-space-after-question/README.md | OK / NG 例。実装は各 src/index.js |
| Markdown 要素 4 種 | packages/textlint-rule-ja-space-around-{code,link,emphasis,strong}/README.md | TxtAST の `Code` / `Link` / `Emphasis` / `Strong` node が対象。Options 節と強調の解析注意 |
| 強調が壊れるスペースの除外・`cjkFriendlyEmphasis` | packages/textlint-rule-ja-space-around-{emphasis,strong}/README.md § 例外, src/index.js | CommonMark と markdown-cjk-friendly での表示の違い (HTML 例つき)、`isPunctuationChar` と `countDelimiter` による判定 |
| 隣接文字が日本語かの判定 | packages/textlint-rule-ja-space-around-code/src/index.js | `isJapaneseChar` と前後 2 文字の取り方。他 3 ルールも同構造 |
| ブラウザで試す | website/ | playground の実体 (README.md § Demo の URL) |

## 蒸留の範囲外

- **textlint の導入・CLI・`.textlintrc` の一般論** — 原典は最小の Usage しか持たない。textlint 本体のドキュメントを当たる
- **JTF-style の個別ルールとの対応表** — 原典は「大部分は共通」と書くだけで対応関係を示さない。対応を見るには `textlint-rule-preset-JTF-style` 側の README を読む
- **和欧間スペースの是非 (組版論)** — 原典は選択肢を出すだけで根拠を論じない。根拠が要るときは ja-writing の表記ガイド系の蒸留版を当たる
- **開発フロー・lerna / yarn の monorepo 運用・テスト実行** — README.md § 開発フロー / Tests
- **CHANGELOG の版ごとの変更履歴** — CHANGELOG.md と各 packages/*/CHANGELOG.md は v2.4.x (2024-04) で止まっている (slash パッケージには CHANGELOG.md 自体が無い)。v3.0.0 以降 (space-around 系の既定有効化 76e586f、slash ルール追加 2e37817、emphasis / strong 無効化 38aac28、v3.1.0 の `cjkFriendlyEmphasis` 追加 bb158a9 など) は git log と GitHub Releases で追う
- **textlint Markdown プラグイン側の `cjkFriendlyEmphasis` の仕様と markdown-cjk-friendly の解析規則** — 原典は「textlint 16 から存在する」「ルールには伝わらない」と書くだけ。詳細は textlint 本体と tats-u/markdown-cjk-friendly のドキュメントを当たる
- **`isPlainStrNode` が何を「プレーン」とみなすか** — 原典は外部の textlint-rule-helper の README を参照させるだけ。見出しが never で valid になるテストはあるが、理由は原典に書かれていない
