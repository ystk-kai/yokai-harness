# Third-party notices

yokai-harness 自身のコードと文書は MIT ([LICENSE](LICENSE)) で配布する。ただし次のものは第三者の著作物に由来し、各原著作者の権利と条件に従う。

## 蒸留版 (`skills/*/references/*.md`)

蒸留版は、下表の原典を読んで書いた要約と原典パスの索引である。原典の本文は原則として転載しない (短い引用は出典を明示する)。各ファイルの frontmatter `source` が出所を示す。原典 clone (`install.sh --with-references` で取得するもの) はこのリポジトリに含めず、各リポジトリの条件で利用者が取得する。

| 原典 | ライセンス | 蒸留版の扱い |
|---|---|---|
| [humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents) | コード Apache-2.0、文章と画像 CC BY-SA 4.0 | 文章の翻案に当たる部分があるとみなし、`skills/harness-design/references/12-factor-agents.md` は **CC BY-SA 4.0** で配布する (原著作者: HumanLayer と貢献者) |
| [anthropics/claude-cookbooks](https://github.com/anthropics/claude-cookbooks) | MIT, (c) 2023 Anthropic | 要約と索引 |
| [anthropics/skills](https://github.com/anthropics/skills) | スキルごとに異なる (Apache-2.0 のもの、ソース公開のみのものがある) | 要約と索引のみ。ソース公開のみのスキルの本文は転載しない |
| [dair-ai/Prompt-Engineering-Guide](https://github.com/dair-ai/Prompt-Engineering-Guide) | MIT, (c) 2022 DAIR.AI | 要約と索引 |
| [rasbt/mini-coding-agent](https://github.com/rasbt/mini-coding-agent) | Apache-2.0 | 要約と索引 |
| [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | MIT, (c) 2025-2026 Shayan Rais | 要約と索引 |
| [shanraisshan/claude-code-hooks](https://github.com/shanraisshan/claude-code-hooks) | MIT, (c) 2026 Shayan Rais | 要約と索引 |
| [ai-boost/awesome-harness-engineering](https://github.com/ai-boost/awesome-harness-engineering) | CC0 1.0 | 要約と索引 |
| [google-labs-code/design.md](https://github.com/google-labs-code/design.md) | Apache-2.0 | 要約と索引 |
| [voltagent/awesome-design-md](https://github.com/voltagent/awesome-design-md) | MIT, (c) 2026 VoltAgent | 要約と索引 |
| [Nutlope/hallmark](https://github.com/Nutlope/hallmark) | MIT, (c) 2026 Hallmark contributors | 要約と索引 |
| [design-tokens/community-group](https://github.com/design-tokens/community-group) | W3C Software and Document License | 要約と索引 |
| [kufu/smarthr-design-system](https://github.com/kufu/smarthr-design-system) | 許諾本文なし | 要約と原典パスの索引のみ。規則本文・表は転載しない |
| [bamboo-nova/meiseki](https://github.com/bamboo-nova/meiseki) | MIT, (c) 2026 bamboo-nova | 要約と索引 |
| [coji/natural-japanese](https://github.com/coji/natural-japanese) | MIT, (c) 2026 coji | 要約と索引 |
| [iKora128/stop-ai-slop-jp](https://github.com/iKora128/stop-ai-slop-jp) | MIT, (c) 2026 Daichi Nagashima | 要約と索引。`ja-slop-review` の規則はこの手法を出所にしている (対応は `skills/ja-writing/MAPPING.md`) |
| [nanaism/yomiyasu](https://github.com/nanaism/yomiyasu) | MIT, (c) 2026 nanaism | 要約と索引 |
| [textlint-ja/textlint-rule-preset-ja-spacing](https://github.com/textlint-ja/textlint-rule-preset-ja-spacing) | MIT, (c) 2024 azu | 要約と索引 |
| [textlint-ja/textlint-rule-preset-ja-technical-writing](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing) | MIT, (c) 2016 azu | 要約と索引 |

ライセンスは各原典の `distilled_commit` 時点の LICENSE / README で確認した。原典がライセンスを変えたときは原典の表示が優先する。蒸留版に原典の表現がまとまった量で残っていると気づいたら、要約に書き直すか、この表の扱いを改める。

## フォント

`assets/architecture.svg` と `assets/references.svg` には Noto Sans JP のサブセットを埋め込んでいる。SIL Open Font License 1.1 ([assets/fonts/OFL.txt](assets/fonts/OFL.txt))。

## アイコン

図 (`assets/src/*.svg`) のエージェントと Git のアイコンは [Simple Icons](https://github.com/simple-icons/simple-icons) の SVG データを使っている。データは CC0 1.0。Git のロゴだけは Jason Long の作品で CC BY 3.0。

## 商標

README・図に出てくる製品名とロゴ (Claude Code、Codex、OpenAI、Gemini CLI、OpenCode、Cursor、Git など) は各社の商標である。対応する製品を示すためだけに使っており、各社がこのリポジトリを推奨・提携しているわけではない。
