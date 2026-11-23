---
source: https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing
distilled_commit: 3a9833da89624f90e37f39ac1bf0fea9d0072ecc
distilled_at: 2026-11-24
---

# textlint-rule-preset-ja-technical-writing 蒸留版

技術文書向け textlint ルールプリセット (作者 azu、MIT)。23 ルールを束ね、各ルールの既定値を決める。**この蒸留版は「日本語技術文書の機械的規則と数値閾値 (文長 100 字・読点 3・漢字連続 6 など) の出所」の索引**。各ルールの検出ロジックや例外の詳細は個別ルールのリポジトリ側にあり、この clone には無い。

## Contents

- まず押さえる
- 版情報
- ルール一覧 (既定値・理由・変更履歴)
- 導入と個別無効化
- 索引テーブル
- 蒸留の範囲外

## まず押さえる

1. **原典自身が「全体的に少し厳しめ」と宣言**している。文章に合わせて設定値を変える前提で、漢字連続 6 字のように例外が必ず出るルールも既定で入っている。例外は `allow` オプションか filter ルール (textlint-filter-rule-comments / -allowlist) で明示する想定 (README.md 冒頭)
2. **数値閾値は 4 つだけ**: 1 文 100 字以下 (`sentence-length`)、カンマ 1 文 3 個まで (`max-comma`)、読点 1 文 3 個まで (`max-ten`)、漢字連続 6 字まで (`max-kanji-continuous-len`)。他は on/off か文体指定 (lib/textlint-rule-preset-ja-technical-writing.js `rulesConfig`)
3. **文長は「厳しめなら 90 字」を推奨**。既定は v3.0.0 以降 100 字、v2.0.0 以下は 90 字 (README.md「1文の長さは100文字以下とする」)。v7.0.0 から URL そのものがリンクになっている箇所は文長に数えない。v8.0.0 で `exclusionPatterns` 廃止 → `skipPatterns` (CHANGELOG.md)
4. **文体の既定は場所で分ける**: 見出しは自動 (`preferInHeader: ""`)、本文はですます、箇条書きはである、`strict: false`。v10.0.0 から「文体は統一されているが prefer と違う」場合もエラー (以前は通っていた) (README.md・CHANGELOG.md 10.0.0)
5. **弱い表現は全面禁止**: `〜かもしれない` `〜と思います` 等を「技術文書で曖昧な表現を避ける」ために使わない (README.md `ja-no-weak-phrase`)。程度の許容枠は preset 側に無い
6. **感嘆符・疑問符 (!！?？) は技術文書では基本使わない**。使うならオプションで許可するかコメントで無視 (README.md `no-exclamation-question-mark`)
7. **冗長表現の代表例は「することができる」→「できる」** (README.md `ja-no-redundant-expression`)
8. **同じ助詞の連続への処方が最も具体的**: 助詞の書き間違いを直す / 文を分割する / 語順を入れ替えるか箇条書きで整理する / 「実際に」等の強調語を削る。直す余地が無ければコメントで無視 (README.md「同じ助詞を連続して使用しない」)
9. **逆接の「が」は否定の意味でなくても安易に使われがち**なので 1 文に複数出さない (lib の rulesConfig コメント・README.md)
10. **SemVer 方針: 既定値の変更・ルール追加・削除は Major**。警告を増やすバグ修正と新オプションは Minor、警告を減らす修正は Patch。安定版は半年ごと (1 月と 7 月)、`@next` で次期版を試せる (README.md「Semantic Versioning Policy」「Install」)
11. **コミットメッセージと diff が逆のものがある**: c3e69fe (2018-07-10) の件名は「100文字から90文字へ変更」だが、実 diff は `max: 90` → `max: 100`。履歴は README の記述 (v3.0.0+ が 100 字) と diff を正とする

## 版情報

- package.json の版は **12.1.0** (fe7b35c、2026-11-22)。12.1.0 の中身は cf1c86d (#222) の**ルール依存の一括更新だけ**で、kuromojin 3.1.0 に依存する各ルールの最新版へ上げ、`engines` を外して Minor リリースにしている (commit message)。`lib/` は不変で、ルール構成・既定値に変化は無い。個別ルール側の検出挙動の差分はこの clone では確かめられない。12.0.0〜12.0.2 はいずれも再リリース・CI 修正のみ (CHANGELOG.md)。preset の既定値 (`rulesConfig` の値) が最後に変わったのは **v3.0.0** (c3e69fe、文長 90→100、2018-07) で、以後は moduleInterop 化・ルール追加・URL 修正のみ (`git log -- lib`)。判定挙動が最後に厳しくなった Major は **10.0.0** (依存ルール no-mix-dearu-desumasu v6 追従で、preset の値は不変)。ルール構成が最後に変わったのは **7.0.0** (no-zero-width-spaces 追加、2021-07)
- 中身 (README) の最終更新は **2025-08-20** (1711aed、Online Demo 節の追加のみ)。preset 定義 `lib/textlint-rule-preset-ja-technical-writing.js` の最終変更は 2023-02-12 (856c3f4、URL 修正)
- 1711aed より後のコミット (HEAD 3a9833d まで) は依存更新・CI・リリース手順の変更だけ。ルール・既定値・README に変化は無い
- **リリース手順が changesets から Release PR 方式に変わった** (cf1c86d): `.changeset/` を削除し、`Type: Release` の PR をマージすると npm へ staged publish する。リリースノートは Release PR の本文 → GitHub Release に書くため、**CHANGELOG.md は 12.0.2 で止まっている**。README の「Version Packages の PR で次期版との差分を確認」「Release Flow」の記述は旧手順のまま更新されていない
- package.json の `files` は `src/` を挙げるが、リポジトリに `src/` は存在しない。preset 本体は `lib/` 直書きの 1 ファイル

## ルール一覧 (既定値・理由・変更履歴)

preset 内キー名 → 既定値 → 理由 (README / lib コメントの要約) → 履歴。履歴欄は git log から確認できたものだけ書く。

| ルール (preset 内キー) | 既定値 | 理由 | 既定値・構成の変更履歴 |
|---|---|---|---|
| `sentence-length` | `max: 100` | 長すぎる文は読みにくい。句点で区切る | 初期 90 → v3.0.0 で 100 (c3e69fe)。v7 URL リンク除外、v8 `skipPatterns` へ |
| `max-comma` | `max: 3` | カンマ多用は文が長い兆候 | 初期から 3 |
| `max-ten` | `max: 3` | 読点多用は文が長い兆候 | 初期から 3 |
| `max-kanji-continuous-len` | `max: 6` (README の JSON は `allow: []` も併記) | 漢字連続は読みにくい。6 字超の固有名詞は `allow` へ | 初期 5 → 2017-11 に 6 (2ddaee6, #22) |
| `arabic-kanji-numbers` | `true` | 数えられる量・序数詞は算用数字、慣用句・熟語・概数・固有名詞・副詞は漢数字 (JTF スタイルガイド 2.2.2) | preset-jtf-style から 1 ルールだけ流用 |
| `no-mix-dearu-desumasu` | 見出し自動 / 本文ですます / 箇条書きである / `strict: false` | 見出し・本文・箇条書きの各内部で文体を統一 | `strict` 初期 true → 2016-07 に false (456ba20)。v10.0.0 で prefer 違反も検出 |
| `ja-no-mixed-period` | `periodMark: "。"` | 文末は「。」。付け忘れと「:」終わりを防ぐ | 初期から |
| `no-double-negative-ja` | `true` | 二重否定は読みにくい | 初期から |
| `no-dropping-the-ra` | `true` | ら抜きは話し言葉 | 初期から |
| `no-doubled-conjunctive-particle-ga` | `true` | 逆接「が」は安易に使われがち。1 文内の重複を検出 | 初期から |
| `no-doubled-conjunction` | `true` | 「しかし、〜。しかし、〜」の連続は読みにくい | 初期から |
| `no-doubled-joshi` | `min_interval: 1` | 1 文中の同じ助詞の連続は読みにくい | 初期から |
| `no-nfd` | `true` | UTF8-MAC 濁点 (コピペ由来) を入れない | 初期から |
| `no-invalid-control-character` | `true` | 改行・タブ以外の制御文字は文字化けの原因 | 2018-07 追加 (4eed026)。v7 で img alt も検査 |
| `no-zero-width-spaces` | `true` | ゼロ幅スペース (`\u200b`) の混入防止 | v7.0.0 で追加 (6c1d348, 2021-07) |
| `no-exclamation-question-mark` | `true` | 技術文書では基本使わない | 初期から |
| `no-hankaku-kana` | `true` | 全角カタカナを使う | 初期から |
| `ja-no-weak-phrase` | `true` | 「かもしれない」「と思います」等の曖昧表現を避ける | 初期から |
| `ja-no-successive-word` | `true` | 同一 token の連続は入力ミスの可能性 | 初期から |
| `ja-no-abusage` | `true` | 漢字・技術表現の誤用 | 初期から |
| `ja-no-redundant-expression` | `true` | 省いても意味が通る表現 (することができる → できる) | 2017-11 追加 (a50f1ef) |
| `ja-unnatural-alphabet` | `true` | `リイr−ス` 型の IME 入力ミス | 2019-03 追加 (fcddd8d) |
| `no-unmatched-pair` | `true` | 1 文中で対になっていない括弧 | 2019-07 追加 (6dd27c2) |

`test/textlint-rule-preset-ja-technical-writing-test.js` は `rules` と `rulesConfig` のキー集合が一致することだけを検査する。

## 導入と個別無効化

- 導入: `npm install textlint-rule-preset-ja-technical-writing`。`.textlintrc.json` に `{"rules": {"preset-ja-technical-writing": true}}` (推奨)、CLI なら `textlint --preset ja-technical-writing README.md` (README.md「Usage」)
- 設定変更・無効化: preset キーの値をオブジェクトにし、ルール名をキーに置く。無効化は `"no-mix-dearu-desumasu": false`、値の変更は各ルール節の形 `"sentence-length": {"max": 100}` (README.md 各ルール節)。なお「ルールの設定方法」節の例は `"max": 120` をルール名なしで preset 直下に置いており、各ルール節の書き方と一致しない
- 文書内の部分無効化: filter-rule-comments を有効にし、`<!-- textlint-disable preset-ja-technical-writing/<rule> -->` のように `preset名/ルール名` で指定する。原典 README 自体がこの形で `no-mix-dearu-desumasu` と `no-exclamation-question-mark` を外し、`example/.textlintrc.json` (`"filters": {"comments": true}`) で自分の README を lint している
- 各ルールの全オプションは個別ルールの README を見る (この clone には無い)

## 索引テーブル

| トピック | 原典パス | 一行説明 |
|---|---|---|
| ルールの束ねと既定値の実体 | lib/textlint-rule-preset-ja-technical-writing.js | `rules` (23 個) と `rulesConfig`。各既定値に理由コメントと個別ルール URL |
| ルールごとの説明・既定値 JSON | README.md「ルール一覧」 | 23 節。文長の版別履歴、助詞連続の処方はここだけ |
| 導入・設定・filter | README.md「Install」「Usage」「ルールの設定方法」 | `.textlintrc.json` / CLI / `@next` / filter ルール 2 種 |
| 版ごとの破壊的変更 | CHANGELOG.md | 7.0.0〜12.0.2。Node.js 要件、sentence-splitter v5、文体 v6。12.1.0 以降は GitHub Releases のみ |
| バージョニング方針 | README.md「Semantic Versioning Policy」「Release Flow」 | Major/Minor/Patch の判定基準、半年リリース |
| 自己 lint の構成例 | example/.textlintrc.json, example/package.json | preset + comments filter で README を lint |
| キー整合テスト | test/textlint-rule-preset-ja-technical-writing-test.js | rules と rulesConfig のキー一致のみ |
| 既定値の変遷 | git log -p -- lib/ | 2ddaee6 (漢字 5→6)、c3e69fe (文長 90→100)、456ba20 (strict false) |

## 蒸留の範囲外

- **各ルールの検出ロジック・オプション全量・例外**: 個別ルールのリポジトリ (lib の rulesConfig コメントと README 各節の URL)。特に `ja-no-weak-phrase` の対象語一覧、`no-doubled-joshi` の例外と `allow`、`no-mix-dearu-desumasu` の `strict` の意味、`ja-no-redundant-expression` の辞書はここに無い
- **JTF スタイルガイド全体**: preset が使うのは `2.2.2.算用数字と漢数字の使い分け` の 1 ルールだけ。残りは textlint-rule-preset-JTF-style と JTF 日本語標準スタイルガイド側
- **CHANGELOG 7.0.0 より前の変更**: CHANGELOG.md に無い。README は GitHub Releases を参照させている。この clone では git log で辿るしかない
- **Online Demo の挙動**: README のリンク先 (GitHub Pages)。`.github/workflows/website.yml` が `@textlint/website-generator` で生成する
- **リリース自動化** (.github/workflows/create-release-pr.yml・release.yml ほか, .agents/skills/release-notes/, renovate.json): ルール内容に関係しない
