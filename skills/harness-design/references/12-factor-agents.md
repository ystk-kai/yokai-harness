---
source: https://github.com/humanlayer/12-factor-agents
distilled_commit: d20c728368bf9c189d6d7aab704744decb6ec0cc
distilled_at: 2026-07-12
---

# 12-factor-agents 蒸留版

HumanLayer の Dex Horthy による「信頼性の高い LLM アプリケーションを作る 12 原則」(12 Factor Apps のオマージュ)。
原典は `12-factor-agents` の clone (原典ルートは SKILL.md 参照)。以下のパスはリポジトリルートからの相対パス。

このファイルは原典の文章 (CC BY-SA 4.0) を要約したもので、CC BY-SA 4.0 で配布する。原著作者は HumanLayer と貢献者。ほかのファイルの扱いは yokai-harness の `THIRD_PARTY_NOTICES.md` を見る。

## Contents

- まず押さえる
- 12 factors 一覧
- 索引 (場面からの逆引き / その他の文書)
- 蒸留の範囲外

## まず押さえる

1. **エージェントの正体は 4 部品**: prompt / switch statement / accumulated context / for loop。魔法ではなくほぼ普通のソフトウェアであり、良いエージェントは「mostly deterministic code に LLM ステップを要所だけ挟んだもの」。(`content/brief-history-of-software.md`, `README.md`)
2. **「ツールの袋を渡してゴールまでループ」は破綻する**: 10-20 ターンを超えるとコンテキストが長くなりすぎて LLM は迷子になり、同じ失敗を繰り返す。"Even as models support longer and longer context windows, you'll ALWAYS get better results with a small, focused prompt and context"。(`content/brief-history-of-software.md`)
3. **フレームワーク丸投げは 70-80% 品質で頭打ち**になり、そこから先はフレームワークのリバースエンジニアリングになる。小さくモジュール的な概念を既存プロダクトに取り込むのが顧客品質への最速経路。(`README.md`)
4. **繰り返されるモチーフ**: "I don't know what's the best approach, but I know you want the flexibility to be able to try EVERYTHING"。プロンプトもコンテキスト形式も first-class code として自分で所有し、実験できる状態を保つ。(`content/factor-02-own-your-prompts.md`, `content/factor-03-own-your-context-window.md`)
5. **LLM は stateless function**。エージェントへの入力は常に「ここまでに起きたこと全部 + 次のステップは?」。標準の message 配列に縛られず、トークン/アテンション効率の良い独自フォーマット (XML 風イベント列など) を使ってよい。(`content/factor-03-own-your-context-window.md`)
6. **tool call = 構造化 JSON 出力 + それを解釈する決定的コード**。LLM が「何をするか」を決め、コードが「どうやるか」を制御する。モデルがツールを「呼んだ」からといって毎回同じ対応関数を同じ方法で実行する必要はない。(`content/factor-04-tools-are-structured-outputs.md`)
7. **execution state (current step, retry count 等) と business state (イベント履歴) は可能な限り統合**し、thread (イベント列) から全実行状態を復元できるようにする。シリアライズ・再開・フォーク・デバッグ・可観測性が自明になる。(`content/factor-05-unify-execution-state.md`)
8. **ツールの「選択」と「実行」の間で中断・承認・再開できることが最重要の制御点**。これがないと high-stakes 操作は「メモリ内で sleep して待つ / 低リスク操作に制限する / yolo で実行する」の三択に追い込まれる。(`content/factor-08-own-your-control-flow.md`, `content/factor-06-launch-pause-resume.md`)
9. **人間への連絡 (質問・承認依頼・完了報告) も通常の tool call としてモデル化する** (`request_human_input`, `done_for_now` など)。これで Agent→Human 起点の outer loop workflow (cron やイベントで起動し、要所で人間を呼ぶ) が可能になる。(`content/factor-07-contact-humans-with-tools.md`)
10. **エラーは整形・圧縮してコンテキストに入れて self-healing させる**。ただし連続エラー閾値 (~3 回) で人間へのエスカレーションや決定的介入 (コンテキストの再構成・イベント削除) に切り替える。スピンアウトの一番の予防策は小さいエージェント。(`content/factor-09-compact-errors.md`)
11. **エージェントは 3-10、最大 20 ステップ程度の小さく焦点の合ったスコープに保つ**。モデルが賢くなってもこの原則は有効で、モデル能力の限界ぎりぎりを狙いつつ品質を保てる範囲でスコープを徐々に広げる。(`content/factor-10-small-focused-agents.md`)
12. **呼ぶと分かっているツールはモデルに呼ばせず決定的に pre-fetch** して結果をコンテキストに入れる。"just call them DETERMINISTICALLY and let the model do the hard part of figuring out how to use their outputs"。(`content/appendix-13-pre-fetch.md`)

## 12 factors 一覧

| # | Factor | 本質 (一行) | 参照する場面 | 原典パス |
|---|--------|------------|--------------|----------|
| 1 | Natural Language to Tool Calls | 自然言語→構造化 tool call への変換がエージェントの原子的パターン | LLM をシステムのどこに入れるか、最小構成を設計するとき | `content/factor-01-natural-language-to-tool-calls.md` |
| 2 | Own your prompts | プロンプトをフレームワークに任せず first-class code として書き、テスト・評価する | フレームワークのデフォルトプロンプトで品質が頭打ちのとき、プロンプトの管理方法を決めるとき | `content/factor-02-own-your-prompts.md` |
| 3 | Own your context window | コンテキスト構築を自分で所有する。標準 message 形式に縛られず密度と効率を最適化 | コンテキスト形式・トークン効率・LLM に何を見せる/隠すかの判断 (context engineering 全般) | `content/factor-03-own-your-context-window.md` |
| 4 | Tools are just structured outputs | ツール = LLM の JSON 出力 + それを処理する決定的コード、それ以上ではない | tool 定義の設計、tool call と実行コードの分離を考えるとき | `content/factor-04-tools-are-structured-outputs.md` |
| 5 | Unify execution state and business state | 実行状態と業務状態を分けず、単一のイベント列 (thread) に統合する | 状態管理・永続化・resume/fork・デバッグ容易性の設計 | `content/factor-05-unify-execution-state.md` |
| 6 | Launch/Pause/Resume with simple APIs | 起動・一時停止・再開を単純な API で誰でも (人・アプリ・他エージェントも) 行えるようにする | 長時間タスク、webhook による再開、オーケストレーション API の設計 | `content/factor-06-launch-pause-resume.md` |
| 7 | Contact humans with tool calls | 人間への質問・承認依頼も tool call として構造化する | human-in-the-loop、承認フロー、outer loop (Agent→Human 起点) の設計 | `content/factor-07-contact-humans-with-tools.md` |
| 8 | Own your control flow | ループの中断/継続/再開を自分のコードで制御する (特にツール選択と実行の間) | 承認ゲート、結果の要約/キャッシュ、compaction、rate limit、durable sleep を挟む場所の設計 | `content/factor-08-own-your-control-flow.md` |
| 9 | Compact Errors into Context Window | エラーを整形してコンテキストに入れ self-healing させ、閾値でエスカレーション | エラー処理、リトライ上限、エージェントがスピンアウトするときの対策 | `content/factor-09-compact-errors.md` |
| 10 | Small, Focused Agents | 巨大な万能エージェントではなく 3-20 ステップの小さいエージェントを組み合わせる | エージェントのスコープ分割、subagent 設計、品質が安定しないときの見直し | `content/factor-10-small-focused-agents.md` |
| 11 | Trigger from anywhere, meet users where they are | Slack/email/cron 等どこからでも起動でき、同じチャネルで応答する | 起動チャネル・通知経路の設計、高リスク操作に人間を素早く巻き込む仕組み | `content/factor-11-trigger-from-anywhere.md` |
| 12 | Make your agent a stateless reducer | エージェント = イベント列を fold する stateless reducer (原典は図のみのほぼ空ページ、"mostly just for fun") | 全体アーキテクチャの心的モデルを整理するとき | `content/factor-12-stateless-reducer.md` |
| 13 (補遺) | Pre-fetch all the context you might need | 呼ぶと分かっているツールは決定的に事前実行し、結果をコンテキストに入れる | ツール往復の削減、初期コンテキストの設計 | `content/appendix-13-pre-fetch.md` |

## 索引

### アーキテクチャ判断からの逆引き

| 設計判断の場面 | 見る factor |
|----------------|-------------|
| 状態管理・永続化・resume/fork | 5, 6, 12 (形式は 3) |
| 制御フロー (ループをいつ切るか、何を挟むか) | 8, 4, 9 |
| human-in-the-loop・承認ゲート | 7, 8, 6, 11 |
| コンテキスト設計・トークン効率・何を見せるか | 3, 9, 13 |
| プロンプトの品質改善・管理 | 2, 3 |
| エラー処理・self-healing・スピンアウト対策 | 9, 8, 10 |
| エージェント分割・subagent のスコープ | 10, 7 (Agent→Agent 拡張), brief-history の micro agent 実例 |
| 起動トリガー・チャネル・outer loop | 11, 6, 7 |
| ツール定義・structured output の設計 | 4, 1, 13 |

### その他の索引価値のある文書

| 文書 | 内容 | 原典パス |
|------|------|----------|
| README | 全体像と動機。「フレームワークで 70-80% → 頭打ち → 作り直し」の典型ジャーニー、12 factors の一覧、関連リンク集 | `README.md` |
| A Brief History of Software | DAG オーケストレータ→エージェントの歴史。「agent = prompt + switch + context + loop」の分解、loop-until-done が破綻する理由、micro agent (deploybot) の実例つき | `content/brief-history-of-software.md` |

## 蒸留の範囲外

- **各 factor のコード例の詳細** (BAML / Python / TypeScript の実装、XML 風コンテキストの具体例): 各 `content/factor-*.md` のコードブロックを直接読む。特に factor 3 (独自コンテキスト形式)、factor 7/8 (webhook 再開とループ制御) に実装イメージが多い。
- **ハンズオン教材**: `workshops/` (2025-05, 2025-05-17, 2025-07-16)。実装を追体験したいときに。
- **デモ/ツールのコード**: `packages/`。ドラフト仕様 (human contact API): `drafts/a2h-spec.md`。
- **図・アニメーション**: 概念図 (`img/`) は本文の補助であり、この蒸留では文章化した内容のみ反映。
- **一桁番号の factor ファイル** (`content/factor-1-*.md` 〜 `factor-9-*.md`) は二桁版へのリダイレクト 1 行のみ。参照には `factor-01` 形式のパスを使う。
- **原典が意図的に扱わないもの**: モデルパラメータ調整・fine-tuning (factor 3 冒頭で明示的に対象外)、MCP (README の DISCLAIMER 2 で言及のみ)。
