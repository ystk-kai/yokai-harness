# ja-slop-review の評価ハーネス

ja-slop-review (`skills/ja-slop-review/SKILL.md` と `references/`) を実際に回して、次の 2 つを測る。

- (a) AI 臭の強い文書に仕込んだ欠陥を、見つけて直せるか
- (b) 人が書いた文の言い回し・言い切りの強さ・対比の節を変えないか

本命は (b)。このスキルは修正時に人の文を変えないことを最重要にしている (SKILL.md 手順 0 と手順 7)。そのため、欠陥のない文書を同じ依頼で推敲させ、何を書き換えたかと、それがどの規則から来たかを記録する。

費用と認証が要るので CI には入れない。スキルの規則を変えたときに手で回す。plugin の外 (`maintenance/`) に置いているので、配布物には入らない。

手本は natural-japanese の critical-thinking の評価ハーネス (`$YOKAI_HARNESS_REFS/natural-japanese/dev/ct-eval/`)。expected を先に書く、判定を別のモデルにする、3 回中 2 回で合否を決める、欠陥のない素材で基準線を取る、の 4 点を借りている。

## 回し方

```sh
python3 maintenance/evals/ja-slop-review/eval.py --dry-run                                  # 何を回すかと回数
python3 maintenance/evals/ja-slop-review/eval.py --repeat 3 --jobs 5 --run-label r1        # 10 本 × 3 回
python3 maintenance/evals/ja-slop-review/eval.py --fixtures blog-clean --repeat 1 --run-label probe   # 1 本だけ
python3 maintenance/evals/ja-slop-review/eval.py --rejudge r1 --run-label r1-rj             # 生成を回さず判定だけかけ直す
```

標準ライブラリだけで動く。`claude` CLI のログインが要る。

- 生成: Opus 5.5 (`--model`、effort は `--effort`、既定 high)。依頼文は「yokai:ja-slop-review スキルを使って source.md を見直し、直すべきところを直してください。直した全文を after.md に保存…」で、規則の中身も、人の文か AI の文かも伝えない
- 判定: Sonnet 5.5 (`--judge-model`)。生成と同じモデルを指定すると止まる
- スキルは作業ツリーを一時ディレクトリにコピーして `--plugin-dir` で渡すので、未コミットの変更がそのまま測られる。`--setting-sources project` で、ユーザー設定と `~/.claude/skills/` の同名スキル (main の作業ツリーへの symlink) は読ませない
- 生成物は `runs/<run-label>/` に残る (gitignore)。`summary.md` に集計、`changes.md` に変更の一覧、各回のディレクトリに `source.md`・`after.md`・`reply.md` (生成側の最後の返答)・`changes.json`・`judge.json`・`log-*.txt`

## 素材

`fixtures/` にある。すべて自作で、著作物の転載はない。各素材に `<名前>.expected.json` があり、最初の実行より前に書いてコミットした (5a2106c)。結果を見て欠陥も残す箇所も足さない。素材を足すときも expected.json を先に書く。

expected.json の中身:

- `defects`: 仕込んだ欠陥。`quote` は素材の該当部分そのまま、`rule` はスキルのどの規則に当たるか、`accept` は合格にする判定 (`fixed`、材料に直す手がかりがないものは `asked` も可)、`optional` は合否に数えないもの
- `keep`: 修正後もそのまま残るべき箇所。`quote` は素材の該当部分そのまま (1 か所にしか出ない文字列) で、`rule` は残す根拠になる規則

| 素材 | 種類 | 欠陥 | 残す | 主な中身 |
|---|---|---|---|---|
| gijiroku-planted | 議事録 | 6 | 4 | 見出しの絵文字、進行宣言、false agency、全角ダッシュ、根拠なし強評価、表示されない太字 |
| gijutsu-planted | 技術文書 | 7 | 5 | 「入口」、敬体と常体の混在、名詞化、二重否定、詰め込んだ括弧、コードの擬人化、全角ダッシュ |
| mail-planted | 業務メール | 5 | 4 | 「近年〜」、箇条の絵文字、仮置きの〇〇、「画期的」、「と言えるでしょう」 |
| essay-planted | 随筆 (AI 臭) | 6 | 4 | フック→反転、体験の壮大化、「解像度」「境地」、劇的な断片化、全方位肯定、「いかがでしたでしょうか」 |
| release-planted | 社内告知 | 5 (任意 1) | 4 | 命題型見出しの積み重ね、前置きのない「〜のは、A、B、C。」、偽の対句、ジャーゴン、冗長語尾 (任意) |
| tegami-clean | 手紙 | 0 | 7 | 手紙の読点、余談の括弧、「正直なところ」「実は」(咳払いの前置きとの境界)、留保 |
| zuihitsu-clean | 随筆 | 0 | 7 | 打ち消しが要点の文、書き手が選んだ短い文、文体としてのダッシュ、伝聞、結びの問い |
| houdou-clean | 報道調 | 0 | 8 | 「〜に潜むリスク」「〜を実施。」(人の報道文は残す 7 形)、伝聞、概数、相関 |
| blog-clean | 設計ブログ | 0 | 11 | 「知りすぎている」、原則の後に詳細が続く「分離する」、意味を絞る打ち消し、「ここで効いてくるのが」、定着した言い方、許可 |
| yasashii-clean | やさしい日本語 | 0 | 6 | やさしい日本語の読点と分かち書き、短い文の連続、義務の言い方、呼びかけ |

仕込んだ文書にも残す箇所を入れてある (意味を絞る打ち消し、許可、「場合がある」、概数など)。AI 臭を直すついでに人の書き方まで均すかを見るため。

## 測るもの

1. 機械的な検査 (LLM なし。1 つでも落ちたら FAIL)
   - 元の文書が変わっていない、`after.md` がある、スキルを使った (`Skill` の呼び出しか `ja-slop-review/SKILL.md` の Read がログにある)
   - `after.md` に【要確認】・TODO の印や改訂の経緯 (改訂・指摘を反映・第 N 版) を足していない (SKILL.md 手順 0)
   - 記録: keep の `quote` がそのまま残ったか、defects の `quote` が残ったか、変わった文の数、読点の増減、字数の増減、文書全体の一致率
2. 判定 (`prompts/judge.txt`、Sonnet 5.5)
   - 欠陥ごとに fixed / asked (元のまま残して返答で書き手に問うた) / remains / harmed (直したが意味・真偽・確信度が変わった)
   - 残す箇所ごとに kept / reworded (言い回しだけ変わった) / changed (主張・重み・言い切りの強さ・文の働きが変わった) / removed
   - `changes.json` (元と後を文の単位で突き合わせた差分) の各変更に、種類、直した欠陥、出所の規則 (「ファイル 節」)、規則の当てはまり (fits = 規則どおり / misread = 除外条件に当たるのに直した / gap = 規則の文面では決まらない / none = どの規則にも当たらない)、意味が変わったか
3. 集計と合否 (`runs/<label>/summary.md`)
   - 安定検出率: 任意でない欠陥のうち、3 回中 2 回以上で `accept` の判定になった割合が 80% 以上
   - 残す箇所: すべての keep で、3 回中 2 回以上 `quote` がそのまま残る (機械の照合で決める。判定の kept / reworded は読む材料)
   - harmed が 0、欠陥のない文書で意味が変わった変更が 0
   - 機械的な検査が全回で通る
   - 欠陥のない文書の変更数と一致率は合否に入れず、基準線として記録する。変更は `changes.md` に全件、規則ごとの件数は `summary.md` に出る

## 費用

1 回 = 生成 1 回 + 判定 1 回。既定の 10 本 × 3 回で、生成 30 回 (Opus 5.5、effort high) と判定 30 回 (Sonnet 5.5、effort medium)、計 60 回の `claude -p`。

見積もりの根拠は、本番の前に gijutsu-planted で 1 回だけ回した校正 (run-label calib): 生成 $0.40 (56 秒)、判定 $0.10。生成はスキルの SKILL.md と references を毎回読むので、素材の長さより読む量で決まる。

- 概算: 30 × ($0.40 + $0.10) ≈ $15。生成の手数が増える素材を見込んで $15〜25
- 時間: `--jobs 5` で 10〜20 分
- 金額は `claude` が報告する `total_cost_usd` で、サブスクリプションの認証で回すときは利用枠を使う。実績は各回の `summary.md` に出る
- 実績: r1 は計 $10.41 (生成 $8.30、判定 $2.11)。欠陥のない文書の生成は仕込んだ文書より軽い。詳細は RESULTS.md

## 限界

- 判定も LLM なので揺れる。1 回の結果を信じず、3 回中の回数を見る。残す箇所は文字列の照合を主にし、判定に頼らない
- 文の単位の差分は、読点 1 つの変更も 1 件と数える。変更の重さは判定の `kind` と `meaning_changed` で見る
- 素材は 10 本で、どれも 400〜800 字。長い文書や、議事録・メール以外の業務文書で同じ成績になるとは限らない
- 生成への依頼は 1 通りだけ。「AI っぽさを消して」のような強い依頼では、書き換えはもっと増えるはず
