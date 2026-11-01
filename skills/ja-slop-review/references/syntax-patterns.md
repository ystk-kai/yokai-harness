---
tracking: review
reviewed_at: 2026-10-23
review_interval_days: 180
---
# Syntax patterns — detect & fix

These catch "generated-ness" deeper than vocabulary. Make each a review question.
Fix in this order: **立場 → false agency → 構造 (§2–7, 11) → 語彙 (banlist) → 記号**. Fixing only vocabulary and symbols leaves the smell.
When revising someone else's text, every fix below is bounded by the revise-mode rules in SKILL.md (no new facts, no confidence change, meaning check at the end).

## 1. False agency（無生物主語）

Fix only two kinds: **an inanimate subject given feelings or intent**, and **a human judgment written as the action of an abstract noun**.
- ✗「課題が浮き彫りになる」「文化が醸成される」→ ✓ name who did what — **only if the text or material says who**. If it doesn't, don't invent an actor; leave it or ask.
- ✗「データが課題を浮き彫りにしている」→ ✓「ログを数えると、未封じ込めの資産が 12 件あった」(the count must exist in the material)
- 大きな主語も同類: ✗「多くのエンジニアが」→ ✓ the actual scope you can back up.
- Keep: a tool's objective function (「ガイドラインがチームに変化を促す」), a paper's 「〜ことを示している」 when citing evidence, and organizations/people as subjects (「Anthropic が示した」— the actor is real).

## 2. 命題型 H2（断定見出しの押し付け）

Each heading carries a thesis → reads like a string of tiny TED talks.
- New writing: conclusion headings are fine — but don't give every heading the same shape, and never make a heading more confident than its body.
- Revising: rewrite at most 2–3 headings. A pile-up of identical thesis headings is the target, not thesis headings as such. Guides and references prefer short names (名詞句).
- ✗「○○もまた同じ方向を指している」→ ✓「○○の話」/「○○の分界」
- **比喩ラベルの見出し**: a heading or first line that is a one-word metaphor the body never uses (「〜の横」「〜係」「〜番」) → read what the section covers and build the heading from the body's words, keeping the purpose the old heading stated (e.g. 「料金を見積もる前に確かめる点」) — not just a list of the body's topics; don't swap the metaphor for another single word. If the body doesn't settle the topic, keep it. Never change the document title. Catch copy in promo headlines is out of scope.

## 3. 打ち消し・偽の対句（Not X. It's Y. / 「XではなくY」）

Three kinds, three treatments:
- **Pre-emptive denial** of a belief nobody stated (「〜すれば自動的に〜わけではない」) → delete the sentence — unless the next sentence stops making sense without it.
- **「A は B ではない。C だ」** where only C matters → join into the affirmative sentence.
- **Negation that narrows meaning**, corrects a common misreading, or warns → keep. 「件数ではなく修正時間で測る」is a real choice.
- 「Aでない。Bでもない。Cだ」: if readers are likely to assume A or B, keep the negation in one sentence; if a preceding question named both, 「どちらでもない。」is enough; if the negation only adds punch, keep just「Cだ」.
- 「A ではなく、B でもある」stays as one sentence.
- Density check: 「ではなく／だけでなく」3+ times, or 4+ sentence-final negations, in one document → suspect overuse.

## 4. フック→反転の出だし

- ✗「ChatGPTで誰でも記事が書ける。しかし——」→ ✓ 控えめに始める「最近、手で書く方が早い気がする」
- 煽り出し→逆張りのテンプレを避ける。

## 5. メタ構造宣言

- 「以下の 3 つの観点から説明します」: if the stated number matches the items, merge it into one sentence with the content; in a long explanation where it guides the reader, keep it.
- If the number doesn't match the items, don't add or drop items to fit — ask the writer.
- ✗「それぞれ順に見ていきましょう」「ここからが本題です」(no information) → delete.

## 6. ❌/✅ 比較（スライド調 bad-then-good）

- ✗ bad例→good例の対カードを並べる → ✓ 地の文で展開。(図解でも「言い換え」だけの対比は避け、関係/閾値/境界を足す)

## 7. 並列の形を中身に合わせる

- Don't manufacture 「3つのポイント」. In new writing, if 2 or 1 suffice, use that. Three parallel blocks in a row → switch form.
- When revising, don't add or remove items just to change a count.
- The reverse also applies: 3+ coordinate items buried in a long sentence → open them into a list. Decorative bullets that carry one thought → fold back into prose.

## 8. 文末の単調

- Keep one style: 敬体 (です／ます) or 常体 (だ／である) throughout; don't mix them to create variety. Technical-writing lint (`no-mix-dearu-desumasu`) flags the mix as an error.
- Vary through sentence length and construction, not by inserting 体言止め or questions as a device. No questions in technical docs.
- When revising, sentence endings alone are not a reason to edit a sentence that reads naturally.
- Don't string together sentences under ~10 characters. Evaluation-only fragments (「速い。軽い。安い。」) are ad copy — fix them.
- Other copy-style shapes in body text: a comma between modifier and a short closing noun (「丁寧な、人。」) → drop the comma and write the predicate the context settles; if none, drop just the comma (a one-off in an ad or heading stays). Transitive verbs chained with commas and no subject or object (「切るか、続けるか、決める。」) → supply them if the text states them; otherwise turn the action into a noun subject as in §12 目的語の抜け, or keep. The verb chain is not a target in essays, promo copy, scripts, or slides.

## 9. 一文圧縮（Wikipedia 調）

- 年代・人名・評価を 1 文に詰め込まない。確度の低い情報は伝聞で「およそ N 日で設計されたらしい」。

## 10. 儀式化した保険・遠い話者

- 各節末の「個人の見解ですが」を 1 記事 1〜2 回に。
- ✗「現代社会では重要だ」→ ✓「最近気になる」/「このチームでは困っている」。

## 11. 型としての構造 slop

- **体験の壮大化**: a routine experience framed as a 設計／装置／境地 (and 必殺技造語) → describe what happened at its actual size.
- **劇的な断片化**: 「シンプル。それだけ。それが本質。」— staccato fragments as a climax → one plain sentence. (This is also why §8 does not prescribe short sentences.)
- **体験→引用→抽象化** run three times in a row (anecdote, famous quote, lesson) → break the template; keep the parts that carry information.
- **全方位肯定**: 「それぞれに独自の強みがあり」— praising every option to avoid a position → say which fits when, or say plainly that you can't tell.

## 12. 読解負荷（構文）

- **二重否定**: fold into an affirmative **without flipping its truth value**. 「招かないとは言えない」=「招くことがある」, not「招かない」. Check the folded sentence against the original before keeping it.
- **係り受け**: long pre-noun modifiers → split into a following clause. 「の」at most twice in a row. Make an ambiguous dependency unique with a comma or word order.
- **間を作るだけの読点**: a comma right after a short subject / object / topic (「は」「が」「を」「も」「では」「とは」) that separates nothing (「回覧板は、木曜の朝に回します」) → remove the comma only; keep word order and predicate. Keep it after a long subject or clause, where another actor follows the topic, before an insertion, between listed items, and where removing it changes what the clause attaches to (「店長は、慌てて逃げた客を追いかけた」).
- **数値の目安 (技術文書)**: 1 文 100 字 (厳しめなら 90)、読点 1 文 3 個、漢字の連続 6 字 (`textlint-rule-preset-ja-technical-writing` の既定値)。超えたら分割・語順・かな書きを検討する目安で、AI らしさの指標ではない。固有名詞の漢字連続は除く。
- **名詞化**: verbal nouns doing the work of a verb (「〜の実施を行う」) → back to the verb. Exception: the missing-object fix in the next item.
- **目的語の抜け** (an exception to 名詞化 above): a transitive verb written without its object, with a comparison or condition phrase in between, lets an earlier noun read as the object (「設定の一覧を渡して比べさせると、Aは残りの2つの案より多く削った」— did A cut the list?). If the material names the target, write it as the object; if not, turn the action into a noun and make it the subject (「Aの修正は、Bより多かった」; not 「〜を行う」); if still unclear, ask the writer (when revising) or write the object explicitly (when writing new). Swap a 漢語 for a 和語 verb only when the object stays traceable and the meaning range stays the same (「確認する」→「見る」 widens it).
- **和語の連用形 1 語の名詞 +「の」**: the stem of a transitive verb used alone as a noun and tied to its object with 「の」(「結果の確かめ」「二つの案の比べ」) — it tends to appear when 漢語 is avoided. Write the object and the verb (「結果を確かめる」) or the settled 漢語 noun (「結果の確認」); the 漢語 noun is not the single-word swap §13 warns against. Keep compounds with a noun (資金集め), nouns from compound verbs (見直し・組み合わせ), the 「お」 form (お選び), and words settled in another sense (住民票の写し). Don't create this shape when opening 漢語 into 和語. Pairs without 「の」 that go wrong the same way (「知らせが来る」) are §13 語の組み合わせのずれ.
- **主題の掛かる範囲**: a topic 「〜は」「〜では」 reads as reaching to the end of the sentence. When the topic names a component or process (class, function, screen) and a later clause after 「〜ため、」「〜て、」 acts on a different named thing (setting, macro, file, library), check whether that clause still belongs to the topic (「ParserではJSONの深さを10までに抑えるため、MAX_DEPTHを定義して再帰を打ち切ります」— inside Parser, or a build setting?). If the material says it's another actor, put that actor at the head of the later clause. Leave sentences whose later clause already has its own subject, or that continue the topic's properties or state. If you can't confirm, leave the sentence as is — don't add a subject or location — and ask which topic it belongs to (when revising). Ask only in this shape; widening it adds precautionary questions to other documents.
- **前置きのない「〜のは、A、B、C。」**: a cleft that ends on a noun list without a predicate (「今回の改修で増えたのは、画面、帳票、通知。」). With no premise in the previous sentence or heading, move the verb back to the predicate without adding words (「今回の改修では、画面、帳票、通知が増えた」). 「重要なのは、」-type lead-ins are a banlist matter, not this one. Keep it after a set-up, in headings, closings, and slide bullets where the emphasis is chosen.
- **中身を詰め込んだ括弧**: a parenthesis holding a sentence, a list that carries the point, or a naming rule (「これを〜と呼ぶ」). Readers skip parentheses, so facts inside get missed. First move the words into the preceding sentence: the list or explanation modifies the word the parenthesis was attached to, and whoever acted becomes the subject (「確認したいのは2点(配送料の負担、返品の受付期間)です」→「確認したいのは、配送料の負担と返品の受付期間の2点です」; 「会議室を予約した(総務の木村さんが手配。利用料は無料)」→「総務の木村さんが会議室を予約した。利用料は無料だ」). Only if it won't fit, write one more sentence with the same subject, reading as a continuation, with the same ending form (「移行の手順書は書きました(#512。まだレビューを受けていません)」→「移行の手順書は #512 に書きました。まだレビューを受けていません」). Don't write a sentence that only re-picks the previous word (「対象は〜です」「例は〜もの」) — it reads choppier than the parenthesis — and don't add connectives or words that decide how the content relates to the body (「〜のため」「〜という指摘である」). Keep short parentheses with no comma or period, numbers or sources backing a claim (「検索流入が減った(71,200件、前月比 -8%)」), and asides in essays. In new writing, parenthesize only an abbreviation's full name, a short paraphrase, or a PR / commit number.
- **段落内の言い換え反復**: restating the same point, or re-summarizing right after describing → cut only the repeats that add no information. If unsure, keep.
- **評価を言い直すだけの文**: the predicate restates the evaluation the noun already carries (「書き心地がなめらかです」). If the same document gives what backs it (material, dimensions, numbers), fold the evaluation into that fact sentence; if not, don't invent it — keep the sentence and ask. Delete it only when the same evaluation appears again in the same paragraph.

## 13. 読み手が取れない言い回し

Signs: re-naming something already named, personification, word-for-word English, mismatched collocations, engineer slang, nominalized actions, metaphors whose content can't be seen.
- Test by translating back to English, or by rewriting as a plain verb sentence; if the meaning won't come through, replace with ordinary words.
- **分野の呼び名からずれた 1 語** (technical and business docs): name things the way the reader writes them in their own field, even if longer — don't settle for a short metaphor or paraphrase the writer came up with (公開エンドポイントを「入口」 is a metaphor, not a translation of "entry point"; リクエストを「要求」). For verbs like 「効く」「拾う」「響く」, write what happens (「失効が効く」→「次のリクエストから通らなくなる」). Keep accurate descriptive phrases (「トークンを発行するエンドポイント」). Watch diagram boxes and table headers — short slots invite this. The writer can't see these on rereading (it reads them with its own intent) — run the candidate scan and questions in SKILL.md step 6.
  - Two different checks: **word-for-word English** (「足すものがない」= add value, 「失効が効く」= take effect) is caught by translating back. Dictionary-equivalent nouns (要求・承認・事実・影響) and set phrases (テストが通る・キャッシュが効く・駅の入口) are not word-for-word copies — keep them, unless the reader's field writes a different name for the thing. A technical phrase counts as settled when specs and reference docs write it, not just because engineers say it. 「要求」 is wrong only where the reader writes 「リクエスト」; neither back-translation nor a word-shape scan finds this, only the field-name question does.
  - Fix by the relation, not the word: check who does what to what from the sentence and its neighbors (the content is often in the very next sentence) and write that. Swapping in another single word (a katakana word, 「〜ごと」) or a broad word that doesn't say what happens (影響する・及ぶ・支障が出る・関わる・左右する) doesn't fix it, and don't leave the broad phrase standing next to the content (「全店舗に響きます」+ 後ろの文「集計中は全店舗のレジの表示が遅くなる」→ 1 文にまとめる; with no such sentence, keep 「響きます」 and ask — not 「影響します」). If the material lacks the real name, the action, or who does it, keep the text and ask; also ask when the marked word and the neighboring sentence use different names and you can't tell they mean the same thing.
  - **英語の短い術語に当てた漢字 1 字の名詞** (version →「版」, head →「頭」, mark →「印」): write the field's settled name — 「バージョン」, 「先頭」 (start of a list), 「冒頭」 (start of a document or output), 「指摘」 (what a check or review produces), 「目印」/「マーカー」. If a neighboring sentence already names the same thing, use that name (「レビューで印をもらった箇所」 after 「担当者がコメントを付ける」 →「コメントが付いた箇所」); if what it means can't be settled from the material, keep the text and ask. This replacement is not the single-word swap forbidden above. Keep literal uses: 第 2 版・日本語版・無料版, ×印・目印・焼き印, 頭が痛い・頭に入れる.
- **語の組み合わせのずれ** (mismatched collocations): a noun–verb pair that ordinary Japanese doesn't use. It runs both ways — 和語 turned into 漢語 (「期限が終了する」→「期限が切れる」, 「消失する」「失効する」 for 「消える」「切れる」) and 漢語 or a loanword opened too far into 和語 (「通知が来る」→「知らせが来る」, 「事実の確認」→「事実の確かめ」). Test by whether you'd say the pair in everyday conversation; check every spot where a word was swapped either way. A noun made from a verb (確かめ・知らせ) counts by whether people say it in that scene, even if the dictionary has it.
- **作業用の名前・文書内の造語**: names that exist only in the material (experiment condition names, branch names, category labels from a tally) mean nothing to the reader — write what they refer to. Don't coin a name for readers to memorize (「以下『高』と呼ぶ」); if plain words do, use them, and if you must coin one, make the name tell its content (住所と支払いを 1 画面にまとめた案 →「1画面案」).
- **成り立たない比喩**: a metaphor that reads smoothly but falls apart when you extract just subject and predicate (「眠気が定規になる」), or whose verb doesn't fit the subject (「嵐がそっと耳打ちした」). In technical and business docs, write what actually happens. In essays, keep a metaphor if a reader can guess what it means, or if the next sentence explains it. If your fix comes out as 「〜がただ黙って〜していた」, keep the original instead.
- If you can't narrow it to one reading, don't guess — list the candidate readings and ask the writer.
