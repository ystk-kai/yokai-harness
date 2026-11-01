# 導入の詳細

README の「入れ方」の続き。オプション、エージェントごとの展開先、`install.sh` が何をして何をしないかをまとめる。

## plugin と install.sh の使い分け

| 入れ方 | 入るもの | 向いている場面 |
|---|---|---|
| plugin | スキル 5 本 | スキルだけ使いたい |
| `install.sh` | スキル、グローバル指示のブロック、原典 clone (`--with-references`)、保守スキル (Claude Code のみ) | 参照資料を原典まで読ませたい、ハーネス自体を保守する |

両方を使うときは、スキルの二重登録を避けるために `install.sh --skills none` にする。

plugin で入れたスキルは名前空間に入り、`yokai:harness-design` のように呼ばれる。Codex は `install.sh` の symlink 経由でも、リポジトリ直下の `plugin.json` を見て同じ名前で並べる。

## install.sh のオプション

前提は git と bash。

```bash
git clone https://github.com/ystk-kai/yokai-harness.git ~/yokai-harness
~/yokai-harness/install.sh --targets claude,codex --with-references
```

| オプション | 意味 |
|---|---|
| `--targets <list>` | 展開先。`claude` / `codex` / `gemini` をカンマで並べる。`auto` は前回の値に PATH にある CLI を足す (減らさない)。省略すると前回の値。前回の記録が無ければ、指示ファイルに残ったブロックから推定し、それも無ければ `claude` だけ。減らすときは明示して指定する |
| `--skills link` / `none` | `link` (既定) は skills を symlink する。plugin と併用するときは `none` |
| `--with-references` | 原典を clone する (合計 1GB 超。最大は `smarthr-design-system` の約 750MB)。外しても蒸留版だけでスキルは動くが、索引から原典を開く経路が使えない |

選んだ対象とスキルの入れ方は `~/.local/state/yokai-harness/install.conf` に残り、次の実行で引き継ぐ。Claude Code だけを使う環境では、オプションなしで実行すれば Claude 以外には何も書かない。

## 展開先

| 対象 | skills | グローバル指示 | ほかに入るもの |
|---|---|---|---|
| `claude` | `${CLAUDE_CONFIG_DIR:-~/.claude}/skills/` | `~/.claude/CLAUDE.md` | 保守スキル、`settings/global.json` のマージ |
| `codex` | `~/.agents/skills/` | `${CODEX_HOME:-~/.codex}/AGENTS.md` | — |
| `gemini` | `~/.agents/skills/` | `~/.gemini/GEMINI.md` | — |

OpenCode と Cursor は対象に入れなくてよい。どちらも `~/.claude/skills/` と `~/.agents/skills/` を自分で読み、OpenCode は自前の AGENTS.md が無ければ `~/.claude/CLAUDE.md` も読む。そのため `claude` と `codex` (か `gemini`) を両方選ぶと、この 2 つには同じスキルが 2 か所から見える。OpenCode の公式ドキュメントは、スキル名をすべての置き場で一意にするよう求めている。OpenCode は `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1` で `~/.claude/skills/` 側を止められる。Cursor での見え方は確かめていない。

## エージェントに任せる

新しい環境のエージェントに次を貼ると、clone から検証まで進めてくれる。

```text
https://github.com/ystk-kai/yokai-harness を ~/yokai-harness に clone し、
~/yokai-harness/install.sh --targets auto --with-references を実行してください。
完了後に次の 3 点を確かめて報告してください:
1. 選ばれた対象の skills ディレクトリに、~/yokai-harness/skills/ の各スキルへの symlink があること
2. 選ばれた対象の指示ファイルに <!-- BEGIN yokai-harness:reference-routing --> のブロックがあること
3. bash ~/yokai-harness/scripts/check-freshness.sh --offline の出力に MISS と ERR が無いこと
   (clone した直後は原典が蒸留時より進んでいて STALE が出ることがある。それは更新待ちで、導入の失敗ではない)
```

## install.sh がすること

何度実行しても同じ状態に収束する。手で書いた部分と、ほかのツールが置いたものには触らない。

1. **skills を symlink する** — `skills/*/` を対象の skills ディレクトリへ張る。同じ名前で実体や、ほかの場所を指す symlink が置かれていたら、上書きせずにスキップする。刈るのは、このリポジトリ (か改名前の claude-harness) が張ったと分かる symlink のうち、消えたスキル・旧名・対象から外したエージェントの分だけ。リンク名とリンク先の名前が違うもの (自分で付けた別名など) には触らない
2. **指示ファイルにブロックを貼る** — `instructions/<name>.md` を `<!-- BEGIN yokai-harness:<name> -->` 〜 `<!-- END yokai-harness:<name> -->` で囲み、対象の指示ファイルの末尾に貼る。先に yokai-harness のブロックを全部剥がしてから貼り直すので、消えた instructions のブロックも残らない。BEGIN と END の対応が崩れていたら、何も書かずに中断する
3. **settings.json にキーをマージする (claude のみ)** — `settings/global.json` をローカルに置いた環境だけで動く。この repo は payload を同梱しない (有効プラグインや marketplace の一覧は個人環境の情報なので)。`jq` が要る
4. **原典を clone する (`--with-references`)** — 蒸留版の frontmatter の `source` から `~/.local/share/yokai-harness/references/<repo>/` へ `git clone --filter=blob:none` する。原典に入っている `.claude/skills` は sparse-checkout で worktree から外す。原典を置いただけで第三者のスキルがディレクトリスコープで自動登録されるのを防ぐため

書き換える前の指示ファイルと settings.json は、`<元の名前>.pre-yokai-harness.<日時>.bak` に残す。前の世代は上書きしない。

書き込む前に、全部の指示ファイルの marker を検査する。対象の指示ファイルで BEGIN と END の対応が崩れていたら、どのファイルも書き換えずに止まる。コードフェンスの中に書いた marker の行は、手書きの説明として扱って触らない。選んだ対象の記録は、全部を適用し終えてから保存する。

旧版 (claude-harness) からの移行も同じ実行で済む。`~/.claude/references/` の実体を新しい置き場へ移し、旧パスには移行用の symlink を残す。旧名のスキルの symlink と旧形式の `managed:harness-design` ブロックは掃除する。

## 管理しないもの

`~/.claude` や `~/.codex` を丸ごと再現するツールではない。次のものは意図して対象から外している。

- **permissions と sandbox 系の設定** — 環境ごとに違ってよく、repo が上書きすると権限昇格の事故につながる
- **effortLevel・theme・model などの個人設定** — マシンごとに変えたいもの
- **agents・memory・tasks** — 個人の状態や、プロジェクトをまたぐ調整に使うもの
- **この repo が置いていないスキル** — 実体で置いたスキルや、ほかの marketplace から入れたスキルには触らない
