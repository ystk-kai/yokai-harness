---
name: ja-slop-review
description: Review and rewrite Japanese (and JP-EN mixed) prose to remove "AI slop" — over-smooth uniform tone, generic buzzwords, weak agency, ritual hedging, false contrasts, propositional headings, and other generated-text tells. Use when writing, editing, reviewing, or scoring Japanese articles, memos, briefings, docs, release notes, social posts, or public-facing copy, or when asked to make text "less AI-ish / 人間が書いたように".
---

# ja-slop-review: AI slop review for Japanese prose

AI-slop prose is surface-polished but hollow and uniform. Detectors are unreliable (human raters do no better than chance), so this skill is a manual review/rewrite method, not a detector. The knowledge base is self-contained in `references/`. Method adapted from `iKora128/stop-ai-slop-jp`. For visual artifacts (web UI, slides, diagrams, images), use the sibling skill `visual-slop-review`; this skill covers the prose. To trace a rule back to its source (stop-ai-slop-jp, natural-japanese, yomiyasu, textlint rule sets, style guides), use the reference skill `ja-writing`; this skill stays the review/rewrite method.

The cardinal rule: **edge (variation, bluntness, a stance) is a means to break uniformity, not a goal.** Don't trade AI-uniform for an "anti-AI template". And always filter techniques by document type (a security briefing is not a personal blog).

## First principle — suspect the absent writer (書き手の不在)

The root cause of "AI smell" is the **absent writer**: no one is behind the text taking a position. Before and after writing, answer three questions (大原則, from stop-ai-slop-jp):

1. 自分は何を「○○だ」と引き受けているか（取っている立場）
2. 反証可能な具体的主張があるか
3. 同じテーマの平均的な記事と何が違うか

If you can't answer these, vocabulary/symbol fixes won't help — restore the author first. This is the highest-leverage move, especially for personal/opinion writing. The 3 questions are the front-loaded 立場/具体 axes of the full score; if they conflict with the full 5-axis result, the full score wins. In **formal** docs "the writer" = the organization's position — show humanity through concrete facts/numbers, not first person or snark, and never fabricate experience to fill the gap.

**Quick path (light use):** short pieces or drafts → answer the 3 questions, then scan Tier-1 banlist + false agency + false contrast (catches most slop in minutes). Anything published, formal, or high-stakes → run the full 6-step process below.

## When not to run this

Over-triggering costs more than under-triggering here: an unrequested rewrite of prose the user is
already happy with reads as noise, and applying 「AI っぽさ」 criteria to the wrong genre makes the
text worse. Skip when:

- **Code, config, logs, commit messages, CLI/API reference output** — mechanical registers where uniformity is correct. Markdown 整形や章構成それ自体も対象外 (別スキルの領域)
- **The user asked something else about the same text** — 事実確認・要約・翻訳・長さ調整。文体には触らない
- **The text is not the deliverable** — 思考メモ、下書きの箇条書き、会話中の即答
- **Casual conversation and short replies** — 数行のやり取りに 5 軸採点をかけない
- **Fixed-form documents** — 法務・規制・監査で文言が定められているもの。ムラは違反になる
- **The user already declined** — 「そのままでいい」「急ぎでいい」と言われた後の同一文書

**Run at most once per artifact per conversation.** 一度通した文章に後続ターンで再採点を重ねない —
指摘が尽きた後の追加指摘は、根拠のない言い換えに落ちる。ユーザーが改稿を依頼したときは当然もう一度回す。

**A caveat is the tell** — 「これは <genre> 向けの基準だが、たぶん役に立つ」と前置きしたくなった
時点で、その文書は対象外。

## Process (run in order)

0. **Decide the mode: writing new, or revising existing text.** Revising (someone's draft, a published doc, text the user pasted) adds hard limits that override everything below:
   - Don't add facts, numbers, examples, causes, or opinions that aren't in the material (the original, the request, provided documents, or facts stated in this conversation). Your own or another AI's earlier output and general knowledge are not material.
   - Don't change confidence in either direction (no hardening a hedge, no softening an assertion), and don't add a summary section. Permission (〜してよい), ability (〜できる), obligation (〜しなければならない), and guarantee (必ず〜する / 保証する) count as confidence too. Don't swap one for another or flatten it into a plain statement (「変更してよい」→「変更できる」, 「含めてよい」→「含める」), don't drop 「〜場合がある」 to assert, and don't add 「必ず」「保証する」 — in specs and design docs these differences are the spec. Rephrasing within the same kind (「〜することができる」→「〜できる」) is fine.
   - Don't write the revision history into the text: no 「第1版では〜としていた」, and no version number, revision date, or 「指摘を反映」 note added at the top. The reader never saw the earlier version.
   - Don't reword what the reader already understands just to suit your taste (「気軽に試せます」→「簡単に試せます」, 「お知らせいたします」→「お知らせします」). Phrases the reader can't parse (syntax-patterns.md §13) do get fixed, even when no banlist entry covers them.
   - Where a fix would need information the material lacks, leave the original wording and ask instead of inventing. Questions go in the reply after the revised text (「書き手に確かめたい点」), never inside it: the revised text must be usable as is. Ask at most 3, only those whose answer would change the wording of the text (a fact, number, or source behind a claim; who does what; what a term or 指示語 refers to). Don't ask for elaboration the original never promised, or whether to cut something you chose to keep. If more qualify, add 「ほかに N か所」.
1. **Decide the document type** — it sets how much variation / bluntness is allowed. See `references/document-types.md`.
2. **Score 5 axes** (立場・リズム・主体性・具体性・削減), 1–10 each. Below 35/50 → rewrite when writing new; when revising, fix the low axes locally. At 35+ still fix any critical syntax slop. See `references/scoring.md`.
3. **Check syntax patterns**, fixing in this order: 立場 → false agency → 構造 → 語彙 → 記号. Vocabulary and symbol fixes alone leave the smell. Covers false agency, thesis headings, negation / false contrast, meta announcements, parallel shapes, sentence endings, template structures, reading-load syntax, and phrases readers can't parse. See `references/syntax-patterns.md`.
4. **Scan the banlist** (3 tiers: always-ban / avoid-by-default, judged by frequency / context-OK). See `references/banlist.md`.
5. **Keep deliberate ムラ** within what the doc type allows — when writing new. When revising, variance alone is not a reason to edit. See `references/variance.md`.
6. **Rewrite**, then re-check 削減 (cut filler) and 具体性 (names/numbers/examples from the material). Study `references/rewrite-examples.md` — including the over-corrected examples. For technical docs, check names and verbs yourself — rereading won't catch them (you read with your own intent), so list candidates mechanically first: machine-as-actor verbs (拾う・引く・通る・効く・響く・足す) and place-metaphor nouns (入口・受け口・口・〜先), headings / tables / diagram labels included; dictionary-translation nouns (要求・承認・事実) go through question (a) too. Ask two separate questions: (a) is the noun the name the reader's field writes in its own specs and procedures? If not, rewrite to the field's name. (b) does the verb alone tell what happens? If not, write what happens. Mapping a phrase word for word back to English (足すものがない = add value) only helps spot word-by-word calques; it is not a test for nouns (syntax-patterns.md §13). Re-run after each rewrite; new ones creep in.
7. **Meaning check (revising).** Compare every changed sentence with the original on four points: claim, weight, strength of assertion, and the sentence's job (fact / opinion / request or rule / metaphor / irony / hypothesis or prediction / quote or hearsay — hearsay must not become assertion, opinion must not become fact). If any point changed, restore the original sentence rather than patching the rewrite. Also check that no fact or number appears that the material doesn't contain, and that these didn't shift: approximation marks on numbers (「約120人」→「120人」, 「以上」⇔「超」), one-of vs. all (「AまたはB」⇔「AとBの両方」), and correlation hardened into causation (「関連がある」→「原因になる」). Check too that no person or role the original lacks (担当者・管理者, a team, 「〜さん」, a pronoun) was added as subject or as the one to notify or ask (「容量が一割を切ったら知らせる」→「…保守担当者に知らせる」); if neither the original, the material, nor the request names them, go back to the original wording.

## Quick checklist

- [ ] Mode decided; if revising, nothing added beyond the material and confidence unchanged.
- [ ] Document type identified; bluntness/variation budget set accordingly.
- [ ] Fixed in order: stance → false agency → structure → vocabulary → symbols.
- [ ] No always-ban items (装飾絵文字 / 説明文の全角ダッシュ / `**` residue / 根拠なし強評価).
- [ ] No inanimate subject given feelings or intent; no human judgment written as an abstract noun's action (tools and cited papers may keep their subjects).
- [ ] No pre-emptive denials / empty "XではなくY" / identical thesis headings in a row / content-free meta openers.
- [ ] One style (敬体 or 常体) throughout; variety comes from length and construction, not inserted questions or fragments.
- [ ] Double negatives folded without flipping truth; long modifiers and nominalizations opened up.
- [ ] Every key claim is anchored to a name / number / example from the material; a stance is taken with a stated basis (≠ unfounded assertion).
- [ ] 5-axis self-score ≥ 35/50 and no critical syntax slop remains.
- [ ] If revising: meaning check passed on every changed sentence.
- [ ] If revising: no questions or 【要確認】 marks inside the revised text; at most 3 questions after it.

## 鮮度

この知識ベースは出所リポジトリの clone を持たない自作の調査資料なので、SHA ではなく日付で棚卸しする。各 `references/*.md` の frontmatter が `tracking: review` + `reviewed_at` + `review_interval_days` (180 日) を持ち、`/yokai-refs-update` が期限切れを `REVIEW` として報告する。棚卸しでは出典 URL の生存と、記述が前提にしている流行・モデル世代の変化を確認する。

手法の出所 `iKora128/stop-ai-slop-jp` は 0.1.1 (`e09d327`、2026-06) から更新が無く、規則は取り込み終えたので蒸留版と clone を持たない。原典の規則とこのスキルの対応は `ja-writing/MAPPING.md` に `e09d327` 時点の記録として残してある。このスキルを直したら MAPPING.md も合わせて直す。
