# MAPPING: 原典の規則と ja-slop-review の対応表

自作の対応表。蒸留版 (`references/*.md`) は「原典に何が書いてあるか」の地図に限り、こちらは「原典の規則が
`ja-slop-review` のどこに入っているか / 入っていないか」を持つ。蒸留版と違い、**原典の SHA ではなく
`ja-slop-review` 側の変更で古くなる**ので鮮度チェックには乗らない。

見直すタイミング:

- `ja-slop-review` の SKILL.md / references を直したとき (取り込み候補を反映したときを含む)
- 対応表を持つ原典 (`textlint-rule-preset-ja-technical-writing`) を再蒸留したとき

作成時点: 2026-10-16 (`stop-ai-slop-jp` `e09d327` / `textlint-rule-preset-ja-technical-writing` `5e73caa` と照合)。
2026-10-17: `ja-slop-review` に修正モード・意味検算・修正の優先順位・構造パターン §11〜13・banlist の頻度原則を反映し、各表を更新。
2026-10-19: banlist に yomiyasu 由来の語彙 (チャット応答の名残・仮置きの残り・表示されない太字・大げさな役割名・英語直訳) と修正時の絵文字の扱い (natural-japanese) を、syntax-patterns §12・13 に間を作るだけの読点・数値の目安・成り立たない比喩を足し、banlist と syntax-patterns の行と textlint 表を更新。
2026-10-21: yomiyasu v2.1.0 / 2.1.1 (`fbe02c9`) から、修正時の確度に許可・能力・義務・保証を含める規則 (SKILL.md 手順 0)、意味検算に概数の印・どれか一つと全部・相関から因果を足し (手順 7)、syntax-patterns §12 に目的語の抜け・主題の掛かる範囲・前置きのない「〜のは、A、B、C。」を足して、SKILL.md § Process と syntax-patterns の行を更新。
2026-10-22: natural-japanese (`a708403`) から、分野の呼び名からずれた 1 語 (「入口」「要求」「効く」) を syntax-patterns §13 に、別コンテキストの読み手に A/B の 2 種だけ挙げさせる確認を SKILL.md 手順 6 に足し、§10 の例「この環境では効く」を差し替え、syntax-patterns の行を更新。
2026-10-23: natural-japanese v1.6.1 (`45ef3a0`。reader-check.md は `10bea80` で削除) と yomiyasu v2.2.0 (`a34d94f`) から、SKILL.md 手順 6 の別コンテキストの読み手を外して候補の洗い出しと書き手自身が当てる 2 つの問いに替え、syntax-patterns §13 を「書き手が思いついたたとえや言い換え」の捉え方に改めて直訳語の線引き (辞書の訳語の名詞・定着した言い方は残す) と作業用の名前・文書内の造語を足し、§2 に比喩ラベルの見出し、§8 にキャッチコピーの読点と他動詞の並び、§12 に評価を言い直すだけの文を、banlist に「〜と言えるでしょう」(Tier 1) と意味の薄いカタカナ語 (Tier 2) を足し、SKILL.md § Process・banlist・syntax-patterns の行を更新。
2026-10-23 (2 回目): yomiyasu v2.2.1 (`91964cd`) の calques.md § 4 から、syntax-patterns §13 に意味の広い語 (影響する・及ぶ 等) への差し替えと広い句を中身と並べて残すことの禁止、尋ねる条件 (動作をする人が材料に無い・呼び名がそろわない) を、§2 比喩ラベルの見出しに元の見出しの目的を残す規則を足し、syntax-patterns の行を更新。
2026-10-25: natural-japanese v1.6.2 (`9d3fd3b`) の SKILL.md §3 から、修正時に意味の取れる言葉を好みで言い換えない・読み手が取れない言い回しは banlist に無くても直す規則を SKILL.md 手順 0 に、技術の言い方の「定着」を仕様書・リファレンスで使うかで決める基準を syntax-patterns §13 に足した。yomiyasu v2.3.0 (`15244a1`) の SKILL.md § 主語と目的語の明確化から、和語の連用形 1 語の名詞 +「の」(「結果の確かめ」) を syntax-patterns §12 に足し、SKILL.md § Process と syntax-patterns の行を更新。
2026-10-25 (2 回目): yomiyasu v2.4.0 (`ae258d7`) から、英語の短い術語に当てた漢字 1 字の名詞 (版・頭・印) の直し方と残す使い方 (calques.md § 1 型 4・§ 3・§ 4) を syntax-patterns §13 に、原文に無い人や担当を主語や知らせる相手に足していないかの点検 (review-points.md「原文にない人や担当を足した文」) を SKILL.md 手順 7 に足し、banlist Tier 2「英語直訳」から §13 へ参照を張って、SKILL.md § Process・banlist・syntax-patterns の行を更新。
2026-10-28: natural-japanese v1.6.3 (`c7dd502`) から、語の組み合わせのずれが和語に開きすぎる向きにも起きること (SKILL.md §3 の 5 と確認手順、`8c1e88e`) を syntax-patterns §13 に足して §12 の和語の連用形の項から参照を張り、ふだんの外来語を漢語に言い換えない歯止め (SKILL.md §5 読みやすさの点検 3、`86cca92`) を banlist Tier 2「意味の薄いカタカナ語」に足して、banlist と syntax-patterns の行を更新。
2026-10-29: natural-japanese v1.6.4 (`25a8638`) から、中身を詰め込んだ括弧 (文・話の中身の列挙・呼び名の取り決めが入った括弧) の直し方 (まず前の文に入れる、入らないときだけ同じ主語の続きの一文にする、受け直すだけの文・関係を決める言葉を足さない、短い括弧・数値や出典の括弧・エッセイの余談の括弧は残す) と、新しく書くときに括弧に入れてよいもの (SKILL.md §3「いつでも直すもの」・§2 文の整え方、`56b8b53`・`8d5a5be`・`94f8d16`・`5e3fe13`) を syntax-patterns §12 に足し、banlist Tier 1「全角ダッシュ」の置き換え先の括弧を読点も句点もない短い補足に限って §12 へ参照を張り、banlist と syntax-patterns の行を更新。
2026-11-02: yomiyasu v2.5.0 (`29d67cc`) の SKILL.md § 3 出力フォーマットから、修正時の問いを本文に入れず本文の後の「書き手に確かめたい点」に置き、答えで本文の語句が変わる問いだけを最大 3 点にする規則を SKILL.md 手順 0 と Quick checklist に足し、banlist Tier 1「仮置きの残り」と rewrite-examples の【要確認】を同じ扱いに直した。AI 臭の強い文書 5 本の試行で、【要確認】が本文に 5 か所埋め込まれ、本文を変えない問い (説明の追加を求めるもの) も混じったため。
2026-11-09: natural-japanese v2.0.0 の critical-thinking (skills/critical-thinking/SKILL.md「指摘を反映して直すよう頼まれたとき」6) から、修正時に改訂の経緯 (「第1版では〜」・版番号・改訂日・「指摘を反映」の注記) を本文に書かない規則を SKILL.md 手順 0 に足し、SKILL.md § Process の行を更新。
2026-11-09 (2 回目): natural-japanese v1.6.5 (`81eb228`) の SKILL.md §6 冒頭から、本文の後にエージェント自身が書く問いや注記にも §12・§13 を当てる規則を SKILL.md 手順 0 に足した。yomiyasu v2.5.0 (`8394e09` 時点) から、syntax-patterns §1 にコード・システムの擬人化 (SKILL.md § 擬人化の解消)、§2 に依頼で指定された見出しの形を保つ歯止め (§ 案内用の見出し)、§3 に否定で終わる定義文 (§ セルフラベリングと否定対比の整理)、§12 に文頭の接続語のあとの読点を残す条件・短い区切りが続く文の読点・推敲で読点を足さない規則 (§ 文長と読点の調整、slop-catalog.md § 9、CHANGELOG § 2.5.0 の測定) と漢語の名詞で動作を省いた文 (§ 内容に合わない大げさな名詞の整理)、§13 に英語の句をなぞった 3 句 (slop-catalog.md § 10 の calque 型 3) と AI によく出る言い回し 7 形 (同 § 10 の ai_phrase) を足し、SKILL.md § Process と syntax-patterns の行を更新。7 形は人の報道文にも出るので、修正時は書き直さず、手順 0 の条件に当たるときだけ尋ねる形にした。

## stop-ai-slop-jp → ja-slop-review

原典は 0.1.1 (`e09d327`、2026-06) から更新が無く、規則は取り込み終えたので、2026-11-02 に蒸留版と clone を外した。この節は `e09d327` 時点の記録で、原典側の変更では古くならない。原典の箇所を確かめるときは GitHub の `e09d327` を見る。

`ja-slop-review` は原典の大原則・5 軸採点・構造/語彙の大半を英語見出しの散文スキルに組み替え、**文書種別による抑制**と **over-fix (過剰修正) への歯止め**を独自に足したもの。対照は `ja-slop-review` 側の各ファイル を本 clone と突き合わせた結果。

| ja-slop-review 側 | 原典の対応箇所 | 独自に足された・変えられた部分 |
|---|---|---|
| SKILL.md 冒頭〜§ When not to run | SKILL.md § 大原則 (3 問はほぼそのまま) | 3 問を 5 軸の前倒しと位置づけ衝突時は 5 軸優先 / formal 文書では「書き手 = 組織の立場」/ 体験の捏造禁止 (以上 § First principle) / 検出器が当てにならないという前提 (冒頭) / Quick path / When not to run / 1 文書 1 回まで (いずれも原典に無い) |
| SKILL.md § Process | SKILL.md § 修正の優先順位 | 原典の「立場 → 主体 → 構造 → 語彙 → 記号」と「語彙・記号だけ直しても残る」を手順 3 に取り込み、構文チェックを banlist より前に置いた。独自: 手順 0 の新規 / 修正の分岐と修正時の不増補、手順 0 の好みの言い換えをしない規則 (natural-japanese v1.6.2 `9d3fd3b` の SKILL.md §3)、手順 0 の改訂の経緯を書かない規則 (natural-japanese v2.0.0 の skills/critical-thinking/SKILL.md「指摘を反映して直す」6)、手順 0 の本文の後に自分で書く問いや注記にも §12・§13 を当てる規則 (natural-japanese v1.6.5 `81eb228` の SKILL.md §6 冒頭)、手順 0 の問いを本文に入れず本文の後に最大 3 点で置く規則 (yomiyasu v2.5.0 `29d67cc` の SKILL.md § 3 出力フォーマット)、手順 0 の確度に許可・能力・義務・保証を含める規則と手順 7 の意味検算 (概数の印・どれか一つと全部・相関から因果、原文に無い人や担当の追加 (yomiyasu v2.4.0 `ae258d7` の review-points.md) を含む)、手順 6 の呼び名の確認 (候補の洗い出しと、書き手自身が当てる 2 つの問い。natural-japanese `45ef3a0` の SKILL.md §6 と yomiyasu calques.md § 2 由来で、原典 stop-ai-slop-jp には無い。2026-10-22 に入れた別コンテキストの読み手は、natural-japanese が `10bea80` で references/reader-check.md ごと外したので除いた) |
| references/scoring.md | SKILL.md § 採点 (5 軸・35/50) | 修正時は全面書き直しでなく低い軸を局所的に直す / 具体性は材料から取り足さない / 35 以上でも重大な構文 slop は直す / 低い・高いの列 / 「立場 ≠ 無根拠な断言」/ 段落あたり 1 つの固有名・数値 / 採点例 2 本。音読の測り方はクイックチェック冒頭の転用 |
| references/banlist.md | references/phrases.md § 1・2・3 (横文字メタファーのみ)・4 (強い評価+根拠なし、三段ヘッジ → Tier 3「Necessary hedges (1 まで)」)・5・7・8 | **3 段 Tier (常時禁止 / 原則回避 / 文脈次第) は独自**。Tier 2 冒頭に原典の頻度原則 (1〜2 回なら自然・全部消さない) を入れ、働きのある前置き・メタ構造宣言を Tier 1 から Tier 2 へ移した。便利語 (課題 / 活用 / 推進…)、冗長語尾「〜することができます」、根拠なし強評価の「ゲームチェンジャー」は原典に無い追加。全角ダッシュは文書種別で線引き (説明文では挿入用法も置き換え、yomiyasu 由来。置き換え先の括弧を短い補足に限るのは natural-japanese v1.6.4 `25a8638` の SKILL.md §2 文の整え方)、装飾絵文字は常時禁止へ締めた (修正時は書き手の癖として文中に使う絵文字を残す、natural-japanese 由来)。yomiyasu slop-catalog 由来の追加: Tier 1 のチャット応答の名残・仮置きの残り (§ 6)、表示されない太字 (gemini-syntax.md 原則 14)、Tier 2 の大げさな役割名 (§ 5)・英語直訳 (§ 2)、v2.2.0 (`a34d94f`) の Tier 1「〜と言えるでしょう」(§ 6 文末の付け足し) と Tier 2 意味の薄いカタカナ語 (§ 5)、英語直訳の「頭」「印」(v2.4.0 `ae258d7` の calques.md 型 4。直し方は syntax-patterns §13)。意味の薄いカタカナ語の直す対象を意味の取り方が割れる語に限り、ふだんの外来語を漢語に替えない歯止めは natural-japanese v1.6.3 (`86cca92`) の SKILL.md §5 読みやすさの点検 3。冗長語尾は AI らしさでなく冗長さの扱いと注記 (natural-japanese の測定) |
| references/syntax-patterns.md | references/structures.md § 1-1・1-3 (→ 1)、3-1 (→ 2)、2-1・2-2 (→ 3)、3-2 (→ 4)、3-4 (→ 5)、3-5 (→ 6)、4-4 (→ 7)、4-5 (→ 8)、3-3 (→ 9)、5-2・5-3 (→ 10)、1-2・2-3・4-3・6-1 (→ 11) | 独自 (他原典由来): false agency を感情・意志の擬人化と人の判断の抽象名詞化に限定 (yomiyasu)、打ち消し 3 種と密度目安 (natural-japanese)、文末は文体統一のまま長さと組み立てで変える (natural-japanese / yomiyasu / ja-technical-writing)、§12 読解負荷 (meiseki。間を作るだけの読点は yomiyasu slop-catalog § 9、数値の目安は ja-technical-writing、目的語の抜け・主題の掛かる範囲・前置きのない「〜のは、A、B、C。」は yomiyasu v2.1.0 の SKILL.md § 主語と目的語の明確化・§ コピー調の抑制、評価を言い直すだけの文は yomiyasu v2.2.0 slop-catalog § 5、和語の連用形 1 語の名詞 +「の」は yomiyasu v2.3.0 (`15244a1`) の SKILL.md § 主語と目的語の明確化、中身を詰め込んだ括弧は natural-japanese v1.6.4 (`25a8638`) の SKILL.md §3「いつでも直すもの」・§2 文の整え方 (`56b8b53`・`8d5a5be`・`94f8d16`・`5e3fe13`))、§2 比喩ラベルの見出し (yomiyasu v2.2.0 SKILL.md § 案内用の見出し・slop-catalog § 5。元の見出しの目的を残す規則は v2.2.1 calques.md § 4)、§8 キャッチコピーの読点と他動詞の並び (yomiyasu v2.2.0 slop-catalog § 9・SKILL.md § コピー調の抑制)、§13 読み手が取れない言い回し (natural-japanese。成り立たない比喩は yomiyasu slop-catalog § 8、分野の呼び名からずれた 1 語と作業用の名前・文書内の造語は natural-japanese `45ef3a0` の SKILL.md §2 原則 4 (`717d8e0`・`ee007f5`)、直訳語との線引きと関係で書き直す直し方は yomiyasu calques.md § 2〜4、意味の広い語への差し替え禁止と尋ねる条件の拡張は v2.2.1 (`91964cd`) の calques.md § 4・5、「定着」を仕様書・リファレンスで使うかで決める基準は natural-japanese v1.6.2 の SKILL.md §3、漢字 1 字の名詞 (版・頭・印) の直し方は yomiyasu v2.4.0 (`ae258d7`) の calques.md § 1 型 4・§ 3・§ 4、語の組み合わせのずれの両向き (和語に開きすぎる向きを含む) と会話で言うかの確かめ方は natural-japanese v1.6.3 (`8c1e88e`) の SKILL.md §3 の 5 と確認手順。旧出所の references/reader-check.md は `10bea80` で削除済み) / 組織・人主語は false agency ではないという注記 / 中身のある要点見出しは命題型でも可 / 「件数ではなく修正時間で測る」のように実質的な選択なら「XではなくY」の否定形のまま残してよい (原典 § 2-1 も違いを具体的に書く対比は認めるが、否定で並べる形は避けよとする) / ❌/✅ を図解にも適用 / yomiyasu v2.5.0 由来の追加 (2026-11-09): §1 コード・システムの擬人化 (SKILL.md § 擬人化の解消)、§2 依頼で指定された見出しの形を保つ (§ 案内用の見出し)、§3 否定で終わる定義文 (§ セルフラベリングと否定対比の整理)、§12 文頭の接続語のあとの読点を残す・短い区切りが続く文・推敲で読点を足さない (§ 文長と読点の調整、slop-catalog.md § 9) と漢語の名詞で動作を省いた文 (§ 内容に合わない大げさな名詞の整理)、§13 英語の句をなぞった 3 句と AI によく出る言い回し 7 形 (slop-catalog.md § 10。7 形は修正時に書き直さない) |
| references/variance.md | references/structures.md § 4-1 (ムラ 5 種)・4-2・4-5 | 文書種別の予算内でのみ / 修正時はムラを理由に直さない / 停止条件 (ブリーフィング等で誤字・毒を足し始めたら止める、強引な一言が全段落に付いたら新しいテンプレ) |
| references/rewrite-examples.md | 対応なし (examples.md の 17 例は 1 本も移していない) | 5 例すべて独自 (ブリーフィング・セキュリティ題材)。D は新規執筆と修正時の 2 通りの fix、E は敬体を保つ fix に改めた。各例に over-fix 欄を持つのは原典に無い型 |
| references/document-types.md | 対応なし | 全体が独自。原典は個人記事前提で文書種別の規定を持たない。毒・誤字・カジュアル一人称を formal 文書で除外し、「わざとの誤字運用は避ける」とする |

原典にあって `ja-slop-review` のどこにも無いもの (grep で確認): 形容詞・心情への「」(SKILL.md ルール 13)、中黒並列 (ルール 14)、過剰なカタカナ表と英語固有名詞の律儀さ (phrases.md § 3)、結論回避・三段ヘッジ・曖昧な断言・弱い否定の各リスト (§ 4。結論回避は例 D にのみ)、根拠なし副詞・「すぎる」・(笑) の頻度上限 (§ 6)、全角に紛れた半角スペース (§ 8)。翻訳調動詞と必殺技造語も一部の語が抜けている (例: 対比をなしている・捉える・論じる、虚飾・禁欲的・冷徹)。

## textlint-rule-preset-ja-technical-writing → ja-slop-review

**原典は LLM・生成文・AI に一切言及しない** (README.md / CHANGELOG.md を検索して確認)。以下は原典の規則を `ja-slop-review` の項目に当てた対応で、原典の主張ではない。

| preset ルール | ja-slop-review 側 | 関係 |
|---|---|---|
| `ja-no-redundant-expression` (することができる) | references/banlist.md Tier 2「冗長語尾」 | 同じ例。preset は機械検出できる。ja-slop-review も AI らしさでなく冗長さとして扱う |
| `ja-no-weak-phrase` | references/banlist.md Tier 3「Necessary hedges (1 まで)」・syntax-patterns.md §10 | preset は技術文書で全面禁止、ja-slop-review は本物の不確実性なら 1 回まで許容 |
| `no-exclamation-question-mark` | syntax-patterns.md §8「技術文書では問いを入れない」 | 一致 (2026-10-17 に処方を反転) |
| `no-mix-dearu-desumasu` | syntax-patterns.md §8「敬体か常体のどちらかで統一」 | 一致 (2026-10-17 に処方を反転。根拠としてこのルール名を引いている) |
| `sentence-length` / `max-ten` / `max-kanji-continuous-len` | syntax-patterns.md §12「数値の目安」・§9「一文圧縮」・variance.md「文長のムラ」 | 一致。§12 が preset の既定値 (100 字・読点 3 個・漢字 6 字) を技術文書の目安として引く |
| `no-doubled-joshi` の処方 (強調語「実際に」を削る) | banlist.md / syntax-patterns.md の削減方針 | 方向は同じ |
