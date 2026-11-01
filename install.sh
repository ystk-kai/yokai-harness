#!/usr/bin/env bash
# yokai-harness を各エージェントの設定ディレクトリへ展開する。何度実行しても同じ状態に収束する。
#
#   install.sh [--targets claude,codex,gemini|auto] [--skills link|none] [--with-references]
#
# --targets         展開先のエージェント。既定は前回の値、初回は claude だけ
#                   auto は前回の値に、PATH にある CLI (claude / codex / gemini) を足す (減らさない)
# --skills link     skills/ を各エージェントの skills ディレクトリへ symlink する (既定)
# --skills none     symlink しない。スキルを plugin で入れた環境で使う (二重登録を防ぐ)
# --with-references 蒸留版の frontmatter (source) から原典 clone を取得する
#
# 対象ごとの展開先:
#   claude  skills → ${CLAUDE_CONFIG_DIR:-~/.claude}/skills   指示 → ${CLAUDE_CONFIG_DIR:-~/.claude}/CLAUDE.md
#           maintenance/ の保守スキルと settings/global.json のマージも claude だけに入る
#   codex   skills → ~/.agents/skills                         指示 → ${CODEX_HOME:-~/.codex}/AGENTS.md
#   gemini  skills → ~/.agents/skills                         指示 → ~/.gemini/GEMINI.md
# OpenCode と Cursor は ~/.claude/skills と ~/.agents/skills の両方を読むので、対象を持たない。
set -euo pipefail

# 物理パスと論理パスの両方を持つ。symlink を挟んだ経路で過去に張ったリンクや hooks も自分のものと判定するため
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR_L="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$REPO_DIR/scripts/paths.sh"
. "$REPO_DIR/scripts/frontmatter.sh"

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
AGENTS_SKILLS="$HOME/.agents/skills"
STATE_FILE="$YOKAI_STATE_DIR/install.conf"
BAK_TAG="pre-yokai-harness"
STAMP="$(date +%Y%m%d-%H%M%S)"
# 改名前の名前。古い symlink・managed ブロック・hooks を掃除するために使う
LEGACY_REPO_NAME="claude-harness"
LEGACY_BLOCKS="harness-design"
LEGACY_SKILLS="avoid-ai-slop-ja avoid-ai-slop-design claude-harness-refs-update harness-design ui-design ja-writing"

usage() { sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; }
note() { echo "note: $*"; }
die() { echo "abort: $*" >&2; exit 1; }

# 指示ファイルとその対象名の組。対象から外したファイルからは、ブロックを剥がすだけ
INSTRUCTION_FILES="claude:$CLAUDE_DIR/CLAUDE.md
codex:$CODEX_DIR/AGENTS.md
gemini:$HOME/.gemini/GEMINI.md"

# ---- 指示ファイルの managed ブロック ------------------------------------------------
# instructions/<name>.md を <!-- BEGIN yokai-harness:<name> --> 〜 END で囲んで末尾に貼る。
# 先に yokai-harness のブロックを全部 (と改名前の managed:<name>) 剥がしてから貼り直すので、
# 消えた instructions/ のブロックも残らない。手書き部分は触らない。
# - marker は行全体一致 (末尾の CR は無視) で判定する。部分一致だと、引用した手書き行から先を巻き込んで消す
# - コードフェンス (``` / ~~~) の中の行は marker とみなさない。書式の説明として書いた手書き行を守るため
# - BEGIN と END の対応が崩れていたら exit 3。何も剥がさなかったら exit 4
strip_blocks() { # $1=file → 剥がした内容を stdout
  awk -v legacy=" $LEGACY_BLOCKS " '
    function marker(l, kind,  n) {
      sub(/\r$/, "", l)
      if (l ~ ("^<!-- " kind " yokai-harness:[a-z0-9-]+ -->$")) return 1
      if (l ~ ("^<!-- " kind " managed:[a-z0-9-]+ -->$")) {
        n = l; sub("^<!-- " kind " managed:", "", n); sub(/ -->$/, "", n)
        return index(legacy, " " n " ") > 0
      }
      return 0
    }
    !skip && /^[ \t]*(```|~~~)/ { fence = !fence; print; next }
    fence { print; next }
    marker($0, "BEGIN") { if (skip) err = 1; skip = 1; found = 1; next }
    marker($0, "END")   { if (!skip) err = 1; skip = 0; found = 1; next }
    !skip
    END { if (skip || err) exit 3; if (!found) exit 4 }
  ' "$1"
}

# 剥がせる (壊れていない) yokai-harness のブロックを持つか
has_block() { [ -f "$1" ] && strip_blocks "$1" >/dev/null 2>&1; }

# ---- 引数 ----------------------------------------------------------------------
targets="" skills_mode="" with_refs=0 explicit=0
while [ $# -gt 0 ]; do
  case "$1" in
    --targets) targets="${2:?--targets に値が要る}"; explicit=1; shift 2 ;;
    --targets=*) targets="${1#*=}"; explicit=1; shift ;;
    --skills) skills_mode="${2:?--skills に値が要る}"; shift 2 ;;
    --skills=*) skills_mode="${1#*=}"; shift ;;
    --with-references) with_refs=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

normalize_targets() { # 空白・カンマの混在を正規化し、重複を除いてカンマ区切りで返す
  printf '%s' "$1" | tr ' \t' ',,' | tr ',' '\n' | awk 'NF && !seen[$0]++' | paste -s -d, -
}

# 前回の選択を引き継ぐ (再実行で対象が黙って減らないように)。
# state が無い (初回、または XDG_STATE_HOME が違う環境) ときは、指示ファイルに残ったブロックから推定する
saved_targets="" saved_skills=""
if [ -f "$STATE_FILE" ]; then
  saved_targets="$(sed -n 's/^targets=//p' "$STATE_FILE" | tr -d '\r')"
  saved_skills="$(sed -n 's/^skills=//p' "$STATE_FILE" | tr -d '\r')"
else
  while IFS= read -r pair; do
    has_block "${pair#*:}" && saved_targets="${saved_targets:+$saved_targets,}${pair%%:*}"
  done <<EOF
$INSTRUCTION_FILES
EOF
fi
saved_targets="$(normalize_targets "$saved_targets")"

if [ "$explicit" = 1 ] && [ "$(normalize_targets "$targets")" = "auto" ]; then
  detected=""
  for cli in claude codex gemini; do
    command -v "$cli" >/dev/null 2>&1 && detected="$detected,$cli"
  done
  targets="$(normalize_targets "$saved_targets$detected")"
  targets="${targets:-claude}"
  echo "auto: 前回の対象と検出した CLI を合わせた対象 = $targets"
else
  targets="$(normalize_targets "${targets:-${saved_targets:-claude}}")"
fi
[ -n "$targets" ] || { echo "--targets が空" >&2; exit 2; }
skills_mode="${skills_mode:-${saved_skills:-link}}"
case "$skills_mode" in link|none) ;; *) echo "--skills は link か none: $skills_mode" >&2; exit 2 ;; esac
IFS=, read -r -a target_list <<<"$targets"
for t in "${target_list[@]}"; do
  case "$t" in claude|codex|gemini) ;; *) echo "unknown target: $t (claude / codex / gemini / auto)" >&2; exit 2 ;; esac
done
has_target() { case ",$targets," in *",$1,"*) return 0 ;; *) return 1 ;; esac; }

# 明示指定で対象が減るときは、何が外れるかを先に言う
IFS=, read -r -a saved_list <<<"$saved_targets"
for t in ${saved_list[@]+"${saved_list[@]}"}; do
  has_target "$t" || note "$t を対象から外す (skills の symlink と指示ファイルのブロックを取り除く)"
done

# ---- 指示ファイルの検査 --------------------------------------------------------
# 書き込む前に全部の指示ファイルを検査する。途中で止まって半分だけ適用された状態を作らないため
preflight_ok=1
while IFS= read -r pair; do
  t="${pair%%:*}" file="${pair#*:}"
  if [ -L "$file" ] && [ ! -e "$file" ]; then
    has_target "$t" && { echo "abort: $file は存在しない先を指す symlink。直してから再実行する" >&2; preflight_ok=0; }
    continue
  fi
  [ -e "$file" ] || continue
  st=0; strip_blocks "$file" >/dev/null || st=$?
  if [ "$st" = 3 ]; then
    if has_target "$t"; then
      echo "abort: $file の yokai-harness marker の BEGIN と END が対応していない。手で直してから再実行する" >&2
      preflight_ok=0
    else
      note "$file の marker が崩れている。対象外なので触らずに進む"
    fi
  elif has_target "$t" && [ ! -w "$file" ]; then
    echo "abort: $file に書き込めない" >&2; preflight_ok=0
  fi
done <<EOF
$INSTRUCTION_FILES
EOF
[ "$preflight_ok" = 1 ] || die "何も書き換えていない"

# ---- skills の symlink ------------------------------------------------------------
# リンク先を物理パスに直して返す (リンク先が消えていても、親ディレクトリが残っていれば直す)
phys() {
  local p="$1" d
  d="$(dirname "$p")"
  if [ -d "$d" ]; then printf '%s/%s' "$(cd "$d" && pwd -P)" "$(basename "$p")"; else printf '%s' "$p"; fi
}
# このリポジトリが張ったリンクか: 先が repo の skills/ か maintenance/ にあり、名前がリンク先と一致する
ours() { # $1=link
  local raw p name
  raw="$(readlink "$1")"; name="$(basename "$1")"
  [ "$(basename "$raw")" = "$name" ] || return 1
  p="$(phys "$raw")"
  case "$p" in "$REPO_DIR"/skills/*|"$REPO_DIR"/maintenance/*) return 0 ;; esac
  case "$raw" in "$REPO_DIR_L"/skills/*|"$REPO_DIR_L"/maintenance/*) return 0 ;; esac
  return 1
}
# 改名前のリポジトリが張ったリンクか: .../claude-harness/skills/<同名> を指し、旧版のスキル名か、先が消えている
legacy_link() { # $1=link
  local raw name
  raw="$(readlink "$1")"; name="$(basename "$1")"
  case "$raw" in */"$LEGACY_REPO_NAME"/skills/"$name") ;; *) return 1 ;; esac
  case " $LEGACY_SKILLS " in *" $name "*) return 0 ;; esac
  [ ! -e "$1" ]
}

# $1=skills ディレクトリ $2...=張るスキルの実体パス
sync_skill_links() {
  local dir="$1"; shift
  local want=" " src name link
  for src in "$@"; do want="$want$(basename "$src") "; done
  if [ -d "$dir" ]; then
    for link in "$dir"/*; do
      [ -L "$link" ] || continue
      name="$(basename "$link")"
      if ours "$link"; then
        case "$want" in *" $name "*) [ -e "$link" ] && continue ;; esac
      elif ! legacy_link "$link"; then
        continue
      fi
      rm "$link" && echo "removed stale link: $link"
    done
  fi
  [ $# -gt 0 ] || return 0
  mkdir -p "$dir"
  for src in "$@"; do
    name="$(basename "$src")"
    link="$dir/$name"
    if [ -L "$link" ]; then
      if ! ours "$link" && ! legacy_link "$link"; then
        echo "skip skill $name: $link はほかの場所 ($(readlink "$link")) を指す symlink (ほかのツールのものなら触らない)"
        continue
      fi
    elif [ -e "$link" ]; then
      echo "skip skill $name: $link に symlink でない実体がある (手動で退避してから再実行)"
      continue
    fi
    ln -sfn "$src" "$link"
  done
}

dist_skills=()
for d in "$REPO_DIR"/skills/*/; do [ -f "$d/SKILL.md" ] && dist_skills+=("${d%/}"); done
maint_skills=()
for d in "$REPO_DIR"/maintenance/*/; do [ -f "$d/SKILL.md" ] && maint_skills+=("${d%/}"); done

claude_links=() agents_links=()
if has_target claude; then
  [ "$skills_mode" = link ] && claude_links+=(${dist_skills[@]+"${dist_skills[@]}"})
  # 保守スキルは作業コピーを書き換えるので plugin に入れず、常に symlink
  claude_links+=(${maint_skills[@]+"${maint_skills[@]}"})
fi
if [ "$skills_mode" = link ] && { has_target codex || has_target gemini; }; then
  agents_links+=(${dist_skills[@]+"${dist_skills[@]}"})
fi
sync_skill_links "$CLAUDE_DIR/skills" ${claude_links[@]+"${claude_links[@]}"}
sync_skill_links "$AGENTS_SKILLS" ${agents_links[@]+"${agents_links[@]}"}

# 二重登録になりうる組み合わせを知らせる
if [ "$skills_mode" = link ]; then
  if has_target claude && grep -qs '"yokai@yokai-harness"' "$CLAUDE_DIR/plugins/installed_plugins.json"; then
    note "Claude Code に plugin yokai@yokai-harness も入っている。スキルが二重になるので --skills none を勧める"
  fi
  if { has_target codex || has_target gemini; } && [ -d "$CODEX_DIR/plugins/cache/yokai-harness" ]; then
    note "Codex に plugin yokai@yokai-harness も入っている。スキルが二重になるので --skills none を勧める"
  fi
  if has_target claude && { has_target codex || has_target gemini; } \
     && { command -v opencode >/dev/null 2>&1 || command -v cursor-agent >/dev/null 2>&1; }; then
    note "OpenCode と Cursor は ~/.claude/skills と ~/.agents/skills の両方を読むので、同じスキルが 2 か所から見える。OpenCode は OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1 で片方を止められる"
  fi
fi

# ---- 指示ファイルの managed ブロック (書き込み) ------------------------------------------
backup() { # 世代ごとに残す。前の backup を上書きしない
  [ -s "$1" ] || return 0
  cp "$1" "$1.$BAK_TAG.$STAMP.bak"
}
write_file() { # $1=file $2=内容。symlink の先へ書き、権限も保つ (cat で上書き)
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/yokai-harness.XXXXXX")"
  if [ -n "$2" ]; then printf '%s\n' "$2" >"$tmp"; else : >"$tmp"; fi
  cat "$tmp" >"$1"
  rm -f "$tmp"
}

sync_blocks() { # $1=指示ファイル $2=1 なら貼る / 0 なら剥がすだけ
  local file="$1" attach="$2" content rebuilt snippet name st=0
  if [ ! -e "$file" ]; then
    [ "$attach" = 1 ] || return 0
    mkdir -p "$(dirname "$file")"; : >"$file"
  fi
  content="$(strip_blocks "$file")" || st=$?
  [ "$st" = 3 ] && return 0            # 対象外で marker が崩れているファイル (preflight で知らせ済み)
  [ "$attach" = 0 ] && [ "$st" = 4 ] && return 0   # 剥がすものが無ければ書かない
  # 末尾の空行を落とす (手書き部分と各ブロックの間は常に空行 1 行に揃える)
  rebuilt="$(printf '%s\n' "$content" | awk '
    { a[NR] = $0 }
    END { l = NR; while (l > 0 && a[l] ~ /^[[:space:]\r]*$/) l--; for (i = 1; i <= l; i++) print a[i] }
  ')"
  if [ "$attach" = 1 ]; then
    for snippet in "$REPO_DIR"/instructions/*.md; do
      [ -e "$snippet" ] || continue
      name="$(basename "$snippet" .md)"
      rebuilt="${rebuilt:+$rebuilt$'\n\n'}<!-- BEGIN yokai-harness:$name -->"$'\n'"$(cat "$snippet")"$'\n'"<!-- END yokai-harness:$name -->"
    done
  fi
  if [ "$rebuilt" != "$(cat "$file")" ]; then
    backup "$file"
    write_file "$file" "$rebuilt"
    echo "updated: $file"
  fi
}

while IFS= read -r pair; do
  if has_target "${pair%%:*}"; then sync_blocks "${pair#*:}" 1; else sync_blocks "${pair#*:}" 0; fi
done <<EOF
$INSTRUCTION_FILES
EOF

# ---- settings.json のマージ ---------------------------------------------------------
# settings/global.json に書いたキーだけを ~/.claude/settings.json へ入れる (settings.json 全体を所有しない)。
# hooks はこの repo (と改名前の repo) の hooks/ を指す handler だけを剥がしてから貼り直すので、再実行しても重複しない。
# claude を対象から外したときは、剥がすだけにする。
MANAGED_SETTINGS="$REPO_DIR/settings/global.json"
settings="$CLAUDE_DIR/settings.json"
if [ -f "$MANAGED_SETTINGS" ] && { has_target claude || [ -s "$settings" ]; }; then
  chmod +x "$REPO_DIR"/hooks/*.sh 2>/dev/null || true
  if ! command -v jq >/dev/null 2>&1; then
    echo "skip settings: jq が無い ($MANAGED_SETTINGS のマージには jq が要る)"
  else
    [ -s "$settings" ] || echo '{}' >"$settings"
    # 壊れた JSON / トップレベルが object でないものは生の jq エラーで落ちるので先に弾く
    jq -e 'type == "object"' "$settings" >/dev/null 2>&1 \
      || die "$settings が JSON object として読めない (壊れているか配列)。手で直すかリネームしてから再実行する"
    if has_target claude; then
      managed="$(jq --arg root "$REPO_DIR" '
        walk(if type == "string" then gsub("\\{\\{REPO_DIR\\}\\}"; $root) else . end)
        | with_entries(select(.key | startswith("_") | not))
      ' "$MANAGED_SETTINGS")"
    else
      managed='{}'
    fi
    merged="$(jq --argjson m "$managed" --arg p1 "$REPO_DIR/hooks/" --arg p2 "$REPO_DIR_L/hooks/" \
                 --arg legacy "/$LEGACY_REPO_NAME/hooks/" '
      def ours: (.command // "") as $c
        | ($c | startswith($p1)) or ($c | startswith($p2)) or ($c | contains($legacy));
      # matcher entry ごと落とすと、同じ entry に同居するユーザー自前の handler も消える。
      # entry の hooks 配列から repo 配下を指す handler だけを抜き、空になった entry のみ落とす。
      def drop_managed:
        (. // {})
        | with_entries(
            .value |= ( map(.hooks |= map(select(ours | not)))
                        | map(select((.hooks | length) > 0)) ))
        | with_entries(select(.value | length > 0));
      . as $c
      | $c
      + { extraKnownMarketplaces: (($c.extraKnownMarketplaces // {}) + ($m.extraKnownMarketplaces // {}))
        , enabledPlugins:         (($c.enabledPlugins // {}) + ($m.enabledPlugins // {}))
        , hooks: (reduce ($m.hooks // {} | to_entries[]) as $e
                    ($c.hooks | drop_managed; .[$e.key] = ((.[$e.key] // []) + $e.value)))
        }
      | if (.extraKnownMarketplaces | length) == 0 then del(.extraKnownMarketplaces) else . end
      | if (.enabledPlugins        | length) == 0 then del(.enabledPlugins)        else . end
      | if (.hooks                 | length) == 0 then del(.hooks)                 else . end
    ' "$settings")"
    if [ "$(printf '%s' "$merged" | jq -S .)" != "$(jq -S . "$settings")" ]; then
      backup "$settings"
      write_file "$settings" "$merged"
      echo "settings merged: $settings"
    fi
  fi
fi

# ---- 原典 clone ------------------------------------------------------------------
# 旧配置 (~/.claude/references) の実体は新しい場所へ移し、旧パスには移行用の symlink を残す。
# 同じファイルシステムの中だけで移す (rename なので途中で止まっても半端な状態にならない)
legacy_refs="$CLAUDE_DIR/references"
fs_of() { df -P "$1" 2>/dev/null | awk 'NR == 2 { print $1 }'; }
if [ -d "$legacy_refs" ] && [ ! -L "$legacy_refs" ]; then
  legacy_p="$(cd "$legacy_refs" && pwd -P)"
  case "$(phys "$YOKAI_REFS_ROOT")/" in
    "$legacy_p"/*) die "原典の置き場 $YOKAI_REFS_ROOT が旧配置 $legacy_refs の中にある。YOKAI_HARNESS_REFS を別の場所にする" ;;
  esac
  if [ -e "$YOKAI_REFS_ROOT" ]; then
    note "原典 clone が旧配置 $legacy_refs と新配置 $YOKAI_REFS_ROOT の両方にある。新配置を使う。旧配置は中身を確かめてから手で消す"
  else
    mkdir -p "$(dirname "$YOKAI_REFS_ROOT")"
    if [ "$(fs_of "$legacy_refs")" = "$(fs_of "$(dirname "$YOKAI_REFS_ROOT")")" ]; then
      mv "$legacy_refs" "$YOKAI_REFS_ROOT"
      ln -s "$YOKAI_REFS_ROOT" "$legacy_refs"
      echo "moved references: $legacy_refs → $YOKAI_REFS_ROOT (旧パスは移行用の symlink。不要なら削除してよい)"
    else
      note "原典 clone の旧配置 $legacy_refs と新配置 $YOKAI_REFS_ROOT はファイルシステムが違う。途中で止まると半端に残るので自動では移さない。手で移すか --with-references で取り直す"
    fi
  fi
fi

if [ "$with_refs" = 1 ]; then
  mkdir -p "$YOKAI_REFS_ROOT"
  for doc in "$REPO_DIR"/skills/*/references/*.md; do
    [ -e "$doc" ] || continue
    url="$(fm_value "$doc" source)"
    [ -n "$url" ] || continue
    dir="$YOKAI_REFS_ROOT/$(repo_dir_name "$url")"
    [ -d "$dir" ] || git clone --filter=blob:none "$url" "$dir"
    # 原典が同梱する .claude/skills は Claude Code のディレクトリスコープ skill として
    # 自動登録される (原典を読むだけで第三者の指示が発火し得る)。worktree から外す。
    # .claude/{agents,commands,hooks,settings.json,rules} は入れ子では自動ロードされず
    # 参照価値があるので残す。中身は git -C <clone> show HEAD:<path> で読める。
    # smarthr-design-system は public/ (画像・約 300MB) を参照しないので外す。
    extra=""
    case "$(basename "$dir")" in
      smarthr-design-system) extra='!/public' ;;
    esac
    git -C "$dir" sparse-checkout set --no-cone '/*' '!/.claude/skills' ${extra:+"$extra"} >/dev/null
  done
fi

# 全部適用し終えてから選択を保存する (途中で止まったら前回の選択のまま)
mkdir -p "$YOKAI_STATE_DIR"
printf 'targets=%s\nskills=%s\n' "$targets" "$skills_mode" >"$STATE_FILE"

echo "applied: targets=$targets skills=$skills_mode references=$YOKAI_REFS_ROOT"
