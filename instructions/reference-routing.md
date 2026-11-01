## 設計時の参照資料

記憶や Web 検索だけで判断せず、まず該当スキルの蒸留版 (`references/*.md`) → 原典 clone (`$YOKAI_HARNESS_REFS`、未設定なら `~/.local/share/yokai-harness/references/`) の順で読む。両者が食い違う場合は原典を正とする。plugin として読み込むエージェントでは、名前の頭に `yokai:` が付く (例 `yokai:harness-design`)。

- ハーネス (CLAUDE.md / AGENTS.md / skills / subagents / hooks / slash commands) やプロンプト、エージェントのオーケストレーション構成の設計・作成・レビュー・監査 → `harness-design`
- UI・LP のデザイン言語、DESIGN.md 雛形、デザイントークン → `ui-design`
- 日本語文書の表記規約 (用字・日英混在のスペース・記号) や文書種別ごとの構成を決めるとき、textlint / prh 規則を選ぶとき、AI 臭の個別規則の出所を確かめるとき → `ja-writing` (日常の応答やコミットメッセージでは読まない)
