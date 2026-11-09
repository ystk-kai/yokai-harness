# UI 系スキルの control run 試験

## 目的

`skills/ui-design` と `skills/visual-slop-review` を読ませたときに、読ませないとき (control) と比べて、生成される画面の見た目が変わるかを確かめる。

AgentCraft の試験 (awesome-harness-engineering 掲載) では、同じ brief で比べると、インストール数上位のデザイン skill 8 個のうち、control から見た目を動かしたのは 2 個だけだった。この 2 スキルを同じ型で 1 回確かめる。

## brief (実行前に固定し、結果を見て変えない)

| ID | 種類 | ファイル |
|---|---|---|
| a-saas-lp | 日本語の SaaS の LP (歯科医院向け予約・問診) | [briefs/a-saas-lp.md](briefs/a-saas-lp.md) |
| b-admin | 社内ツールの管理画面 (経費精算の承認待ち一覧) | [briefs/b-admin.md](briefs/b-admin.md) |
| c-event | イベント告知ページ (地方の Rust 勉強会) | [briefs/c-event.md](briefs/c-event.md) |

3 本とも末尾に共通の出力条件 [briefs/common.md](briefs/common.md) を付ける (単一 HTML、外部画像なし、最終回答は HTML 全文のみ)。

## 条件

違いは skill の有無だけにそろえる。

| | control | skill |
|---|---|---|
| モデル | `claude-opus-5-5` | 同じ |
| brief 文 | brief + common | 同じ文の前に、2 つの SKILL.md のパスと「読んでから作る」指示を足す |
| ツール | Read, Glob, Grep | 同じ |
| 読める場所 | 空の作業ディレクトリだけ | 加えて、スキルの写し (`~/.cache/htmlgen/skills/`) と原典 clone (`~/.local/share/yokai-harness/references/`) を `--add-dir` |

両条件で共通の隔離:

- `claude -p` の別プロセスで、毎回新しい空ディレクトリ (`~/.cache/htmlgen/w.XXXXXX`) を cwd にする。パスに条件名を含めない
- `--disable-slash-commands` で、インストール済みの plugin を含むスキルを全て無効にする (control がスキルを自動で使うのを防ぐ)
- `claudeMdExcludes` で全ての CLAUDE.md を読ませない (ユーザーの CLAUDE.md に ui-design を使えという記述があるため)。auto-memory も切る
- skill 条件は Skill ツールではなく Read で SKILL.md を読ませる。グローバルにインストールされた別版の plugin が混ざらないようにするため。スキルの写しは試験時点の作業ツリーのもの

## 生成回数と費用の上限

- 3 brief × 2 条件 × 2 回 = **12 回** の生成
- 1 回あたり `--max-budget-usd 5`。採点に別プロセスを 1 回使う
- 実費は RESULTS.md に記録する

## 手順

1. `./run.sh <brief> <control|skill> <rep>` を 12 通り回す。HTML は `html/<brief>-<arm>-<rep>.html` に出る。生ログ (stream-json) は作業ディレクトリ外に置き、要約 (費用・ターン数・読んだファイル) だけを `runs.tsv` に残す
2. Playwright (Chromium) で 1280px 幅の全ページのスクリーンショットを撮り、幅 640px の JPEG に縮めて `shots/` に置く
3. HTML から機械的に特徴を抜く (`features.py`: 書体・色・グラデーション・絵文字・角丸・影など) → `features.tsv`
4. 盲検採点: ファイルを乱数の ID に付け替えて (`blind/`)、条件を知らない別プロセスに visual-slop-review の `references/web-ui.md` の観点で採点させる。対応表は採点後に開ける
5. 比較と結論を RESULTS.md に書く
