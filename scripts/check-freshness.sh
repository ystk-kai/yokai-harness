#!/usr/bin/env bash
# 全スキルの references/*.md の鮮度を報告する。1 ファイル 1 行で、タグは「次にやること」を示す。
#   BEHIND: clone が upstream より遅れ → git pull --ff-only してから再実行 (STALE はその後に再判定)
#   STALE : 蒸留版が clone の HEAD より古い → DISTILLING.md の手順で再蒸留
#   REVIEW: 出所を追従しない知識ベースの棚卸し期限切れ → 内容を見直して reviewed_at を更新
#   DEAD  : 蒸留版の索引テーブルが指す原典ファイルが clone の HEAD に無い (移動・削除) → 再蒸留で索引を直す
#   OK    : 追従先と一致している / 棚卸し期限内
#   MISS  : clone がない・壊れている / ERR: frontmatter か SHA が解決できない
#   NOTE  : 判定を諦めた。「最新」ではないので exit 1 側に数える (未検証を緑に紛れ込ませない)
# frontmatter の 3 形式 (正は DISTILLING.md「frontmatter の形式」):
#   1. source + distilled_commit                             … 原典 clone を SHA で追従する蒸留版
#   2. tracking: review + reviewed_at + review_interval_days  … 出所を追従しない知識ベース
#   3. tracking: none                                        … 対象外 (明示)
# どれにも当てはまらないものは ERR。frontmatter が無いだけで無言に対象外にはしない。
# 既定で origin を fetch する (shallow clone は履歴ごと取得)。--offline で fetch を省略。
# 終了コード: 0=全て最新, 1=要対応あり
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(dirname "$SCRIPT_DIR")/skills"
. "$SCRIPT_DIR/paths.sh"
. "$SCRIPT_DIR/frontmatter.sh"
REFS_ROOT="$YOKAI_REFS_ROOT"

offline=0
if [ "${1:-}" = "--offline" ]; then offline=1; fi
status=0
found=0
now_epoch="$(date +%s)"

# YYYY-MM-DD → epoch 秒。GNU date と BSD date の両方を試し、どちらも駄目なら空を返す
epoch_of_day() {
  date -d "$1" +%s 2>/dev/null || date -j -f %Y-%m-%d "$1" +%s 2>/dev/null || true
}

# 蒸留版の索引テーブル (行頭 `|`) に書かれた原典ファイルパスのうち、clone の HEAD に無いものを空白区切りで返す。
# SHA 比較はファイル単位なので、原典側の移動・削除で索引だけが切れても STALE は「差分がある」としか言わない。
# 誤検出を避けるため対象を絞る: `dir/file.ext` 形 (先頭セグメントが HEAD に実在し、末尾が / でなく、
# glob・brace・<placeholder>・空白を含まない) だけを見る。作業ツリーでなく HEAD の tree を引くのは、
# install.sh が sparse-checkout で .claude/skills を外しているため
dead_index_paths() {
  local doc="$1" clone="$2" p
  grep '^|' "$doc" | grep -o '`[^`]*`' | tr -d '`' \
    | grep -E '^[A-Za-z0-9._-]+/[^ <>{}*]*[^/]$' | sed -E 's/[:#].*$//' | sort -u \
    | while IFS= read -r p; do
        git -C "$clone" cat-file -e "HEAD:${p%%/*}" 2>/dev/null || continue
        git -C "$clone" cat-file -e "HEAD:$p" 2>/dev/null || printf '%s ' "$p"
      done
}

for doc in "$SKILLS_ROOT"/*/references/*.md; do
  [ -e "$doc" ] || continue
  found=1
  rel="${doc#"$SKILLS_ROOT"/}"
  tracking="$(fm_value "$doc" tracking)"

  # 形式 3: 明示的に対象外
  if [ "$tracking" = "none" ]; then continue; fi

  # 形式 2: 日付で棚卸しする知識ベース (出所 clone を持たない)
  if [ "$tracking" = "review" ]; then
    reviewed_at="$(fm_value "$doc" reviewed_at)"
    interval="$(fm_value "$doc" review_interval_days)"
    if [ -z "$reviewed_at" ] || [ -z "$interval" ]; then
      echo "ERR    $rel: tracking: review には reviewed_at (YYYY-MM-DD) と review_interval_days が要る"
      status=1; continue
    fi
    # 算術に入る前に検証する。非整数を $(( )) に渡すと set -u 下で走査全体が落ち、
    # 以降のファイルが一切報告されなくなる (1 ファイルの誤記で鮮度チェックが盲目化する)
    case "$interval" in
      ''|0|*[!0-9]*)
        echo "ERR    $rel: review_interval_days ($interval) が正の整数でない"
        status=1; continue ;;
    esac
    case "$reviewed_at" in
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
      *) echo "ERR    $rel: reviewed_at ($reviewed_at) が YYYY-MM-DD 形式でない"
         status=1; continue ;;
    esac
    reviewed_epoch="$(epoch_of_day "$reviewed_at")"
    if [ -z "$reviewed_epoch" ]; then
      # 検証できなかっただけで「最新」ではない。status を上げて exit 0 に紛れ込ませない
      echo "NOTE   $rel: reviewed_at ($reviewed_at) を date で解釈できない (存在しない日付か date の非対応) — 棚卸し判定を省略"
      status=1; continue
    fi
    elapsed=$(( (now_epoch - reviewed_epoch) / 86400 ))
    if [ "$elapsed" -lt 0 ]; then
      # 未来日付は「stale でない」ので OK に落ちてしまう。打ち間違いか時計ずれを最新扱いで隠さない
      echo "ERR    $rel: reviewed_at ($reviewed_at) が未来の日付 (打ち間違いか時計ずれ)"
      status=1; continue
    fi
    if [ "$elapsed" -gt "$interval" ]; then
      echo "REVIEW $rel: 前回の棚卸しから $elapsed 日 (期限 $interval 日) — 内容を見直して reviewed_at を更新"
      status=1
    else
      echo "OK     $rel @ reviewed $reviewed_at (残り $(( interval - elapsed )) 日)"
    fi
    continue
  fi

  # 形式 1: 原典 clone を SHA で追従する蒸留版
  source_url="$(fm_value "$doc" source)"
  pinned="$(fm_value "$doc" distilled_commit)"
  if [ -z "$source_url" ] || [ -z "$pinned" ]; then
    echo "ERR    $rel: frontmatter が 3 形式のどれでもない (source+distilled_commit / tracking: review / tracking: none) — DISTILLING.md 参照"
    status=1; continue
  fi
  name="$(repo_dir_name "$source_url")"
  clone="$REFS_ROOT/$name"
  if ! git -C "$clone" rev-parse --git-dir >/dev/null 2>&1; then
    echo "MISS   $name: clone がない/壊れている ($clone) — install.sh --with-references で取得"
    status=1; continue
  fi

  if [ "$offline" -eq 0 ]; then
    if [ "$(git -C "$clone" rev-parse --is-shallow-repository 2>/dev/null)" = "true" ]; then
      git -C "$clone" fetch --quiet --unshallow origin 2>/dev/null \
        || git -C "$clone" fetch --quiet origin 2>/dev/null \
        || echo "NOTE   $name: fetch 失敗 (オフライン?) — ローカル状態のみで判定"
    else
      git -C "$clone" fetch --quiet origin 2>/dev/null \
        || echo "NOTE   $name: fetch 失敗 (オフライン?) — ローカル状態のみで判定"
    fi
  fi

  head_sha="$(git -C "$clone" rev-parse HEAD 2>/dev/null)" \
    || { echo "ERR    $name: HEAD が解決できない ($clone)"; status=1; continue; }

  # 短縮 SHA も受け付け、完全 SHA に解決してから比較する
  pinned_full="$(git -C "$clone" rev-parse --verify --quiet "$pinned^{commit}" 2>/dev/null || true)"
  if [ -z "$pinned_full" ]; then
    echo "ERR    $name: distilled_commit ($pinned) が履歴に見つからない — git -C \"$clone\" fetch origin $pinned で取得"
    status=1; continue
  fi

  upstream="$(git -C "$clone" rev-parse --verify --quiet origin/HEAD 2>/dev/null || true)"
  behind=""
  if [ -n "$upstream" ] && [ "$upstream" != "$head_sha" ]; then
    behind="$(git -C "$clone" rev-list --count HEAD..origin/HEAD 2>/dev/null || echo '?')"
  fi

  # タグは「次の一手」を示す。BEHIND と STALE が同時に立つときは pull が先なので BEHIND を出す
  # (pull で HEAD が動くと STALE の差分そのものが変わるため、古い HEAD で蒸留させない)
  if [ -n "$behind" ]; then
    also=""
    [ "$pinned_full" = "$head_sha" ] || also=" / 蒸留版も遅れ — pull 後に再実行して STALE を再判定"
    echo "BEHIND $name: clone が upstream より $behind commits 遅れ — git -C \"$clone\" pull --ff-only$also"
    status=1
  elif [ "$pinned_full" = "$head_sha" ]; then
    echo "OK     $name @ ${head_sha:0:12}"
  elif git -C "$clone" merge-base --is-ancestor "$head_sha" "$pinned_full" 2>/dev/null; then
    # HEAD が distilled_commit の祖先 = clone の方が蒸留版より古い。STALE の逆向きで、
    # そのまま STALE 分岐に落ちると "0 commits" と表示され、空の log を見せて
    # 「再蒸留しろ」と促してしまう (蒸留の材料が clone に無いので何もできない)。
    # --offline で origin/HEAD が古いまま BEHIND を判定できなかったときに起きる。
    n="$(git -C "$clone" rev-list --count "HEAD..$pinned_full" 2>/dev/null || echo '?')"
    echo "BEHIND $name: clone が蒸留版より $n commits 古い (HEAD ${head_sha:0:12} < distilled_commit ${pinned_full:0:12}) — git -C \"$clone\" pull --ff-only してから再実行"
    status=1
  else
    n="$(git -C "$clone" rev-list --count "$pinned_full..HEAD" 2>/dev/null || echo '?')"
    echo "STALE  $name: 蒸留時 ${pinned_full:0:12} → 現在 ${head_sha:0:12} ($n commits) — 蒸留版: skills/$rel"
    git -C "$clone" log --oneline "$pinned_full..HEAD" 2>/dev/null | sed 's/^/         /' || true
    status=1
  fi

  # BEHIND のときは pull で HEAD が動くので判定しない
  if [ -z "$behind" ]; then
    dead="$(dead_index_paths "$doc" "$clone")"
    if [ -n "$dead" ]; then
      echo "DEAD   $name: 索引の原典パスが HEAD に無い (${dead% }) — 蒸留版: skills/$rel"
      status=1
    fi
  fi
done

if [ "$found" -eq 0 ]; then
  echo "ERR    どのスキルにも references/*.md がない ($SKILLS_ROOT/*/references/*.md)"
  exit 1
fi
exit $status
