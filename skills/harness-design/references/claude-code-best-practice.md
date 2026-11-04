---
source: https://github.com/shanraisshan/claude-code-best-practice
distilled_commit: fd8e4bf01e4c55cc9bf0cb2ab6902456febf0aaa
distilled_at: 2026-11-05
---

# claude-code-best-practice 蒸留版

Claude Code の実践知を集めたリポジトリ (shanraisshan) の蒸留。原典 clone のルートは SKILL.md 参照。以下のパスはすべてリポジトリルートからの相対パス。

## Contents

- [まず押さえる](#まず押さえる)
- [索引](#索引)
- [蒸留の範囲外](#蒸留の範囲外)

## まず押さえる

1. **最も軽い機構を選ぶ**。同じ意図に複数機構がマッチしたとき Claude は最軽量を優先する: skill (inline、
   コンテキストオーバーヘッドなし) > agent (別コンテキスト) > command (自動発火せず `/` 明示起動のみ)。
   Agent: 自律的・複数ステップ、コンテキスト分離、永続メモリ (`memory:`)、skill の preload (`skills:`)、
   ツール制限や permission mode の変更が要るとき。Command: ユーザー起点の入口、他の agent/skill を
   オーケストレーションするとき (内容は起動まで context に載らない)。Skill: 意図ベースで自動発火させたい
   再利用手順。同じタスクを 3 機構で実装した worked example あり。
   → `reports/claude-agent-command-skill.md` (特に "When to Use Each")

2. **Command → Agent → Skill の層状オーケストレーション**。command が入口、agent が別コンテキストで
   自律実行 (preloaded skill 持ち)、skill が inline で出力生成。weather システムとして完動する実装例あり。 →
   `orchestration-workflow/orchestration-workflow.md` (実体は `.claude/commands|agents|skills/`)

3. **ハーネスはプロンプトの言い換えではない**。「全部プロンプトになるから強いプロンプトで代替可能」という還元論は、
   context isolation・harness 強制のツール制限・hooks の決定的実行・model routing・並列・セッション横断永続化など
   10 の能力の前で崩れる。決定論が要る挙動 (attribution、権限、フォーマット) は hooks/settings で強制する。
   → `reports/why-harness-is-important.md`

4. **CLAUDE.md は 1 ファイル 200 行以下を目標** (humanlayer は 60 行)。「どの開発者が起動して
   "run the tests" と言っても一発で動く」が品質基準。settings.json で決定的に強制できるもの
   (`attribution.commit` 等) を CLAUDE.md に書かない。長くなったら `.claude/rules/*.md` に分割し、
   `paths:` frontmatter で対象ファイルに触れたときだけ lazy-load させる。ロード規則はモノレポ設計に直結する:
   ancestor は起動時に全ロード、descendant はそのディレクトリのファイルに触れたとき lazy-load、sibling は
   決してロードされない。root に共通規約、コンポーネント配下に固有規約。個人用は CLAUDE.local.md。
   subagent 単位で CLAUDE.md を切る手段が `omitClaudeMd: true` (boolean、任意、v2.1.271) — user/project/local の
   CLAUDE.md を読まずに起動し managed policy file だけは読む。`--agent` や `agent` 設定で**メインセッションとして
   走る場合は無視**。原典の subagents 表には 09-28 も未反映 (ON HOLD、項目 12)。`AGENTS.md` は v2.1.277 から
   公式サポート (公式 overview の引用: "Claude Code can read that on its own or alongside CLAUDE.md") だが、README の
   Memory 行 Location には未記載で 09-23 から ON HOLD (11-04 も継続)。 → README.md「CLAUDE.md + .claude/rules」tips、
   `best-practice/claude-memory.md`、`changelog/best-practice/claude-subagents/changelog.md`、`changelog/best-practice/concepts/changelog.md` (09-23)

5. **Skills のロードは CLAUDE.md と別物**。ancestor loading はなく、description だけが常駐。full content は
   呼び出し時のみロード。ネストされた `packages/*/.claude/skills/` はそのディレクトリで作業したときに自動発見
   される。例外: subagent の `skills:` preload は full content を起動時注入。バジェットの正は settings 側の
   2 キー — `skillListingBudgetFraction` (既定 `0.01` = context window の 1%。超過すると使用頻度の低い skill の
   description が名前だけに collapse され、呼べるが理由が見えなくなる) と `skillListingMaxDescChars`
   (既定 `1536`、1 skill の `description` + `when_to_use` 合算上限、超過分は truncate)。後者は
   2026-07-31 まで原典が `maxSkillDescriptionChars` と誤記していた無効キー (silent no-op) なので注意。
   可視性は `skillOverrides` で `on` / `name-only` / `user-invocable-only` / `off` を skill 単位に指定できるが、
   **managed の `skillOverrides` エントリまたは `--settings` フラグで指定された skill・plugin skill・`disable-model-invocation: true` の skill は
   `/skills` 画面から切り替えられない** (`--settings` は 10-30 に追記)。切り替わるのは「Claude と `/` メニューへの見え方」。バジェットの実測には `/skill-doctor` (未使用 skill と各 skill の
   context コストを出す。**v2.1.252 以降 + feature-flag fetching が必要**。skills 表 row 18 の
   「Introduced v2.1.261」と**原典内で食い違う**)。`/skills` 画面の `t` キーで token 数順にも並ぶ。なお
   `reports/claude-skills-for-larger-mono-repos.md` の「既定 15,000 文字」「`SLASH_COMMAND_TOOL_CHAR_BUDGET` で
   拡大」は settings レポート (同 env var は slash command tool 出力用) と食い違う。後者を正とする。
   → `reports/claude-skills-for-larger-mono-repos.md`, `best-practice/claude-settings.md`

6. **Skill の書き方 (Anthropic 内部の教訓)**。description は要約でなくトリガーとして書く ("when should I
   fire?")。明白なことは書かず、デフォルト挙動から押し出す差分だけ書く。手順を railroad せず goal と制約を
   与える。Gotchas セクションが最高シグナル (Claude の失敗点を追記していく)。scripts/references/examples を
   同梱しフォルダとして設計。危険な skill は `disable-model-invocation: true` で明示起動のみに。良い skill は
   9 類型 (Library & API Reference / Product Verification / Data Fetching & Analysis / Code Scaffolding ほか) の 1 つに収まる。
   → `tips/claude-thariq-tips-17-mar-26.md`

7. **スコープ設計原則**。個人状態・プロジェクト横断調整 (tasks, teams, auto-memory, credentials,
   keybindings) は global (`~/.claude/`) のみ。チーム共有可能な設定 (settings, rules, agents, commands,
   skills, hooks) は dual-scope で project が優先。settings の優先順位: CLI flags >
   `.claude/settings.local.json` > `.claude/settings.json` > `~/.claude/settings.local.json` >
   `~/.claude/settings.json`。`deny` ルールは最優先で上書き不可。**権限昇格につながる設定は
   project/local から無視される** — untrusted なリポジトリが自分に権限を与えられないようにするため:
   `permissions.defaultMode` の `"auto"` (v2.1.142+、`~/.claude/settings.json` に書く)、`processWrapper`
   (managed/user/`--settings` のみ、v2.1.210)、`footerLinksRegexes`、`pluginConfigs` (v2.1.207+)、
   `sshConfigs` (managed/user)、`strictPluginOnlyCustomization`・`disableCommandPluginSources` (managed のみ)、
   sandbox の緩和系 (`sandbox.filesystem.disabled`・`sandbox.network.strictAllowlist`/`tlsTerminate`・
   `sandbox.credentials` の `mask`)、`askUserQuestionTimeout` (user/managed のみ。10-13 に「project/local のみ」から反転訂正)。
   **非対称**なのが要点で、逆に制限を強める値は下位スコープからも効く — `disableClaudeAiConnectors: true` は
   managed の `false` に対しても任意スコープから、`remoteControlAtStartup: false` は project/local からでも
   managed の `true` を上書きできる。`crossSessionInbound` (`accept` < `hold` < `refuse`) と
   `permissions.blockReadsOutsideWorkingDirectories: true` (作業ディレクトリ + `additionalDirectories` 外の Read を全遮断、
   v2.1.257+) も同じ型で、厳しい側なら project/local が managed に勝つ (書き込み側の `permissions.blockWritesOutsideWorkingDirectories` は 10-30 の concepts run が v2.1.314 CHANGELOG の変更として名前を挙げただけで settings 表には無い — 未検証扱い。10-31 run が v2.1.316 の変更として挙げた `CLAUDE_CODE_DISABLE_ULTRATHINK`・gateway の pooled budgets・`managed.policy_mode: layered` も同じ扱い)。10-13 の訂正で `allowedMcpServers` /
   `deniedMcpServers` は managed 専用でなく任意ファイル (エントリはマージ)、`autoMemoryDirectory` は workspace trust 後なら project/local も有効になった。配列のマージ例外は 2026-09-01 の更新で 4 キーに増えた
   — `fallbackModel` / `availableModels` / `modelPicker` / `modelSettings` はマージされず、定義した最上位の
   ファイルが値全体を供給する (`fallbackModel` は重複除去後 4 件目以降を無視、`availableModels` は managed が
   定義したら下位から拡張できない)。
   → `reports/claude-global-vs-project-settings.md`, `best-practice/claude-settings.md`

8. **permissions 構文には落とし穴がある**。`Tool(param:value)` (`Agent(model:opus)`, `Agent(isolation:worktree)`,
   `Bash(run_in_background:true)`) は **deny / ask 専用**で allow では使えない (allow は各ツール固有の specifier 構文)。
   主コンテンツ欄へのマッチ (`Bash(command:rm *)`) も禁止で起動時 warning。`Write(path)` / `NotebookEdit(path)` /
   `Glob(path)` は allow に書くと parse は通るが**一切参照されない** — allow 評価は `Edit(path)` と `Read(path)` しか
   見ない (v2.1.210)。実質 no-op なので書き込み許可は `Edit` 側で表現する (deny / ask では機能する)。`:*` サフィックスは
   末尾でしか解釈されない (`Bash(git:* push)` はコロンをリテラル扱い)。allow のツール名 glob は **`mcp__<server>__` という
   リテラル前置がある場合しか受理されない** — `"*"` / `"B*"` / `"mcp__*"` は warning 付きで skip され何も自動承認しない。
   全体を allowlist 化するなら `deny: ["*"]` + 個別 allow。
   `Cd(path)` は allow を 1 本でも書くと `/cd` が allowlist モードになり、ワイルドカードも Read/Edit と違う
   (`*` は 1 セグメントのみ、`**` は跨ぐ、gitignore 形式ではない)。`Skill(weather *)` と `MCP(server:tool)` 短縮形は
   2026-08-02 に「公式 docs に無い = 未検証」と注記済み。確実なのは `mcp__server__tool` のみ、`Task(agent-name)` は
   `Agent` の legacy alias。 → `best-practice/claude-settings.md` の Permissions 節

9. **ハーネス側のハード上限を前提に設計する**。並列 subagent は `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`
   (既定 `20`) で制限され超過分は queue へ。ネストは `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` (v2.1.219 時点の
   既定 `3`) まで。Stop hook のブロックは `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` (既定 `8`) 回で打ち切られ以降は
   exit code に関係なくセッションが終了する — 無限にブロックする Stop hook は設計できない。
   `effortLevel` に `"max"` / `"ultracode"` は書けない (session 限定)。**v2.1.284 で ultracode は effort レベルから
   トグルに変わった** — `/effort ultracode [on|off]` でセッションの ultracode を ON/OFF する (commands 表 #56、`on`/`off` 引数は v2.1.284+ と 10-31 に明記。10-30 に
   "at the current level" と v2.1.284 の経緯文を削り「`ultracode` キーは永続、`max` は session 限定」と書き直した)。settings 側は 10-13 に
   独立キー `ultracode` (boolean) を「任意ファイルに書ける永続値」へ訂正したが、settings ファイル内の Effort Level 表と `/effort` 行は
   「session-only・xhigh + workflow」のままで**原典内で食い違う** (commands 表の側は 10-30 で永続キー説に揃った)。永続化できるのは
   `low` / `medium` / `high` / `xhigh` だが、**`/effort` はモデル別に `modelSettings` へ保存する** (10-13 に要求版を
   v2.1.243 → v2.1.251 へ訂正。How to use 節は 243 のまま)。各エントリは `effortLevel`・`maxEffortLevel`・`autoCompactWindow` を持つ
   (`modelSettings: {"opus": {"effortLevel": "xhigh"}, ...}`)。**Opus 5.5 以降の 5.x はユーザー設定のトップレベル `effortLevel` を無視する** — fallback として効くとは限らない。
   `alwaysThinkingEnabled` は既定 ON で `true` は no-op、Opus/Sonnet/Haiku 5.5 と Fable では `false` でも思考を切れない。 → `best-practice/claude-settings.md`

10. **subagent はコンテキスト管理の道具**。判断基準は「このツール出力を後で使うか、結論だけでよいか」— 結論だけなら
    subagent に出す (探索の 20 file reads も dead end も子側に残る)。別コンテキストの同一モデルが自分の書いたバグを
    見つける (test time compute)。~40% 消費で劣化 ("dumb zone") が始まるので /clear・/compact・/rewind で刻む。自動
    compact の発火点は `autoCompactWindow` (100,000〜1,000,000 tokens、未設定ならモデル別) で `/autocompact` /
    `--autocompact` / `CLAUDE_CODE_AUTO_COMPACT_WINDOW` から設定 (v2.1.221+)。走っている subagent / 別セッションへの働きかけは cross-session messaging (`SendMessage`・
    `ListAgents`・`/list-agents` (alias `/peers`)、v2.1.224 で GA。v2.1.239 で agent-team のチームメイトと
    自セッション名の行も出るよう反転)。subagent のモデル指定は **v2.1.238 が breaking change** で、
    `CLAUDE_CODE_SUBAGENT_MODEL` は override から**既定値**に変わった — agent 定義の `model:` と呼び出し時の
    明示指定が env var に優先する。dynamic workflow 内の subagent だけは `CLAUDE_CODE_WORKFLOW_SUBAGENT_MODEL`
    (v2.1.296) が `CLAUDE_CODE_SUBAGENT_MODEL` に優先。`teammateDefaultModel` は v2.1.234 で削除 (10-13 に 251 から訂正) され、teammate はリードのモデルを継承する。
    **タスク管理を todo ツールに寄せる設計は避ける** — v2.1.233 で新しいモデルでは task/todo ツールが
    deprecated になり、既定は `TaskCreate`/`TaskUpdate`/`TaskGet`、旧 `TodoWrite`/`TodoRead`/`TodoDone` は
    `CLAUDE_CODE_ENABLE_TODO_TOOLS=1` での opt-in になった。
    → README「Context」「Agents」tips、`tips/claude-thariq-tips-16-apr-26.md`

11. **Agent memory は CLAUDE.md と補完関係**。`memory:` frontmatter (user/project/local) で agent 専用の永続知識を
    持てる。MEMORY.md の先頭 200 行が system prompt に注入され、超過分は topic 別ファイルへ。CLAUDE.md (人が書く・
    全員が読む) / auto-memory (Claude が書く・本人のみ) / agent memory (agent が書く・その agent のみ) の 3 系統。
    → `reports/claude-agent-memory.md`

12. **frontmatter の正確なリファレンスは best-practice/ にあるが、そのまま信じない**。skills 20・
    commands 20・subagents 16 フィールドの型・意味の表と、公式ビルトイン一覧 (bundled skills 25、
    slash commands 96、agent types 5) がある。設計時は記憶で書かずここを引く。ただし**日次 drift check が動かす
    のはバッジ行と `changelog/` 追記が中心で、表本体は ON HOLD で据え置かれる項目が多い**。10-17 時点:
    - bundled skills は 19 → 25。09-23〜09-30 に row 19–23 (`update-config`・`slides`・`artifact-capabilities`・`artifact-diagramming` (v2.1.221+)・`claude-in-chrome` (Chrome 連携有効時のみ))、
      10-04 に row 24 `artifact-design` (根拠は v2.1.281 の CHANGELOG + 実行セッションの skill 一覧)、10-12 に row 25 `plugin-authoring` (mod = pane・prompt 上の band・status line・toast・slash command・tool call/prompt の hook を作る/直す。根拠は CHANGELOG v2.1.290/v2.1.295 の "the built-in `plugin-authoring` skill"。10-18 に公式 docs の "Requires Claude Code v2.1.287 or later" で導入版を「v2.1.290 から言及」→「v2.1.287+」へ訂正)。
      **row 24・25 は公式 docs の bundled 一覧に無い** — 10-13 run 自身が「report 25 vs official docs 24」と書き、commands 側は `/plugin-authoring` を「built-in plugin の skill」として 10-11・10-12 に INVALID (範囲外) 判定。artifact 系 4 つは Claude が自分で load する参照 skill。
      削除候補 3 件 — row 15 `review` (v2.1.223 で `/code-review` の alias、説明が旧挙動のまま)・row 16 `security-review` (公式は「Skill ツール経由で呼べる built-in command」)・row 18 `skill-doctor` (commands reference の `[Skill]` マークが run ごとに揺れる) —
      は判定が**反転を繰り返している** (09-17 / 09-20 の INVALID が翌 run 以降に再 ON HOLD)。**1 run の INVALID を確定と見なさない**、bundled skill の個数は引用しない (公式 docs が明示列挙する数も run ごとに 24 / 12 / 11 と揺れる)。10-17 (v2.1.302) も 3 件とも ON HOLD 継続、加えて row 25 `plugin-authoring` が「built-in plugin 経由で bundled skill の仕組みではない」として NEW の削除候補 ON HOLD に入った (additive drift なし、20 フィールドは公式と同期)。10-18〜10-26 (v2.1.304〜v2.1.310) も 4 件とも ON HOLD 継続。10-23・10-24 run は冒頭で「bundled skills (25) は公式と完全同期」と書きつつ同じ表で削除候補 4 件を保留しており、**1 run の要約文と表も食い違う**。10-25 run は一転「report 25 vs official docs 20」と書いた (しかも changelog 上で 10-24 エントリより前に挿入されている)。10-27〜10-29 は再び「fully synchronized」、10-30 (v2.1.314) はまた「25 in report vs 20 in official docs」で、v2.1.314 CHANGELOG が `security-review` を "a prompt-based command" と呼ぶことを削除候補の根拠に足した (4 件とも ON HOLD 継続)。10-31 (v2.1.316) も「25 vs 20」のまま 4 件とも ON HOLD 継続。
      **`review` という名前の自作 skill は `/review` から起動できない** (公式 docs の "typing the bundled alias `/review` never runs your skill")。
    - `allowed-tools` の型は commands 表 (09-16)・skills 表 (10-22) とも `string/list` に揃った — 表本体の訂正は 1 か月以上遅れうる。
      10-25 に commands 表だけが公式 skills.md の frontmatter reference に合わせ 16 フィールドの説明を一括同期し、**同日の skills run は「no drift」で skills 表は旧文言のまま** — 同じフィールドの意味は commands 表の側を引く。同期後の commands 表: `allowed-tools` の許可と `disallowed-tools` の制限は**次のメッセージ送信で解除**される (`EndConversation` は他ツールが残る限り外せない)、`model` は**そのターンだけ**有効で `availableModels` で除外された値や auto mode 非対応の値は無視、`hooks` は skill 起動時に登録されセッションの残りずっと動く、`disable-model-invocation: true` は subagent への preload と session-scoped scheduled task からの起動も止める、`paths` は cwd 相対で cwd 外のファイルにはマッチしない、`effort` の選べるレベルはモデル依存。
    - subagents 表 — 5 個 (`general-purpose`, `Explore`, `Plan`, `statusline-setup`, `claude-code-guide`)
      のまま。`claude` (model 継承・全ツール、dispatch された background セッションの既定) は 08-07 から
      ON HOLD。`fork` は 08-20 以降 INVALID / 再オープン / ON HOLD を往復した末 08-31 に drift 表から消え、
      09 月の run にも復活していない。**1 run の判定を確定と見なさない**。frontmatter 側は `experimental`
      (object、任意。`cacheTtl` に `5m` / `1h` を置き prompt cache の寿命を指定。subagent ファイルからのみ
      読まれる。v2.1.248 導入) が 08-29 から ON HOLD で未反映 — **未確定扱いで使う**。09-15 に
      `omitClaudeMd` (boolean、任意、v2.1.271) が HIGH / NEW として追加提案されたがこれも ON HOLD で
      表は 16 フィールドのまま (項目 4 に内容)。subagent 単位の `autoCompactWindow` (integer、100,000〜1,000,000、v2.1.296+。
      主会話より早く compact させる) は 10-12 の LOW watch から 10-15 に「公式 docs で確認」として HIGH へ上がったが ON HOLD で表には未反映。公式とずれる watch item:
      `permissionMode` に公式の `manual` (`default` の alias、v2.1.200+) が無く、`Explore` の model は `haiku`
      (公式は「親から継承」、Claude API では Opus 上限)、`model` 例は `claude-opus-4-6` のまま (公式は `fable` /
      `claude-opus-5`)、`prompt` は公式の `--agents` CLI JSON 側にしか無い。
    - 10-31・11-01 時点で skills・commands・subagents のバッジは揃って v2.1.316 だが subagents 側の ON HOLD 4 件と watch item、skills 側の削除候補 4 件は 1 つも解消していない (11-01 の skills run は「25 vs 公式で [Skill] タグ付きの 20」と数え方を書き足した。10-31 の skills run は「no drift・公式と完全同期」と書きつつ削除候補 4 件を保留。11-03・11-04 にバッジが v2.1.317 → v2.1.318 へ揃って進んでも同じ 8 件が残る。11-04 の skills run は「No new bundled skills or frontmatter fields in v2.1.307–v2.1.318」) — **バッジの更新は表本体が直ったことを意味しない**。
    - **ON HOLD は解消されずに静かに消えることがある**。commands 側の `/cost` (cache miss 表示)・`/reload-plugins`
      (headless 対応)・`/effort` (既定保存と `s` キー) は 09-05 を最後に changelog から落ちたが公式 docs 表には
      入っておらず、以降の run は「fully in sync」と宣言。**「最新 run に出ていない = 解決した」ではない**。
      v2.1.283 で入った `/doctor prompt-audit` サブコマンドも skills 側の changelog (09-26) が触れるだけで commands 表には無い。
      CHANGELOG のみの変更は docs 反映まで ON HOLD (`/mcp reconnect all` は 09-29 → 10-03 適用、`/autocompact` のモデル別保存 (v2.1.288) は 10-03 から ON HOLD が続き (10-19 の run では挙がらず、10-20〜10-25 に再掲)、10-25 の一括同期後も未適用。10-26・10-27 run は「fully in sync」とだけ書きこの ON HOLD は表から消えたが、10-28 run が「recurring from 2026-10-27」として再掲した — 消えた ON HOLD は戻ってくる。10-29 run ではまた消え、10-30 run が「recurring since 2026-10-03」として三たび戻し、10-31〜11-04 run も継続)。
    - `claude-settings.md` は 6 週間止まった末 10-13 に v2.1.252 → v2.1.296 へ追いつき、33 項目を直した。**その大半が型・scope・意味の誤り** (`feedbackDrafts` boolean → `"notify"/"quiet"/"off"`、`strictKnownMarketplaces` boolean → source object 配列、`enableArtifact`・`alwaysThinkingEnabled` の `true` は no-op、`USE_BUILTIN_RIPGREP` の向きが逆、ほか項目 7・9・10) — **止まっていた表の値は追従後にも疑う**。`claude-memory.md` (2026-03)・`claude-mcp.md` (2026-03)・`claude-cli-startup-flags.md` (2026-06) は数か月動いていない。
    → `best-practice/claude-skills.md`, `claude-commands.md`, `claude-subagents.md`, `claude-settings.md`

13. **MCP は少数精鋭**。「15 個入れて日常使いは 4 個」が典型。secrets は `${VAR}` 展開。権限は `mcp__<server>__<tool>` 構文。スコープは Subagent (`mcpServers:`) > Project (`.mcp.json`) > User。 → `best-practice/claude-mcp.md`

14. **主要ワークフローは Research → Plan → Execute → Review → Ship に収斂**。README の比較表に
    agents/commands/skills の構成数と各ステップ (黄タグ = 親ステップ内で反復するサブループ) がある。★ 数も
    ステップ列も日次更新されるので都度引く。 → README「DEVELOPMENT WORKFLOWS」、`development-workflows/rpi/`

15. **fork 実行と background セッションの境界**。skill/command は `context: fork` で隔離コンテキストに逃がし、
    `agent:` で subagent type を指定 (既定 `general-purpose`)、`background` (boolean、既定 `true`、v2.1.218+) を
    `false` にすると呼び出したターン内で結果を待つ。この 3 つは skill と command のみで subagent 側には無い。
    ユーザー側の入口は `/subtask` (親の会話を継承する forked subagent を background で回す。**v2.1.212+ が必要で
    agent view を切っていると使えない**)。**`/resume` で走っている background セッションを選ぶと、v2.1.285 以降はこの端末がそれに attach し、今の会話が background に回る** (picker からでも ID・名前指定でも同じ。11-04 に明記。空プロンプトで `←` を押すと agent view へ戻る。旧版は再開不可で `claude agents` で attach するか先に停止が必要だった)。他の制約: `/insights` はローカルセッションのみ HTML 化、`/tasks` (alias `/bashes`) が見せるのは**現セッションの** background work、`/stop` は attach 中の background セッションか peek reply の送り先を停止 (transcript と worktree は残る。止めずに離れるなら `/exit` か `←`)。`/add-dir` は v2.1.234 からターン中に即確認を求め、成功時に `DirectoryAdded` hook が走る — 追加ディレクトリの `.claude/` 設定はほぼ読まれないので必要な副作用はこの hook で組む。
    → `best-practice/claude-skills.md`, `claude-commands.md` の Frontmatter Fields 表と各コマンド行

## 索引

| トピック | 原典パス | 内容 (一行) |
|---|---|---|
| 全体目次・機能→docs 対応表 | `README.md` | CONCEPTS 表 (機能ごとの docs/実装リンク)、Hot features、tips 集、ワークフロー比較、購読先 |
| agents/commands/skills の使い分け | `reports/claude-agent-command-skill.md` | 3 機構の比較表・使い分け基準・最軽量優先の解決順・frontmatter 比較 |
| skill frontmatter + 公式 skill | `best-practice/claude-skills.md` | skill の 20 フィールド (`background` と Agent Skills spec の `metadata`/`license`/`compatibility` 含む。`allowed-tools` は 10-22 に `string/list` へ訂正) とバンドルスキル 25 個 (`doctor` は `disableBundledSkills` の唯一の例外。row 11 `design` は v2.1.234 追加。row 17 `workflow-authoring` は v2.1.248 追加・dynamic workflows 有効時のみ。row 19 `update-config` は 09-23 追加。row 20–24 (`slides`・`artifact-capabilities`・`artifact-diagramming`・`claude-in-chrome`・`artifact-design`) は 09-29〜10-04、row 25 `plugin-authoring` は 10-12 追加 (row 24・25 は公式 docs の一覧に無く CHANGELOG 根拠。row 25 は 10-18 に v2.1.287+ と訂正)。row 12 `design-sync` に「standalone Claude Design は 2026-12-14 終了」を 10-18 追記 (v2.1.302 CHANGELOG)。row 15 `review`・row 16 `security-review`・row 18 `skill-doctor` は削除候補 ON HOLD で INVALID との間を往復中、row 25 も 10-17 から削除候補 ON HOLD。`review` と `security-review` は command 表にも重複) |
| subagent frontmatter + 公式 agent | `best-practice/claude-subagents.md` | subagent の 16 フィールドと built-in agent type 5 個 (`experimental` と `omitClaudeMd` (v2.1.271) の 2 フィールド・`claude` agent は ON HOLD で表に未反映、`fork` は 08-31 以降 drift 表から消えたまま。`Explore` の model 欄・`model` 例の model 名 (公式は `claude-opus-5` / `fable`)・`permissionMode` の `manual` も未反映の watch item。subagent 単位の `autoCompactWindow` (v2.1.296) は 10-12 から LOW watch) |
| command frontmatter + 公式コマンド | `best-practice/claude-commands.md` | command の 20 フィールド (skill と同じ 3 フィールドが追加。`allowed-tools` は 09-16 に `string/list` へ訂正) と built-in slash command 96 個。#13 `/output-style [style]` (09-20 に引数表記を `[name]` から訂正、v2.1.269+) は **v2.1.74 で「deprecated、`/config` を使え」として削除された行の復活**で、削除済みコマンドも戻りうる実例。09-23 に v2.1.280 準拠で 10 行の説明が更新: `/clear` 前の会話は rewind メニューから復元可 (v2.1.191+)、`/model` と `/rename` は `-p` でも動く (v2.1.205+、`/model` は現セッションのみ)、`/rename` は制御文字除去と 200 文字上限 (v2.1.221+)、`/heapdump` はメニュー非表示で `.heapsnapshot` に会話と credentials が入るため共有は `-diagnostics.json` のみ、`/bug` はサードパーティ provider では `~/.claude/feedback-bundles/` にローカル保存、`/feedback` は引数なしで Claude が起草した feedback の下書きキュー、`/import` (`[codex\|gemini\|cursor]`) は Bedrock/Vertex/Foundry/gateway 等と feature-flag fetching 無効時に使えない。既存の記載: `/advisor` は `-p` と Remote Control で引数なしだと現在値をテキスト出力 (v2.1.260)。`/review` は `/code-review` の alias で引数も同形、レベル省略時は前回のレベルを再利用。`/skill-doctor` は v2.1.252 以降 + feature-flag fetching (skills 表 row 18 の「v2.1.261」と食い違う)。`/status` の "Auto mode server" 行 (v2.1.278) は公式 docs 未掲載で 09-19 から ON HOLD。09-29〜10-04 の更新: `/effort` の ultracode はトグル (`ultracode [on\|off]`)、`/review` に `--max-findings n\|all\|default` (指定は `default` まで持ち越し)、`/mcp reconnect all` と `-p` で引数なしなら状態をテキスト出力、`/rename` は同名の live セッションがあると variant を付け空名を拒否、`/rate-limit-options` はメニューに出るようになった。10-11 更新: `/focus` の `[on\|off]` (Remote Control から現セッションのみ切替、保存値は変えない、v2.1.281+。tool-call 要約に subagent 数と完了 background 通知の集約。10-29 にシグネチャ列は素の `/focus` へ戻り、引数は Remote Control 限定として説明文側だけに残る)、`/copy` の picker は blockquote も選べる (v2.1.295)。10-21 更新 (v2.1.306): `/auto-mode-setup` は Enterprise と Console API key でも使える (v2.1.283+)、10-24 (v2.1.310) に要求版を公式に合わせて分け直し — Pro/Max/Team は v2.1.228+ (native Windows は v2.1.233+)、Enterprise と Console API key は v2.1.283+、10-21 に入れた「Bedrock/Vertex/Foundry/Claude apps gateway/telemetry 無効セッションでも使える」節は公式から消えたとして削除 (コマンドが出ないときは公式のトラブルシュートページを案内)、`/team-onboarding` の共有リンクは Team/Enterprise のみ (Pro/Max は外れた)、`/design-login` の先の standalone Claude Design は 2026-12-14 終了、`/resume` の background attach に v2.1.285+ を明記。10-22 更新 (v2.1.308): `/color` は Remote Control 接続中なら claude.ai/code に同期、`-p` でも使える。10-23 更新 (v2.1.309): 設定可能キーの一覧は `/config --help` (従来の `/config help` 表記は誤り)。`key=value` 形式は v2.1.181+ で `-p` と Remote Control でも動く (確認ダイアログが要る設定は ON にできず OFF だけ可)。10-25 (v2.1.310) に 16 フィールドと 43+ コマンドの説明を公式 docs へ一括同期 (項目 12)。同期後の表: `/agents` は「Claude に頼むか `.claude/agents/` を直接編集せよ」というリマインダーを出すだけ (対話 UI は v2.1.197 以前)、`/tasks` は完了済み subagent も出す、`/status` の `Session kind` 行で background か interactive かが分かる (v2.1.221+)、`/branch` (分岐へ切替)・`/fork` (別 background セッションへ複製)・`/subtask` (結果が今の会話に戻る forked subagent) の使い分け。`/design consent`・`/design revoke` (Claude Design へのアクセス許可と取り消し。Claude の返答が `/design consent` を求めたらユーザー自身がプロンプトに打つ) は 10-22・10-25 に bundled skill の subcommand として INVALID だったが、10-29 に「独立した built-in command」と判定が反転し Auth の先頭行に追加 (94 → 95)。10-28 更新 (v2.1.312、8 件): `/config` の `key=value` から「v2.1.181+」の修飾が公式から消え、例に `/config thinking=false` が加わった、`/plugin` は install 中に plugin を activate することがあり、install summary が activate 済みか `/reload-plugins` が要るかを示す、`/setup-bedrock`・`/setup-vertex` は env var を立てるまでメニュー非表示で全文入力、`/effort` の `-p` 対応は v2.1.205+、`/fast` の `-p` 対応は限定的、`/usage-credits` はブラウザで billing 設定を開き、Team/Enterprise の billing 権限なしメンバーは admin へ通知が飛ぶことをダイアログで確認。10-30 更新 (v2.1.314、12 件 + 新規 1): Session に `/restart` (alias `/update`) を追加 (95 → 96、v2.1.288 から欠落していた) — Claude Code を再起動してセッションを再開し、インストール済みの更新を適用する。**Pro/Max プランかつ macOS/Linux の native install のみで WSL は対象外**、v2.1.288+。`/skills` の可視性切替は「Claude と `/` メニューへの見え方」で、`--settings` フラグ指定の skill も切替不可、`/fork` のコピーが自前 worktree を作るのは「その場編集でない場合」、`/bug` は first-party 接続なら Anthropic へ送り、それ以外は `~/.claude/feedback-bundles/` のローカル archive を自分で転送、`/terminal-setup` から「必要な端末でのみ表示」の限定が消えた、`/artifacts` の v2.1.208/v2.1.216 要件が公式から消えた、`/design-login` は `/design-sync` か `/design consent` に促されたら使う、`/effort` と `/model` から v2.1.242 以前・v2.1.284 の経緯文を削除、`/advisor` の `fable` は "Fable access" が要る (旧 "Fable 5 access")。10-31 更新 (v2.1.316、8 件): 公式 docs に **Ultra プラン**が現れ、`/privacy-settings` (Pro/Max/Ultra)・`/usage` (Pro/Max/Ultra/Team/Enterprise)・`/restart` (Pro/Max/Ultra、WSL 対象外は不変)・`/auto-mode-setup` (Pro/Max/Ultra/Team は v2.1.228+) の要件に追加、`/effort` の `ultracode on`/`off` は v2.1.284+、`/clear` 前の会話を rewind メニューから戻せるのは同じ Claude Code プロセス内で previous-session エントリから、`/install-github-app` は repo 選択と設定を対話で案内、`/team-onboarding` のガイドは teammate が最初のメッセージとして貼る想定。11-01 (v2.1.316) は `/ultrareview` の無料 3 回の対象に Ultra を足しただけ (Pro/Max → Pro/Max/Ultra)。11-04 更新 (v2.1.318、10 件、新規・廃止なし): `/review` は引数なしなら open PR の一覧から選ばせる (`/review 1234` の例、レベル再利用の厳密な規則は公式の "Review locally with `/code-review`" を参照と追記)、`/permissions` から実行中ターンでの挙動と v2.1.234 以前の queue の説明文が消え alias `/allowed-tools` だけが残った、`/install-github-app` に GitLab pipelines は GitLab CI/CD のページを見よと追記、`/effort` の `on`/`off` は v2.1.284+ を独立文に分けた。`/auto-mode-setup`・`/design-login`・`/team-onboarding`・`/clear`・`/fork`・`/resume` は文言の組み替えで意味は不変 |
| settings.json 網羅リファレンス | `best-practice/claude-settings.md` | 階層・permissions 構文・hooks・sandbox・model/effort・env vars・完全例 (「244+ settings / 396+ env vars」、2026-10-13 に v2.1.296 へ追従)。10-13 に入った主なキー: `bashOutputMaxChars` (`BASH_MAX_OUTPUT_LENGTH` に優先、v2.1.261+)・`permissions.blockReadsOutsideWorkingDirectories`・`maxEffortLevel`・`deniedModels`/`availableModelsMatch` (managed)・`managedMcpServers`・`allowedProviders`・`syncClaudeAiSkills`/`syncClaudeAiPlugins`・`prependPlugins`/`appendPlugins`・`subagentStatusLine`・`timeFormat`/`timeZone`/`maxProseWidth`、model alias `best` (Fable があれば Fable、無ければ Opus)。`permissionExplainerEnabled` は v2.1.257 で削除。09-01 の run で入ったキー: `crossSessionInbound`・`dialogExpiry`・`autoContinueAtUsageLimit`・`feedbackDrafts` (`SendFeedback` ツールの gate)・`desktopSessionCleanupPeriodDays`・`modelSettings`・`modelPicker`・`modelPricing` (managed)・`promptCacheTtl`/`subagentPromptCacheTtl`・`keybindingFlavor`・`spellcheck`・`disableCommandPluginSources`・marketplace source type `command` (+`mode: "link"`)・sandbox credentials の JWT/AWS マスキング (`decode: "jwt"`・`maskClaims`・`awsPairs`・`sigv4`)。公式側の**キー索引は `docs/en/settings-reference` に移動**し (`docs/en/settings` は task 指向のガイドに再編)、原典もこちらを Sources に追加した |
| CLAUDE.md の書き方・ロード規則 | `best-practice/claude-memory.md` | ancestor/descendant/sibling のロード挙動、モノレポでの配置指針 (2026-03 で更新停止) |
| MCP 設定と選定 | `best-practice/claude-mcp.md` | 日常用 MCP 5 選、.mcp.json 例、承認 settings、権限構文、3 スコープ (2026-03 で更新停止) |
| CLI フラグ・環境変数 | `best-practice/claude-cli-startup-flags.md` | `claude` の起動フラグ・サブコマンド・env vars の分類表 (2026-06 で更新停止) |
| /powerup | `best-practice/claude-power-ups.md` | インタラクティブな機能学習レッスン 10 個の紹介 |
| global vs project スコープ | `reports/claude-global-vs-project-settings.md` | global-only と dual-scope の切り分け・settings 優先順位・Tasks・Agent Teams |
| モノレポでの skill 発見 | `reports/claude-skills-for-larger-mono-repos.md` | ネスト discovery・description のみ常駐・文字バジェット (数値は settings レポートを正とする)・CLAUDE.md との差分表 |
| agent の永続メモリ | `reports/claude-agent-memory.md` | `memory:` frontmatter、3 スコープ、200 行注入、他メモリ系との比較 |
| ハーネス擁護論 | `reports/why-harness-is-important.md` | 「全部プロンプト」還元論への反証 10 項目と正しいメンタルモデル |
| Agent SDK vs CLI | `reports/claude-agent-sdk-vs-cli-system-prompts.md` | system prompt の差 (CLI は 110+ fragments)、出力の決定性は保証されない |
| 高度なツール使用 (API 寄り) | `reports/claude-advanced-tool-use.md` | Programmatic Tool Calling・Tool Search Tool・tool use examples |
| 使用量・レート制限 | `reports/claude-usage-and-rate-limits.md` | /usage・extra usage・fast mode の課金挙動 |
| 「モデルが劣化した」問題 | `reports/llm-day-to-day-degradation.md` | インフラ起因の実例 (2025-09 postmortem) と心理要因の切り分け |
| ブラウザ自動化 MCP 比較 | `reports/claude-in-chrome-v-chrome-devtools-mcp.md` | Chrome DevTools MCP / Claude in Chrome / Playwright MCP の使い分け |
| Anthropic 内部の skill 運用 | `tips/claude-thariq-tips-17-mar-26.md` | skill 9 類型・description の書き方・Gotchas・railroad しない等の原則 |
| セッション/コンテキスト管理 | `tips/claude-thariq-tips-16-apr-26.md` | 毎ターンが分岐点 (Continue/rewind/clear/compact/subagent)、context rot |
| Boris (Claude Code 作者) の tips | `tips/claude-boris-*.md` | 日付別 tips 集。README「TIPS AND TRICKS」節にカテゴリ別で集約済み |
| command→agent→skill 実装例 | `orchestration-workflow/orchestration-workflow.md` | weather システムの設計・実行フロー・パターン解説 (動く実体は `.claude/`) |
| RPI ワークフロー | `development-workflows/rpi/rpi-workflow.md` | Research→Plan→Implement の commands + 8 agents 構成の実装 |
| クロスモデル併用 | `development-workflows/cross-model-workflow/cross-model-workflow.md` | Claude で Plan、Codex で QA-Review する 2 ターミナル手順 |
| 機能別の動く実装例 | `implementation/*.md` | subagents/skills/commands/agent-teams/goal/scheduled-tasks の手順書 |
| Agent Teams 実例 | `agent-teams/` | team 構成の prompt・agents・skills・出力一式 |
| 入門チュートリアル / 動画要約 | `tutorial/day0/`, `tutorial/day1/`, `videos/*.md` | 段階的入門と、Boris/Thariq/Cat/Dex/Karpathy らの講演・対談の書き起こしノート |
| このリポジトリ自身のハーネス | `.claude/` | agents/commands/skills/hooks/settings.json の実働サンプル (音声 hooks 含む) |
| 各レポートの drift 履歴 | `changelog/**/changelog.md` | 日次 drift check の指摘・ON HOLD・誤修正の revert 記録。表の値を疑うときここを見る |

## 蒸留の範囲外

- **settings.json の全キーと permissions 構文の詳細** — 1400 行超の網羅表は写していない。確定させるときは
  `best-practice/claude-settings.md` を直接引く。キー名の誤りは silent no-op (`maxSkillDescriptionChars` の例)。原典が
  `*(not in official ... — unverified)*` と注記した値 (`thinkingBudgetTokens`・`Skill(...)`・`MCP(server:tool)`) は前提にしない。
- **公式 slash command・CLI フラグ・env vars の全リスト** — `best-practice/claude-commands.md` と `claude-cli-startup-flags.md` を引く。
- **tips 全文** — カテゴリ別一覧は `README.md` の TIPS AND TRICKS 節。各 tip に一次ソースリンク付き。
- **★ 数とバッジ日付** — 日次 refresh で書き換わる。蒸留版は数値を持たない。バッジは「その表がまだ追われているか」の
  指標としてのみ使う (項目 12)。2026-11-04 時点で skills / commands / subagents が v2.1.318、settings は v2.1.296 (10-13)。
- **コミュニティワークフローの詳細比較・skill/agent コレクション集** — `README.md` の
  DEVELOPMENT WORKFLOWS / SKILL COLLECTIONS / AGENT COLLECTIONS 表。★ 数だけでなく**ステップ列も行の並び順も
  個数も日次で書き換わる** (gstack skills は 53/48/65/32/58/54/55 と揺れ、BMAD agents は 0 と 5 を往復、10-17 run は 11 workflow 中 9 個、10-18 run は 8 個のステップ列が前回と食い違い chain reset で ON HOLD、10-23 run も 7 個、10-24 run も 7 個が chain reset。10-23 に現行と一致した Superpowers・Matt Pocock も 10-24 は別のステップ数の版が出た) ため蒸留版は
  数値もステップ列も持たない。採用の閾値は **2 run 連続で同じ値** (件数は加えて confidence 0.90 以上) だが、**確定した値も翌週には変わる** — 表の数値はスナップショットであって定説ではないので他所へ引用しない (閾値の実例: CE は 10-22・10-23 の 2 run 連続で先頭の `/ce-setup` が無い版が出て 10-23 に 7 → 6 step へ確定したが、10-25 run は `ce-setup` 付きの 7 step を再び拾った。Superpowers は 10-24・10-25 の 2 run 連続で 9 step 版が出て 10-25 に 7 → 9 step へ更新したが、翌 10-26 run は 7 step 版を拾い、追加した implementer / task-reviewer は skills ディレクトリに無く「phantom steps だった可能性」と書き、10-27 run が 2 run 連続 (confidence 0.93) と phantom 確認を根拠に 7 step へ戻した — 確定値が 2 日で往復した)。ECC の skills 数は 10-26 に 293 → 1,004 へ跳ねたが 10-31 に README の記載 (confidence 0.90) を根拠に 314 へ戻り、commands 数は 10-30 に 97 → 112 (「少なくとも」の下限見積り) へ。BMAD は 2 run 連続でも confidence 0.82 で据え置き。CE は 10-29 に 12 step 版が出たが 10-30 に外れ値として 6 step を確認。10-31 は閾値の例外も出た — HumanLayer は commands/agents ディレクトリの消滅を根拠に 1 run で 9 step の command 型から 6 step の skill 型へ置き換え、Superpowers は skill の実在だけを根拠に 1 run で `receiving-code-review` を足した。ECC は repo 名が `everything-claude-code` へ変わり URL を直した)。
- **Claude API 寄りの詳細** (Programmatic Tool Calling、SDK 設定、rate limits の数値) —
  `reports/claude-advanced-tool-use.md`, `claude-agent-sdk-vs-cli-system-prompts.md`, `claude-usage-and-rate-limits.md`。
- **hooks の実装詳細** — 別リポジトリ (shanraisshan/claude-code-hooks) が正。10-13 に 28 → **33 イベント**へ更新 (`PostToolBatch`・`UserPromptExpansion`・`StopFailure`・`PostCompact`・`PermissionDenied`・`TaskCreated`・`CwdChanged`・`FileChanged`・`WorktreeCreate`/`Remove`・`Elicitation`/`ElicitationResult`・`InstructionsLoaded`・`MessageDisplay` ほか)。
  ただし `CLAUDE.md` の列挙は 30 個しか名前が無く件数と合わない。settings の hooks 節は `onFailure: "block"` (v2.1.295+) にも触れる。実働サンプルは `.claude/hooks/`。
- **プレゼン資料・チュートリアル本文と CLI バイナリ抽出物** — `presentation/`, `tutorial/`, `reports/claude-spinner-verbs-and-tips.md`。
- 注意: 特定バージョン (v2.1.x) や beta 機能に固定された記述が多い。beta バッジは GA 化で外れる (Auto Mode 2026-07-28、
  Voice Dictation と Artifacts 2026-08-29。Code Review は 10-23 に公式ページの banner 消失で NEW ON HOLD、翌 10-24 に GA と判断して README の beta バッジを外した) ため、バージョン依存・beta 前提の断定は避け `changelog/` の drift ログで確認する。
  **ON HOLD も INVALID も「保留」であって「否定」ではない** — 後日反転しうる (`skill-doctor` は 09-05 INVALID → 09-07 追加
  → 09-15 削除候補 → 09-17 INVALID → 09-18 再 ON HOLD、`/output-style` は v2.1.74 で削除された行が v2.1.269 で復活、`/design consent` は 10-22・10-25 の INVALID が 10-29 に追加へ反転)。
  ただし反転していない INVALID を取り込み候補に昇格させない。逆に **1 run の提案も早まって取り込まない** — 09-10 の
  「`/review --comment` は GitLab MR にも投稿する」、09-19 の「`/plugin install --marketplace`」はどちらも後の run で INVALID。
- 注意: 原典が張る公式 docs の URL・anchor・機能名も動く。Rules の anchor は 09-18 に `#organize-rules-with-clauderules` →
  `#organize-rules-with-claude/rules/` へ変わった (が 10-27・10-30・10-31・11-01 run は旧 `#organize-rules-with-clauderules` を有効と記録し、11-04 run はまた新 anchor を有効と記録しており run ごとに食い違う)、Plugins 行の 3 URL は 10-14 に `/plugins/` 配下 (`overview`・`anthropic-marketplaces`・`create-marketplace`) へ移った、TIPS 表の commands
  3 リンクは `docs/en/skills` のまま、Code Review 行の Local `/code-review` は 10-22 に `/en/commands` → `/en/code-review-local` へ。README の "No Flicker Mode" (公式は "Fullscreen rendering")・"Claude Code Web"
  (v2.1.281 で設定ラベルが "Cloud sessions")・"Routines" (公式は "scheduled tasks (formerly routines)"、10-22 ON HOLD) も未追従。CONCEPTS の Settings 行に公式キー索引 `docs/en/settings-reference` へのリンクが無い点は 10-25 に NEW ON HOLD、Output Styles が Settings の補助リンク止まりで独立行が無い点は 10-26 に NEW ON HOLD。URL は原典のリンクを写さず公式 docs で確認する。原典自身、09-15 の
  run で `claude-code-guide` agent が sitemap に無い URL を複数 fabricate したと記録している。
