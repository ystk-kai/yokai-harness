# 開発と保守

スキルを足す・直すときの規則と、構成をいまの形にした理由をまとめる。

## 命名規則

| 対象 | 規則 | 例 |
|---|---|---|
| リポジトリ・marketplace | `yokai-harness` | `yokai@yokai-harness` |
| plugin | `yokai`。スキルの名前空間になる | `yokai:ui-design` |
| 配るスキル | `<領域>-<役割>`。領域は `harness` / `ui` / `ja` / `visual`、役割は参照資料なら `design` / `writing`、レビュー手順なら `slop-review`。名前空間は plugin が付けるので、スキル名には `yokai` を入れない | `ja-writing`, `ja-slop-review` |
| 保守スキル | `yokai-<動作>`。plugin の外で symlink され名前空間を持たないので、`yokai-` で始めて出所を示す | `yokai-refs-update` |
| グローバル指示 | `instructions/<中身>.md`。ファイル名がブロック名になる | `reference-routing` → `yokai-harness:reference-routing` |
| 環境変数・置き場 | `YOKAI_HARNESS_*`、XDG のディレクトリの下の `yokai-harness/` | `YOKAI_HARNESS_REFS`, `~/.local/state/yokai-harness/` |

スキル名は Agent Skills 仕様に従い、英小文字・数字・ハイフンで 64 字まで、ディレクトリ名と一致させる。

## スキルを増やす・外す

増やすとき:

1. `skills/<name>/SKILL.md` を書く。frontmatter は Agent Skills 仕様の 6 フィールド (`name` / `description` / `license` / `compatibility` / `metadata` / `allowed-tools`) に限る。Claude Code だけのフィールドはほかのエージェントでは効かず、claude.ai への upload では弾かれる
2. 外部の状態に頼らず、`references/` で自己完結させる。避けられない外部依存は `compatibility` に書く
3. 常時ルールにしたいものだけ `instructions/<name>.md` を足す
4. `install.sh` を再実行する。plugin の利用者に届けるには、`plugin.json` の `version` も上げる。Codex の利用者は `codex plugin add yokai@yokai-harness` を実行し直すと新しい内容を受け取る

外すとき・改名するときは、ディレクトリを消すか `git mv` してから `install.sh` を再実行する。古い symlink とブロックは `install.sh` が刈る。改名したら、命名規則の表と、スキル名を書いている箇所 (`instructions/`・各 SKILL.md の相互参照) も直す。

## 設計の判断

### 原典 clone をスキルの外に置く

Agent Skills 仕様の `references/` は、そのスキルのために書いた文書を置く場所になっている。ここで扱う原典は外部リポジトリの丸ごとの clone (合計 1GB 超・第三者のライセンス・`git pull` で独立に更新) で、性質が違う。

- 外部 clone は共有コーパスとして `~/.local/share/yokai-harness/references/` に置く。スキルや plugin に第三者のリポジトリを同梱せずに済み、どのエージェントからも同じ場所を読める。特定のエージェントの設定ディレクトリに置かないのは、そのエージェントを使わない環境にまで設定ディレクトリを作らないため
- スキルの外への依存は、SKILL.md の `compatibility` に書く
- 自作の蒸留資料は `skills/<skill>/references/` に置き、SKILL.md から 1 階層でリンクする。ふだんは蒸留版で足り、原典の全文を読みにいく入力トークンを抑えられる
- 原典と 1 対 1 に対応しない自作文書 (`PATTERNS.md` など) は `references/` に入れず、スキルの直下に置く。`references/` を蒸留版だけの場所に保ち、「frontmatter の `source` が repo リストの唯一の正」という規約を崩さないため

### グローバル指示は import でなく書き写す

1 つの AGENTS.md を各エージェントから import する形も取れる。ただし Claude Code は Cowork のセッションでユーザー単位の指示ファイルから作業ディレクトリ外への import を飛ばし、Codex の公式ドキュメントには import の記述が無い。どのエージェントでも確実に効く形として、同じ中身を各指示ファイルへ managed ブロックで書き写している。

### plugin に入れるものと入れないもの

plugin はインストール時にキャッシュへコピーされ、更新のたびに置き場所が変わる。plugin 直下の CLAUDE.md も読まれない。そのため plugin で読み込ませるのはスキルだけにし、作業コピーを書き換える保守スキルと、原典 clone・グローバル指示は `install.sh` の担当にしている。plugin の source はリポジトリ直下 (`./`) なので、`maintenance/` や `install.sh` もキャッシュにコピーされる。読み込まれるのは `skills/` だけ。同じ理由で、Codex の marketplace を `--sparse` で追加すると plugin 本体が欠ける。

Claude Code 用の `.claude-plugin/plugin.json` には `version` を書いていない。書くと利用者がその版に留まり、蒸留版の更新が届かなくなるため。Codex 用の `plugin.json` には `version` を書いている。codex-cli 0.165 は version ごとにキャッシュを分け、書かないと `1.0.0` 扱いになった。ただし同じ version のままでも、`codex plugin add` を実行し直せば中身は上書きされる。公式ドキュメントにはローカルの plugin の version は `local` とあり、手元の挙動と食い違っている。

## 図とロゴを作り直す

図は `assets/src/` の SVG が原稿で、`assets/build.py` が図に出てくる字だけを Noto Sans JP から切り出して埋め込む。GitHub の閲覧環境に日本語フォントがあるとは限らないため。フォントのライセンス (SIL OFL 1.1) は [assets/fonts/OFL.txt](../assets/fonts/OFL.txt)。画像 (`@EMBED:<パス>@` と書いた箇所) も data URI にして埋め込む。`<img>` で表示した SVG は外の画像を読まないため。図を直したら次で作り直す。

```bash
curl -L -o NotoSansJP.ttf 'https://github.com/google/fonts/raw/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf'
python3 assets/build.py NotoSansJP.ttf
```

図のエージェントのアイコンは [Simple Icons](https://simpleicons.org/) (CC0) から取り、`assets/src/*.svg` の `<symbol>` に書き写した。Git のアイコンだけは CC BY 3.0 (Jason Long)。どれも製品を見分けるためだけに使っており、商標は各社に帰属する。

| ファイル | 役割 |
|---|---|
| `assets/src/wordmark.png` / `assets/src/emblem.png` | ロゴとエンブレムの原画 |
| `assets/wordmark.png` | README の見出しのロゴ (原画を余白を詰めて 1600px に縮小) |
| `assets/emblem.png` | 図に埋め込むエンブレム (400px) |
| `.claude-plugin/icon.png` | plugin の一覧に出るアイコン (紺地にエンブレム、1024px) |
