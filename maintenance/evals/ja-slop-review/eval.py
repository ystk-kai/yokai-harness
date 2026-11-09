# /// script
# requires-python = ">=3.11"
# ///
"""ja-slop-review スキルの評価ハーネス。

fixtures/ の文書を ja-slop-review で推敲させ (claude -p、既定 Opus 5.5)、別のモデル (既定 Sonnet 5.5) で判定する。

1. 機械的な検査 (LLM を使わない)
   - 元の文書が変わっていない、after.md がある、スキルを使った (Skill の呼び出しか SKILL.md の Read がログにある)
   - after.md に【要確認】・TODO の印や改訂の経緯 (改訂・指摘を反映・第N版) を足していない
   - 記録だけ: expected.json の keep の quote が after.md にそのまま残っているか、defects の quote が残っているか、
     変わった文の数 (changes.json)、読点の増減、字数の増減、文書全体の一致率
2. 判定 (prompts/judge.txt)
   - defects ごとに fixed / asked / remains / harmed
   - keep ごとに kept / reworded / changed / removed
   - changes.json の各変更に、種類・直した欠陥・出所の規則・規則の当てはまり (fits / misread / gap / none)・意味が変わったか
3. 集計 (runs/<label>/summary.md と changes.md)
   - 欠陥ごとの安定検出 (repeat の 2/3 以上で accept の状態)
   - 残す箇所ごとの安定保持 (repeat の 2/3 以上で quote がそのまま残る)
   - 欠陥のない文書で書き換えた箇所の一覧と、規則ごとの件数

使い方:
    python3 maintenance/evals/ja-slop-review/eval.py --dry-run
    python3 maintenance/evals/ja-slop-review/eval.py --repeat 3 --jobs 5 --run-label r1
    python3 maintenance/evals/ja-slop-review/eval.py --fixtures blog-clean --repeat 1 --run-label probe
    python3 maintenance/evals/ja-slop-review/eval.py --rejudge r1 --run-label r1-rj   # 生成を回さず判定だけかけ直す

費用と認証が要るので CI には入れない。生成物は runs/ に残る (gitignore)。
"""

from __future__ import annotations

import argparse
import difflib
import hashlib
import json
import math
import re
import shutil
import subprocess
import sys
import tempfile
import time
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
FIXTURES = HERE / "fixtures"
RUNS = HERE / "runs"
JUDGE_PROMPT = (HERE / "prompts" / "judge.txt").read_text()
DEFAULT_FIXTURES = ("gijiroku-planted,gijutsu-planted,mail-planted,essay-planted,release-planted,"
                    "tegami-clean,zuihitsu-clean,houdou-clean,blog-clean,yasashii-clean")

# 規則の中身は書かない (スキルがどう直すかを測るため)。人の文か AI の文かも伝えない
PROMPT = ("yokai:ja-slop-review スキルを使って {file} を見直し、直すべきところを直してください。"
          "直した全文を after.md に保存してください。直すところがなければ、元の文をそのまま after.md に保存してください。"
          "{file} は変えないでください。"
          "この実行では対話ができません。確認したくなったことは自分で判断して進め、何をどう判断したかを最後の返答に書いてください。")
# cd を許さないと「cd X; cat Y」が1回却下され、以後 Bash を使わなくなる (dontAsk の却下文が回避を禁じるため)
RUN_TOOLS = ["Skill", "Read", "Write", "Edit", "Glob", "Grep", "Bash(cd:*)", "Bash(cat:*)", "Bash(head:*)",
             "Bash(wc:*)", "Bash(ls:*)", "Bash(grep:*)", "Bash(diff:*)", "Bash(cp:*)", "Bash(python3:*)"]
JUDGE_TOOLS = ["Read", "Write", "Glob"]
MARKERS = re.compile(r"【要確認】|要確認|TODO")
REVISION_NOTES = re.compile(r"改訂|指摘を反映|レビューを反映|初版|前版|第\s*[0-9０-９一二三]\s*版")


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def make_plugin_dir() -> Path:
    """未コミットのスキルも測れるよう、作業ツリーをコピーして --plugin-dir で渡す。"""
    d = Path(tempfile.mkdtemp(prefix="jsr-plugin-"))
    shutil.copy(REPO / "plugin.json", d / "plugin.json")
    shutil.copytree(REPO / ".claude-plugin", d / ".claude-plugin")
    shutil.copytree(REPO / "skills", d / "skills", ignore=shutil.ignore_patterns("__pycache__"))
    return d


def claude(prompt: str, cwd: Path, tools: list[str], model: str, effort: str, log: Path, plugin: Path | None = None,
           add_dirs: list[Path] = (), timeout: int = 1800) -> dict:
    """claude -p を1回呼び、最後の result イベント (費用・返答) を返す。"""
    base = sorted({t.split("(")[0] for t in tools})
    # --setting-sources project で、ユーザー設定と ~/.claude/skills の同名スキル (main の作業ツリーへの symlink) を読ませない
    cmd = ["claude", "-p", prompt, "--model", model, "--effort", effort, "--output-format", "stream-json", "--verbose",
           "--setting-sources", "project", "--permission-mode", "dontAsk", "--strict-mcp-config",
           "--tools", ",".join(base), "--allowedTools", ",".join(tools)]
    if plugin:
        cmd += ["--plugin-dir", str(plugin), "--add-dir", str(plugin)]
    for d in add_dirs:
        cmd += ["--add-dir", str(d)]
    try:
        r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout, stdin=subprocess.DEVNULL)
        out, err = r.stdout, r.stderr
    except subprocess.TimeoutExpired as e:
        out, err = (e.stdout or b"").decode() if isinstance(e.stdout, bytes) else (e.stdout or ""), "TIMEOUT"
    log.write_text(out + "\n--- stderr ---\n" + err)
    res: dict = {}
    for line in out.splitlines():
        if line.startswith("{") and '"type":"result"' in line.replace(" ", ""):
            try:
                res = json.loads(line)
            except json.JSONDecodeError:
                pass
    return res


# ---------------------------------------------------------------------------
# 差分と機械的な検査
# ---------------------------------------------------------------------------

def units(text: str) -> list[str]:
    """行ごとに分け、行の中は 。！？ の後ろで切る。空行は捨てる。"""
    out: list[str] = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        out += [s for s in re.split(r"(?<=[。！？])", line) if s.strip()]
    return out


def sentence_changes(before: str, after: str) -> list[dict]:
    a, b = units(before), units(after)
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    changes = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            continue
        changes.append({"id": len(changes) + 1, "before": "\n".join(a[i1:i2]), "after": "\n".join(b[j1:j2])})
    return changes


def skill_used(log: Path) -> bool:
    t = log.read_text() if log.exists() else ""
    return bool(re.search(r'"skill"\s*:\s*"yokai:ja-slop-review"', t) or "ja-slop-review/SKILL.md" in t)


def mechanical(src: Path, src_sha: str, after: Path, log: Path, exp: dict) -> dict:
    c: dict = {"source_unchanged": sha(src) == src_sha, "after_exists": after.exists(), "skill_used": skill_used(log)}
    s = src.read_text()
    if not after.exists():
        c["PASS"] = False
        return c
    t = after.read_text()
    c["markers_added"] = len(MARKERS.findall(t)) - len(MARKERS.findall(s))
    c["revision_notes_added"] = len(REVISION_NOTES.findall(t)) - len(REVISION_NOTES.findall(s))
    c["identical"] = s.strip() == t.strip()
    c["similarity"] = round(difflib.SequenceMatcher(None, s, t, autojunk=False).ratio(), 3)
    c["commas_delta"] = t.count("、") - s.count("、")
    c["chars_delta"] = len(re.sub(r"\s", "", t)) - len(re.sub(r"\s", "", s))
    c["keep_verbatim"] = {k["id"]: k["quote"] in t for k in exp["keep"]}
    c["defect_quote_left"] = {d["id"]: d["quote"] in t for d in exp["defects"]}
    c["PASS"] = (c["source_unchanged"] and c["after_exists"] and c["skill_used"]
                 and c["markers_added"] <= 0 and c["revision_notes_added"] <= 0)
    return c


def load_json(p: Path) -> dict | None:
    try:
        return json.loads(p.read_text())
    except (OSError, json.JSONDecodeError):
        return None


def judge(w: Path, skill_dir: Path, judge_model: str) -> dict | None:
    (w / "judge.json").unlink(missing_ok=True)
    prompt = JUDGE_PROMPT.replace("{DIR}", str(w)).replace("{SKILL}", str(skill_dir))
    res = claude(prompt, w, JUDGE_TOOLS, judge_model, "medium", w / "log-judge.txt", add_dirs=[skill_dir], timeout=900)
    j = load_json(w / "judge.json")
    if j is not None:
        j["_cost"] = res.get("total_cost_usd", 0)
    return j


def one_run(fixture: str, i: int, run_dir: Path, plugin: Path, a: argparse.Namespace) -> dict:
    name = f"{fixture}-{i}"
    w = run_dir / name
    w.mkdir(parents=True, exist_ok=True)
    src = w / "source.md"
    shutil.copy(FIXTURES / f"{fixture}.md", src)
    shutil.copy(FIXTURES / f"{fixture}.expected.json", w / "expected.json")
    exp = json.loads((w / "expected.json").read_text())
    src_sha = sha(src)
    t0 = time.time()
    res = claude(PROMPT.format(file="source.md"), w, RUN_TOOLS, a.model, a.effort, w / "log-run.txt", plugin=plugin)
    (w / "reply.md").write_text(res.get("result", ""))
    result = {"name": name, "fixture": fixture, "kind": exp["kind"], "i": i, "seconds": round(time.time() - t0),
              "cost": res.get("total_cost_usd", 0), "turns": res.get("num_turns"),
              "mechanical": mechanical(src, src_sha, w / "after.md", w / "log-run.txt", exp)}
    after_text = (w / "after.md").read_text() if (w / "after.md").exists() else ""
    changes = sentence_changes(src.read_text(), after_text) if after_text else []
    (w / "changes.json").write_text(json.dumps(changes, ensure_ascii=False, indent=2))
    result["changes"] = changes
    if after_text:
        result["judge"] = judge(w, plugin / "skills" / "ja-slop-review", a.judge_model)
    (w / "result.json").write_text(json.dumps(result, ensure_ascii=False, indent=2))
    return result


def rejudge_one(w: Path, plugin: Path, judge_model: str) -> dict:
    result = json.loads((w / "result.json").read_text())
    if (w / "after.md").exists():
        result["judge"] = judge(w, plugin / "skills" / "ja-slop-review", judge_model)
    (w / "result.json").write_text(json.dumps(result, ensure_ascii=False, indent=2))
    return result


# ---------------------------------------------------------------------------
# 集計
# ---------------------------------------------------------------------------

def one_line(s: str, n: int = 70) -> str:
    s = s.replace("\n", " / ").replace("|", "\\|")
    return s if len(s) <= n else s[: n - 1] + "…"


def summarize(results: list[dict], repeat: int, run_dir: Path) -> tuple[str, str, bool]:
    need = math.ceil(repeat * 2 / 3)
    by_fx: dict[str, list[dict]] = defaultdict(list)
    for r in sorted(results, key=lambda r: (r["fixture"], r["i"])):
        by_fx[r["fixture"]].append(r)
    L = [f"# ja-slop-review eval: {run_dir.name}", "",
         f"安定の基準: {repeat} 回中 {need} 回以上。", ""]
    ok = True

    # 機械的な検査
    L += ["## 機械的な検査", "", "| run | PASS | skill | 同一 | 一致率 | 変更 | 読点 | 字数 | 秒 | $ |", "|---|---|---|---|---|---|---|---|---|---|"]
    for fx, rs in by_fx.items():
        for r in rs:
            m = r["mechanical"]
            ok &= bool(m.get("PASS"))
            L.append(f"| {r['name']} | {'PASS' if m.get('PASS') else 'FAIL'} | {m.get('skill_used')} | {m.get('identical')} | "
                     f"{m.get('similarity')} | {len(r.get('changes', []))} | {m.get('commas_delta')} | {m.get('chars_delta')} | "
                     f"{r.get('seconds')} | {r.get('cost', 0):.2f} |")
    gen_cost = sum(r.get("cost", 0) or 0 for r in results)
    judge_cost = sum((r.get("judge") or {}).get("_cost", 0) or 0 for r in results)
    L += ["", f"費用 (claude の報告する total_cost_usd): 生成 ${gen_cost:.2f}、判定 ${judge_cost:.2f}、計 ${gen_cost + judge_cost:.2f}", ""]

    # 欠陥
    L += ["## 欠陥ごとの検出 (AI 臭を仕込んだ文書)", "", "| 素材 | id | 規則 | 各回 | 安定 |", "|---|---|---|---|---|"]
    n_scored = n_stable = 0
    for fx, rs in by_fx.items():
        exp = json.loads((FIXTURES / f"{fx}.expected.json").read_text())
        for d in exp["defects"]:
            sts = []
            for r in rs:
                j = r.get("judge") or {}
                st = next((x.get("status") for x in j.get("defects", []) if x.get("id") == d["id"]), "?")
                sts.append(st)
            good = sum(s in d["accept"] for s in sts)
            stable = good >= need
            if not d.get("optional"):
                n_scored += 1
                n_stable += stable
            mark = ("○" if stable else "×") + (" (任意)" if d.get("optional") else "")
            L.append(f"| {fx} | {d['id']} | {d['rule']} | {' / '.join(sts)} | {mark} |")
    rate = n_stable / n_scored if n_scored else 1
    ok &= rate >= 0.8
    L += ["", f"安定検出率: {n_stable}/{n_scored} = {rate:.0%} (基準 80% 以上)", ""]

    # 残す箇所
    L += ["## 残す箇所の保持", "", "機械 = quote がそのまま残った回数。判定 = kept / reworded / changed / removed の各回。", "",
          "| 素材 | id | 規則 | 機械 | 判定 | 安定 |", "|---|---|---|---|---|---|"]
    n_keep = n_keep_ok = 0
    for fx, rs in by_fx.items():
        exp = json.loads((FIXTURES / f"{fx}.expected.json").read_text())
        for k in exp["keep"]:
            verb = sum(bool(r["mechanical"].get("keep_verbatim", {}).get(k["id"])) for r in rs)
            sts = [next((x.get("status") for x in (r.get("judge") or {}).get("keep", []) if x.get("id") == k["id"]), "?") for r in rs]
            stable = verb >= need
            n_keep += 1
            n_keep_ok += stable
            L.append(f"| {fx} | {k['id']} | {k['rule']} | {verb}/{len(rs)} | {' / '.join(sts)} | {'○' if stable else '×'} |")
    ok &= n_keep_ok == n_keep
    L += ["", f"安定保持: {n_keep_ok}/{n_keep} (基準 すべて)", ""]

    # 意味の変化と害
    harmed = sum(x.get("status") == "harmed" for r in results for x in (r.get("judge") or {}).get("defects", []))
    mc_clean = sum(bool(c.get("meaning_changed")) for r in results if r["kind"] == "clean"
                   for c in (r.get("judge") or {}).get("changes", []))
    mc_all = sum(bool(c.get("meaning_changed")) for r in results for c in (r.get("judge") or {}).get("changes", []))
    ok &= harmed == 0 and mc_clean == 0
    L += ["## 意味の変化", "", f"- 欠陥の直しで害 (harmed): {harmed} (基準 0)",
          f"- 欠陥のない文書で意味が変わった変更: {mc_clean} (基準 0)", f"- 全文書で意味が変わった変更: {mc_all}", ""]

    # 欠陥のない文書の書き換え (基準線)
    L += ["## 欠陥のない文書の書き換え (基準線)", "", "| 素材 | 各回の変更数 | 平均 | 一致率 |", "|---|---|---|---|"]
    for fx, rs in by_fx.items():
        if rs[0]["kind"] != "clean":
            continue
        ns = [len(r.get("changes", [])) for r in rs]
        sims = [str(r["mechanical"].get("similarity")) for r in rs]
        L.append(f"| {fx} | {' / '.join(map(str, ns))} | {sum(ns) / len(ns):.1f} | {' / '.join(sims)} |")
    L.append("")

    # 規則ごとの件数 (欠陥のない文書の変更と、仕込んだ文書のうち欠陥に当たらない変更)
    for title, pick in (("欠陥のない文書の変更", lambda r, c: r["kind"] == "clean"),
                        ("仕込んだ文書のうち欠陥に当たらない変更", lambda r, c: r["kind"] == "planted" and not c.get("defect"))):
        tally: Counter = Counter()
        fit: dict[str, Counter] = defaultdict(Counter)
        for r in results:
            for c in (r.get("judge") or {}).get("changes", []):
                if pick(r, c):
                    tally[c.get("rule", "?")] += 1
                    fit[c.get("rule", "?")][c.get("rule_fit", "?")] += 1
        L += [f"## 規則ごとの件数: {title}", "", "| 規則 | 件数 | fits / misread / gap / none |", "|---|---|---|"]
        for rule, n in tally.most_common():
            f = fit[rule]
            L.append(f"| {rule} | {n} | {f['fits']} / {f['misread']} / {f['gap']} / {f['none']} |")
        L.append("")

    L += [f"## 合否: {'PASS' if ok else 'FAIL'}", ""]

    # 変更の一覧
    C = [f"# 変更の一覧: {run_dir.name}", "", "changes.json と判定を合わせたもの。欠陥のない文書の変更は、すべて人の文を書き換えた箇所。", ""]
    for fx, rs in by_fx.items():
        C += [f"## {fx} ({rs[0]['kind']})", "", "| 回 | 元 | 後 | 種類 | 欠陥 | 規則 | 当てはまり | 意味 |", "|---|---|---|---|---|---|---|---|"]
        for r in rs:
            jc = {c.get("id"): c for c in (r.get("judge") or {}).get("changes", [])}
            for ch in r.get("changes", []):
                c = jc.get(ch["id"], {})
                C.append(f"| {r['i']} | {one_line(ch['before'])} | {one_line(ch['after'])} | {c.get('kind', '?')} | "
                         f"{c.get('defect') or ''} | {c.get('rule', '?')} | {c.get('rule_fit', '?')} | "
                         f"{'変わった' if c.get('meaning_changed') else ''} |")
        C.append("")
    return "\n".join(L), "\n".join(C), ok


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--fixtures", default=DEFAULT_FIXTURES)
    ap.add_argument("--repeat", type=int, default=3)
    ap.add_argument("--jobs", type=int, default=5)
    ap.add_argument("--model", default="claude-opus-5-5")
    ap.add_argument("--effort", default="high")
    ap.add_argument("--judge-model", default="claude-sonnet-5-5", help="判定者。生成 (--model) とは別のモデルにする")
    ap.add_argument("--run-label", default=time.strftime("%Y-%m-%d-%H%M%S"))
    ap.add_argument("--rejudge", default=None, help="生成を回さず、この run の出力に判定だけかけ直す。結果は --run-label に写す")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    if a.judge_model == a.model:
        sys.exit("判定者は生成と別のモデルにする (--judge-model)")
    fixtures = a.fixtures.split(",")
    for f in fixtures:
        if not (FIXTURES / f"{f}.expected.json").exists():
            sys.exit(f"{f}.expected.json がない")
    run_dir = RUNS / a.run_label
    if a.dry_run:
        for f in fixtures:
            for i in range(1, a.repeat + 1):
                print(f"would run {f}-{i}")
        n = len(fixtures) * a.repeat
        print(f"生成 {n} 回 ({a.model}, effort {a.effort}) + 判定 {n} 回 ({a.judge_model})")
        return
    if run_dir.exists():
        sys.exit(f"{run_dir} はもうある")
    plugin = make_plugin_dir()
    print(f"plugin dir: {plugin}", file=sys.stderr)
    if a.rejudge:
        shutil.copytree(RUNS / a.rejudge, run_dir, ignore=shutil.ignore_patterns("summary.md", "changes.md", "results.json"))
        dirs = sorted(d for d in run_dir.iterdir() if (d / "result.json").exists()
                      and json.loads((d / "result.json").read_text())["fixture"] in fixtures)
        with ThreadPoolExecutor(max_workers=a.jobs) as ex:
            results = list(ex.map(lambda d: rejudge_one(d, plugin, a.judge_model), dirs))
    else:
        run_dir.mkdir(parents=True)
        jobs = [(f, i) for f in fixtures for i in range(1, a.repeat + 1)]
        results = []
        with ThreadPoolExecutor(max_workers=a.jobs) as ex:
            for r in ex.map(lambda j: one_run(*j, run_dir, plugin, a), jobs):
                print(f"done {r['name']} {r['seconds']}s ${r.get('cost', 0):.2f} "
                      f"mech={'PASS' if r['mechanical'].get('PASS') else 'FAIL'} changes={len(r['changes'])}", file=sys.stderr)
                results.append(r)
    (run_dir / "results.json").write_text(json.dumps(results, ensure_ascii=False, indent=2))
    summary, changes, ok = summarize(results, a.repeat, run_dir)
    (run_dir / "summary.md").write_text(summary)
    (run_dir / "changes.md").write_text(changes)
    print(summary)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
