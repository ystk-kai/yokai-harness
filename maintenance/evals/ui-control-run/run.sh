#!/usr/bin/env bash
# 使い方: run.sh <brief> <arm: control|skill> <rep>
# 1 回分の HTML を claude -p の別プロセスで生成する。
set -euo pipefail
brief=$1 arm=$2 rep=$3
here=$(cd "$(dirname "$0")" && pwd)
root=${GEN_ROOT:-$HOME/.cache/htmlgen}          # 条件名を含まない中立な作業場所
sk=$root/skills                                  # skill 条件で読ませるスキルの写し
refs=${YOKAI_HARNESS_REFS:-$HOME/.local/share/yokai-harness/references}
log=${GEN_LOG:-$root/logs}
model=${GEN_MODEL:-claude-opus-5-5}
mkdir -p "$log" "$here/html"
wd=$(mktemp -d "$root/w.XXXXXX")                 # 空の cwd。control は読めるものが無い

prompt=""
extra=()
if [ "$arm" = skill ]; then
  prompt="この作業では、次の 2 つのスキルの手順と参照資料に従ってデザインを決めてください。最初に両方の SKILL.md を読み、SKILL.md が読むよう指示している references (蒸留版、必要なら原典) を Read で読んでから作り始めてください。
- $sk/ui-design/SKILL.md
- $sk/visual-slop-review/SKILL.md
原典ルートは $refs/ です。

"
  extra=(--add-dir "$sk" --add-dir "$refs")
fi
prompt+="$(cat "$here/briefs/$brief.md")

$(cat "$here/briefs/common.md")"

cd "$wd"
claude -p "$prompt" \
  --model "$model" \
  --tools Read,Glob,Grep \
  --disable-slash-commands \
  --settings '{"claudeMdExcludes":["**/CLAUDE.md","**/CLAUDE.local.md"],"autoMemoryEnabled":false}' \
  --max-budget-usd 5 \
  --output-format stream-json --verbose \
  "${extra[@]}" > "$log/$brief-$arm-$rep.jsonl" 2> "$log/$brief-$arm-$rep.err" || true

python3 - "$log/$brief-$arm-$rep.jsonl" "$here/html/$brief-$arm-$rep.html" <<'PY'
import json, re, sys
src, dst = sys.argv[1], sys.argv[2]
res = None
for line in open(src, encoding="utf-8"):
    try: o = json.loads(line)
    except Exception: continue
    if o.get("type") == "result": res = o
if not res or not res.get("result"):
    sys.exit(f"no result in {src}")
t = res["result"]
m = re.search(r"<!DOCTYPE html>.*</html>", t, re.S | re.I)
open(dst, "w", encoding="utf-8").write((m.group(0) if m else t) + "\n")
print(dst, "cost=%.2f" % res.get("total_cost_usd", 0), "turns=%s" % res.get("num_turns"))
PY
