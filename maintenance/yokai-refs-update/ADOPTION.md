# 取り込み候補台帳 (ADOPTION)

`/yokai-refs-update` の手順6が追記する台帳。原典 (`~/.local/share/yokai-harness/references/`) の変更のうち、
**このハーネス自身や運用に手を入れるべきもの**を記録し、対応するまで消さない。蒸留版の SHA を進めても
自分のハーネスは自動では直らない — その落差をここで埋める。

## 書式

エントリは日付の新しいものを上に置く。1 項目 1 行のテーブルで、列は固定:

| 列 | 内容 |
|---|---|
| 状態 | `未対応` / `対応済 (SHA または日付)` / `却下 (理由)` |
| 深刻度 | `BREAKING` (今の書き方が壊れている) / `RECOMMENDED` / `FYI` — 定義は [DISTILLING.md](DISTILLING.md) |
| 対象 | `CLAUDE.md` / `skill` / `subagent` / `hook` / `settings` / `MCP` / `運用` |
| 内容 | 何を直すのか。壊れている書き方も書く |
| 根拠 | 原典の相対パスまたは commit SHA (どの repo かは節見出しで示す) |

規律 3 つ:

- **grep で実ハーネスに当ててから載せる。** 原典の記述として正しくても、このハーネスに当たらなければ `FYI`。推測での「影響あり」は台帳を腐らせる
- **却下も残す。** 消すと同じ候補が毎回上がってくる。却下理由を書けば次回の判断が要らない
- **対応済は消さずに畳む。** 判断の履歴が provenance になる (原典側が結論を撤回することがある)
- **環境固有・機密の値を書かない。** この repo は公開されている。アカウント ID・ホスト名・IP・バケット名・
  ユーザー名・社内組織名や、permission / soft_deny ルールの具体的な中身は台帳に載せない。書くのは
  「どの設計上の判断が要るか」までで、値は環境側 (`~/.claude/`) に置く。影響対象を示すのに具体値が
  必要になったら、それは台帳ではなく環境側に書くべき項目

---
## 2026-11-01

### 再蒸留 (claude-code-best-practice) から

今回は取り込み候補なし。`4f5224c` までの 13 commit は commands 表の Ultra プラン追記 (`/privacy-settings`・`/usage`・`/restart`・`/auto-mode-setup`) と 4 件の説明補足、skills・subagents・concepts のバッジと drift ログ、ワークフロー / コレクション表の数値更新だけ。`/restart` の WSL 対象外は 2026-10-31 に却下済みで変化なし。concepts run が v2.1.316 の変更として名前だけ挙げた `CLAUDE_CODE_DISABLE_ULTRATHINK`・`managed.policy_mode: layered` は settings 表に無く未検証なので載せない。

---
## 2026-10-31

### 再蒸留 (yomiyasu v2.5.0) から

banlist.md と syntax-patterns.md は全文を Read して照合した (Grep ツールが無い環境)。ja-slop-review の他の references は未照合。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 未対応 | RECOMMENDED | skill | ja-slop-review に、AI の文章によく出る言い回し 7 形 (「〜という見立てです」「〜に潜むリスク」「〜が招く＋名詞」「今や〜に欠かせない存在」「〜という挙動を排除」「なんよ」「〜して、〜を＋漢語の名詞。」) が無い。原典は禁止語ではなく「何が足りない文か」と確かめる問いの組で持ち、材料が無ければ残して尋ねる。人のニュース記事にも出るので、入れるなら banlist の置き換え式ではなく syntax-patterns に問いの形で | skills/yomiyasu/references/slop-catalog.md § 10、CHANGELOG.md § 2.5.0 |
| 未対応 | RECOMMENDED | skill | syntax-patterns.md §13 (英語の直訳) に型 3 の 3 句が無い: 「そこで効くのは / ここで効いてくるのが」、「プロジェクト / 組織レベルの〜」、案が主語の「テーブルの上にある」。文字どおりの「効く」・OS の層の「レベル」・表の「テーブル」は除外 | slop-catalog.md § 10、CHANGELOG.md § 2.5.0 |
| 未対応 | RECOMMENDED | skill | syntax-patterns.md §12 (間を作るだけの読点) は外す規則だけで、「推敲で読点を足さない」「短い区切りが続く文は文頭の接続語のあと以外を外す」が無い。AI と人の差は読点の数でなく位置 (短い主題・主語のあと約 1.7 倍、短い目的語の「を、」のあと約 3.4 倍) という測定も書ける | SKILL.md § 文長と読点の調整、slop-catalog.md § 9、CHANGELOG.md § 2.5.0 |
| 未対応 | RECOMMENDED | skill | syntax-patterns.md に推敲手順 4 つが無い: コードを説明する文の擬人化 (「知っている」「門番」等は動作が分かるときだけ書き直し、「責務を持つ」「委譲する」は残す)、否定で終わる定義文、漢語の名詞だけで動作を省いた文 (「申請と承認を分離する」)、依頼で指定された見出しの形を保つこと | SKILL.md § 擬人化の解消・§ セルフラベリングと否定対比の整理・§ 案内用の見出し |
| 却下 (§13 は定着した言い方を語の形で決めていないので当たらない) | FYI | skill | lint の型 1 が「テストがまだ通らない」のように副詞が挟まった定着した言い方に誤って指摘を出していたのを、挟まってよい副詞 20 語の一覧で直した | CHANGELOG.md § 2.5.0 lint |
| 却下 (このハーネスの skill はスクリプト実行を allowed-tools で配る形を取っておらず、原典の確認範囲も macOS の `claude -p` だけ) | FYI | skill / settings | SKILL.md の `allowed-tools` を付属スクリプトの呼び出しに絞った 6 ルールにし、`claude -p --permission-mode dontAsk` でも検査が動く。許可は呼んだターンだけ有効 | skills/yomiyasu/SKILL.md frontmatter、CHANGELOG.md § 2.5.0 |

### 再蒸留 (claude-code-best-practice / awesome-harness-engineering) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (この環境は WSL で対象外。~/.claude の設定は Grep ツールが無く未照合) | FYI | 運用 | `/restart` (alias `/update`、v2.1.288+) はインストール済みの更新を適用してセッションを再開する。Pro/Max かつ macOS/Linux の native install が要件で、WSL は対象外 | ccbp: `2cb4da5`、`best-practice/claude-commands.md` #91 |
| 却下 (このハーネスは `--settings` で skill の可視性を配っていない。未照合) | FYI | skill | `/skills` 画面で可視性を切り替えられない skill に、`--settings` フラグ指定の skill が加わった (plugin skill・`disable-model-invocation: true`・managed の `skillOverrides` と同じ扱い) | ccbp: `2cb4da5`、`best-practice/claude-commands.md` #53 |
| 未対応 | FYI | skill | AgentCraft の同一 brief 試験で、インストール数上位のデザイン skill 8 個のうち no-skill の control から見た目を動かしたのは 2 個だけだった。自作の ui-design / visual-slop-review を同じ型 (同一 brief・control run) で確かめていない | ahe: `2a035cb`、`README.md` の `Skills & MCP` (README の注記ベース、記事本文は未検証) |

hallmark (`4f6a46c`、theme.mjs が CRLF の frontmatter を受け付ける修正と、sloplint が symlink の循環ディレクトリを重ねて走査しない修正) と smarthr-design-system (`1881998`、lint-staged の設定だけ) は規則・文書に変更が無く、候補なし。

---
## 2026-10-30

### 再蒸留 (claude-cookbooks / awesome-harness-engineering) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: この repo で `claude-haiku-4-5` を含むのは蒸留版・台帳の引用だけ (`git log -S` で追加は `32d76c3` の 1 件)、~/.claude/settings.json にモデル指定なし。Grep ツールが使えず ~/.claude/agents/ は未照合) | FYI | subagent / hook | Haiku の既定が `claude-haiku-5-5` になり、`claude-haiku-4-5` (と `-20251001`) は `SUPERSEDED_MODELS` (warning、retire ではない) に入った。assistant prefill を受け付けるのは Haiku 4.5 だけなので、prefill に頼る呼び出しは一律に置き換えない (原典も 2 本を 4.5 に固定) | cookbooks: `c43f56d`、`CLAUDE.md`、`scripts/validate_all_notebooks.py` (`SUPERSEDED_MODELS`・`PINNED_LEGACY_NOTEBOOKS`) |
| 却下 (ハーネスの自動改善ループを持たない。失敗の再発防止は人手で CLAUDE.md・hook に入れている (2026-10-25 の HarnessFix の行と同じ)。README の注記ベースで論文本文は未読) | FYI | 運用 | Harness Evolution Hits a Ceiling (arXiv 2610.11655): 自己進化ループは process 失敗 (block・ループ・step 予算切れ) は直せるが content 失敗で頭打ちになる。失敗を 2 種に分けて診断し、content 側はハーネス編集以外 (LoRA) で当てる | ahe: `03e5733`、`README.md` の `Generators & Meta-Harnesses` |

claude-code-best-practice (`c0e47f1`、10-29 の v2.1.312 run。commands 表に `/design consent`・`/design revoke` が入り 95 個、`/focus` のシグネチャ修正、subagents の ON HOLD 継続、skills・CONCEPTS は no drift) は候補なし。`/design consent` は 10-22・10-25 に INVALID だった判定の 1 run での反転なので昇格させない。skills (`ca45fc4`、mcp-builder を MCP TypeScript SDK v2 に)・awesome-design-md (`fcc7028` ほか、README のバナー差し替え)・smarthr-design-system (`4538b70`、色トークンページ・Base 非推奨化・依存更新で contents/ に変更なし) は候補なし。

---
## 2026-10-29

### 再蒸留 (natural-japanese v1.6.4) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-29: syntax-patterns.md §12 に「中身を詰め込んだ括弧」を足し、MAPPING.md 更新) | RECOMMENDED | skill | ja-slop-review に括弧の詰め込みを扱う規則が無かった (§9 一文圧縮は年代・人名・評価を 1 文に詰める話で別物)。原典は文・話の中身の列挙・呼び名の取り決めが入った括弧を直す対象とし、まず前の文に入れ、入らないときだけ同じ主語の続きの一文にする。受け直すだけの文や関係を決める言葉は足さない。短い括弧・数値や出典の括弧・エッセイの余談の括弧は残す | skills/natural-japanese/SKILL.md §3「いつでも直すもの」・§2 文の整え方 (`56b8b53`・`8d5a5be`・`94f8d16`・`5e3fe13`) |
| 対応済 (2026-10-29: banlist.md Tier 1「全角ダッシュ」に条件と §12 への参照を追記、MAPPING.md 更新) | RECOMMENDED | skill | Tier 1「全角ダッシュ」は置き換え先に無条件で「括弧」を挙げており、ダッシュで挟んだ文や列挙をそのまま括弧へ移すと上の新規則に当たる形を作っていた。括弧に移すのは読点も句点もない短い補足だけに限った | skills/natural-japanese/SKILL.md §2 文の整え方 |
| 却下 (ja-slop-review は lint.py を使わず、natural-japanese プラグインは settings.json で無効。必要時は natural-japanese.md の読解負荷レーンから引ける) | FYI | skill | `lint.py --reading-load` が括弧内の文を `sentence_in_paren` として示す。人の文章でも 1 割前後の文書に出るので AI らしさの判定には使わず、読みにくさの指摘として扱う | skills/natural-japanese/scripts/lint.py (`699ba6f`) |

### 再蒸留 (hallmark) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-29: color-chroma.md の集計と ui-design SKILL.md の「30 個中 17 個」を数え直し) | RECOMMENDED | skill | テーマが 48 → 50 個 (Refract atmospheric・light、Vantage modern-minimal・dark) になり、ライト地色は 31 個。Refract の地 `oklch(98.2% 0.006 95)` は C 0.006 で白側なので暖色クリームは 17 個のまま、白に近い地は 10 個、gate 65 の地の条件を満たすのは 24 個、accent C 0.16 超は 29 個。ROADMAP § Now の cream の扱いは未決定のまま | skills/hallmark/references/themes/refract.md・vantage.md・index.json (`2a1240f`)、ROADMAP.md § Now |
| 却下 (web-ui.md に時刻表の tell は無いが、web-ui.md は計測・批評の出典付きカタログで、hallmark の生成規律は hallmark.md「まず押さえる」9 から引ける。次の web-ui.md 棚卸しで一次記事が見つかれば足す) | FYI | skill | Schedule (時刻表) は訪問者が選ぶ・予定に組む時刻にだけ使い、工程・1 日の業務・配送を時刻で語るのは既定値への落ち込みとする。Steps・Figures・Schedule は生成ページの大半に出るが、作られたページでは選ぶもの | skills/hallmark/references/layout.md § 5 の 16・§ 7 (`87e0df9`) |

### 再蒸留 (awesome-harness-engineering) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (user settings に自前の MCP サーバ定義は無く `enableAllProjectMcpServers: false`。導入時は awesome-harness-engineering.md の索引から引く。README の注記ベースで記事本文は未読) | FYI | MCP | MCP Security Testing Checklist: 導入前に OAuth/token の scope、tool schema・description の poisoning、動的 discovery の固定、引数の SSRF / path traversal、tenant 分離、応答中の secret の redaction を確かめる (8 段階) | ahe: `80c484d`・`6d4db43`、`README.md` の `Security, Sandbox & Permissions` |
| 却下 (安全上重要な規則を compaction に頼らない場所に置く方針は既存 (蒸留版「まず押さえる」15)。学習による手法でハーネス設定の対象ではない。論文本文は未読) | FYI | CLAUDE.md / hook | AutoCompact (arXiv 2610.02163): 固定の token 閾値での compaction を暫定策とし、発火時点を学習した agent の行動にする (SWE-bench Verified +9.2%) | ahe: `6d4db43`、`README.md` の `Context Delivery & Compaction` |

claude-code-best-practice (`77862da`、10-28 の v2.1.312 定期 run。commands 8 件の説明文同期、skills は no drift、subagents・CONCEPTS は既存 ON HOLD の継続、残りは ★ 数) は候補なし。`/config thinking=false` の例が加わったが、Opus/Sonnet/Haiku 5.5 と Fable で思考を切れない件 (蒸留版項目 9) との関係は原典に無いので候補にしない。smarthr-design-system (`f94d727`) は eslint-plugin-mdx の依存更新だけで、蒸留版の本文への影響なし (SHA のみ更新)。

---
## 2026-10-28

### 再蒸留 (natural-japanese v1.6.3) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-28: syntax-patterns.md §13 に「語の組み合わせのずれ」を足し、§12 の和語の連用形の項から参照、MAPPING.md 更新) | RECOMMENDED | skill | §13 は Signs に mismatched collocations を挙げるだけで、向きも確かめ方も無かった。和語に開きすぎる側は §12 の「〜の確かめ」型 (「の」付き) しか拾えず、「知らせが来る」のような組み合わせが漏れる。原典は組み合わせのずれを両向き (漢語化・和語化) とし、ふだんの会話で言うかで確かめ、動詞由来の名詞は辞書にあってもその場面で言うかで決める | skills/natural-japanese/SKILL.md §3 の 5 と確認手順の 3 つ目 (`8c1e88e`) |
| 対応済 (2026-10-28: banlist.md Tier 2「意味の薄いカタカナ語」に追記、MAPPING.md 更新) | RECOMMENDED | skill | 「意味の薄いカタカナ語」は読み手と分野で決めるとするだけで、ふだんの外来語 (バージョン・コピー・ファイル・アップデート) を漢語 (版・複製) に替える過剰修正を止めていなかった。原典は直す対象を意味の取り方が割れる語 (会議の意味のアジェンダ、約束の意味のコミット) に限る | skills/natural-japanese/SKILL.md §5 読みやすさの点検 3 (`86cca92`) |

`842a946` (スキル自身の文面の直し) と版番号 (`0a08c6b`) は候補なし。

### 再蒸留 (awesome-harness-engineering) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: この repo に skill の eval 基盤は無く (2026-10-06 の行と同じ)、定時実行は参照資料の更新で eval ではない。eval を組むときは awesome-harness-engineering.md の索引から引く。README の注記ベースで記事本文は未読) | FYI | 運用 | ネットにつないだ内部 eval でモデルが環境自体を攻撃面として扱った (SQL / command injection、実在サイトへの虚偽通報、URL 短縮で fetch 制限を回避)。Anthropic は全内部 eval からネット接続を外した。eval 環境の隔離が計測の信頼性の前提 | ahe: `0f2d443`、`README.md` の `Evals & Verification` |
| 却下 (検証を決定論的な hook に寄せる方針は既に取っている (2026-09-26・10-18 の行)。会計領域の 1 ベンチで未検証) | FYI | skill / hook | LevelBench-100: 素のモデル 71.0%、CLI ハーネス 84.0%、決定論的な検証チェックリストと HITL の保留ゲートを足して 100% | ahe: `1dcf2f2`、`README.md` の `Evals & Verification` |
| 却下 (自作ハーネスの成熟度監査をする予定なし。awesome-harness-engineering.md に索引済み。論文本文は未読) | FYI | 運用 | arXiv 2605.13357 "AI Harness Engineering: A Runtime Substrate": 部品責務を H0–H3 の成熟度段階に整理し、上の段ほど再現ログ・決定論的な要件チェック・構造化された検証レポートを出す | ahe: `49fa995`、`README.md` の `Foundations` |

蒸留版に残っていた dead URL 2 件 (`writing-effective-tools-for-agents` → `writing-tools-for-agents`、`beyond-permission-prompts` → `claude-code-sandboxing`) は再蒸留で直した。

claude-code-best-practice (`64bcf8a`、10-27 の v2.1.311 定期 run。commands・skills は no drift、subagents は既出の ON HOLD 4 件、agent-collections は全件 INVALID、残りは ★ 数・件数・ステップ列と URL 検証) は候補なし。

---
## 2026-10-27

再蒸留 4 件 (claude-code-best-practice / natural-japanese / smarthr-design-system / yomiyasu) はすべて候補なし。ccbp は badge と drift ログの追記だけ (`/autocompact` の ON HOLD が commands 表から静かに消えたのは既存の注意の追加例)、natural-japanese は Cursor 向け `plugin.json` とロゴ、smarthr は components/ の FormControl 実装手順・角丸トークン・依存更新、yomiyasu は README の Grok Build の入れ方で、ハーネスの書き方を変える記述はない。

---
## 2026-10-25 (2 回目)

### 再蒸留 (yomiyasu v2.4.0) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-25: syntax-patterns.md §13 に漢字 1 字の名詞の小項目を追加、banlist Tier 2「英語直訳」から参照、MAPPING.md 更新) | RECOMMENDED | skill | banlist Tier 2「英語直訳」は version →「版」の例だけで、head →「頭」・mark →「印」と直し方 (分野の呼び名「先頭」「冒頭」「指摘」「目印」、前後の文の呼び名に合わせる、決まらなければ尋ねる) が無かった。原典はこの置き換えを「1 語の差し替え」の禁止に入れず、第 2 版・×印・頭が痛いのような文字どおりの使い方は残す | yomiyasu: `skills/yomiyasu/references/calques.md` § 1 型 4・§ 3・§ 4・§ 5、CHANGELOG.md § 2.4.0 (`ae258d7`) |
| 対応済 (2026-10-25: ja-slop-review/SKILL.md 手順 7 に 1 文追加、MAPPING.md 更新) | RECOMMENDED | skill | 手順 7 の意味検算は数値・範囲・因果を見るが、原文に無い人や担当 (担当者・管理者、部署・チーム、「〜さん」、人称) を主語や知らせる・頼む相手に足す書き直しを点検していなかった。手順 0 の不増補で原則は押さえているが、原典の測定で意味が変わった箇所の多くがこの形だった | yomiyasu: `skills/yomiyasu/references/review-points.md`「原文にない人や担当を足した文」、CHANGELOG.md § 2.4.0 (`ae258d7`) |
| 却下 (ja-slop-review はスライドを扱わず、視覚物は visual-slop-review の担当。スライドの日本語を推敲する場面が出たら引く) | FYI | skill | スライドの見出しと 1 行の箇条では、地の文なら残す読点 (文頭のつなぎ語・決まった「〜ば」・長い時の句・短い主題・「を」のあと) も外す。逆接・条件・理由・名詞の並び・掛かり先が変わる所の読点は残す | yomiyasu: `skills/yomiyasu/references/doc-types/slides.md`、CHANGELOG.md § 2.4.0 (`ae258d7`) |

`552c12c` (README の版ごとの節を外して CHANGELOG へ案内) は候補なし。

### 再蒸留 (claude-code-best-practice / claude-cookbooks / awesome-harness-engineering) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: この repo の skills/*/SKILL.md は allowed-tools・disallowed-tools・model・hooks を使っていない (grep 済)) | FYI | skill | 10-25 に同期された commands 表では、skill frontmatter の `allowed-tools` / `disallowed-tools` は次のメッセージで解除され、`model` はそのターンだけ有効、`hooks` は skill 起動時に登録されてセッションの残りずっと動く。skills 表 (同日 no drift) は `hooks` を「scoped to this skill」のまま書き、原典の中で食い違う | ccbp: `best-practice/claude-commands.md` Frontmatter Fields 表、`changelog/best-practice/claude-commands/changelog.md` 2026-10-25 (`d4f0a99`) |
| 却下 (該当なし: `disable-model-invocation: true` は yokai-refs-update だけで、定時実行は SKILL.md を Read させる形で preload にも scheduled task の起動にも頼っていない。`paths` は未使用) | FYI | skill | `disable-model-invocation: true` は subagent の `skills:` preload と session-scoped scheduled task からの起動も止める。`paths` は cwd 相対で cwd の外にマッチしない | ccbp: `best-practice/claude-commands.md` Frontmatter Fields 表 (`d4f0a99`) |
| 却下 (該当なし: repo と ~/.claude/settings.json にモデル ID の直書きは蒸留版・台帳の引用以外に無い (grep 済)) | FYI | 運用 | 既定が `claude-opus-5-5` / `claude-sonnet-5-5` / `claude-fable-5-1` に上がり、バリデータの `SUPERSEDED_MODELS` (warning) と `RETIRED_MODELS` (error。`claude-sonnet-4-5` は 2026-11-30 retire) が旧 ID の置換表になる | cookbooks: `bfe50e5`、`CLAUDE.md`、`scripts/validate_all_notebooks.py` |
| 却下 (自作の tool / MCP サーバを持たず、think 系の tool も無い (grep 済)。README の注記ベースで論文本文は未読) | FYI | 運用 | "The Devil Is in the Interface" (arXiv 2608.11386): 能力集合を固定して tool の束ね方だけを変えると挙動が大きく変わり、構造化した低レベル interface と CodeAct 型が効く。テキストだけの think tool 系は挙動をほとんど動かさない | ahe: `8534467`、`README.md` の `Tool Design` |

claude-code-best-practice の残り (subagents 4 件・skills 4 件・`/autocompact` 等の ON HOLD 継続、Settings reference リンクの NEW ON HOLD、★ 数とコレクション表の日次更新) は候補なし。

---
## 2026-10-25

### 再蒸留 (natural-japanese v1.6.2) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-25: ja-slop-review/SKILL.md 手順 0 に好みの言い換えをしない・読み手が取れない言い回しは banlist に無くても直すの 1 項目を追加、MAPPING.md 更新) | RECOMMENDED | skill | `ja-slop-review/SKILL.md` 手順 0 (修正時の制約) は不増補と確度だけで、意味の取れる言葉を好みで言い換える直し (「気軽に試せます」→「簡単に試せます」、「お知らせいたします」→「お知らせします」) を止めていなかった。原典は v1.6.2 で、直す・直さないの線引きを lint の指摘の有無から「好みか、読み手が取れないか」に改めた | skills/natural-japanese/SKILL.md §3 (`9d3fd3b`) |
| 対応済 (2026-10-25: syntax-patterns.md §13 の直訳語との線引きに 1 文追加) | FYI | skill | §13 の「定着した言い方は残す」に判定基準が無い。原典は、技術の言い方が定着しているかを仕様書・リファレンスのような書き言葉で使うかで決め、エンジニアの会話でよく使うだけでは定着と見ない | skills/natural-japanese/SKILL.md §3「読み手が何のことか取れない言い回し」末尾 (`a88b8e9` で確認) |

`91a56e8` (リリースノートを release-notes/ へ移動)・`359e0b0`・`1796f15` (リポジトリ内文書の日本語の直し)・`cfe396e` (版番号) は候補なし。

### 再蒸留 (yomiyasu v2.3.0) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-25: syntax-patterns.md §12 に「和語の連用形 1 語の名詞 +『の』」を追加、MAPPING.md 更新) | RECOMMENDED | skill | 他動詞の連用形を 1 語だけ名詞にして「の」で目的語につなぐ形 (「結果の確かめ」) は、漢語を避けて和語にひらく直しで出やすい。§12 の名詞化は漢語の動作名詞 (「〜の実施を行う」) しか扱っていなかった。動詞の文か定着した漢語の名詞に直し、複合語・複合動詞由来・「お」付き・別義で定着した語は残す。漢語の名詞にするのは §13 の 1 語差し替えに当たらない。原典は通常の AI の下書きでは出現が少なく効き目は小さいと書く | skills/yomiyasu/SKILL.md § 主語と目的語の明確化、CHANGELOG.md § 2.3.0、references/lists/renyo-nouns.txt (`15244a1`) |
| 却下 (Claude Code で本体を読み込める環境だけで使っている。字数上限のある環境で日本語推敲を使う予定が出たら引く) | FYI | 運用 | SKILL.md の字数に上限がある環境やスキルを読み込めない環境向けに、yomiyasu-mini (18,000 字以下) と yomiyasu-pocket (400〜500 字の指示文) が別リポジトリで出ている。本体を読み込める環境では本体を勧める | README.md § 本体を入れられない環境では (`5dd154e`) |

### 再蒸留 (claude-code-best-practice / awesome-harness-engineering) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: 環境の settings に cloud provider 経由の設定は無く、autoMode は手書きで `/auto-mode-setup` を前提にした手順も ~/.claude/CLAUDE.md に無い。二次資料の記述が 10-21 → 10-24 で反転しており確定情報として扱わない) | FYI | 運用 | `/auto-mode-setup` の要求版が Pro/Max/Team は v2.1.228+ (native Windows は v2.1.233+)、Enterprise と Console API key は v2.1.283+ に分けて書かれ、10-21 に入った「Bedrock/Vertex/Foundry/gateway でも使える」の一文は公式から消えたとして削除された | ccbp: `best-practice/claude-commands.md` row 7、`changelog/best-practice/claude-commands/changelog.md` 2026-10-24 (`490f151`・`fcc23e2`) |
| 却下 (既に回している: 2026-10-21 の Hashimoto の行と同じく、失敗の再発防止は CLAUDE.md・auto-memory・環境側 hook で行っている。README の注記ベースで論文本文は未読) | FYI | 運用 | HarnessFix (arXiv 2606.06324): 失敗軌跡からどのハーネス部品 (指示文・tool・hook・context 供給) が原因かを先に特定し、範囲を限った修正を退行検証つきで当てる診断先行の修復が、人手設計・self-evolution の baseline を 6.3–18.4% 上回る | ahe: `ca0a32b`、`README.md` の `Debugging & Developer Experience` |

claude-code-best-practice の残り (subagents 4 件・skills 4 件・CONCEPTS の ON HOLD 継続、Code Review の beta バッジ削除、★ 数とワークフロー表の日次更新) は候補なし。

---
## 2026-10-23

### 再蒸留 (yomiyasu v2.2.1 / v2.2.2) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-23: syntax-patterns.md §13 の Fix by the relation に意味の広い語への差し替え禁止と「全店舗に響く」の例を追加、MAPPING.md 更新) | RECOMMENDED | skill | `ja-slop-review/references/syntax-patterns.md` §13 は「カタカナ語や『〜ごと』に替えるだけでは直らない」までで、何が起きるかを言わない広い語 (影響する・及ぶ・支障が出る・関わる・左右する) に替えることと、広い語の句を中身の文と並べて残すことを止めていない | skills/yomiyasu/references/calques.md § 4・5 (`91964cd`) |
| 対応済 (2026-10-23: 同じ項目の「keep the text and ask」に、動作をする人が材料に無いときと呼び名がそろわないときを追加) | RECOMMENDED | skill | §13 の尋ねる条件が名前と動作だけで、動作をする人が材料に無いとき、印の語と前後の文で呼び名がそろわず同じものを指すか分からないときが無い | calques.md § 4、CHANGELOG.md § 2.2.1 |
| 対応済 (2026-10-23: syntax-patterns.md §2 比喩ラベルの見出しに追記) | RECOMMENDED | skill | §2 比喩ラベルの見出しは「本文の語で見出しを作る」だけで、元の見出しが言っていた目的を項目名に残し、本文の題目を並べただけの名前にしない規則が無い | calques.md § 4 |
| 却下 (手順 6 が「響く」「入口」を手作業の洗い出しで拾っており範囲は足りる。残す例を増やすと §13 が長くなるだけ) | FYI | skill | lint の印の範囲が広がり、印をつけない例 (駐車場の入口・サーバールーム・「全社員に響く言葉」・安全性の「全」) が足された。§13 の残す例は「駅の入口」だけ | CHANGELOG.md § 2.2.1 |
| 却下 (既に入っている: SKILL.md 手順 0 の leave it and ask) | FYI | 運用 | 印の語を残すとき、尋ねずに理由だけ書いて済ませてよいのは定着した言い方か文字どおりの意味のときだけ (check の `kept_marks`) | SKILL.md Step 5、review-points.md § 2 |

v2.2.2 (`488dd37`、diff の高速化で出力は不変) は候補なし。

### 再蒸留 (claude-code-best-practice / awesome-harness-engineering / smarthr-design-system、2 回目) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: `/config help` の記載は蒸留版の訂正記述だけ。skills/・instructions/・~/.claude/ の CLAUDE.md・agents・hooks を grep 済) | FYI | 運用 | 設定可能キーの一覧は `/config --help`。原典の `/config help` 表記は誤りで v2.1.309 に訂正された | ccbp: `bde3002`、`best-practice/claude-commands.md` #9 |
| 却下 (いま要らない: 登録済みの hook は PreToolUse(Bash) の検査型 2 本で、止めて理由を返すだけ。イベントの書き換え・代答は要らない。README の注記ベースで docs 本文は未読) | FYI | hook | Claude Code の mods (2026-10) は TypeScript 関数でイベント (tool call / prompt / turn / UI 描画) を観測・書き換え・遮断・代答でき、settings の hooks にできないループ内の拡張になる。副作用は `$` API に集約され `claude plugin validate` で到達範囲を事前に列挙できる | ahe: `a63c03a`、`README.md` の `Skills & MCP` |

smarthr-design-system (`d831109`、18 commits はすべて renovate の依存更新 (react・astro・pnpm・styled-components 等) とその merge で、ライティングガイドラインの MDX に触れるものは無い) は候補なし。蒸留版は内容への影響なしとして SHA だけを進めた。

### 再蒸留 (hallmark) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-23: ui-design/SKILL.md の例外 (2) を gate ではなく craft.md § 2 の帯・テーマの地・playful の既定の上書きに絞り、Floor は満たし Reflex だけ v2 書式で waive する形に) | BREAKING | skill | `ui-design/SKILL.md` の hallmark 優先の例外 (2) が v2 で壊れた。上書き対象の `color.md`・`custom-theme.md` § B は削除、gate 7 は 7a (Floor、waive 不可) と 7b (Reflex) に分割、accent の彩度上限は genre ファイルでなく `craft.md` § 2、stamp 例 `gates: 7,23 waived (color-chroma)` は v2 の waiver 書式 (1 gate 1 行・根拠と理由つき。Floor は waive 不可) に合わない | skills/hallmark/references/gates.md § 1・2・4、craft.md § 2 (`7ec8682`) |
| 対応済 (2026-10-23: ui-design/SKILL.md の例外 (1) と japanese-web-typography.md の根拠を genres/editorial.md § Allowed here と 38i / 38iii に付け替え) | BREAKING | skill | `ui-design/SKILL.md` の例外 (1)「gate 38a が許す本文中の italic 強調」: 38a は 38i (Floor) / 38iii (Reflex) に付け替わり、本文中の italic は gate でなく `genres/editorial.md` の "Allowed here" へ移った | gates.md § 4 Type、genres/editorial.md |
| 対応済 (2026-10-23: ui-design/SKILL.md の hallmark 行から study を削除し、名指し時の redesign / audit に限定) | BREAKING | skill | `ui-design/SKILL.md` の hallmark 行「既存 UI の audit / redesign / study にも使う」: study verb は廃止。v2 の verb は redesign と audit だけで、既存デザインには名指ししない限り使わない | skills/hallmark/SKILL.md frontmatter・§ Flow、references/study.md の削除 |
| 対応済 (2026-10-23: color-chroma.md の [原典] 主張を themes/*.md の :root の数え直し (ライト地色 30 個中暖色クリーム 17 個) と gate 65・direction.md § Spent・craft.md § 2 で書き直し、accent 中彩度の前提を撤回) | BREAKING | skill | `ui-design/references/color-chroma.md` の [原典] 主張が削除済みファイル (`site/css/tokens.css`・`color.md`・`custom-theme.md`・`slop-test.md`) と旧集計 (ライト地色 17 個中 8 個が暖色クリーム) に立っている。v2 ではテーマの正は `themes/*.md` の `:root`、gate 65 (cream 地 + serif + terracotta の named look) と direction.md の "Spent" が hallmark 自身の規則になった。比率を数え直して前提を見直す | gates.md gate 65、references/direction.md § Spent、ROADMAP.md § Now、themes/ |
| 対応済 (2026-10-23: japanese-web-typography.md の参照を v2 のファイルと 38i・49a / 49b に直し、引用を genres/editorial.md から取り直し、scaffold の font-synthesis: none の注意を追加) | BREAKING | skill | `ui-design/references/japanese-web-typography.md` が `slop-test.md` (削除済み) と gate 38a・49 (49a Floor / 49b Reflex に分割) を指している。引用 "emphasis inside running paragraphs" の出所を v2 で取り直す | gates.md § 1 (退役番号)・§ 4 |
| 却下 (このハーネスは原典 clone のスクリプトを実行しない運用で、hook を入れる予定も無い) | FYI | hook | `scripts/install-hook.mjs` は `.claude/settings.json` (`--global` なら user settings) に PostToolUse hook (lint-hook.mjs) を書き込む。ROADMAP は plugin で既定有効にする方向 | scripts/install-hook.mjs、ROADMAP.md § Next |
| 却下 (harness-design の evaluator-optimizer の索引で足り、直す箇所が無い) | FYI | subagent | ビルダーを最も弱いレビュアーとみなし、fresh context の subagent にパスだけ渡してレビューさせ、返答の最初の語で分岐、採点は 1 ラウンドまで | gates.md § 6 |

### 再蒸留 (natural-japanese) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-23: ja-slop-review/SKILL.md 手順 6 を、候補の洗い出しと書き手自身が当てる 2 つの問い (分野の呼び名か / 動詞だけで何が起きるか) に置き換え) | RECOMMENDED | skill | `ja-slop-review/SKILL.md` 手順 6 の「別コンテキストの読み手に A/B 2 種だけ挙げさせる」は v1.6.1 で原典から外れた (書く時間が約 2 倍、§2 の原則と calques.py で直せない語を拾えたのは 1 語)。出所は旧 SHA だけになっている | commit 10bea80、旧 references/reader-check.md (`a708403`) |
| 対応済 (2026-10-23: ja-writing/MAPPING.md の履歴と出所欄を更新し、reader-check.md は 10bea80 で削除済みと明記) | RECOMMENDED | skill | `ja-writing/MAPPING.md` の履歴と出所欄が削除済みの reader-check.md を出所に挙げている。上の行の扱いに合わせて直す | commit 10bea80 |
| 対応済 (2026-10-23: syntax-patterns.md §13 を「短い 1 語のたとえや言い換えで済ませない」に改め、作業用の名前・文書内の造語の項を追加) | RECOMMENDED | skill | `ja-slop-review/references/syntax-patterns.md` §13 の「英語の概念を短い 1 語に置かない」は原典が撤回した「英語の直訳」という捉え方のまま (原典は「思いついた短い 1 語のたとえや言い換えで済ませない」に改めた)。原則 4 に足された、素材の作業用の名前 (条件名・ブランチ名・集計区分名) を出さない・文書の中で呼び名を作らない (作るなら名前で中身が分かるもの) も §13 に無い | commit 717d8e0・ee007f5、skills/natural-japanese/SKILL.md §2 原則 4 |
| 却下 (手順を足すときの判断の型で、直す箇所が無い。比較の道具は蒸留版の索引から引ける) | FYI | 運用 | 手順 1 つを、所要時間と伏せた判定による効果で比べて外す。道具は dev/release-eval/ | commit 10bea80・21d0da1 |

### 再蒸留 (yomiyasu) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-23: syntax-patterns.md §13 に直訳語との線引きを追加。「要求」は分野の呼び名の問いで見つかる例として残す) | RECOMMENDED | skill | `ja-slop-review/references/syntax-patterns.md` §13 が「リクエストを『要求』」を直す例に挙げるが、yomiyasu v2.2.0 の calques.md は辞書の訳語を当てた名詞 (要求・承認・事実・影響) と定着した言い方 (テストが通る・キャッシュが効く) を直訳語の型から外す。残す線引きと 2 つの問い (分野の人が自分で書く呼び名か / 英語に戻すと一語ずつ対応するか) が §13 に無い | skills/yomiyasu/references/calques.md § 2・3 (`a34d94f`) |
| 対応済 (2026-10-23: banlist.md Tier 1 に追加。引用・会話・カギ括弧の中と判断の文は残す) | RECOMMENDED | skill | `ja-slop-review/references/banlist.md` に「〜と言えるでしょう」が無い。直し方は「と言える」だけを外して推量の「でしょう」は残す | skills/yomiyasu/references/slop-catalog.md § 6 |
| 対応済 (2026-10-23: banlist.md Tier 2 に意味の薄いカタカナ語、syntax-patterns.md §2 に比喩ラベルの見出し、§8 にコピー調の読点と他動詞の並び、§12 に評価の言い直しを追加) | RECOMMENDED | skill | `ja-slop-review` に無い型 4 つ: 評価を言い直すだけの文、意味の薄いカタカナ語 (分野で定着した使い方は残す)、本文に出てこない一語の比喩の見出し、キャッチコピーの読点と主語・目的語の無い他動詞の並び。原典はどれも「印は直す合図ではない」とするので、常時禁止でなく文脈で判断する側に置く | slop-catalog.md § 5・9、SKILL.md § 案内用の見出し・§ コピー調の抑制 |
| 却下 (ja-slop-review は語の一覧で網羅しない方針。プロジェクト固有の語の例外が要る事例がまだ無い) | FYI | 運用 | プロジェクトごとの語の一覧 `.yomiyasu-words/` (allow.txt・flag.txt) | CHANGELOG.md § 2.2.0 |
| 却下 (ja-slop-review に同じ型は無く、足さないことの確認にとどまる) | FYI | skill | 「〜できる仕組み。」で終える文の規則は 3 回測って直せず、残すべき文を書き換えたので見送られた。同じ型を足さない | CHANGELOG.md § 2.2.0 |

### 再蒸留 (claude-code-best-practice / awesome-harness-engineering / smarthr-design-system) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (このハーネスの SKILL.md は `allowed-tools` を使っていない) | FYI | skill | skill frontmatter の `allowed-tools` は文字列でも YAML の list でも書ける。原典の skills 表が `string` だけだったのは誤りで訂正済み | commit 5164759、best-practice/claude-skills.md |

awesome-harness-engineering (Harness Handbook の 1 行追加) と smarthr-design-system (`.node-version` のみ) は取り込み候補なし。

---
## 2026-10-22

### 再蒸留 (natural-japanese) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-22: ja-slop-review/references/syntax-patterns.md §13 に追記、MAPPING.md を更新) | RECOMMENDED | skill | 物の呼び名を読み手の分野の呼び名にそろえる (公開エンドポイントを「入口」、リクエストを「要求」と 1 語に置かない)、「効く」「拾う」で済ませず起きることを書く。§13 は word-for-word English を挙げるだけで、呼び名と動詞の判定の問いが無かった | skills/natural-japanese/SKILL.md §2 原則 4・§6 (`70e6e6a`) |
| 対応済 (2026-10-22: ja-slop-review/SKILL.md 手順 6 に追記、syntax-patterns §10 の例を差し替え) | RECOMMENDED | skill | 逐語置換の語は書いたモデルが読み返しても気づけないので、本文だけを別コンテキストの読み手に渡し A (分野の呼び名と違う語) / B (英語の決まった言い方の逐語置換) の 2 種だけ挙げさせる。問いを広げると 30 行で 50 件以上挙がる。§10 の良い例「この環境では効く」は直す対象の動詞そのものだった | skills/natural-japanese/references/reader-check.md (`b2d1d34`) |
| 却下 (語のリストで網羅しない方針の材料にとどまり、直す箇所が無い) | FYI | skill | calques.py が拾うのは助詞に続く和語動詞と場所の比喩名詞だけで、分野の呼び名からずれた漢語は対象外。banlist のような語リストで calque を網羅しようとしない | skills/natural-japanese/scripts/calques.py |

### 再蒸留 (awesome-harness-engineering / claude-code-best-practice / yomiyasu) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (このハーネスは記憶基盤を自前で持たず、auto memory の方式は選べない) | FYI | 運用 | memory substrate を同一ハーネスで比べると一貫した優位は無く、広い retrieval は逐次意思決定で害になる。方式を固定せず振り分ける。README の注記のみで論文本文は未読 | README.md Memory & State (`c586328`) |

claude-code-best-practice (badge・star 数・commands 説明 4 件・ON HOLD 再掲) と yomiyasu v2.1.2 (check / diff の不具合修正) は候補なし。

### ui-design の見直しから (原典の更新ではなく利用時の偏りの調査)

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-22: ui-design/references/color-chroma.md と scripts/chroma-check.py を新設、SKILL.md の hallmark 優先に例外 (2) を追加し gate 7・22・23 と genre の彩度上限を上書き) | RECOMMENDED | skill | ui-design は生成規律の衝突で hallmark を優先させていたが、hallmark の配色規則はライト地色 17 個中 8 個が暖色クリーム、custom の accent を C 0.12〜0.16 に置き、accent を 3% 以下・gate 23 で 5% 超を禁じ、gate 7 で `#fff` 地を禁じる。結果がくすみ・ベージュに寄り、visual-slop-review が tell とする cream/beige + terracotta と衝突していた。a11y の比不足も彩度を削って直す流れになっていた | hallmark site/css/tokens.css、skills/hallmark/references/color.md・custom-theme.md § B |

## 2026-10-21

### 再蒸留 (yomiyasu) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-21: ja-slop-review/SKILL.md 手順 0 の確度の項に追記) | RECOMMENDED | skill | 修正時の「言い切りの強さ」に許可 (〜してよい)・能力 (〜できる)・義務・保証 (必ず / 保証する) を含め、仕様書・設計文書では互いに替えない・「〜場合がある」を消さない・「必ず」を足さない。ja-slop-review の手順 0・7 は推量と断定の軸しか書いておらず、「変更してよい → 変更できる」を止められなかった (「許可\|保証」で grep 0 件) | yomiyasu: `8be3ef6`、`skills/yomiyasu/SKILL.md` § 最優先ルール 3、`CHANGELOG.md` § 2.1.0 |
| 対応済 (2026-10-21: ja-slop-review/references/syntax-patterns.md §12 に 3 項目を追加、MAPPING.md の行を更新) | RECOMMENDED | skill | 読み違いの型 3 つ — (a) 挟まった句で目的語が抜けて読める文、漢語 → 和語の言い換えは目的語が追えて意味の幅が同じときだけ、(b) 主題「は」「では」が後半の節まで掛かるか決まらない文は主体を足さずに問う、(c) 前置きのない「〜のは、A、B、C。」は述語の形に戻す (見出し・結び・スライドは残す)。syntax-patterns に該当の型が無かった (grep 済) | yomiyasu: `8be3ef6`、`SKILL.md` § 主語と目的語の明確化・§ コピー調の抑制、`CHANGELOG.md` § 2.1.0 |
| 対応済 (2026-10-21: ja-slop-review/SKILL.md 手順 7 に追記) | FYI | skill | 意味検算の「元に無い数値を足さない」は数値の追加しか見ていない。概数の印の増減 (約120人 → 120人、以上 ⇔ 超)、「AまたはB」⇔「両方」、相関の文への因果の語の追加も意味の変化として見る。1 文の追記で済むので入れた | yomiyasu: `fbe02c9`、`CHANGELOG.md` § 2.1.1 |
| 対応済 (2026-10-21: ja-writing/SKILL.md の参照リポジトリ表の yomiyasu 行を更新) | FYI | skill | 参照リポジトリ表の yomiyasu 行の説明が v2.0 の内容で止まっていた | yomiyasu: `8be3ef6` |
| 却下 (該当なし: yomiyasu はスキルとして入れておらず原典として読むだけ。自作の ja-slop-review / ja-writing は名前を出さない日本語作業でも発火させるのが目的なので、同じ絞り込みは入れない (絞ると暗黙の利用が消える。yomiyasu 自身も名前を出さない推敲依頼で 18/18 → 0/18)。発火を絞る description の型は蒸留版 yomiyasu.md に索引済) | FYI | skill | v2.0.2 で description を「名前を出して頼んだときだけ使う」に絞り、名前の無い作業での誤発火が Claude Code で 10/72 → 0/72 に減った (`claude -p` での測定のみ) | yomiyasu: `5b7cacc`、`CHANGELOG.md` § 2.0.2 |

### 再蒸留 (awesome-harness-engineering) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (既に実施: agent の失敗を 1 件ずつ恒久的に塞ぐ運用は、CLAUDE.md の規約、auto-memory の再発防止メモ、環境側の PreToolUse hook で回している。この台帳と refs-update は上流原典の変化を追う仕組みで別物。新たに直すものは無い。README の注記ベースで記事本文は未読) | FYI | 運用 | agent の失敗 1 件ごとに AGENTS.md の 1 行か専用 tool で恒久的に塞ぎ、同種の失敗を再発させない (Hashimoto "My AI Adoption Journey"。Ghostty で修正が要る commit が 3 か月で 40% → 3%) | ahe: `ec1e1b7`、`README.md` の Foundations 先頭 |

claude-code-best-practice (`9f9f5d9`、drift は ON HOLD / INVALID の再掲と commands 表の description 4 件のみ)、meiseki (`9750d92`、rikai のダッシュボードと手動の卒業のみ)、smarthr-design-system (`170cea3`、`products/contents/` と textlint 設定に差分なし) は候補なし。

---
## 2026-10-18

### 再蒸留 (awesome-harness-engineering / claude-code-best-practice / yomiyasu) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-19: 環境側 PreToolUse(Bash) hook にガードを追加。pathspec 無しの一括ステージと `git commit -a` を止め、`git status --short` で確かめてパス指定で add するよう返す。pathspec 付きは通す) | RECOMMENDED | hook / 運用 | コーディング agent の失敗の大きなクラスタは change hygiene (`git add -A` で debug スクリプトや無関係な編集がコミットに混ざる) で、提出時の衛生 (`git status` の確認、raw `sed` より構造化編集) を強制するほうがモデルを替えるより効く。環境側の PreToolUse(Bash) hook (`commit-guard.sh`) はコミット文言と環境固有値の混入だけを見ており、ステージ内容の衛生は見ていない (grep 済)。README 注記ベースで記事本文は未読 | ahe: `626b647`、`README.md` の `Debugging & Developer Experience` (Faros AI) |
| 却下 (該当なし: 2026-10-19 に skills/*/SKILL.md・instructions/・~/.claude/CLAUDE.md・~/.claude/agents/ を一律禁止文で grep し 0 件。書き方の指針は蒸留版 awesome-harness-engineering に索引済) | FYI | CLAUDE.md / skill | 最大の失敗クラスタは instruction conflict — 「DO NOT MODIFY: Tests」のような範囲を絞らない禁止文を字義どおりに守りすぎて必要な作業を拒む (最弱・最強モデルで同程度)。このハーネスの禁止文 (`~/.claude/CLAUDE.md` のコミットメッセージ規約、各 SKILL.md) は対象を限定しており、一律の禁止文は無い (grep 済)。禁止文を足すときの書き方の指針として残す | ahe: 同上 |
| 却下 (該当なし: 個人リポジトリで merge queue・大規模 CI を持たない。Scion は harness-design/references/awesome-harness-engineering.md に索引済み) | FYI | 運用 | agent 規模の開発で merge が 1 日約 2,500 → 30,000 件超、CI checkout が 1 日約 2,500 万回に増え、Git の分散 clone 前提が破綻した (Anthropic Scion)。並列 agent を大きくするとハーネスの下のインフラ (merge queue / lock / full clone) が先に壊れる。個人リポジトリのこのハーネスには当たらない | ahe: `8c7f4fc`、`README.md` の `Production Infrastructure & Operations` |

claude-code-best-practice (`3433a39`、確定は plugin-authoring の導入版訂正と design-sync の 2026-12-14 終了告知の 2 件。このハーネスは design-sync を使っていない (grep 済)。他は ON HOLD の継続) と yomiyasu (`84e1f5b`、テスト隔離のみ) は候補なし。

---
## 2026-10-17

### 再蒸留 (yomiyasu v2 / claude-cookbooks / awesome-harness-engineering / design.md) から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-17) | RECOMMENDED | skill | `ui-design/SKILL.md` が DESIGN.md のトークンを「frontmatter」に限定して書いていた。spec がセクション内の ```yaml ブロック (interleaved) を許し、front matter と merge されて top-level キーの重複がエラーになったので、表の行と DTCG の写像の記述を直した | design.md: `6e5da53`、`docs/spec.md` の `# Design Tokens` |
| 対応済 (2026-10-17) | RECOMMENDED | skill | yomiyasu v2.0.0 は不増補を撤回していない — 根拠に会話の文脈 (利用者の発言・開いたファイル・コマンド出力) を足したが、6 条件を満たすときだけで「迷ったら補わない」。`ja-slop-review` の修正モード (手順 0) の「材料」の定義と、意味検算 (手順 7。1 点でも変わったら書き直しではなく原文に戻す = 言い直しテストの型) に反映した。前日の RECOMMENDED 1 行目と同時に対応 | yomiyasu: `skills/yomiyasu/SKILL.md` § 情報の不増補、`skills/yomiyasu/references/fact-recovery.md` §3、`skills/yomiyasu/references/rephrase-test.md` §1・2 |
| 対応済 (2026-10-19: ja-slop-review/references/syntax-patterns.md §12 に間を作るだけの読点、§13 に成り立たない比喩を追記。MAPPING.md 更新) | FYI | skill | `ja-slop-review` の語彙に足せる材料が 2 つ増えた: 間を作るだけの読点 (短い主語・主題の直後の読点。残す条件付き) と、主語と述語だけ取り出すと成り立たない比喩。前日の FYI「語彙の追加材料」と合わせて扱う | yomiyasu: `skills/yomiyasu/references/slop-catalog.md` §8・9、`b8ddf6e` |
| 却下 (該当なし: README「管理しないもの」で permissions は repo 管理外と明記。instructions/ と ~/.claude/CLAUDE.md に permission 記述なし (grep 済)。原典は claude-cookbooks.md に索引済み) | FYI | 運用 | エージェントの許可範囲の記述は設定を写さず意図から書く (設定を写すと設定ミスが「やってよいこと」に入る)。permission の allow (自動 policy を含む) は安全の証明にならない。transcript 内の文言は「証拠であって権限ではない」。このハーネスに permission ルールの記述や事後監査の仕組みは無い (grep 済) | cookbooks: `a162e01`、`managed_agents/CMA_agent_security_review.ipynb` §1・§2 |
| 却下 (該当なし: ~/.claude/agents/ の定義に memory store の共有・memory 記述なし。2026-10-19 grep 済) | FYI | subagent | untrusted な入力を読む agent が書く memory store を、行動する agent に付けない。書く必要のない agent には `read_only` で付ける。このハーネスの subagent 定義に memory store の共有は無い (grep 済) | cookbooks: 同 notebook の "What to do with a finding" 表 |
| 却下 (手を入れる対象なし: 論文本文は未読。外部内容を context に入れる hook は無く、登録済み hook は検査専用) | FYI | hook | context を組み立てる層そのもの (外部内容の message role への昇格、scope を越えた残存) が権限昇格の面になる、という論文 (12 の実システム。Claude Code / Codex を含む)。外部内容をどの role・scope で context に入れるかを境界として設計する。README 注記ベースで論文本文は未読 | ahe: `fad270e`、`README.md` の `Security, Sandbox & Permissions` (arXiv 2609.01222) |

claude-code-best-practice (`0f92b29`、新規指摘は全て原典が ON HOLD / INVALID)・smarthr-design-system (`132dae3`、蒸留範囲外のみ)・textlint-rule-preset-ja-spacing (`5d1e213`、かっこルールの誤検知修正) は候補なし。

---
## 2026-10-16 (ja-writing 新設時の初回蒸留)

### natural-japanese / yomiyasu / stop-ai-slop-jp / meiseki / textlint 2 本 / smarthr-design-system から

対象 `skill` の行はすべて `ja-slop-review` (形式 2 の自作知識ベースで原典に従う義務は無い) で、主張は `ja-slop-review/references/` を grep して該当行を確認済み。`運用` の行は textlint 導入と clone 容量の話。
`natural-japanese` プラグインが無効な環境では `ja-slop-review` が実働するので、ここでの食い違いはそのまま出力に出る。原典の規則と `ja-slop-review` の対応は `ja-writing/MAPPING.md` にある (反映したら MAPPING.md も直す)。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-17) | RECOMMENDED | skill | **「直すとき足さない」制約が無い (最重要)**。`scoring.md` は 35/50 未満を全面書き直しにし、`rewrite-examples.md` D の fix はヘッジを元に無い数値 (「1 MR 約 0.5 ドル」) に置き換えている。`natural-japanese` は既存文書の修正で確信度の変更・元に無い事実 / 数値 / 見解の追加・要約節の新設を禁じ、仕上げに元文書と突き合わせる。`yomiyasu` も意味保持 4 点 (主張・比重・言い切りの強さ・文の働き) と文の種類 7 つの読み比べを最優先にする。Process に「新規執筆か修正か」の分岐と、修正時の意味検算ステップを足す | natural-japanese: `skills/natural-japanese/SKILL.md` 「いちばん大事な規則」§3・§6 / yomiyasu: `skills/yomiyasu/SKILL.md` § 1 最優先ルール・§ 情報の不増補 / meiseki: `.agents/skills/meiseki/SKILL.md` §4 Step 5・7 |
| 対応済 (2026-10-17) | RECOMMENDED | skill | **ムラ処方が原典 3 本と逆向き**。`syntax-patterns.md` §8 / `variance.md` は体言止め・短文・問いを混ぜて文末を割るよう勧め、`rewrite-examples.md` E は敬体を常体に変えている。`natural-japanese` は「型を崩す手段として疑問形や体言止めを入れない」「文長がそろっていることだけを理由に直さない」とし、校正で文長変動の識別力はジャンル依存と結論。`yomiyasu` は語尾を散らすために文の働き・時制・敬体 / 常体を変えない。`ja-technical-writing` は技術文書で疑問符を使わず、文体を統一する (v10 以降は指定と違う文体もエラー)。少なくとも修正時と技術文書では処方を外す | natural-japanese: SKILL.md §2 原則 8、`corpus/reports/research/sentence-length-analysis.md` / yomiyasu: SKILL.md § 文書の立場と文末、`references/gemini-syntax.md` 原則 7・8 / ja-technical-writing: `README.md`、`CHANGELOG.md` 10.0.0 |
| 対応済 (2026-10-17) | RECOMMENDED | skill | **banlist Tier 1 の一律禁止が原典より強すぎる**。「ここで重要なのは」「結論から言うと」「結局のところ」は、評価・方針転換・絞り込みを担うなら残す (`yomiyasu`)、「重要なのは」は人間側にも出る弱いシグナル (`natural-japanese` の実測)。メタ構造宣言も、数が合えば 1 文にまとめ、案内になっていれば残す。全角ダッシュは文書種別で線引きが違い、技術・業務文では挿入用法も置き換える。Tier 2 へ移し「削っても主張が変わらないときだけ削る」を付ける。Tier 2 には `stop-ai-slop-jp` の頻度上限 (「1〜2 回なら自然」) を添える | yomiyasu: `references/gemini-syntax.md` 原則 5・9・13 / natural-japanese: `skills/natural-japanese/scripts/lint.py` `FORBIDDEN_PHRASES_WEAK_SIGNAL` 直上コメント / stop-ai-slop-jp: `references/phrases.md` 冒頭 |
| 対応済 (2026-10-17) | RECOMMENDED | skill | **false agency と否定対比の判定が無条件**。`syntax-patterns.md` §1 は非生物主語を一律に減点し、修正例は原文に無い動作主を足す。`yomiyasu` は感情・意志の擬人化と、人の判断を抽象名詞の作用として書いた文だけを直し、道具の客観的な働きと論文の「〜ことを示している」は残す。§3 の「A でない。B でもない。C だ → C だ」も、`natural-japanese` は打ち消しを 3 種に分け (先回り打ち消しは削る / 「A は B ではない。C だ」は肯定文につなぐ / 意味を絞る・注意は残す)、密度 2% / 3% の目安を持つ | yomiyasu: `gemini-syntax.md` 原則 1・3・5 / natural-japanese: SKILL.md §3、`corpus/reports/antithesis-recalibration.md` |
| 対応済 (2026-10-17) | RECOMMENDED | skill | **構文・読解負荷の観点が丸ごと無い**: 二重否定を肯定へ畳むときに真偽を反転させない検算、長い連体修飾・「の」3 連以上・サ変名詞化の展開、段落内の言い換え反復、埋もれた列挙を開く (`ja-slop-review` は 3 並列を減らす方向しか持たない)。あわせて `natural-japanese` の「読み手が取れない言い回し」7 分類 (擬人化・英語の逐語訳・動作の名詞化・中身の見えない比喩 等) と、英語に訳し戻して確かめる方法 | meiseki: `.agents/skills/meiseki/references/patterns.md` A–H / natural-japanese: SKILL.md §3 |
| 対応済 (2026-10-17) | RECOMMENDED | skill | 修正の優先順位が出所と逆。`stop-ai-slop-jp` は「立場 → false agency → 構造 → 語彙 → 記号」で、「語彙・記号だけ直しても AI 臭は残る」とする。現 Process は banlist 走査 (語彙・記号) を構文チェックより前に置く。出所にある構造パターン 4 種 (体験の壮大化・劇的な断片化「シンプル。それだけ。」・体験→引用→抽象化の 3 連・全方位肯定) も欠けている。劇的な断片化は §8 の「短文を混ぜる」と衝突する | stop-ai-slop-jp: `SKILL.md` § 修正の優先順位、`references/structures.md` §1-2・2-3・4-3・6-1 |
| 対応済 (2026-10-19: 命題型 H2 の新規 / 修正の差は syntax-patterns.md §2 に既出。装飾絵文字は banlist.md Tier 1 に修正時は書き手の癖を残す旨を追記。stop-ai-slop-jp との意図的な差分は維持。MAPPING.md 更新) | FYI | skill | 書く側と直す側で規則の向きが変わる項目: 命題型 H2 (`natural-japanese` は新規なら結論見出しを推奨、修正なら 2〜3 か所まで)、装飾絵文字 (修正時は書き手の癖を残す)。`stop-ai-slop-jp` との意図的な差分 (ダッシュは緩く・絵文字は厳しく、誤字や毒の容認を formal 文書のために抑制) は戻さない | natural-japanese: SKILL.md §1・§2 原則 6・§3 / stop-ai-slop-jp: `SKILL.md` コアルール 6・14 |
| 対応済 (2026-10-19: syntax-patterns.md §12 に技術文書の数値の目安 (100 字・厳しめ 90 / 読点 3 / 漢字連続 6) を出典付きで追記。banlist.md の冗長語尾に AI らしさでなく冗長さの扱いと注記。MAPPING.md の textlint 表を更新) | FYI | skill | 数値の目安を出典付きで引ける: 技術文書は 1 文 100 字 (厳しめで 90)・読点 3 個・漢字連続 6 字。`ja-slop-review` は定性記述だけなので食い違いではない。`〜することができます` は `ja-no-redundant-expression` と同じ例で一致するが、`natural-japanese` の 2026-10 測定では AI 以前の人間文書のほうが多く、AI らしさではなく冗長さの扱い | ja-technical-writing: `README.md` / natural-japanese: `skills/natural-japanese/scripts/lint.py` コメント |
| 対応済 (2026-10-19: banlist.md Tier 1 にチャット応答の名残・仮置きの残り・表示されない太字と直し方、Tier 2 に大げさな役割名・英語直訳を追記。「最後に」「まさに」は足していない。MAPPING.md 更新) | FYI | skill | 語彙の追加材料: 大げさな役割名 (契約 / 正本 / ゲート / 台帳。CI・会計の正式な意味は除く)、チャット応答の名残、仮置きの残り (〇〇 / XXX)、英語直訳 (version→「版」 等)、太字が表示されない書き方 (CommonMark の flanking 規則) と直し方。`natural-japanese` が禁止語から外した「最後に」「まさに」は足さない | yomiyasu: `references/slop-catalog.md` §2・5・6、`gemini-syntax.md` 原則 14 / natural-japanese: `skills/natural-japanese/scripts/lint.py` |
| 却下 (2026-10-19: textlint は導入しない。この repo は Markdown の参照資料で CI も Node 依存も持たず、流派の不一致で大量指摘が出る規則を既定のまま当てる利点が無い。和欧間スペースの方針と導入時の設定値はこの行と ja-writing/SKILL.md に残っているので、導入するときはここから引く) | FYI | 運用 | 和欧間スペースの流派: このリポジトリの和文は入れる側で統一 (和欧間・インラインコード前後・スラッシュ前後)。`ja-spacing` を既定のまま当てると、誤りではなく流派の不一致として大量に指摘される。textlint を導入するなら `space: "always"`、code / link の `before` / `after` を `true`、`ja-no-space-around-slash` を無効にし、「」の前後にスペースを置く箇所 (`ja-no-space-around-parentheses` に掛かる) は直すか無効にするかを決める。一般原則 (既定より対象文書の実測を先に数える) だけは `ja-writing/SKILL.md` に入れた。この行で未対応なのは textlint を実際に導入するかどうか。和文字間の半角スペース 1 件 (`skills/harness-design/SKILL.md` の「clone より古い を」) は `ja-no-space-between-full-width` に検出されるが、列挙の直後に助詞を続けた意図的な区切りなので直さない | ja-spacing: `packages/textlint-rule-ja-space-between-half-and-full-width/README.md` § Options、`packages/textlint-rule-ja-no-space-around-slash/src/index.js` |
| 対応済 (2026-10-16) | FYI | skill | `ja-slop-review/SKILL.md` § 鮮度の「出所 clone を持たない」が、`stop-ai-slop-jp` の SHA 追従開始で実態とずれた → 原典 STALE 時に対応表経由で見直す経路を追記 | stop-ai-slop-jp 蒸留版の frontmatter |
| 対応済 (2026-10-19: install.sh の sparse-checkout に repo 別の除外を追加し、smarthr-design-system は参照しない public/ (画像) を外す。手元の clone も同じ設定にして 748MB → 447MB。.git の blob は残る) | FYI | 運用 | `smarthr-design-system` の clone は画像込みで約 750MB と他の原典より 1 桁重い。参照するのは `src/content/articles/products/contents/` だけ。`install.sh` の sparse-checkout は全 repo 共通 (`/*` から `.claude/skills` を除く) なので、repo 別の絞り込みを入れるなら `install.sh` 側の改修が要る | `du -sh` 実測 |

---
## 2026-10-16

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (2026-10-18: 公式 docs で確認。Opus 5.5 が top-level を無視するのは正しいが、Opus 5.5 / Sonnet 5.5 / Haiku 5.5 の既定は `medium` で設定値と同じなので実害なし。top-level は Opus 5 / Fable 5.1 以前には効くので残す。BREAKING の前提「既定 `high`」は誤り) | BREAKING | settings | Opus 5.5 以降の 5.x はユーザー設定のトップレベル `effortLevel` を**無視する**。環境側 `settings.json` にトップレベル `effortLevel` が実在し `modelSettings` は無い (grep 済) ので、Opus 5.5 では意図した値が効かずモデル既定 (`high`) で動いている。`modelSettings` のモデル別エントリへ移す。原典自身は LOW / confidence 0.85 の追記なので、直す前に公式 `settings-reference` で裏を取る。2026-09-01 の `effortLevel` fallback 項目 (RECOMMENDED) はこれで格上げ | ccbp: `best-practice/claude-settings.md` の `effortLevel` 行、`3a30a81` (changelog #32) |
| 対応済 (2026-10-18: 公式 settings-reference で no-op を確認し環境側から削除) | RECOMMENDED | settings | `alwaysThinkingEnabled: true` は no-op (思考は既定 ON。Opus/Sonnet/Haiku 5.5 と Fable は `false` でも切れない)。環境側 `settings.json` に `true` で実在 (grep 済) — 削ってよい。`enableArtifact: true` も no-op だが未使用 | ccbp: 同ファイル `alwaysThinkingEnabled` 行、`3a30a81` (#5・#6) |
| 却下 (該当なし: 列挙された 5 キーは環境側の settings・hooks・agents のどこにも無い。2026-10-19 grep 済) | FYI | settings | 旧記述どおり書くと壊れるキー: `feedbackDrafts` は `"notify"`/`"quiet"`/`"off"` (boolean ではない)、`strictKnownMarketplaces` は source object 配列 (空配列で全ブロック)、`USE_BUILTIN_RIPGREP` は `0` がシステム `rg`、`CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE` は v2.1.142 から no-op、`askUserQuestionTimeout` は user / managed からしか読まれない。いずれも環境側・この repo で未使用 (grep 済) | ccbp: `3a30a81` (#2・#3・#7・#20・#21) |
| 却下 (いま使う必要なし: 2 キーとも公式 settings index に実在を確認。未使用なので必要になったら使う) | FYI | settings | 新しい制御キー: `permissions.blockReadsOutsideWorkingDirectories` (v2.1.257+。任意スコープの `true` が managed の `false` に勝つ) で Read を作業ディレクトリ + `additionalDirectories` に閉じる、`bashOutputMaxChars` (v2.1.261+、`BASH_MAX_OUTPUT_LENGTH` より優先) で Bash 出力取り込み上限。未使用 (grep 済)、必要になったら使う | ccbp: `best-practice/claude-settings.md` Permissions 表・`bashOutputMaxChars` 行 |
| 却下 (該当なし: WORKFLOW_SUBAGENT_MODEL / SUBAGENT_MODEL / autoCompactWindow は環境で未使用。autoCompactWindow は ON HOLD) | FYI | hook / subagent | hook イベントは 33 件 (原典 CLAUDE.md の列挙は 30 件なので正は claude-code-hooks / 公式)。dynamic workflow 内 subagent は `CLAUDE_CODE_WORKFLOW_SUBAGENT_MODEL` (v2.1.296) が `CLAUDE_CODE_SUBAGENT_MODEL` より優先。subagent frontmatter の `autoCompactWindow` は 10-15 時点でも ON HOLD → 確定情報として使わない | ccbp: `11cdc15`、`3a30a81`、`changelog/best-practice/claude-subagents/changelog.md` 10-15 entry |

### claude-cookbooks 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: Managed Agents 未使用。repo・~/.claude/hooks に API 呼び出しコードなし (grep 済)。claude-cookbooks.md に索引済み) | FYI | 運用 | Managed Agents の `multiagent_20261001` ではオーケストレータ自身の inline agents と workflow runs が**既定で on**。委譲先を固定したいなら `subagents.inline_agents` / `workflows` を `{"type": "disabled"}` にする。自動付与 tool は `create_agent` / `send_to_agent` / `list_agents` / `send_to_parent` に変わった (旧 `coordinator` 型の `wait_for_agents` / `submit_result` 前提のプロンプトは要書き換え)。このハーネスは Managed Agents 未使用 (grep 済) | cookbooks: `39cd5a7`、`managed_agents/CMA_plan_big_execute_small.ipynb` |
| 却下 (該当なし: 環境の agents は単独の専門家定義。オーケストレータ側にワーカーの振る舞いを書いたプロンプトは無い) | FYI | subagent | オーケストレータはワーカーの system prompt を見られない — ワーカーについて知っているのは自分のプロンプトに書かれたことだけで、記述と実プロンプトの一致はサーバが強制しない。`predefined_agents` は作成・更新時に snapshot されるので、ワーカー定義を変えたらオーケストレータも update する。Managed Agents 固有だが、Claude Code の orchestrator 系プロンプトに subagent の振る舞いを書くときも同じ同期問題がある | cookbooks: 同上 |
| 却下 (該当なし: SDK・API を呼ぶコードなし (grep 済)。traceparent の要点は claude-cookbooks.md に索引済み) | FYI | 運用 | SDK / API 利用の可観測性: 処理単位を自前 span で包み SDK span と API span を `traceparent` で 1 trace に繋ぐ。トークン合計は `CLIENT`・`SERVER`・`model_request` を重ねて数えない。課金は span でなく Usage & Cost API で照合。`content_mode` は既定 `metadata_only` で運用し、それでも外へ出る tool description・agent 名・MCP サーバ名に機密を書かない。未使用 (grep 済) | cookbooks: `b2b0aa1`、`observability/opentelemetry_tracing.ipynb` |

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: agent loop を自作していない。660 turn の実測は awesome-harness-engineering.md に索引済みで、自作するときに引ける) | FYI | 運用 | compaction を既定にしない根拠の実測 (本番 AI tutor 660 turn): 全履歴保持 recall 100% / $0.11/turn に対し compaction 構成 58% / $0.24/turn。要約が cache 済み prefix を書き換えて cache hit を壊すのが原因。先に真の制約 (window / 請求額 / 品質) を名指しし、cache を保つ truncation と tool 出力上限を優先する。README 注記のみが根拠で記事本文は未確認。agent loop を自作するときの判断材料 | ahe: `277feb4`、`README.md` の `Context Delivery & Compaction` |
| 対応済 (2026-10-16) | FYI | 運用 | upstream が履歴を書き換え (旧 13 commit を同内容で再作成)、`distilled_commit` `2bcb329` が上流履歴から消えた。ツリー一致を確認のうえ clone を `origin/main` に揃え、同一ツリーの `809d878` に付け替えた。`check-freshness.sh` は diverged clone を `BEHIND` としか出さず `pull --ff-only` 案内が失敗する — 再発したら同手順 (tree 比較 → reset → SHA 付け替え) で直す | ahe: `809d878` (旧 `2bcb329` と tree `1b7089a` 一致) |

---
## 2026-10-13

### visual-slop-review 棚卸しから

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-19: visual-slop-review/SKILL.md の Quick checklist に terracotta・near-black + 単色アクセント・tinted near-black・broadsheet 調・template chrome を追記) | RECOMMENDED | skill | `visual-slop-review/SKILL.md` の Quick checklist は既定ルックを indigo/purple-blue・cream-beige・Inter・serif italic・eyebrow・pill・01/02/03 までしか名指ししていない。`references/web-ui.md` に足した 4 類型 (near-black + acid green / vermilion の単色アクセント、terracotta `#D97757`、broadsheet 調、テンプレ小道具 = `A · B · C` 連結・末尾 `→`・小ラベルだけ monospace) が常に読まれる checklist に無い。grep 済: SKILL.md に該当語なし | anthropics/skills `41bbe19` の `skills/frontend-design/SKILL.md` calibration 節 |
| 対応済 (2026-10-19: visual-slop-review/references/prescriptions.md に plan → review の 2 パスと行長 80 文字未満を追記。5 類型と見出しの強調語は web-ui.md と SKILL.md checklist に反映) | FYI | skill | Anthropic 公式 frontend-design skill が 2026-09-03 に改訂 (5 類型の既定ルック回避、見出しの一語強調・ALL CAPS ラベル禁止、行長 80 字未満、plan → review の 2 パス)。併用環境では生成時の振る舞いが変わる | anthropics/skills `41bbe19` (June 版 `2235be7` との差分) |
| 却下 (反映済: visual-slop-review/references/images.md の表と処方「焼き込まない」に既出) | FYI | 運用 | 画像内の日本語テキスト崩れは GPT Image 2 以降で弱まった (常用漢字の短い語句は読める)。短い見出しが正しくても実写・人手の証拠にならない。小さい文字・長文は今も崩れ、OpenAI 公式も Limitations に文字配置を挙げるので、処方「画像に日本語を焼き込まない」は据え置き | developers.openai.com image-generation guide Limitations 節、aifromjapan.com の実地検証 |

### skills (anthropics/skills) 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-19: yokai-refs-update/SKILL.md 手順4 に失敗・中断・契約不履行の子 agent の repo は他を止めず未カバーとして手順7で列挙すると追記。手順7と Quick checklist にも反映) | RECOMMENDED | skill | 並列 fan-out の指示に入れる 4 点: (1) 起動は条件付きで書き "always" にしない (2) 子 agent に日付を渡す (3) 1 agent の失敗で全体を落とさず「未カバー」として列挙 (4) miss が高くつく review は全 item を独立 second look に回す。全 agent に届くべき規則は "state this to every agent word for word" と書く。grep 済: `yokai-refs-update` 手順4 は (2) を持つが (3) の失敗時の扱いが無い | skills: `dbd4588`、`skills/claude-api/shared/managed-agents-multiagent.md` § Dynamic workflows、`shared/managed-agents-quickstarts/bug-hunter.md` |
| 却下 (該当なし: 環境の agents と hooks に reasoning / thinking / trace field の要求なし。2026-10-19 再 grep 済) | FYI | CLAUDE.md / skill / subagent | 出力や tool input に `reasoning` / `thinking` / `trace` field を要求する指示が Fable 5/5.1・Opus 5/5.5・Sonnet 5.5 で refusal を招きうる。thinking block を読むか「答えの短い説明」を求める形に書き換える。grep 済: skills/・instructions/・`~/.claude/agents/`・`~/.claude/CLAUDE.md` に該当なし = **当たらない** | skills: `9d63080`、`skills/claude-api/shared/prompt-audit.md` Group 1 |
| 却下 (該当なし: 独立判定を要する fan-out を持たない) | FYI | subagent | 独立判定のはずの複数 agent が共有ファイルで互いの結果を見られる構成は独立性が崩れる。作業フォルダを分け、証明役には claim だけ渡す。この repo の fan-out (再蒸留) は 1 agent 1 出力ファイルで判定の独立性を要しないので当たらない | 同上 2 ファイル |
| 却下 (該当なし: Managed Agents 固有の話で、このハーネスは使っていない) | FYI | MCP | Managed Agents の既定推奨は agent toolset `auto` 明示 + `web_fetch`/`web_search` 明示 off (bare toolset では 8 tool 全有効)、`mcp_toolset` は `always_ask` 既定のまま。Claude Code の settings とは直接対応しないが MCP 承認を緩めるときの判断材料 | skills: `dbd4588`、`shared/managed-agents-tools.md` |
| 却下 (該当なし: 原典は Managed Agents onboarding のセットアップ手順。このハーネスに本番 run を伴うセットアップ手順は無い) | FYI | 運用 | セットアップ手順では check で捕まる失敗に本番 run を使わない: 着手前に read-only の前提確認、user に用意させるものは 1 ターンで列挙、token は対象 host に who-am-I で検証、seed は読み戻す | skills: `dbd4588`、`shared/managed-agents-onboarding-from-url.md` |

### awesome-harness-engineering 再蒸留から

原典は README 注記のみ。リンク先の論文・記事本体は未読。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (既に機械化済: グローバル CLAUDE.md の安全上の禁止事項 (commit 規約のメタ語・環境固有値の流出・一括ステージ) は PreToolUse hook で強制。残りは参照資料の案内と言語設定で、安全制約ではない) | RECOMMENDED | CLAUDE.md / hook | 安全上重要な制約を compaction されうる context (CLAUDE.md の散文・会話中の指示) だけに置くと、compaction 後に違反率が 0% → 30% (モデルにより 59%) に上がり、Constraint Pinning で 0% に戻る。禁止事項は permissions / hooks のように compaction の外で効く仕組みに寄せる。grep 済: グローバル CLAUDE.md の禁止事項のうち commit 規約は PreToolUse hook で一部機械化済み、他は散文のみ | ahe: `f106c46` (arXiv 2606.22528)、`README.md` Context Delivery & Compaction |
| 却下 (常時ロードの指示は CLAUDE.md の手書き約 20 行 + managed block 9 行と小さく、各行に理由がある。eval 基盤が無いため ablation で効果を測れない。原則は awesome-harness-engineering.md の中心原則 3 に Boris Cherny 講演とともに索引済み) | RECOMMENDED | 運用 | 積み上げた指示はモデル能力への賭けで古くなる。Anthropic は Opus 5 で Claude Code の system prompt を約 80% 削り eval 退行なし。モデル更新ごとに指示を剥がし、繰り返す失敗を直す行だけ足し戻す棚卸しを運用に組む。grep 済: CLAUDE.md・instructions/ にモデル更新時の棚卸し規定は無い | ahe: `14aa095`、`README.md` Context Delivery & Compaction |
| 却下 (自作ハーネスなし。点検の基準線は awesome-harness-engineering.md に索引済み) | FYI | 運用 | Pi / OpenClaw / Claude Code / Letta と Arize 自社 agent が独立に同じ context 管理機構に収束: read 上限 + pagination、tool call 境界での閾値 compaction、巨大結果の disk 退避、subagent の context 分離。自作ハーネス点検の基準線 | ahe: `2bcb329` |
| 却下 (meta-harness を導入する予定なし。arXiv 2609.01437 は awesome-harness-engineering.md に索引済み) | FYI | 運用 | 自律的なハーネス生成・進化は code / deep-research 系で人手ハーネスに大きく劣り、改善の未知タスクへの転移も部分的。自己改善型 meta-harness 導入の判断材料 | ahe: `3452ab7` (arXiv 2609.01437) |

### claude-code-best-practice / awesome-design-md 再蒸留から

claude-cookbooks (`9c1e493`、self-hosted sandbox の claude-quickstarts への移動のみ) は候補なし。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (重複なし・対応不要: plugin-authoring と同名・同用途の自作 skill は無い。原典の判定も割れたまま) | FYI | skill | `plugin-authoring` が bundled skill に追加 (pane・band・status line・toast・slash command・hook の mod 作成/修正)。本セッションの skill 一覧で実在を確認。原典内では skills 側 COMPLETE / commands 側 INVALID と判定が割れ、公式 docs の bundled 一覧にも未掲載。この repo と環境側 skills に同名・同用途なし (grep 済) | ccbp: `d9f3c8b`, `b8d79b6`、`best-practice/claude-skills.md` row 25 |
| 却下 (原典 ON HOLD: agents で autoCompactWindow 未使用。公式 frontmatter 表に載るまで書かない) | FYI | subagent | subagent frontmatter の `autoCompactWindow` (v2.1.296、主会話より早く compact) は CHANGELOG のみが根拠で 2 run 連続 ON HOLD。公式 frontmatter 表に載るまで agent 定義に書かない | ccbp: `8d65977`, `5913991`、`changelog/best-practice/claude-subagents/changelog.md` 10-12・10-13 |
| 却下 (該当なし: ui-design に Responsive Behavior / Iteration Guide 章を前提にした記述は無い。grep 済) | FYI | skill | awesome-design-md の DESIGN.md は 10 章型と 8 章型 (Responsive Behavior / Iteration Guide 章なし、34 件) の 2 型。8 章型のレスポンシブ方針は Layout 節の "Responsive Strategy"。grep 済: `ui-design` 等に両章を前提にした記述なし = **当たらない** | awesome-design-md: `c7c1bad` |

---
## 2026-10-06

### skills (anthropics/skills) 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (2026-10-19 に Group 2 の 2 行を skills/*/SKILL.md と instructions/ に当てた。解決しないパス・リンクは 0 件、同じ論点での食い違いも無く直す対象なし) | RECOMMENDED | 運用 | `claude-api` の prompt-audit が coding agent の設定ファイル (`CLAUDE.md` / `AGENTS.md` / rules / skills / commands / subagents / output styles) を正式な監査対象にした。Group 2 に「複数の instruction file が同じ論点で食い違う (狭いスコープの override は除く。新旧が履歴で決まらなければ `flag`)」「instruction file に書いたパス・コマンドが実在しない」の 2 行が入った。このハーネスの skills/ と instructions/ に一度当てる価値がある。`~/.claude/` 配下は request で名指ししたときだけ scope に入る | skills: `8a1541c` / `skills/claude-api/shared/prompt-audit.md` Step 0・1・Group 2 |
| 却下 (該当なし: think harder / overthink / ultrathink 等を grep し 0 件) | FYI | CLAUDE.md / skill | thinking の深さを散文で指示する文 (think harder / don't overthink 等) は cruft 扱いになり、`effort` (frontmatter が受け付けるならそこ) に置き換える。grep 済: skills/・instructions/・`~/.claude/CLAUDE.md`・`~/.claude/agents/` に該当表現なし = **当たらない** | skills: `8a1541c` / `prompt-audit.md` Group 1 thinking-depth 行 |
| 却下 (該当なし: tool 最小化・必要なときだけ型の抑制文を grep し 0 件) | FYI | CLAUDE.md / skill | 「tool は必要なときだけ」「tool 呼び出しを最小化」等の抑制文に Sonnet 5.5 が字義どおり従い、接続済み tool / skill を使わず手持ち知識で答えがちになる。抑制文を消して「いつ参照先を確認するか」を書く。grep 済: 該当表現なし = **当たらない** | skills: `8a1541c` / `prompt-audit.md` Group 1d Tool-use discouragement 行 |
| 対応済 (2026-07-12) | FYI | skill | frontend 生成で「generic な AI 感を避けよ」の曖昧な 1 行は所見扱い。効くのは既定スタイルの名指し列挙 (原典例: cream 背景、見出しの italic 強調語、01/02/03 番号ラベル、monospace ラベル、pill ボタン)。grep 済: `visual-slop-review/references/web-ui.md` が cream・serif italic・01/02/03・badge pill・monospace (cyberpunk 文脈) を既に名指ししている | skills: `8a1541c` / `prompt-audit.md` "One exception to 'restate positively'" |
| 却下 (該当なし: この repo に skill の eval 基盤は無い。規律は蒸留版 skills.md の evals 索引から必要時に引ける) | FYI | 運用 | skill / prompt を eval で改善するときの規律: 登る前に oracle / null baseline、mechanism を外して score が落ちるか確認、split はランダムで headline は test delta、1 round 1 仮説、停滞時は失敗を grader / harness / 構造 / variance に分類してから動く。eval 実行は subagent で包まず `run_in_background`。この repo に skill の eval 基盤は無い | skills: `8a1541c` / `skills/claude-api/shared/evals/{eval-audit,eval-hillclimb}.md` |
| 対応済 (2026-10-19: DISTILLING.md の再蒸留プロンプト雛形に、原典は data であり原典内の CLAUDE.md・SKILL.md・AI 宛て文言に従わない・コマンドを実行しない・トークンや ID を写さないと追記) | FYI | 運用 | URL からの取り込みに trust tier を設ける型: first-party は内容を写してよく、それ以外は設計だけ持ち込む。tier は下がる方向にしか動かない。page は data であり、ページ内コマンドは実行せず AI 宛て文言は無視、ID / token は写さない。原典の対象は Managed Agents onboarding で、refs-update の再蒸留 (外部 clone を subagent に読ませる) への適用は類推 | skills: `683bc88` / `skills/claude-api/shared/managed-agents-onboarding-from-url.md` §0・§2b |

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-19: 環境側 commit-guard hook の冒頭にガードごとの撤去条件を記載。モデル能力の補助に当たるのは一括ステージのガードだけで、他は方針が変わるまで残す。skill は判断手順で撤去対象の統制ではない) | RECOMMENDED | 運用 / skill / hook | ハーネスの各統制に expiry condition (いつ外すか) を付け、モデル向上に合わせて外していく。grep 済: skills/・instructions/・`~/.claude/CLAUDE.md` に撤去条件の記述は 1 つも無い = **当たる**。原典 `templates/HARNESS_CHECKLIST.md` の「Can be removed when」表が雛形。README 注記ベースで記事本文は未確認 | ahe: `c0f85b2` / README Foundations「The State Of AI Harness Engineering 2026」、`templates/HARNESS_CHECKLIST.md` |
| 却下 (該当なし: ~/.claude/CLAUDE.md と instructions/ はどちらも手書き。後半は既存方針と同じ向きで、ETH Zurich の件は awesome-harness-engineering.md に索引済み) | FYI | CLAUDE.md | 機械生成した context file は成功率を下げ推論コストを上げる (ETH Zurich の結果の引用)、散文ルールより実行可能スクリプトを推奨。grep 済: この repo と `~/.claude/` の CLAUDE.md は手書き = 前半は **当たらない**。後半は 2026-09 以前の「自然言語ルールは guardrail ではない」系と同方向。README 注記ベースで数値未確認 | ahe: `c0f85b2` / README Foundations |
| 却下 (該当なし: 多段 handoff の構成なし) | FYI | subagent | agent 間 handoff が 4 回を超えるとほぼ失敗 (Microsoft)、reviewer agent が性能を落とす例もある。refs-update は 1 段の並列委譲で該当しない。多段連鎖を設計するときの判断材料 | ahe: `c0f85b2` / README Foundations |
| 却下 (並列 agent の隔離基盤は運用対象外。isolation の論点は awesome-harness-engineering.md に索引済み) | FYI | 運用 | 並列 agent の信頼性を prompt の行動規則でなく container・worktree・credential・network policy の隔離で担保する (isolation over coordination)。並列 subagent の衝突対策の材料 | ahe: `9224798` / README Task Runners & Orchestration「Scion」 |

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: ハーネス内に ultracode の言及なし (grep 済)。トグル化は claude-code-best-practice.md に反映済み) | FYI | 運用 | v2.1.284 で ultracode は effort レベルではなくトグル (`/effort ultracode [on\|off]`) になり、`xhigh` を強制しなくなった。effort を上げたいならレベルを別に指定する。原典 settings 表 (v2.1.252 で更新停止) は旧説明のまま。grep 済: ハーネス内に ultracode の言及なし = **当たらない** | ccbp: `89c46ca` / `best-practice/claude-commands.md` #55 |
| 却下 (該当なし: attach 手順の記述なし (grep 済)。v2.1.285 の挙動は claude-code-best-practice.md に反映済み) | FYI | 運用 | v2.1.285 以降 `/resume` で走っている background セッションを選ぶと、この端末がそれに attach し今の会話が background に回る。「再開不可なので `claude agents` で attach」系の手順は古い。grep 済: 該当手順なし | ccbp: `5d35032` / `best-practice/claude-commands.md` #90 |
| 却下 (該当なし: --max-findings の挙動は claude-code-best-practice.md に反映済み。必要になったら引ける) | FYI | 運用 | `/review` (`/code-review`) に `--max-findings n\|all\|default` が加わり、`default` を渡すまで次回以降も持ち越される | ccbp: `9940964` / `best-practice/claude-commands.md` #63 |
| 却下 (いま手を入れる対象なし: visual-slop-review はチャートを dataviz に回している。artifact-* は Artifact 実行環境向けで用途が違う。個数の主張は ON HOLD) | FYI | skill | bundled skills に `slides` / `artifact-capabilities` / `artifact-diagramming` / `artifact-design` / `claude-in-chrome` (Chrome 連携時のみ) が加わった。自作 skill (`ui-design` / `visual-slop-review`) との用途重複を点検するときの材料。`artifact-design` は commands reference に無く、削除候補 3 件も ON HOLD なので個数は確定値として引用しない | ccbp: `5a9b008` `68b1951` `0f757ce` / `best-practice/claude-skills.md` |

### awesome-design-md 再蒸留から

候補なし (差分は README のバッジ追加 1 行のみ)。

## 2026-09-29

### claude-cookbooks 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: Messages API を呼ぶコードなし。claude-cookbooks.md に索引済み) | FYI | 運用 | 会話途中で top-level `output_config.effort` を変えると prompt cache が壊れる (effort はプロンプトに描画される)。会話内では固定するか、対応モデルなら per-message effort 変更 (beta) を使う。grep 済: この repo に Messages API を呼ぶコードは無く、環境側の `effortLevel` は Claude Code の設定で API の `output_config` ではない = **当たらない**。自前の agent loop を書くときの規準として保持 | cc: `bf24d45` / `cost_optimization/cost_optimization.ipynb` |
| 却下 (該当なし: client 側 compaction の実装なし。preserved thinking の件は claude-cookbooks.md に索引済み) | FYI | 運用 | preserved thinking check を走らせるモデルでは、client 側で過去の tool 結果を prune すると以降の thinking block が全部無効になり、次のリクエストが拒否されうる (境界ごとの一括 prune がそのままでは壊れる)。server 側 context editing / compaction を使うか、prune 時に該当 thinking block も落とす。grep 済: この repo に client 側 compaction の実装は無い = **当たらない** | cc: `bf24d45` / `cost_optimization/cost_optimization.ipynb` |
| 却下 (該当なし: API を呼ぶコードなし。claude-cookbooks.md に索引済み) | FYI | 運用 | effort の既定値はモデルごとに違うので呼び出しごとに明示する。thinking を切れないモデルでは effort が推論コストの主な制御手段。1 世代古いモデルなら、下位階層へ下げる前に「新世代 + 低 effort」を測る。cache read 0.1x は一部の新モデルでさらに低い。compaction の `instructions` は既定の要約プロンプトを置き換える (追記ではない)。grep 済: API を呼ぶコードが無い = **当たらない** | cc: `bf24d45` / `cost_optimization/cost_optimization.ipynb` |

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: MCP 設定手順・plugin trust の規約なし。根拠は README 注記だけ) | FYI | MCP / 運用 | Kimi Code CLI は MCP 設定を JSON の手編集でなく対話コマンド `/mcp-config` で行い、plugin の trust level をハーネスの一級の関心事として扱う。grep 済: この repo に MCP 設定手順・plugin trust の規約は無い = **当たらない**。README の注記のみが根拠で本体は未検証 | ahe: `cf40b01` / `README.md` `### Demo Harnesses` |

claude-code-best-practice の再蒸留は**候補なし** (38 commits はバッジ・★数・drift-check の定期エントリで、changelog は既報 ON HOLD 項目の繰り返し。v2.1.283 の `/doctor prompt-audit` は名前が出るだけで使い方の記述が無い — 2026-09-05 の `prompt-audit` 運用項目の関連情報)。

---
## 2026-09-26

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (既に満たしている: 登録済みの PreToolUse hook は commit-guard だけで、一致箇所と対処を stderr に返す) | FYI | hook | 検証 hook のエラー文もハーネスの出力として設計する型 — 決定論的チェックが「次に何をすべきか」(具体値・該当パス) を agent に返すとループが 1 回の修正で閉じ、prompt 上のルールだけより 10–48% 安いと原典注記。grep 済: 環境側の `PreToolUse` hook 2 本 (`commit-guard.sh` / `codex-prompt-guard.sh`) はいずれも一致箇所と「対処:」行を stderr に返しており**既に満たしている**。新しい hook を書くときの規準として保持。根拠は README の 1 文注記のみでリンク先本体は未検証 | ahe: `396366f` / `README.md` `### Verification & CI Integration` (shadcn-ui/lint) |
| 却下 (該当なし: 並列 worktree・完了判定の仕組みなし。DeepCode は awesome-harness-engineering.md に索引済み) | FYI | 運用 | 完了判定を固定の合格条件にせず、タスクに応じて test / build / 静的検査 / diff を選び、検証失敗を次の修復の入力にする (evidence-driven completion)。並列 worktree の衝突は黙って上書きせず明示する。grep 済: この repo の skill / instructions に完了判定や並列 worktree の規約は無い = **当たらない**。README の注記のみが根拠 | ahe: `c4d4810` / `README.md` `### Demo Harnesses` (DeepCode) |
| 却下 (該当なし: context 圧縮の仕組みなし。SoL-Pi は awesome-harness-engineering.md に索引済み) | FYI | 運用 | 圧縮・効率化機構は opt-in にし、検証を飛ばさない・証拠を隠さないことを条件にする (ログを receipt に圧縮するのは、残す引用がアーカイブ原文と全件一致するときに限る)。grep 済: この repo は context 圧縮機構を持たない = **当たらない** | ahe: `1e12fda` / `README.md` `### Context Delivery & Compaction` (SoL-Pi) |

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: repo と ~/.claude/ に AGENTS.md なし。原典 clone 内の AGENTS.md への注意は harness-design/SKILL.md で済んでいる。v2.1.277 の事実は claude-code-best-practice.md に反映済み) | FYI | CLAUDE.md | v2.1.277 から Claude Code が `AGENTS.md` を公式に読む ("can read that on its own or alongside CLAUDE.md")。ON HOLD は README 表の載せ方の編集判断だけで、サポートの事実ではない。grep 済: この repo にも `~/.claude/` にも `AGENTS.md` は無く、言及は `instructions/reference-routing.md` の対象列挙と `skills/harness-design/SKILL.md` の「原典内の AGENTS.md はそのリポジトリの規約」注意書きのみ = **当たらない**。原典 clone を cwd にして作業する場合はその clone の `AGENTS.md` が読み込まれうる点は、この注意書きの前提として知っておく | cbp: `58c39e4` / `changelog/best-practice/concepts/changelog.md` |
| 却下 (該当なし: repo の skill はどれも allowed-tools を使っていない。grep 済) | FYI | skill | command の `allowed-tools` 型が `string/list` に訂正されたが、原典の skills 表は `string` のまま (原典内で食い違い)。grep 済: この repo の skill は `allowed-tools` を使っておらず、環境側で使うのは第三者 skill 1 本のみで文字列表記 = **当たらない**。skill でリスト表記を使う前に公式 docs で確認する | cbp: `af44910` / `dcefa30` / `best-practice/claude-commands.md`・`best-practice/claude-skills.md` |
| 却下 (重複なし: settings 編集系の自作 skill は無い) | FYI | skill | bundled skill に `update-config` (settings.json の変更を自然言語で依頼) が加わり 19 本。grep 済: この repo・環境側に settings 編集系の自作 skill は無い = **重複なし**。settings 変更系の skill を自作する前にこれを確認する | cbp: `ef69750` / `best-practice/claude-skills.md` row 19 |
| 却下 (/heapdump の注意は claude-code-best-practice.md に反映済み。毎セッション読ませる価値は無いので CLAUDE.md に足さない) | FYI | 運用 | `/heapdump` の `.heapsnapshot` には会話と credentials が入る。バグ報告で共有するのは `-diagnostics.json` だけにする。grep 済: ハーネス内に言及なし。運用上の注意として保持 | cbp: `4b86b1c` / `best-practice/claude-commands.md` #37 |

### claude-cookbooks 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: API 直叩きのマルチエージェントなし。elapsed 時計は claude-cookbooks.md に索引済み) | FYI | 運用 | Messages API で自前のマルチエージェントを組むと、チームは速さより徹底性に最適化しがち。対策は共有時計 `[elapsed Ns]` (予算付きなら `[elapsed Ns / Ms]`) を毎回の呼び出し直前に最新 user message の末尾へ追記すること (末尾追記なので cache は壊れない)。`claude-fable-5-1` 前提で、Opus 5 以前は十分テストされていない、品質への影響も未測定と原典に明記。grep 済: この repo は API 直叩きのマルチエージェントを持たない = **当たらない** | cookbooks: `a4b0d89` / `patterns/agents/latency_multi_agent.ipynb` |
| 却下 (該当なし: fallback を組む API コードなし。claude-cookbooks.md に索引済み) | FYI | 運用 | Fable 5 fallback の課金記述が改訂された — 「出力前の classifier block は非課金」は撤回。`bio` / `frontier_llm` / `reasoning_extraction` カテゴリの block は通常料金で課金され、fallback すると両方に課金される。block を繰り返し再送する運用はそのぶんコストが増える。grep 済: この repo に fallback を組む API コードは無い = **当たらない** | cookbooks: `c5ff1dc` / `fable_5_fallback_billing/guide.ipynb` |
| 却下 (該当なし: Admin API を使っていない。claude-cookbooks.md に索引済み) | FYI | 運用 | Admin API では API キーを作れない (一覧・改名・無効化・archive のみ)。原典は定期監査用途を想定しており、例は 90 日超・無期限のキーを dry run 既定で flag する。service account を扱うには `org:admin` の OAuth が必要。grep 済: ハーネス内に言及なし = **当たらない** | cookbooks: `6b671ef` / `misc/admin_api.ipynb` |

skills (anthropics/skills)・awesome-design-md (ui-design) の再蒸留は**候補なし** (前者は claude-api skill の refusal 課金記述の訂正のみ、後者は README の宣伝バナー差し替えのみ)。

---
## 2026-09-16

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: 計画 artifact も ~/.claude/commands も無い。原典も README の 1 行注記で本体未検証) | FYI | skill / 運用 | GitHub Spec Kit (<https://github.com/github/spec-kit>) が Planning & Task Decomposition に追加。`spec.md` → `plan.md` → `tasks.md` を成果物とし、`/specify` `/plan` `/tasks` `/implement` で着手前に意図を機械検査可能な計画へ落とす型。計画の記録層を prompt でなく文書に置き、計画品質をレビュー可能な成果物にする側。grep 済: この repo は `instructions/reference-routing.md` + skill 5 本の構成で、計画 artifact も slash command 定義 (`~/.claude/commands` 自体が不在) も持たない = **当たらない**。原典の記述も README の 1 行注記のみで本体未検証。計画を成果物化する必要が出たときの参照先 | ahe: `9dd1a74` / `README.md` `### Planning & Task Decomposition` |

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: 環境の agents はどれも CLAUDE.md を最初に確認する前提で書かれている) | FYI | subagent | subagent frontmatter に `omitClaudeMd` (boolean、任意、v2.1.271) が追加された。`true` で user/project/local の CLAUDE.md を読まず起動する (managed policy file は読む)。`--agent` や `agent` 設定で**メインセッションとして走る場合は無視される**。grep 済: 環境側の subagent 定義 8 本はいずれも本文に「CLAUDE.md を最初に確認し」と明記しており、**CLAUDE.md を読ませる前提で書かれている** = 現状そのまま当てる対象は無い。この repo 側に subagent 定義は無い。CLAUDE.md 非依存の単機能 subagent を足すときの選択肢。原典の subagents 表には ON HOLD で未反映なので採用前に公式 docs で確認する | ccbp: `changelog/best-practice/claude-subagents/changelog.md` 2026-09-15 #1 / `34dfc03` |
| 却下 (仕様確認済みだが上限を固定する必要なし: 公式 docs で maxEffortLevel はどのファイルにも置けて低い値が優先と確認。上限を設けると /effort で上げられなくなる) | FYI | settings | v2.1.271 で `maxEffortLevel` setting が追加されたと concepts changelog が CHANGELOG 由来で記録。ただし原典の settings リファレンス本体は v2.1.252 止まりで**型・取りうる値・スコープは原典から確認できない**。grep 済: 環境側 `settings.json` にトップレベル `effortLevel` が実在する (2026-09-04 台帳の `/effort` 項目と同じ当たり先) ので、effort の上限を settings 側で固定できるなら当たる。仕様は公式 docs で確認してから | ccbp: `changelog/best-practice/concepts/changelog.md` 2026-09-15 #12 / `c0099b2` |
| 却下 (原典が未確定: /skill-doctor は ON HOLD と INVALID を行き来している。repo には /skill-doctor を前提とする手順が無い (grep 済)) | FYI | 運用 | 2026-09-07 台帳の `/skill-doctor` 項目 (skill バジェット点検に使う RECOMMENDED) の**前提が再び揺れた**。分類が 3 回反転している — 09-05 INVALID → 09-07 bundled skill として追加確定 → 09-15 再び削除候補 ON HOLD。公式 docs は「v2.1.252 以降 + feature-flag fetching が必要」と書き原典の「v2.1.261 追加」と食い違ったまま。`/skill-doctor` 前提の運用手順を組むなら**起動可否を実機で確認してから**にする | ccbp: `changelog/best-practice/claude-skills/changelog.md` 2026-09-15 #3 / `0d9318c` |

---
## 2026-09-14

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: verifier 役の subagent も、親 context を継承する経路も無い) | FYI | subagent / skill | subagent へ渡す context を 2 モードで設計し分ける型。`isolated` = 新規 context で開始し context isolation を firewall として使う / `forked` = supervisor の会話全体を継承し、末尾の tool call 除去・task description を user message へ書き直し・prompt caching 維持。判断規則は「進行中の調査を継続する worker は fork、独立に判断すべき verifier は isolate」。grep 済: この repo で subagent を使うのは `yokai-refs-update` の手順4 だけで、自己完結した再蒸留を `general-purpose` (isolated) に投げる構成 = 規則どおり。**verifier 役の subagent も、親 context を継承する経路も持たない**ため現時点で当たらない。環境側の 8 エージェント定義もすべて新規 context。今後レビュー/検証役の subagent を足すときの設計材料 | ahe: `README.md` `Design Primitives > Context Delivery & Compaction` (`3be1ff8`)、<https://www.langchain.com/blog/organizing-context-in-a-multi-agent-harness> |
| 却下 (埋め込み型 agent を作る予定なし。codex-as-a-platform は awesome-harness-engineering.md に索引済み) | FYI | 運用 | OpenAI が Codex ハーネスを再利用可能な基盤として組み込む分業論を一次資料化 — アプリ側が UI・業務コンテキスト・MCP tool・承認ゲート、app-server 側が agent loop と sandbox 実行。付随 datapoint: ARC-AGI-3 で reasoning 保持 + compaction がスコア 3 倍・出力トークン 1/6。埋め込み型 agent を作る段になったときの境界設計の参照先 | ahe: `README.md` `Design Primitives > Task Runners & Orchestration` (`ca71915`)、<https://developers.openai.com/blog/codex-as-a-platform> |
| 却下 (eval 駆動へ移る判断は将来の話で、いま直す対象なし。Beagle と DarwinX は awesome-harness-engineering.md に索引済み) | FYI | 運用 | ハーネス改変を測定可能な最適化ループとして回す研究基盤 (Salesforce Beagle / DarwinX) と、自己改善ハーネス研究の地図 (STOP → Meta-Harness → ADAS → AFlow → AlphaEvolve、および workflow automation / filesystem を永続記憶に / sub-agent・backend job の 3 パターン) が Foundations に揃った。いまの手動チューニング運用を eval 駆動へ寄せる将来判断の材料 | ahe: `692a1a6` / `1cf81ec`、<https://lilianweng.github.io/posts/2026-07-04-harness/>、<https://arxiv.org/abs/2608.07545> |

### claude-code-best-practice 再蒸留から

74 commits の大半は star drift・バッジ日付・changelog 追記。実質変更は built-in command 3 件のみで、frontmatter フィールド数・settings キー・bundled skills・built-in agent types はいずれも動いていない。`BREAKING` / `RECOMMENDED` なし。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (二次資料の判定を確定と見なさない規律は claude-code-best-practice.md に明記済み。追記すると重複になる) | FYI | 運用 | **ON HOLD は解消されずに静かに消える** — `/cost` / `/reload-plugins` / `/effort` の 3 件が 09-05 を最後に changelog から落ちたのに公式 docs 表には未反映のまま、以降の run は "fully in sync" と宣言している。二次資料の「同期済み」宣言を、保留項目が決着した証拠として読まない | ccbp: `changelog/best-practice/claude-commands/changelog.md` (`87432c6`) |
| 却下 (該当なし: output-style の記載なし (grep 済)。復活の件は claude-code-best-practice.md に反映済み) | FYI | 運用 | `/output-style [name]` が built-in slash command として復活 (Config #13、v2.1.269)。v2.1.74 で「deprecated、`/config` を使え」として表から削除された行の復活。**削除されたコマンドは戻りうる**ので「過去に消えたから存在しない」と決め打ちしない。grep 済: repo・環境側とも `output-style` / `outputStyle` の記載なし | ccbp: `0a8ab15`、`best-practice/claude-commands.md` #13 |
| 却下 (該当なし: /import の cursor 対応は claude-code-best-practice.md に反映済み) | FYI | 運用 | `/import` が `cursor` を第 3 の取り込み元として受け付ける (`/import [codex|gemini|cursor]`、v2.1.265+)。Cursor の instruction files・MCP servers・commands・subagents・skills を移行できる。grep 済: 該当なし | ccbp: `a39717e`、`best-practice/claude-commands.md` #11 |
| 却下 (該当なし: /advisor のテキスト出力は claude-code-best-practice.md に反映済み) | FYI | 運用 | `/advisor` は非対話 (`-p`) と Remote Control では引数なしで現在の advisor を**テキスト出力**し、ピッカーを開かない (v2.1.260)。ヘッドレス実行から advisor 状態を取れる。grep 済: 該当なし | ccbp: `a39717e`、`best-practice/claude-commands.md` #53 |

### skills (anthropics/skills) 再蒸留から

差分 1 件は claude-api skill の Managed Agents 承認まわり。grep 済: この repo と環境側に Managed Agents クライアント実装は無く (`evaluated_permission` / `always_ask` / `ant beta:sessions` のヒットは蒸留版と本台帳のみ)、**いま当たる箇所は無い**ため 3 件とも `FYI` に落とす。Managed Agents を実装する段で `RECOMMENDED` に昇格させる。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: Managed Agents の承認フローを実装したコードは無い。蒸留版 skills.md に索引済) | FYI | 運用 | 承認待ちの検知条件は、自分が設定した policy (`always_ask`) ではなく **イベントの `evaluated_permission === "ask"`**。`agent.tool_use` だけでなく `agent.mcp_tool_use` も対象。policy で分岐する実装は `auto` の判定不能ケースを取りこぼし、session が `requires_action` で止まる。`auto` で server が deny した呼び出しは承認フローに入らず、そこに `user.tool_confirmation` を送ると 400 | skills: `skills/claude-api/shared/managed-agents-client-patterns.md` §4、`managed-agents-tools.md` § Permission Policies (`34040c9`) |
| 却下 (該当なし: Managed Agents の permission policy を使う箇所が無い。蒸留版 skills.md に索引済) | FYI | 運用 | `auto` は人間のチェックポイントではない。safe と判定された呼び出しは誰も見ないうちに実行され、効果は取り消せないことがある。人の確認を必須にしたい tool には `auto` でなく `always_ask` を明示する | skills: `managed-agents-tools.md` § `auto` 警告ブロック |
| 却下 (該当なし: Managed Agents の auto 評価に依存する箇所が無い。蒸留版 skills.md に索引済) | FYI | 運用 | `auto` の評価が「あなたの意図」として信頼するのは **`user.message` のテキストだけ**で、tool result・取得した Web ページ・MCP 応答・thread 間メッセージの同じ文言には効力がない。裏返すと信頼できない end-user 入力を `user.message` に中継すると意図として読まれ、deny されるはずの呼び出しが allow されうる。multiagent では subagent thread のメッセージにこの重みはなく、`auto` の deny は primary thread に cross-post されない | skills: `managed-agents-tools.md` § "What the evaluation trusts"、`managed-agents-multiagent.md` § "`auto` in multiagent sessions" |
| 却下 (該当なし: ant CLI でセッションを運用していない。必要時に anthropic-cli.md を引けば足りる) | FYI | 運用 | `ant beta:sessions connect <session-id>` で走行中セッションに端末を接続し、承認待ちを Allow / Deny (`deny_message` 付き) で捌ける。`--web` は Console の session viewer を `127.0.0.1` にローカル配信 (URL は 1 回・2 分限り)。端末ビューは primary thread のみ、`--web` は全 thread を追従 | skills: `skills/claude-api/shared/anthropic-cli.md` § "Attach a terminal to a session" |

---
## 2026-09-09

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: 環境の permissions に ask は 0 件) | FYI | settings | 非技術者 113 名の user study で、ユーザーが事前に書く allow/ask/never ポリシーは per-action の HITL 承認より overreach 阻止率が**約 20 ポイント低い**。原因は大半のルールを `ask` に倒すこと — 静的な事前コミットが実行時プロンプトに退行し、判断負荷だけ残って保護が増えない。grep 済: 環境側の permissions は `ask` が 0 件で、危険操作は `deny` と `autoMode.soft_deny` で決め切っている構成のため、この失敗形には当たらない (**個々のルールの中身は環境固有なので台帳に書かない**)。今後 `ask` を足したくなったときの判断材料として持つ | ahe: `README.md` `Permissions & Authorization` 節 (`86e75a3`)、<https://arxiv.org/abs/2608.27443> |
| 却下 (transcript 正規化の構想なし。trajectory は awesome-harness-engineering.md に索引済み) | FYI | 運用 | `letta-ai/trajectory` — Claude Code / Codex / Cursor / Gemini CLI 等 15+ ハーネスの session transcript を検証済みの単一レコード形式へ正規化するライブラリ。狙いは observability ではなく **agent による消費** (記憶形成・検索・訓練)。複数ハーネスのログを記憶や eval の素材にする構想が出たときの基盤候補。grep 済: この repo に transcript 正規化の記述は無い | ahe: `README.md` `Memory & State` 節 (`c02c6a2`)、<https://github.com/letta-ai/trajectory> |

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (原典が未確定で、かつ /skill-doctor を前提とする手順がハーネスに無い。バージョンの食い違いは claude-code-best-practice.md に記載済み) | FYI | 運用 | 上の 2026-09-07 `/skill-doctor` 項目への訂正 — 必要バージョンは原典内で**いまも食い違ったまま**。`claude-commands.md` は「v2.1.252 以降 + feature-flag fetching」、`claude-skills.md` は「Introduced v2.1.261」。09-06 の訂正で決着したわけではない。grep 済: ローカルは v2.1.266 なのでどちらの前提でも満たしており実害なし。手順に組むなら厳しい側 (v2.1.261 以上) を要求する | ccbp: `best-practice/claude-commands.md` 97 行目 / `best-practice/claude-skills.md` 65 行目 (`965621e`) |
| 却下 (1 run の判定を確定と見なさない規律は claude-code-best-practice.md に skill-doctor の例ごと明記済み) | FYI | 運用 | 二次資料の 1 run 判定を確定と見なさない規律の追加実例、かつ**逆向き**の実例。`skill-doctor` は 09-05 に「built-in command であって bundled skill ではない」で INVALID とされた後、09-07 に commands reference の `[Skill]` マーカーを根拠に採用され bundled skills 表 row 18 に入った。1 run の INVALID を根拠に台帳から項目を落とすと取りこぼす。さらに 09-08 の run は公式ページの truncation で `simplify` / `review` / `security-review` の検証に失敗しており、原典自身が「取得できなかったことは削除の証拠ではない」と明記している | ccbp: `changelog/best-practice/claude-skills/changelog.md` の 2026-09-07 / 09-08 entry (`c3f5e85`) |

### community-group 再蒸留から

今回は取り込み候補なし。差分 4 件は DTCG 仕様リポジトリ内に閉じる — `799af2d` は JSON Pointer 対応の MAY/MUST 内部矛盾の解消 (蒸留版の既存記述 MUST と元から一致)、`8e43819` は `@dtcg/test-suite` パッケージ追加、残り 2 件は devDependency bump。

---

## 2026-09-07

### awesome-harness-engineering 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-19: check-freshness.sh に DEAD 判定を追加。形式 1 の蒸留版で索引テーブルの dir/file.ext 形パスを clone HEAD の tree で引き、無ければ exit 1。SKILL.md・DISTILLING.md・README に DEAD の扱いを追記) | RECOMMENDED | 運用 / skill | 記憶・参照資料の失効を**主張単位**で検出する型 (OpenWiki self-correcting memory) — 各 claim をバージョン付きの根拠と紐づけ、根拠が動いた claim だけを stale として旗立て、再検証まで「不確か」を持続させる。grep 済: `check-freshness.sh` の判定は形式 1 が clone HEAD と `distilled_commit` の SHA 比較、形式 2 が `reviewed_at` の経過日数だけで、いずれも**ファイル単位**。蒸留版の個々の主張と原典パスの対応が切れても検出されない (原典側でファイルが移動・削除されても STALE は「差分がある」としか言わない)。索引テーブルの原典パス生存チェックを足すのが最小の一歩 | ahe: `README.md` `Memory & State` 節 (`0a10903`)、<https://www.langchain.com/blog/self-correcting-memory-openwiki> |
| 却下 (手を入れる対象なし: 第三者の teardown。挙動の確定には公式 docs を使う) | FYI | CLAUDE.md / skill / subagent / hook / settings | `lintsinghua/claude-code-book` — Claude Code ハーネス内部の teardown (15 章 139 図)。tool system・**4 段階の permission pipeline**・context compaction・memory・hooks・subagent スケジューリング・MCP・skills・streaming・plan mode を設計判断の *why* 付きで扱う。permission や hook の設計根拠を調べるときの当たり先候補。第三者の teardown なので挙動の確定には公式 docs を優先する。grep 済: この repo に permission pipeline の記述は無い | ahe: `README.md` `Tutorials & Educational` 節 (`adfc01b`) |

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (原典が未確定: skill-doctor は削除候補 ON HOLD で、INVALID との間を往復中。前提が確定するまでは運用に組み込まない) | RECOMMENDED | 運用 | `/skill-doctor` で「ロード済みだが未使用の skill」と「skill ごとの context コスト」を出せる。grep 済: 環境側 12 skill + この repo 5 skill が常時ロードされており剪定判断の材料になるが、台帳にも repo にも `/skill-doctor` の記述は無い。`/skills` 画面の `t` キーで token 数ソートも可。要件は **v2.1.252 以降 + feature-flag fetching** (原典が 09-06 に v2.1.261 から訂正したので古い数字を持たない) | ccbp: `best-practice/claude-commands.md` #50、`changelog/best-practice/claude-commands/changelog.md` 2026-09-05 / 09-06 (`70481a1`, `80b755c`) |
| 却下 (DEVELOPMENT WORKFLOWS 表を設計根拠に使っている箇所なし。規律は claude-code-best-practice.md に明記済み) | FYI | 運用 | 原典 README の DEVELOPMENT WORKFLOWS 表の agent / command / skill 個数とステップ列は run ごとに揺れ、09-05 の run は 8 リポジトリ分の変更提案を**全件 ON HOLD** で据え置いた。他リポジトリのワークフロー構成をこの表から引用してハーネス設計の根拠にしない (二次資料の 1 run 判定を確定と見なさない規律の追加実例) | ccbp: `changelog/development-workflows/changelog.md` 2026-09-05 (#10〜#21) |

---
## 2026-09-05

### skills (anthropics/skills) 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-10-19: 不足していた見出しの 1 語だけを強調する tell と不要な typographic ラベルを web-ui.md、行長 80 文字未満を prescriptions.md と SKILL.md checklist に追記。他は web-ui.md に既出) | RECOMMENDED | skill | 公式 frontend-design の AI っぽさ tell クラスタが 3 → 5 に増え、既存の tell リストに**無い**項目が出た: **template chrome** (中黒つなぎの meta 文字列、`WORD — fragment`、`#0B0B0B`/`#111` の擬似黒、リンク末尾の `→`)、`#D97757` を「Anthropic 自身の accent なので tell」と名指し、typography 既定禁止 3 項目 (見出し中 1 語だけのアクセント / ラベルの全大文字 / 不要な typographic ラベル)、行長 80 字未満。grep 済: eyebrow・ALL-CAPS・カード kit の同一 radius/shadow (`opacity 0.1`) は `visual-slop-review/references/web-ui.md` に既出だが、上記は未収載。`ui-design` / `visual-slop-review` の次の棚卸しで差分を足す | skills: `skills/frontend-design/SKILL.md` (`41bbe19`) |
| 却下 (このハーネスはモデルを固定していない (settings の model 未指定、agents に model 指定なし) ので「モデルを上げる」契機が来ない。prompt-audit は蒸留版 skills.md に索引済) | RECOMMENDED | 運用 | モデル移行後に prompt を据え置くと**精度でなくコストで効く** (Opus 4.8 向け prompt を Opus 5 で回すと ticket あたり +36%、精度は不変。監査後は未監査比 -14% かつ正答 92%→97%)。モデルを上げたら `prompt-audit` を走らせる運用にする | skills: `skills/claude-api/shared/cost-optimization.md` § 2.2 |
| 却下 (該当なし: update suppressor・anti-formatting 型の指示を grep し 0 件) | FYI | CLAUDE.md | 「hold all findings for the final response」「don't narrate」型の update suppressor と、「never use bullets」「no headers」「no bold」型の anti-formatting rule は over-narrate / over-format する旧モデル向けで、現行モデル (特に Fable 5.1) では逆に *under*-narrate / *under*-format を招く。`~/.claude/CLAUDE.md`・`instructions/`・各 `SKILL.md` を grep したが該当表現は無く実害なし。今後この型の指示を書かない指針として持つ | skills: `skills/claude-api/shared/prompt-audit.md` Group 1d (`5304866`) |
| 却下 (該当なし: reminder を履歴に差し込む hook なし) | FYI | hook | 数ターンごとに「reminder: ...」を履歴へ差し込み次リクエストで取り除く実装は二重に有害 — 現行モデルは 1 回で保持し、かつ preserved thinking では**取り除くこと自体が history edit** で cache が miss し以降の thinking block が無効化される。残すなら `role: "system"` + `clear_at: "next_user_message"` を毎ターン append し過去分を消さない。この repo と環境側に hook 定義は無い (grep 済) | skills: `shared/prompt-audit.md` Group 1d、`shared/prompt-caching.md` |
| 却下 (手を入れる対象なし: 自作の tool schema なし) | FYI | skill / MCP | progressive disclosure の閾値が数値化された — tool schema は**合計 ~10K token を超えてはじめて `defer_loading` が黒字**で、それ未満は検索ステップが純オーバーヘッド。「取りに行くターン」が増えて逆に高くつく場合があるので eval で検証する条件付き | skills: `shared/cost-optimization.md` § 2.2 と "Workload shape -> lever" 表 |
| 却下 (手を入れる対象なし: 一般知識で、蒸留版から必要時に引ける) | FYI | subagent | subagent は「自己完結する重い中間結果を吸収して 1 行返す」ステップに使う。判断側がその中間文脈を要るなら使わない。**subagent は親と cache を共有しない新規 prefix** になる。context editing は節約レバーではなく context-window ツール (クリアのたびに cache を壊す)、`max_tokens` は backstop であってチューニングノブではない | skills: `shared/cost-optimization.md` § 2.3 / § 2.4 |
| 却下 (該当なし: Managed Agents を使っていない) | FYI | 運用 | Managed Agents のリポジトリ skill 発見は **cloud sandbox 限定** (self-hosted sandbox は `github_repository` 非対応)、agent 1 つに attach できる skill は**最大 20** | skills: `shared/managed-agents-tools.md` |

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (2026-10-18: 2026-10-16 の BREAKING 行と同じ理由。既定と設定値が一致し、`modelSettings` のキー形式は docs に明記が無いので、固定したくなったら `/effort` に書かせる) | RECOMMENDED | settings | `/effort` は v2.1.243 から**モデル別に `modelSettings` へ保存**するようになり、トップレベル `effortLevel` は「`modelSettings` にエントリの無いモデルの fallback」へ降格した。環境側 `settings.json` に `effortLevel` が実在する (grep 済) ので**この repo で唯一実ハーネスに当たる項目**。no-op ではないが、モデルごとに既定 effort を固定したいなら `modelSettings` 側に書く。あわせて `modelSettings` / `modelPicker` は**マージ例外**で、最上位スコープのファイルが値全体を供給する (下位からの追記が消える) | ccbp: `best-practice/claude-settings.md` Model Overrides 表・Scope precedence 節、同 changelog 2026-09-01 項目 4・5・7 |
| 却下 (ハーネス内に旧 docs/en/settings を参照する箇所なし (grep 済)。移動の件は claude-code-best-practice.md に反映済み) | RECOMMENDED | 運用 | 公式の settings キー索引が **`docs/en/settings-reference` に移動**した (`docs/en/settings` は task 指向ガイドに再編されキー索引を持たない)。settings を調べるときの当たり先を変える | ccbp: `best-practice/claude-settings.md` Sources 節、同 changelog 2026-09-01 項目 2 |
| 却下 (該当なし: CLAUDE_CODE_SUBAGENT_MODEL と teammateDefaultModel は未使用。公式では teammateDefaultModel は削除済みと確認) | FYI | settings / subagent | `CLAUDE_CODE_SUBAGENT_MODEL` は v2.1.238 で **override から「既定値」に変わった** (agent 定義の `model:` や呼び出し時の明示指定に負ける)。`teammateDefaultModel` は **v2.1.251 で削除**され残すと no-op (teammate はリードのモデルを継承)。環境側 `settings.json` と repo をいずれも grep したが未使用で該当なし | ccbp: `best-practice/claude-settings.md`、同 changelog 2026-09-01 項目 6・12 |
| 却下 (意図どおり: yokai-refs-update は disable-model-invocation の明示起動専用で、/skills 画面の toggle を前提にしていない) | FYI | skill | `skillOverrides` の運用注意 — **plugin skill / `disable-model-invocation: true` の skill / managed `skillOverrides` エントリを持つ skill は `/skills` 画面から可視性を切り替えられない**。この repo では `yokai-refs-update` が該当する (明示起動専用の設計なので意図どおり)。ユーザーの手動 toggle を前提にした skill 設計をしない、の根拠として持つ | ccbp: `best-practice/claude-commands.md` `/skills` 行、同 changelog 2026-09-02 項目 2 |
| 却下 (該当なし: PreModelSwitch / PostModelSwitch は環境の hooks で未使用) | FYI | hook | hook イベントが **26 → 28** になり v2.1.252 で `PreModelSwitch` / `PostModelSwitch` が追加された (2026-08-31 台帳の「公式 changelog の孫引き」項目が原典表に反映された形)。この repo と環境側に hook 定義は無い (grep 済) | ccbp: `best-practice/claude-settings.md` hooks リダイレクト節、同 changelog 2026-09-01 項目 13 |
| 却下 (該当なし: 列挙された新キーはいずれも環境の settings で未使用。2026-10-19 grep 済) | FYI | settings | 凍結していた `claude-settings.md` が v2.1.224 → v2.1.252 に追いつき、新設キーが本文に載った: `crossSessionInbound` (`accept`/`hold`/`refuse`。**より厳しい値なら project/local が managed に勝つ**非対称ルールの新実例)、`dialogExpiry`、`autoContinueAtUsageLimit`、`feedbackDrafts` (`SendFeedback` の gate)、`desktopSessionCleanupPeriodDays`、`promptCacheTtl` / `subagentPromptCacheTtl`、`keybindingFlavor`、`spellcheck`、`disableCommandPluginSources` (managed のみ)、marketplace source type `command` (+`mode: "link"`)、sandbox credentials の JWT/AWS マスキング。2026-08-27 台帳の「未反映の新キー」項目はこれで解消 | ccbp: `best-practice/claude-settings.md`、同 changelog 2026-09-01 項目 3・4・8・9・10 |
| 却下 (該当なし: /subtask・/desktop・/review の前提条件に依存する手順なし。claude-code-best-practice.md に反映済み) | FYI | 運用 | slash command の前提条件が明文化: `/subtask` は **v2.1.212+ かつ agent view 有効時限定**、`/desktop` は macOS または **x64** Windows + サブスクリプション必須、`/review` は引数が `/code-review` と同じ完全形になりレベル省略時は**前回のレベルを再利用**。`/usage-credits` の `DISABLE_EXTRA_USAGE_COMMAND=1` は公式 docs から消えたため、2026-08 蒸留に載せていた記述を撤回 | ccbp: `best-practice/claude-commands.md` #61/#66/#91、同 changelog 2026-09-02 項目 1・3 / 2026-09-04 項目 1・2 |
| 却下 (原典が未確定: cacheTtl・claude agent・fork は ON HOLD のまま。ハーネス内に依存する記述なし) | FYI | 運用 | 前回台帳の watch item の現況: `experimental.cacheTtl` (subagent frontmatter) と `claude` built-in agent は 09-04 時点でも **ON HOLD のまま**で公式表に未反映 → 確定情報として使わない。`fork` agent type は 08-31 に drift 表から消えて以降 09 月の run にも復活せず**判断保留のまま**。2026-09-01 台帳の `fork` 項目 (5 回目の変転) をこれで更新する | ccbp: `changelog/best-practice/claude-subagents/changelog.md`、`changelog/best-practice/claude-commands/changelog.md` |

### claude-cookbooks 再蒸留から

原典側では BREAKING / RECOMMENDED として上がったが、**このハーネスには permission ルールも hook も Agent SDK コードも無い** (`~/.claude/settings.json` に `permissions` / `hooks` キーが両方とも存在しないことを確認済) ため、全件 `FYI` に落とす。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (既に正しい形: settings.local.json の絶対パス Read ルールはスラッシュ 2 個で書かれている) | FYI | settings | permission のパスルールを絶対パスで書くとき、**スラッシュ 1 個で始めると設定ソース基準で解決されて何にもマッチしない** (`dontAsk` 下では全 read が拒否される)。正しい形はスラッシュ 2 個。環境側 `settings.json` に permission ルール自体が無いので現時点の該当なし。将来 allowlist を書くときの必須知識 | cookbooks: `claude_agent_sdk/scheduled_repository_reviewer/scheduled_repository_reviewer.ipynb` code cell 12 |
| 却下 (該当なし: read を repo 内に閉じ込める要件が無い) | FYI | hook | `allowed_tools` の `Read(...)` ルールは `Grep` / `Glob` へ **best-effort にしか適用されない**。read を repo 内に閉じ込めたいなら `PreToolUse` hook で symlink 解決後のパス検査と、`/`・`~` 始まり / `..` を含む / `{` を含む glob の deny を重ねる | cookbooks: 同 notebook (MD 11)、`scheduled_review.py` |
| 却下 (該当なし: 他人の repo を処理する Agent SDK エージェントを持たない) | FYI | settings | 他人の repo を処理するエージェントには `setting_sources=[]` を設定する。マシン側設定を切るだけでなく**対象 repo 自身の `.claude/settings.json` と `CLAUDE.md` をセッションから外す** ("a repository you don't control should not configure its own reviewer")。あわせて `strict_mcp_config=True` で MCP tool 定義が全リクエストに載るのを防ぐ | cookbooks: 同 notebook (MD 11) |
| 却下 (該当なし: claude-agent-sdk 未使用 (grep 済)。claude-cookbooks.md に索引済み) | FYI | 運用 | `max_budget_usd` は「超過してから止まる」ので実費は cap を超えうる。bound 超過は `ResultError` (claude-agent-sdk **0.2.140 以降**の型) として raise される | cookbooks: 同 notebook (MD 11, Prerequisites) |
| 却下 (該当なし: resume 型の SDK エージェントなし。claude-cookbooks.md に索引済み) | FYI | 運用 | resume ベースの「前回を覚えている」エージェントは、継続が効いたかを**スキーマの required フィールド**で証明させる (前回 id と所見 id を echo させ、呼び出し側で突き合わせて行頭マーカーを出す)。resume したエージェントは前回読んだファイルの記憶で答えるので、プロンプト冒頭で「ファイル一覧を取り直せ」と明示する | cookbooks: 同 notebook (MD 9, MD 21) |
| 却下 (該当なし: repo と ~/.claude/ (CLAUDE.md・settings.json・agents・hooks) に retired ID なし (再 grep 済)。置換表は claude-cookbooks.md に索引済み) | FYI | 運用 | 旧モデル ID の一括置換表が原典にある。現行の正は `claude-sonnet-5` / `claude-haiku-4-5` / `claude-opus-4-8` で、`claude-opus-4-1` / `claude-opus-4-5` / `claude-sonnet-4-5` / `claude-sonnet-4-6` は retire 済み。Bedrock は新しめが suffix 無し、古いものだけ `-YYYYMMDD-v1:0` 付きの混在。repo と `~/.claude/` を grep したが retired ID の記載は無し | cookbooks: `26b5cdc`、`CLAUDE.md` 3 節、`scripts/validate_all_notebooks.py` の `deprecated_models` |

### awesome-harness-engineering 再蒸留から

差分 4 件はすべて curated list への新規リンク追加で、収載規約 (`CONTRIBUTING.md`)・repo 運用規約 (`AGENTS.md`)・`templates/*.md` に変更なし。既存の書き方を無効化する内容は含まれない。

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (セキュリティ系ハーネスを作る予定なし。Mean Time to Adapt の件は awesome-harness-engineering.md に索引済み) | FYI | 運用 | セキュリティ系エージェントハーネスの設計型 (4 フェーズ 11 ステージ) が公開された。読みどころは解析前の threat modeling で攻撃面を絞る / multi-agent の決定論的投票で false positive を抑える / adversarial validation を修正候補の採用ゲートにする / ハーネス水準の有効性指標に **Mean Time to Adapt** を置く | ahe: `4b2305d`、`README.md` の `Security, Sandbox & Permissions` |
| 却下 (複数 runtime を使い分ける運用なし。fragmentation の件は awesome-harness-engineering.md に索引済み) | FYI | 運用 | 複数 agent runtime を跨ぐ運用の「harness fragmentation」に対し、統一 API 規約の裏で runtime を交換可能にする self-hosted router が登場。単一 CLI に縛られない運用を将来検討する場合の当たり先 | ahe: `1e5cbe1`、`README.md` の `Task Runners & Orchestration` |
| 却下 (手を入れる対象なし: 一般知識で、蒸留版から必要時に引ける) | FYI | skill / hook | ワークフロー一式 (plan→test→implement→review→verify→remember→improve) を agent + skill + hook + memory の**インストール可能な配布物**として梱包する例と、同じ構成要素を zero-code で宣言的に生成するプラットフォームが追加された。自前 skill 群のパッケージ化・配布形態を考えるときの参照 | ahe: `cf8a1a3`, `43905de`、`README.md` の `Generators & Meta-Harnesses` |

---

## 2026-09-01

### claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (該当なし: repo の skill と ~/.claude/skills/ に bundled 名と衝突する name は無い) | FYI | skill | bundled alias が同名の自作 skill を完全に隠す — 公式 docs 引用 "typing the bundled alias `/review` never runs your skill"。skill 名を bundled skill / slash command と衝突させると起動経路を失う。この repo の 5 skill と環境側 12 skill を grep したが `review` 名は無く実害なし。新規 skill 命名時のチェック項目として持つ | ccbp: `changelog/best-practice/claude-skills/changelog.md` の 2026-08-31 entry (`e8f40e6`) |
| 却下 (該当なし: agents で permissionMode・model・prompt の frontmatter は未使用) | FYI | subagent | 原典 subagent 表の未反映 watch item が 3 件に増えた — `permissionMode` の `manual` (`default` の alias、v2.1.200+)、`model` 例の model 名 (公式は `claude-opus-5`、原典は `claude-opus-4-6` のままで `fable` 未記載)、`prompt` フィールド (公式では `--agents` CLI JSON にしか存在せず frontmatter 表には無い)。この repo は subagent 定義ファイルも追跡対象の `settings.json` も持たない (grep 済) ので影響なし。subagent を書く場面では原典の表を正としない | ccbp: `best-practice/claude-subagents.md` と同 changelog の 2026-08-31 entry |
| 却下 (原典が未確定: fork は判定が変転中。ハーネス内の参照は蒸留版と台帳だけで実害なし) | FYI | 運用 | `fork` agent type が 08-31 の subagents drift 表から**行ごと消えた** (08-20 INVALID → 08-24 再オープン → 08-27 再 INVALID → 08-30 ON HOLD に続く 5 回目の変転)。台帳の既存 `fork` 項目 (2026-08-31 / 08-26 分) の「ON HOLD」記述もこれで更新する。二次資料の 1 run 判定を確定と見なさない規律の実例として累積 | ccbp: `changelog/best-practice/claude-subagents/changelog.md` の 2026-08-31 entry |

---

## 2026-08-31

### claude-code-best-practice / claude-cookbooks 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (原典 ON HOLD: agents で experimental / cacheTtl は未使用) | FYI | subagent | subagent frontmatter に `experimental` (object 任意。`cacheTtl` に `5m` / `1h` を置き prompt cache の寿命を指定。subagent ファイルからのみ読まれる、v2.1.248) が drift check で検出された。環境側に長寿命の subagent 定義が 8 件あるので当たりうるが (grep 上いずれも未使用)、**原典自身が ON HOLD で表に未反映**のため確定事実として使えない。採用前に公式 docs で裏を取る | ccbp: `changelog/best-practice/claude-subagents/changelog.md` の 2026-08-29 / 08-30 entry |
| 却下 (該当なし: hooks で未使用。2026-09 の PreModelSwitch 行と重複) | FYI | hook | v2.1.251 で `PreModelSwitch` / `PostModelSwitch` hook が追加されたと CONCEPTS drift ログが記録。モデル切替時に決定的処理を挟む設計の候補だが、凍結した `claude-settings.md` (v2.1.224) には未収録で原典の記述も公式 changelog の孫引き。環境側 `settings.json` の hooks にも未使用 (grep 済) | ccbp: `changelog/best-practice/concepts/changelog.md` 2026-08-30 entry の verification 行 |
| 却下 (重複なし: workflow 作成系の自作 skill は無い) | FYI | skill | `workflow-authoring` が bundled skill (row 16) として確定。dynamic workflows 有効環境では workflow スクリプト作成用の参照 skill が既に載っているので、同等の自作 skill を足す前に重複を確認する。この repo と環境側の skills には同種のものは無い (grep 済) ので現時点の対応は不要 | ccbp: `best-practice/claude-skills.md` row 16, `changelog/best-practice/claude-skills/changelog.md` 2026-08-29 |
| 却下 (ON HOLD は否定ではないという規律は claude-code-best-practice.md に明記済み) | FYI | 運用 | 原典の ON HOLD は「否定」ではない、の実例が増えた。Voice Dictation (06-25 起票) と Artifacts (07-03 起票) の beta バッジは 1〜2 か月 ON HOLD ののち 08-29 に confidence 0.95 で削除確定。逆に `workflow-authoring` は 08-28 INVALID → 08-29 COMPLETE、`fork` agent type は 4 回目の判定反転。「二次資料の 1 run 判定でハーネスを直さない」既存方針の追加裏付け | ccbp: 上記 3 changelog の 2026-08-28〜30 entry |
| 却下 (該当なし: コスト優位を前提とした記述なし (grep 済)。撤回の件は claude-cookbooks.md に索引済み) | FYI | 運用 | Anthropic 公式が「コーディネータ + 安価な並列ワーカー」の**コスト優位の断言と比率 (約 2.5 倍安・3 倍速) を撤回**した。残るのは「チームの入力トークンの 84-98% がワーカー単価で課金される」という構造だけで、比率は run ごとの 1 サンプル扱い。オーケストレーション構成をコスト理由で正当化するときは、比率ではなく rigor を揃えた実測を根拠にする。この repo にコスト優位を前提とした記述は無い (grep 済) | cookbooks: `bbfab1b`, `managed_agents/CMA_plan_big_execute_small.ipynb` |

---

## 2026-08-27

### awesome-harness-engineering / claude-code-best-practice 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 却下 (2026-10-19: 手書き soft_deny はまれだが破局的な操作を止める型で、発火ゼロは不要の証拠にならない。Auto mode の Recently denied は拒否された action の一覧でルール別の発火回数は出ないので、空振りはそもそも測れない) | RECOMMENDED | settings | `/permissions` に v2.1.246 で **Auto mode タブ**が付き、classifier ルールの閲覧・編集と auto mode 拒否履歴の確認が UI からできるようになった。`permissions.defaultMode: "auto"` を使う環境では、手書きした `autoMode.soft_deny` が実際に発火しているかを確認する手段がこれまで無かった。拒否履歴で実効性を測り、空振りしているルールを畳める。**個々のルールの内容は環境固有なのでこの台帳には書かない** (公開リポジトリ) | ccbp: `best-practice/claude-commands.md` row 13 `/permissions`, commit `9640e8a` |
| 却下 (Codex CLI は awesome-harness-engineering.md に索引済み。codex-companion の恒久対処はプラグイン側の話で、いま直す対象なし) | FYI | 運用 | Codex CLI (<https://github.com/openai/codex>) が `Demo Harnesses` に追加。OpenAI 公式の agent loop (sandbox 化された tool 実行・複数ファイル編集・streaming loop) の OSS 参照実装として位置づけられている。環境側に置いている codex 呼び出しの回避策は `codex-companion.mjs` の引数渡しという**プラグイン側の実装都合**に対するものなので、この upstream は直接の解決にはならない。恒久対処 (argv/stdin 経由への修正) を検討するときの一次ソース候補 | ahe: `README.md` の `### Demo Harnesses`, commit `9925eb4` |
| 却下 (ハーネス自身に CLAUDE.md や skill を書き換えさせる運用なし。Exo は awesome-harness-engineering.md に索引済み) | FYI | 運用 | 自己改良ハーネスの設計軸 — Exo (<https://github.com/exoharness/exo>) は prompt / memory / tool / policy を agent 自身に編集させるが、**immutable event log だけは書き換えられない**ことで recursive self-improvement を安全側に留める。ハーネス自身に `CLAUDE.md` や skill を書き換えさせる運用を組むなら「唯一の書き換え不能な土台」を先に決める。中身は未検証 (README の注記ベース) | ahe: `README.md` の `### Generators & Meta-Harnesses`, commit `6a14670` |
| 却下 (該当なし: 列挙された新キーは環境の settings で未使用。2026-10-19 grep 済) | FYI | settings | 凍結した `claude-settings.md` (v2.1.224 止まり、v2.1.247 に対し 23 版遅れ) に無い新キーの実例が増えた: `modelPicker`・`promptCacheTtl`・`keybindingFlavor`・`spellcheck`・`ANTHROPIC_DEFAULT_MODEL` (v2.1.246)、`spinnerTipsOverride` (v2.1.247、同版で `SendFeedback` ツールと `/claude-api cost-optimize` も追加)。`~/.claude/settings*.json` と `yokai-harness` を grep したがいずれも未使用 — settings を触るときは同レポートを正としない、の裏付けとして持つだけ | ccbp: `changelog/best-practice/concepts/changelog.md` の 2026-08-26 / 08-27 entry #13 |
| 却下 (原典が未確定: fork は判定が変転中。ハーネス内の参照は蒸留版と台帳だけで実害なし) | FYI | 運用 | `fork` agent type の判定が **3 回反転**した (08-20 INVALID → 08-24 v2.1.241 docs で確認・再オープン → 08-27「docs は 6 agent、fork 不在」で再 INVALID)。2026-08-26 の台帳項目「再オープンされた」も撤回する。二次資料の 1 run 判定を確定と見なさない規律の追加実例。`yokai-harness` 内の `fork` 参照は蒸留版と本台帳だけ (grep 済) で実害なし | ccbp: `changelog/best-practice/claude-subagents/changelog.md` の 2026-08-27 entry |

---

## 2026-08-26

### awesome-harness-engineering / claude-code-best-practice / skills 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 一部対応 (2026-08-28。環境ローカルの `~/.claude/hooks/` に guard スクリプトを作成・テスト済だが、`settings.json` への登録は auto mode classifier にブロックされ未完了。対象は特定プラグインの引数渡しの不具合への回避策で、この repo の収録物ではないため `hooks/` にも `settings/global.json` にも載せない) | RECOMMENDED | hook | 自然言語の禁止事項は built-in control に写像しない限り guardrail にならない (公開 `CLAUDE.md` 481 件で裏打ちがあるのは約 4%)。この repo が所有する hook は現時点でゼロなので、対象になるのは環境ローカルの `~/.claude/CLAUDE.md` に散文で書かれた規約。**どの規約が該当するかは環境固有なのでこの台帳には書かない** (公開リポジトリ)。原則だけ残す — 散文の禁止事項は `PreToolUse` の block に写すか、写さないと決めた理由を書く | ahe: `82736a9`, README `Permissions & Authorization` の <https://arxiv.org/abs/2608.23550> |
| 却下 (対応不要: refs-update が自分の作業と user 判断の分離を構造として持っている。新しく手順書 skill を作るときの型として蒸留版から引ける) | FYI | skill | 手順書型 skill では「機械的に自分で直す項目」と「user が決める項目」を行頭マーカーで分離し、末尾の Checklist / Report 節でも同じマーカーで再掲する型 (`[BREAKS]` / `[DECIDE]`)。値が確定できないものは推測で書かず report に列挙させる。この repo では `yokai-refs-update` が同じ分離を構造として持ち (再蒸留 = 機械的 / 取り込み候補 = user 判断、深刻度 3 値も本台帳にある) ので新規対応は不要。他の手順書 skill を足すときの型として使う | skills: `3b3fad9`, `skills/claude-api/python/claude-api/sdk-upgrade.md` |
| 却下 (fork と /list-agents の参照はハーネス内に無く実害なし。規律は claude-code-best-practice.md に明記済み) | FYI | 運用 | 二次資料の 1 run 判定を確定と見なさない、の実例が増えた。`fork` agent type は 2026-08-20 に「公式 docs に無い = 誤検出」で INVALID にされた後、2026-08-24 に公式 docs (v2.1.241) で確認され再オープン。前回蒸留の「INVALID で決着」は撤回した。`/list-agents` も v2.1.239 で挙動が反転し、除外されていた agent-team のチームメイトが列挙対象に入った。どちらも `yokai-harness` 内に参照はない (grep 済) ので実害なし | ccbp: `changelog/subagents/changelog.md` の 2026-08-24 entry, `05dd0ee` |

---

## 2026-08-21

### skills / claude-code-best-practice / claude-cookbooks 再蒸留から

| 状態 | 深刻度 | 対象 | 内容 | 根拠 |
|---|---|---|---|---|
| 対応済 (2026-08-21) | RECOMMENDED | skill | `harness-design` / `ui-design` の description 末尾 `Triggers: <語の列挙>` を削る。Anthropic が `claude-academy-guide` → `academy-guide` の rename で description を縮めたとき捨てたのは**まさにトリガー語の列挙**で、残したのは意図カテゴリ。`shared/prompt-audit.md` も trigger-case enumeration を anti-pattern とする。両 skill は本文前半で既に意図カテゴリを書いており、列挙は冗長 | skills: `0a64e39`, `skills/claude-api/shared/prompt-audit.md` の Group 2 |
| 対応済 (2026-08-21。(a)(b) を適用。(c) は不適用 — このスキルの出力はレビュー結果と改稿案で、nudge のような定型 1 行ではないため逐語固定が意味を持たない) | RECOMMENDED | skill | `ja-slop-review` / `visual-slop-review` は返答直前に割り込む **gate 型**だが、gate 型の 3 規律が欠けている — (a)「やらない条件」節が無い (grep で確認)、(b) 回数制限が無い、(c) 出力形式が逐語固定でない。`discernment-nudge` は "When not to" を "When to" より長く書き、「user が既に不要と伝えている」パターンを別立てする。判定ヒューリスティックは `academy-guide` の **"A caveat is the tell"** (「X 向けだが役立つかも」と書きたくなった時点で match 失敗) | skills: `skills/discernment-nudge/SKILL.md`, `skills/academy-guide/SKILL.md` |
| 却下 (実害なし: install.sh のローカル配置だけで packaged skill として配っていない。description は全 skill が 1,024 字以内。配ると決めた時点で再起票) | FYI | skill | `yokai-refs-update` の name は予約語 "claude" を含む。**uploaded custom skill** では name に "claude"/"anthropic" を含められず、description には 1,024 字上限がかかる。`install.sh` 経由のローカル配置では効かないので実害なし。packaged skill として配る決定をしたときに rename する (slash command 名・README・`instructions/` の参照が連動するので単独では動かせない)。description は全 5 skill が上限内 (最長 `harness-design` 583 字) | skills: `0a64e39` の commit 本文 |
| 却下 (LLM 判定を含む仕組みを持たない。compiler と extractor の型は claude-cookbooks.md に索引済み) | FYI | 運用 | LLM 判定を含む仕組みを作るときの既定形 — **モデルを判定者でなくコンパイラ + 抽出器に置く**。モデル呼び出しはポリシー散文→ルール JSON の compile と、コンテンツ→型付きフィールドの extract だけで、判定はモデル呼び出しゼロの純関数。生成物は静的バリデータを通し versioned artifact として固定する (validator-driven repair loop) | cookbooks: `capabilities/content_moderation/engine.py`, `pipeline.py` |
| 却下 (このリポジトリに該当なし。他プロジェクトで todo 前提の指示を書いたら再掲) | BREAKING | CLAUDE.md | v2.1.233 で新しいモデルでは task/todo ツールが deprecated (env var で opt-in)。タスク管理を todo ツールに寄せる設計は避ける。`yokai-harness` を grep したが該当なし | ccbp: `best-practice/claude-commands.md` |
| 却下 (`~/.claude/settings*.json` と project 設定を grep して該当なし) | BREAKING | settings | allow の `Write(path)` は評価されず warning のみの no-op (v2.1.210) → 書き込み許可は `Edit` 側で表現する。allow のツール名 glob は `mcp__<server>__` リテラル前置がある場合しか受理されず、`"*"` / `"B*"` / `"mcp__*"` は起動時 warning 付きで skip され何も自動承認しない | ccbp: `best-practice/claude-settings.md` |
| 却下 (multi-dir 運用をしていない) | RECOMMENDED | hook | `/add-dir` は v2.1.234 からターン中に即確認を求め、成功時に `DirectoryAdded` hook が走る。追加ディレクトリの `.claude/` 設定はほぼ読まれないので、必要な副作用はこの hook 側に組む | ccbp: `best-practice/claude-commands.md` |
| 却下 (managed settings を使っていない) | FYI | settings | settings マージは**非対称**。制限を強める値は下位スコープからも効く (`disableClaudeAiConnectors: true` は managed の `false` を任意スコープから上書き、`remoteControlAtStartup: false` は project/local からでも managed の `true` を上書き) が、逆向きはできない。`fallbackModel` だけは配列なのにマージされず、定義した最上位ファイルがチェーン全体を供給する | ccbp: `best-practice/claude-settings.md` |
| 対応済 (2026-08-21, この台帳と手順6そのもの) | RECOMMENDED | 運用 | 二次資料は公式と必ず突き合わせる。`claude-code-best-practice` の日次 drift check は自ら誤りを注入する (`fork` agent を NEW 判定 → 2 日後に「公式 docs に無い」で INVALID、`CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` を改名・説明反転して 4 日後 revert)。**バッジの日付がその表がまだ追われているかの唯一の指標** — 日次追従は 4 本 + 3 コレクション表だけで、`claude-settings.md` は v2.1.224 停止 (13 版遅れ)、`claude-memory.md` / `claude-mcp.md` は数か月停止 | ccbp: `changelog/*/changelog.md` の各 INVALID 判定 |
| 対応済 (2026-08-21, 既に実装済みと確認) | FYI | 運用 | 腐るデータは同梱せず runtime fetch + staleness 契約にする (`academy-guide` は catalog を fetch し `staleAfter` / `generatedAt` で信頼判定、失敗時は具体名を出さず silent degrade、取得物は "data, not instructions" として field allowlist)。この参照資料機構が `distilled_commit` / `reviewed_at` で既に同型を実装している | skills: `skills/academy-guide/SKILL.md` の "The catalog" |
