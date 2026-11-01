# install.sh・check-freshness.sh・yokai-refs-update が共用するパスの定義。
# 原典 clone は特定のエージェントに属さないデータなので XDG の data に置く。

# XDG Base Directory の規定どおり、絶対パスでない XDG_* は無いものとして扱う
# (相対パスのまま使うと、実行した cwd の下に原典が移ってしまう)
_yokai_abs() { case "${1:-}" in /*) printf '%s' "$1" ;; esac; }
_yokai_data_home="$(_yokai_abs "${XDG_DATA_HOME:-}")"
_yokai_state_home="$(_yokai_abs "${XDG_STATE_HOME:-}")"

# 原典 clone のルート。YOKAI_HARNESS_REFS で上書きできる (絶対パスに限る)
if [ -n "${YOKAI_HARNESS_REFS:-}" ] && [ -z "$(_yokai_abs "$YOKAI_HARNESS_REFS")" ]; then
  echo "YOKAI_HARNESS_REFS は絶対パスで指定する: $YOKAI_HARNESS_REFS" >&2
  exit 2
fi
YOKAI_REFS_ROOT="${YOKAI_HARNESS_REFS:-${_yokai_data_home:-$HOME/.local/share}/yokai-harness/references}"
# install.sh が前回選んだ対象を覚えておく場所
YOKAI_STATE_DIR="${_yokai_state_home:-$HOME/.local/state}/yokai-harness"
