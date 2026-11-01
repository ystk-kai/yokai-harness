---
source: https://github.com/bamboo-nova/meiseki
distilled_commit: 9750d9262c949aa3919b05b9dff1ba9ef502da03
distilled_at: 2026-10-21
---

# meiseki 蒸留版

日本語文章の Agent Skill / Claude Code・Codex プラグイン (bamboo-nova 製、package.json 上は v0.10.0)。狙いは「明晰さ (clarity) = 内容を知らない読者が一度読んで正しく理解できること」だけ (.agents/skills/meiseki/SKILL.md §1)。**この蒸留版は「読解負荷を生む構文」と「やさしい日本語」の検出・書き換え規則の索引**として読む。AI 臭の診断と声の回復は姉妹スキル `ja-slop-review` の領域で、meiseki は原典自身が「声を足さない」逆方向だと宣言している (README.md 冒頭)。

## Contents

- まず押さえる
- 索引テーブル
- 蒸留の範囲外

## まず押さえる

1. **3 スキルの分担は「読者」と「目的」で切られている**。
   - `meiseki` は日本語ネイティブ向け。構文の読解負荷を下げる
   - `yorisoi` は在留外国人・日本語学習者向け。出入国在留管理庁・文化庁「在留支援のためのやさしい日本語ガイドライン」(2020年8月) に沿って、語彙レベル (既定 N4 相当) まで落とす
   - `rikai` は書き換えをしない。資料から選択式クイズを出して読者の理解を測り、誤読が集中した段落を書き手向けの「還流レポート」に返す。書き手はそれを見て meiseki で原文を直し、もう一度 rikai で確かめる
   - 第 4 の `jp-pdf` は Markdown を PDF にする補助 (pandoc → xelatex)

   出典は README.md「収録スキル」・yorisoi 節 (対象読者の違い)・rikai 節 (還流レポートから meiseki へ戻す往復)、.agents/skills/yorisoi/SKILL.md §1、.agents/skills/rikai/SKILL.md §1。

2. **核の主張: 読みにくさは語彙ではなく構文から生まれる**。二重否定・長い連体修飾・「の」の連鎖・過剰な名詞化・冗長表現・一文に埋もれた列挙は、語を置き換えても消えない (meiseki/SKILL.md §1)。「自然さ」「AI 検出の回避」「文章の上手さ」は目的に入れていない。

3. **声・立場は注入しない**。ガードレールには次の 4 つが明記されている。
   - 一般論を「自分は」という意見に書き換えない
   - 言い切らせない
   - 語り口を強めない
   - `ja-no-weak-phrase` は「曖昧で意味が取りにくいときだけ」外し、立場を強める方向には使わない

   原典はこれを `stop-ai-slop-jp` 系との決定的な差分としている (meiseki/SKILL.md §5)。§5 のガードレールは全 11 項目あり、ほかの主なものを抜粋する (残りは意味不変・技術精度・litotes・接続詞・G・H・I の扱い)。
   - 元から読みやすい文は触らない (均質に整えると「エディタ感」が出る)
   - 敬体／常体を勝手に統一しない
   - 新しい情報・根拠・例を足さない

4. **高負荷構文カタログ A–H は優先度順に並ぶ** (.agents/skills/meiseki/references/patterns.md)。各項目は「問題 / Before / After / 注意」の 4 点で書かれている。
   - **A 否定・条件の入れ子 (最優先)**: A1 二重否定 (litotes)、A2 否定と条件のネスト (真理値表が原文と一致するか確認する)、A3 否定疑問・婉曲 (問いかけとして意図的に開いている文は触らない)
   - **B 係り受け・修飾の距離**: B1 長い連体修飾は連用に開く、B2 一文に節を詰めすぎない (1 文 1 メッセージ)、B3 係り先が曖昧なら読点と語順で一意にする
   - **C 名詞化・漢語**: C1 サ変名詞化した動作は動詞に戻す、C2「の」は 2 連まで、C3 硬い漢語・指示語 (「当該」「〜に起因する」)
   - **D 冗長・空虚**: D1「することができる」、D2 中身のない枠付け、D3 誇張、D4 惰性の枕詞 (基本的に／一般的に)、D5 冒頭の一般論前置き
   - **E 体裁**: E1 太字＋コロンの箇条書き、E2 三点リストの強制、E3 ダッシュ・記号の乱用、E4 見出しの過剰構造化・体言止めの連発
   - **F 埋もれた列挙**: 同格の 3 項目以上が一文に詰まっていたら箇条書きに開く
   - **G LLM 定型句**: G1 予告と総括、G2 空虚な形容、G3 空虚な動詞 (掘り下げる／深掘り)、G4 接続の型
   - **H 段落レベルの冗長**: H1 言い換え反復、H2 描写直後の再要約、H3 並列事実の分散、H4 1 段落に複数トピック

5. **E1 と F は「構造を内容の論理形状に合わせる」という 1 つの原理で両立させる**。飾りの箇条書きは散文に戻し、埋もれた列挙は開く。F を発動するのは「同格の項目が 3 つ以上、かつ一文が長い」場合だけ。開くときも太字＋コロンの定型にしない (patterns.md F)。

6. **二重否定を畳む前に真偽を検算する。原典はこれを最重要のガードとしている**。
   - 「負荷の増大を招かないとは言えません」は「負荷が増えることがある」と同じ意味。「負荷が増えない」と畳めば誤訳で、不合格になる
   - 控えめな肯定の含意 (litotes) が本質的な箇所は、安全に畳めなければ残す
   - G を削ったら、主張の強さが原文より強くも弱くもなっていないか確認する
   - H で文を削ったら、新しい含意・条件・例外を持つ文を消していないか一文ずつ確認する。迷ったら残す

   出典は meiseki/SKILL.md §4 Step 5 と examples/meiseki/README.md 01。

7. **処理は「検出と採点は決定論層、書き換えは LLM 層」の分担で組まれている**。順序は次のとおり。
   1. textlint を `npx` で実行し、行・列つきの指摘から RLS(before) を出す
   2. 任意で Jev 層が文脈判断 (G の語に実質があるか／H の段落が反復か／A が意図的な litotes か) を 1 リクエストにまとめて返す。確率 p ≥ 0.8 は yes、p ≤ 0.2 は no として採用し、その間は LLM が判断する
   3. LLM が A→H の順に書き換える
   4. textlint を再実行して検算する

   textlint では取れない部分は LLM が担う。具体的には B1 長い連体修飾、C の「の」連鎖の深さと一般の名詞化、F、辞書外の G、H、E の散文に戻すかの判断。原典はこれを独自価値と呼ぶ (meiseki/SKILL.md §4・§8、README.md「アーキテクチャ」)。

8. **読解負荷スコア RLS の定義** (meiseki/SKILL.md §7)。

   `RLS = Σ(カテゴリ件数 × 重み) ÷ 本文の文数 × 100`。値が低いほど読みやすい。

   重みは A=3、B=2、C=2、D〜H=1。

   二重計上を防ぐ規則は 4 つある。
   - `ja-no-redundant-expression` は C と D が共有するので D に 1 回だけ数える
   - 同じ位置を prh と `no-ai-hype-expressions` が拾ったら G に 1 回
   - 同じ位置を `ja-no-redundant-expression` と `ai-tech-writing-guideline` が拾ったら D に 1 回
   - `ai-tech-writing-guideline` の総括行は件数に数えない

   受け入れ基準は「after < before が必須、A は原則 0 件」。カテゴリ I (文字化け) は RLS に数えない。

   RLS は textlint が見える範囲しか測れない。そのため C の一部や H だけを直した例では 0.0 → 0.0 のまま動かない。原典はこれを「設計どおり」と明記している (examples/meiseki/README.md の 03・07)。

9. **yorisoi の書き換えカタログは YA–YH** (.agents/skills/yorisoi/references/patterns-yorisoi.md)。ガイドラインのステップ 1 (日本人にわかりやすく) が YA と YH、ステップ 2 (外国人にもわかりやすく) が YB〜YG に当たる。
   - **YA 一文一義**: 文長の上限 50 字は本スキルの実務値。ガイドライン自体は字数を定めていない
   - **YB 二重否定**: meiseki の A1 と同じ基準で畳む
   - **YC 受身・使役を能動に**: prh の検出は近似で、可能形や自発の「される」も拾う
   - **YD 推測・曖昧**: 分かっていることは言い切る。分からないことは「〜かもしれません」と書き、これは削らない
   - **YE 敬語は丁寧語だけ**: 文末は「です・ます」、指示は「〜してください」
   - **YF 語彙**: 言い換えられない重要語は「余震＜＝後から来る地震＞」形式で説明を付ける。略語は開く。定着した外来語は残す
   - **YG 表記**: 元号は西暦、「〜」は「から…まで」、24 時間表示は午前／午後、日付の「/」は年月日
   - **YH 構造**: 結論と読者がすべきことを先頭に置く。3 項目以上は箇条書きにする

10. **YLS は RLS と同じ形の式で、語彙超過を含む** (yorisoi/SKILL.md §7)。重みは次のとおり。
    - YB 二重否定 (`no-double-negative-ja` と prh の A1 補完): 3
    - YF 語彙超過 (vocab-check の `over`): 2
    - YA 文長・読点: 2
    - YF 漢字連続・冗長: 2
    - YC/YD/YE/YG の prh (A1 以外) と `no-mix-dearu-desumasu`: 1
    - その他 (`no-doubled-joshi`、`no-doubled-conjunction`): 1

    `unknown` (語彙リストに無い語) は数えない。判定モードでは書き換えず、違反と YLS だけを報告する。

    「N○相当」はすべて推定値。JLPT の公式語彙リストは 2010 年以降非公開で、同梱リストは次の 2 つで近似している。
    - tanos.co.uk 由来のリスト (CC BY)
    - 国語研『日本語教育のための基本語彙調査』(CC BY 4.0)

    語彙表 JEV は二次配布禁止なので同梱していない。利用者が自分で置けば最優先で参照される (.agents/skills/yorisoi/references/vocab/README.md)。

11. **textlint の設定は「読解負荷に効くルールだけ残す」方針で絞っている**。プリセットをそのまま使うと、表記ゆれや感嘆符のような読解負荷と無関係なルールまで効いて「整えすぎ」になるためで、原典はこれを差別化の肝と呼ぶ (README.md の textlint 設定の節)。

    meiseki は `.agents/skills/meiseki/references/textlint.config.json`。使っているプリセットは 3 つ。
    - **`preset-ja-technical-writing`** の有効ルール: `no-double-negative-ja`、`sentence-length` (max 90)、`max-ten` (max 3)、`max-kanji-continuous-len` (max 6)、`ja-no-redundant-expression`、`no-doubled-joshi` (min_interval 1)、`no-doubled-conjunction`、`no-doubled-conjunctive-particle-ga`、`ja-no-weak-phrase`。I (文字化け) 用に `no-nfd`、`no-invalid-control-character`、`no-zero-width-spaces`、`no-hankaku-kana` も有効
    - **`preset-ai-writing`**: `no-ai-list-formatting`、`no-ai-hype-expressions`、`no-ai-emphasis-patterns`、`ai-tech-writing-guideline` の 4 つ
    - **`prh`**: `prh-llm-phrases.yml` を読む

    無効にしているルールは `arabic-kanji-numbers`、`no-mix-dearu-desumasu`、`ja-no-mixed-period`、`no-dropping-the-ra`、`no-exclamation-question-mark`、`ja-no-abusage`、`ja-no-successive-word`、`ja-unnatural-alphabet`、`max-comma`、`no-unmatched-pair`。

    パッケージは版を固定している: `textlint@14.8.4`、`textlint-rule-preset-ja-technical-writing@10.0.2`、`textlint-rule-preset-ai-writing@1.1.0`、`textlint-rule-prh@6.1.0`。実行時は `npx --min-release-age=7` を付ける (meiseki/SKILL.md Step 2、package.json)。

12. **yorisoi の textlint 設定は同じプリセットを読み手向けに締めている** (.agents/skills/yorisoi/references/textlint-yorisoi.config.json)。
    - `sentence-length` は 50、`max-kanji-continuous-len` は 4
    - `no-mix-dearu-desumasu` を有効にし、本文もリストも「ですます」に揃える
    - `ja-no-weak-phrase` は無効。「かもしれません」を消させないため (patterns-yorisoi.md YD)
    - `preset-ai-writing` は使わず、文字化け系ルールも無効
    - prh は `prh-yorisoi.yml` を読む

13. **同梱の prh 辞書は 2 本あり、どちらも検出専用**。`--fix` で自動置換はしない。`expected` は書き換えの方針を示すヒントで、置換文字列ではない。
    - **`prh-llm-phrases.yml`** には 3 つのセクションがある。
      - I 補完: U+FFFD を検出する。推測で復元させない
      - A1 補完: `no-double-negative-ja` が拾えない分離型 (「〜ないとは言えない」「〜なくはない」「〜は否定できない」「〜ないわけがない」) と丁寧形 (「〜ないわけではありません」「〜ないとは限りません」等) を検出する。統計の「仮説は否定できない」は除外する
      - G1〜G3 の定型句: 「重要なのは」「見ていきます」「多角的」「包括的」「不可欠」「鍵となる」「非常に」「極めて」「掘り下げ」「深掘り」「に他ならない」など
    - **`prh-yorisoi.yml`** は A1 補完 (meiseki と同じパターン) に加え、YC 受身、YD 推測、YE 敬語、YG 表記を検出する
    - 正当な用法が多い語 (「総合的」「要するに」など) は誤検知を避けるため辞書から外し、LLM の判断に残している (prh-llm-phrases.yml 冒頭コメント)

14. **PostToolUse hook は LLM を呼ばず、textlint だけで書き換えを差し戻す**。
    - 発動条件: 二重否定が 1 件以上、または指摘が計 3 件以上。満たすと `decision:"block"` で meiseki の適用を要求する
    - 判定の前に、コード・数式・引用・図表キャプション・参考文献セクション・脚注定義をマスクする
    - 同一セッションの同一ファイルへの block は最大 2 回。以降は警告に格下げする
    - textlint が動かない環境では書き込みを止めない (フェイルオープン)
    - 文字化けは block せず、警告だけ出す
    - 閾値は環境変数で差し替えられ、yorisoi 等の別ルールセットにも転用できる

    この閾値は hook 側の簡易基準で、スキル本体の受け入れ基準は before と after の相対比較にとどまる (README.md「自動適用 hook」。README は scripts/meiseki-check.sh 冒頭を参照先に挙げるが、蒸留時点の同ファイル冒頭コメントにこの記述は無い)。

15. **rikai の問題設計は「誤読の型」の一覧として使える** (.agents/skills/rikai/references/question-design.md §1・§4)。
    - 論点は主張 → 前提 → 例外の順で抽出する
    - ディストラクタ (誤答の選択肢) には、急いで読んだときに起こりうる誤読を使う。型は 6 つ: 条件と結論の逆転、対象範囲の拡大、必要条件と十分条件の混同、例外の見落とし、手順の順序違い、相関と因果の混同
    - 資料外の知識や極端な断定でひっかけを作らない

## 索引テーブル

| トピック | 原典パス | 一行説明 |
|---|---|---|
| 全体像・3 層構成・RLS・hook・Jev | README.md | 560 行。英語版は README.en.md |
| meiseki 本体の手順 | .agents/skills/meiseki/SKILL.md | §4 の 8 ステップ、§5 ガードレール、§7 RLS、§8 textlint が拾える／拾えないもの |
| 高負荷構文カタログ A–H | .agents/skills/meiseki/references/patterns.md | 267 行。各項目に Before／After と注意、末尾に全体の検算 |
| meiseki の textlint 設定 | .agents/skills/meiseki/references/textlint.config.json | 3 プリセットで有効・無効にしたルールの実体 |
| LLM 定型句と二重否定の補完辞書 | .agents/skills/meiseki/references/prh-llm-phrases.yml | I / A1 補完 / G1〜G3 の正規表現と expected |
| Markdown 構文のリグレッションガード | .agents/skills/meiseki/references/markdownlint.config.jsonc | `default:false` に 13 ルール。MD013 と MD041 を外した理由をコメントに記載 |
| 適用例と実測 RLS | examples/meiseki/README.md, examples/meiseki/*.before.md / *.after.md | 9 ペア。05 は「元から平易なので触らない」例、09 は学術文書の混在例 |
| yorisoi 本体の手順 | .agents/skills/yorisoi/SKILL.md | 変換モードと判定モード、YLS、Jev の同意ポリシー |
| やさしい日本語カタログ YA–YH | .agents/skills/yorisoi/references/patterns-yorisoi.md | 152 行。ガイドラインのステップ 1・2 との対応 |
| yorisoi の textlint 設定と prh 辞書 | .agents/skills/yorisoi/references/textlint-yorisoi.config.json, .agents/skills/yorisoi/references/prh-yorisoi.yml | 文長 50、漢字連続 4、ですます統一。YC/YD/YE/YG の検出パターン |
| 語彙レベル判定 | .agents/skills/yorisoi/scripts/vocab-check.js, .agents/skills/yorisoi/references/vocab/README.md | kuromoji で形態素に分けて同梱リストと照合。jReadability 近似の帯ラベル。JEV の置き方 |
| yorisoi の適用例 | examples/yorisoi/README.md | 3 ペア (お知らせ／表記／語彙) と実測 YLS |
| rikai の手順 | .agents/skills/rikai/SKILL.md | 7 ステップ。`.rikai/` の配置、卒業判定 (三回挑戦法)、出題を伴わない依頼 (進捗表示・手動の卒業と取り消し)、ガードレール |
| 問題とディストラクタの設計 | .agents/skills/rikai/references/question-design.md | 論点抽出、原文アンカー、誤読の型、別角度での再出題の規則 |
| 還流レポートの形式 | .agents/skills/rikai/references/study-format.md | study.md の frontmatter の状態、`manual_graduation`、§2.1 frontmatter に書ける YAML の範囲、書き手向けレポート |
| hook の判定コア | scripts/meiseki-lint-core.sh, scripts/meiseki-check.sh | マスキング、閾値、再実行ガード、上書きできる環境変数 |
| Jev ベンチ | experiments/jev-benchmark/README.md | 判定セット、再現手順、2026-10-11 と 10-12 の生データ |

## 蒸留の範囲外

- **Jev 層の運用全般**: キーの解決 4 経路、OS のセキュアストアへのキャッシュ、`.meiseki.json` のポリシー、`.meiseki-no-jev` マーカー、送信データと ZDR の扱いが該当する。いずれも外部 API (TypeSafe) 固有の話なので、README.md「Jev 高速判定層」と scripts/jev-judge.js を直接読む。
- **rikai の出題・採点・進捗表示の実装**: quiz-format.md、explainer-html.md、explainer-textbook.md、dashboard.md、scripts/build_quiz.py、quiz_server.py、build_textbook.py、build_dashboard.py が該当する。文章規範ではなくクイズアプリの仕様。v0.10.0 で足された進捗ダッシュボード (`.rikai/dashboard.html`、study.md から決定的に生成する読み取り専用 HTML) と手動の卒業 (`manual_graduation`。挑戦履歴には書かない) もここに含める。
- **jp-pdf**: .agents/skills/jp-pdf/。PDF の組版であり、文章の規則ではない。
- **プラグインの配布と install 手順**: .claude-plugin/、.codex-plugin/、hooks/、README.md「インストール」。
- **語彙リストの中身**: jlpt-tanos.csv (7973 行) と kokugoken-basic.csv (5540 行)。照合規則は vocab/README.md に書かれている。国語研の基本語二千は常に許容し、基本語彙六千の残りは目標が N4 より難しい側 (N4〜N1) のときに許容する。
- **原典内の食い違い** (蒸留時点の実測):
  - README.md の textlint 設定の節は `no-nfd` を無効化したルールに挙げている。しかし textlint.config.json では `no-nfd` が `true` で、カテゴリ I の検出に使われている。設定ファイルの値を正とする。
  - README.md「アーキテクチャ」が参照する `docs/diagrams/` は、この commit には存在しない。
  - README.md の見出しには「v0.6.0 から」等の版表記が残っている。package.json の版は 0.10.0。
  - vocab/README.md は基本語彙六千の残りを「目標レベルが N3 以上のとき」に許容すると書く。一方 vocab-check.js の実装 (`targetIdx >= LEVELS.indexOf('N4')`) は N4 から許容する。実装を正とした。
