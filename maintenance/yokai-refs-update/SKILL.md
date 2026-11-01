---
name: yokai-refs-update
description: yokai-harness の参照資料 (蒸留版 skills/*/references/*.md と原典 clone ~/.local/share/yokai-harness/references/ の 2 層) の鮮度チェックと更新を実行する。check-freshness → BEHIND を git pull → STALE を DISTILLING.md の手順で再蒸留 → REVIEW (出所 clone を持たない知識ベース) を棚卸し → 実ハーネスへの取り込み候補を照合して ADOPTION.md に記録。明示起動専用 (/yokai-refs-update で呼ぶ)。
disable-model-invocation: true
argument-hint: "[repo-name ...] | --check"
compatibility: Requires git and network access. Owns DISTILLING.md and ADOPTION.md, drives the repo-level scripts/check-freshness.sh, and operates on every skill's references/*.md in this repo (harness-design, ui-design, ja-writing, ...) plus the reference clones (default ~/.local/share/yokai-harness/references/). Claude Code only: installed by install.sh as a symlink, not shipped in the plugin.
---

# yokai-refs-update: 参照資料の鮮度チェックと更新

yokai-harness の参照資料は 2 層 — 蒸留版 (`skills/*/references/*.md`。`harness-design` / `ui-design` / `ja-writing` が持つ) と原典 clone (`~/.local/share/yokai-harness/references/<repo>/`)。このスキルは鮮度チェックから再蒸留までを 1 コマンドで回す。参照資料の更新機構はこのスキルが一元所有する: `scripts/check-freshness.sh` が検出、[DISTILLING.md](DISTILLING.md) が更新レシピと再蒸留プロンプト雛形、`scripts/frontmatter.sh` が `install.sh` と共用のパーサ、[ADOPTION.md](ADOPTION.md) が「原典の変更を自分のハーネスに取り込むか」の判断台帳。参照スキル側 (`harness-design` / `ui-design` / `ja-writing`) は蒸留版を持つだけで、判定も規約も持たない。更新の入口はこのスキルだけ (スラッシュコマンドを増やさない)。

引数: repo 名 (例 `12-factor-agents`) を渡すとその repo だけを対象にする。`--check` で鮮度チェックのみ (更新に進まない)。無引数なら全 repo を対象に更新まで進む。

## Process (run in order)

0. **前提を解決する。**
   - 当日日付を控える: `date +%F`。`distilled_at` に使う。**サブエージェントは当日日付を知らないので、後で必ずプロンプトに埋める。**
   - このスキルの実体パスを解決する: `SELF="$(readlink -f "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/yokai-refs-update")"`。このスキルは `install.sh` が Claude Code の skills ディレクトリへ symlink したもので、plugin には入っていない (リポジトリの作業コピーを書き換えるため)。`readlink -f` で実体 (`<repo>/maintenance/yokai-refs-update`) を取る。以降 `$SELF/DISTILLING.md` / `$SELF/ADOPTION.md` を使う。
   - yokai-harness リポジトリのルートを解決する: `ROOT="$(dirname "$(dirname "$SELF")")"`。蒸留版は `harness-design` / `ui-design` / `ja-writing` の各スキル配下にあるので、出力先は `$ROOT/skills/<skill>/references/<repo>.md` になる (どのスキルかは手順1の STALE 行に併記される)。
   - スクリプト: `$ROOT/scripts/check-freshness.sh`。
   - 原典ルート: `. "$ROOT/scripts/paths.sh"; REFS="$YOKAI_REFS_ROOT"` (既定 `~/.local/share/yokai-harness/references`、`$YOKAI_HARNESS_REFS` で上書き)。clone は `$REFS/<repo>`。

1. **鮮度チェック** — `bash "$ROOT/scripts/check-freshness.sh"` を実行 (fetch あり = 最新 upstream を反映)。**1 ファイル 1 行**で、行頭タグは「次にやること」を示す: `OK` / `BEHIND` (pull) / `STALE` (再蒸留) / `REVIEW` (知識ベースの棚卸し) / `DEAD` (索引テーブルの原典パスが clone の HEAD に無い) / `MISS` / `ERR` / `NOTE`。BEHIND と STALE が同時に立つ repo は pull が先なので `BEHIND` 行だけが出る (`/ 蒸留版も遅れ` が併記される)。`NOTE` は「判定できなかった」であって「最新」ではないので exit 1 側に数える — したがって exit 0 は全件検証済みを意味する。引数に repo 名があれば、その repo の行だけを対象にする (スクリプトに絞り込み機能はないので出力からフィルタ)。引数が `--check` なら結果を提示してここで終了。exit 0 (= 要対応なし) なら「更新不要」と伝えて終了。

2. **MISS / ERR を処理** — `MISS` (clone がない/壊れ) は `install.sh --with-references` を案内して中断する (clone がないと更新できない)。`ERR` は 2 種類: `distilled_commit` が履歴にない場合は行に併記された復旧コマンドに従う。**frontmatter が 3 形式のどれでもない**場合は `DISTILLING.md`「frontmatter の形式」を見て、その資料が蒸留版 (形式 1) / 知識ベース (形式 2) / 対象外 (形式 3) のどれなのかを決めて frontmatter を直す。

3. **BEHIND を解消** — 各該当 clone を `git -C "$REFS/<repo>" pull --ff-only`。pull で新コミットが来ると STALE に変わるので、**pull 後に `check-freshness.sh` を取り直して STALE を再評価する** (順序を守る — 古い HEAD で蒸留しないため)。

4. **STALE を再蒸留** — STALE と `DEAD` の各リポジトリを `general-purpose` サブエージェントに**並列委譲**する (`Agent` tool。蒸留版を Write するので Explore 不可)。各プロンプトは `$SELF/DISTILLING.md` の「再蒸留プロンプト雛形」に次を埋めて作る:
   - 原典 clone パス `$REFS/<repo>` と owner/repo
   - 出力ファイル `$ROOT/<STALE 行に併記された蒸留版パス>` (例 `skills/ui-design/references/hallmark.md`)。どのスキルの蒸留版かを取り違えないため、パスは推測せず STALE 行の記載を使う
   - 重点領域 — 既存蒸留版の索引が扱っている範囲を引き継ぐ
   - 差分 — `git -C "$REFS/<repo>" log --oneline <distilled_commit>..HEAD` の内容 (何が変わったか。蒸留版に影響する変更だけ本文へ反映する判断材料)
   - **当日日付** (手順0の `date +%F`) を `distilled_at` として明示
   - 構成規約は `DISTILLING.md` に従うこと (frontmatter 3 キー / `## Contents` / `## まず押さえる` / 索引テーブル / `## 蒸留の範囲外` / 250 行以内 / 実際に Read した事実だけ・推測で書かない)

   各サブエージェントは蒸留版 1 ファイルを Write し、frontmatter の `distilled_commit` を clone の新 HEAD・`distilled_at` を当日に更新、最後に **2 本立てで返す** — (a) 行数・使った SHA・内容の 3 行要約、(b) **取り込み候補** (`DISTILLING.md`「取り込み候補の抽出」の 4 点セット。該当なしなら「候補なし」と明示)。雛形にこの返却契約が入っているので、プロンプトから落とさない。

   `DEAD` は索引が指す原典ファイルが移動・削除された状態。同じ repo が STALE なら再蒸留のプロンプトに切れたパスを併記して直させる。STALE でない (`distilled_commit` が HEAD と一致) なら蒸留時の誤記なので、索引の該当行だけを直し SHA は動かさない。

   1 つのサブエージェントが失敗・中断した、または返却契約を満たさなかった場合も、他の repo の作業は止めない。その repo は「未カバー」として手順7の集約に列挙し (蒸留版は STALE のまま残る)、黙って成功扱いにしない。

   再蒸留した repo が `ja-writing/MAPPING.md` の対応表に載っているもの (`stop-ai-slop-jp` 等) なら、MAPPING.md の該当節と、そこが指す `ja-slop-review` の references も見直す。自作スキルは原典の更新を自動では受け取らないので、ここで差分を取り込み候補 (手順6) に流す。

5. **REVIEW を棚卸し** — `REVIEW` は出所 clone を持たない知識ベース (`*-slop-review` 等) の期限切れ。SHA 差分がないので機械的な更新はできない。該当ファイルの主張を読み、**出典 URL の生存と撤回、記述が前提にしているモデル世代・流行の変化**を確認して本文を直す。委譲するなら `general-purpose` サブエージェント (WebFetch/WebSearch が要る)。直したら `reviewed_at` を当日に更新する。中身を見ずに日付だけ進めるのは禁止 (SHA の無言 bump と同じ)。見直した結果「変更不要」なら、その判断理由を commit message に書いて日付を進める。棚卸しで出典の撤回や前提の陳腐化が見つかったら、それも手順6の取り込み候補として扱う (知識ベースは自作なので、影響先は蒸留版ではなく自分のハーネスや文書規約になりやすい)。

6. **取り込み候補を照合して台帳に記録** — サブエージェントと手順5が返した取り込み候補を集める。
   **提示する前に、その候補が実際にこのハーネスに当たっているかを grep で確認する。** 照合先:
   - `$ROOT` — `skills/*/SKILL.md` の frontmatter (name の予約語・description の字数と書きぶり)、`skills/*/references/`、`instructions/`、`install.sh`
   - `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` — `settings.json` / `settings.local.json` / `CLAUDE.md`、および対象プロジェクトの `.claude/`

   「該当あり」と「該当なし (原典の記述としては正しいが、このハーネスには当たらない)」を分け、後者は深刻度を `FYI` に落とす。**grep せずに「影響あり」と言わない** — 推測での警告は台帳を腐らせる。確認できたものを `BREAKING` → `RECOMMENDED` → `FYI` の順に提示し、[ADOPTION.md](ADOPTION.md) へ追記する (書式は同ファイル冒頭)。台帳には**前回までの未対応項目も残っている**ので、それも併せて提示する。候補ゼロなら「今回は取り込み候補なし」と明示する (黙って省略しない)。

7. **集約と確認** — 更新したファイル一覧と各 3 行要約、取り込み候補の件数 (深刻度別)、未カバーの repo (あれば理由付き) を提示する。`bash "$ROOT/scripts/check-freshness.sh" --offline` を再実行し、exit 0 に戻ったことを確認する。ここまでの変更は作業ツリーに残す。

8. **commit (ユーザーが望むときのみ)** — 変更内容と、各リポジトリの差分 3 行要約を含む commit message 案を提示して承認を得てから commit する。**SHA だけの無言 bump をしない** (内容への影響なしと判断して SHA だけ進める場合も、その理由を message に書く)。`ADOPTION.md` の追記も同じ commit に含める。承認がなければ diff を残して終了。個人リポジトリなので main への直接 commit でよい。

## Gotchas

- 二次資料 (`claude-code-best-practice` 等) 由来の候補は、公式 docs との食い違いが原典側の誤検出である場合がある。原典の changelog が自ら INVALID にした項目を取り込み候補に昇格させない。
- 新規リポジトリの追加は別作業 (`DISTILLING.md`「新規リポジトリの追加」)。このスキルは既存蒸留版の更新に使う。

## Quick checklist

- [ ] `date +%F` を控え、サブエージェントに `distilled_at` として渡した
- [ ] `MISS`/`ERR` を先に解消した (clone 未取得なら `install.sh --with-references`)
- [ ] BEHIND を `git pull --ff-only` してから STALE を再評価した
- [ ] 各再蒸留が `DISTILLING.md` の規約 (frontmatter 3 キー / 250 行以内 / 推測で書かない) に従った
- [ ] `distilled_commit` を clone の新 HEAD に、`distilled_at` を当日に更新した
- [ ] `REVIEW` は出典と前提の生存を確認したうえで `reviewed_at` を進めた (日付だけの bump をしていない)
- [ ] 各サブエージェントから取り込み候補を受け取った (該当なしの明示も受け取った)
- [ ] 取り込み候補を実ハーネスに grep で当てて深刻度を確定し、`ADOPTION.md` に追記した
- [ ] 台帳の未対応項目 (前回以前の分を含む) を提示した
- [ ] 失敗したサブエージェントの repo を未カバーとして列挙した (成功扱いにしていない)
- [ ] `check-freshness.sh` が exit 0 に戻った
- [ ] commit する場合、message に差分 3 行要約を含め、`ADOPTION.md` の追記も同じ commit に入れた (SHA だけの無言 bump をしない)
