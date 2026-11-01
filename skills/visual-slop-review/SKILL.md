---
name: visual-slop-review
description: Review and fix "AI slop" in visual design — web UI, landing pages, slides, diagrams, and AI-generated images that look default-AI (purple-blue gradients, Inter-everywhere, identical feature-card grids, glassmorphism, emoji icons, uniform bullet rhythm, Midjourney default look). Use when designing or reviewing UI / pages / decks / figures / generated images, when asked to make a design "less AI-ish / AIっぽくない", or before shipping any AI-assisted visual artifact.
---

# visual-slop-review: AI slop review for visual design

Design slop is the statistical average of the training corpus: safe, symmetric, purple, interchangeable. No single tell proves anything — several co-occurring tells mark a design as *unintended*. The knowledge base is self-contained in `references/` (sources cited inline; measured research distinguished from designer folklore).

The cardinal rule (shared with `ja-slop-review`): **breaking uniformity is a means, not a goal.** Don't swap the AI template for an "anti-AI template" — every visual decision should trace to content, brand, or audience. And fixing 記号 (purple gradients, Inter) without fixing 構造 (meaningless hierarchy, decoration without purpose) leaves the design just as hollow.

## When not to run this

Over-triggering costs more than under-triggering: 動いている UI に理由のない見た目の変更を入れるのは
退行で、「AI っぽい」判定を誤った文脈に当てると設計意図を壊す。Skip when:

- **Functional-only work** — バグ修正、ロジック変更、テスト、a11y 欠陥の修正。見た目を触らない変更に配色論を持ち込まない
- **The user asked something else about the same screen** — 挙動・パフォーマンス・文言・実装方針
- **Throwaway artifacts** — デバッグ用の図、自分用のスケッチ、社内の一時画面
- **The brand guide or design system already decides it** — 適合が要求なら、それに反する提案はしない (Process 1 と同旨)。トークンで決まっている色・書体を「AI っぽい」理由で変えない
- **Charts as such** — チャート・凡例・軸の設計は別スキル (`dataviz`) の領域。ここで見るのは周辺のレイアウトとタイポだけ
- **The user already declined** — 「今の見た目でいい」と言われた後の同一画面

**Run at most once per artifact per conversation.** 一度通した画面に後続ターンで tell 探しを重ねない —
尽きた後の追加指摘は、根拠のない差分に落ちる。

**A caveat is the tell** — 「これは LP 向けの基準だが、業務 UI にも役立つかも」と前置きしたくなった
時点で、その指摘は当たっていない (`references/` の抽出元は LP / マーケティングサイト中心)。

## Process (run in order)

1. **Identify the artifact type and its budget** — web UI / slide deck / diagram / image, plus the governing brand or design system. If a brand guide or design system exists, conformance to it outranks every technique below.
2. **Scan the tell catalogue for the type**:
   - Web UI: `references/web-ui.md` (color/gradient, typography, layout, motion, UI copy)
   - Slides & diagrams: `references/slides-diagrams.md` (uniform bullets, rigid layout, 図の文法エラー)
   - Images & illustration: `references/images.md` (durable vs dated tells — anatomy tells are decaying, physics tells persist)
3. **Separate 記号 from 構造** — list symbol-level fixes (palette, fonts, icons) and structure-level fixes (hierarchy matching importance, relationships made explicit, content-driven layout) independently. Both are required.
4. **Apply `references/prescriptions.md`** — constraints before generation (tokens, negative constraints, WCAG), content-connected decisions during design, separated evaluation after (5-second / first-click / one-variable comparison).
5. **Hand text to the sibling skill** — UI copy, slide prose, and Japanese body text go through `ja-slop-review`; the two skills catch the same slop from the visual and verbal sides.

## Quick checklist

- [ ] Palette/fonts chosen for a reason traceable to brand or content — not indigo/purple-blue gradient, cream-beige + terracotta (`#D97757`), near-black + a single acid-green / vermilion accent, tinted near-black (`#0B0B0B` / `#111`), or Inter-by-default. Text contrast ≥ 4.5:1 (3:1 for large text)
- [ ] Real typographic hierarchy (role-based pairing, size + weight + spacing), not one family with weight changes; no single accented word in the headline (serif italic, bold, or another color), no monospace or tiny-uppercase eyebrow labels by default; body line length under ~80 characters
- [ ] No identical icon-tile feature-card grids, badge-pill or pill-button reflexes, numbered "01/02/03" section labels that encode no real order, cardocalypse, broadsheet look (hairline rules, zero radius, dense columns) by default, template chrome (`A · B · C` meta strings, `WORD — fragment` labels, a trailing `→` on links and buttons), or uniform radius/shadow everywhere; layout derived from actual content, visual weight matches importance
- [ ] Icons: one family, adopted for a reason; no emoji-as-icons; ✨ never means "AI" without a label
- [ ] Motion explains state, continuity, or attention — otherwise deleted
- [ ] Slides: type/color/icons unified across the deck, layout varies only at meaningful transitions; bullet rhythm broken on purpose
- [ ] Diagrams: one relationship type chosen (parallel / causal / sequence / comparison); every arrow and label verified; built as editable vector, not a single raster
- [ ] Images: default AI look actively steered away (art-direction prompt + references); no Japanese text baked in; light/shadow/reflection consistent
- [ ] Symbol fixes accompanied by structure fixes — if only the colors changed, it is still slop

## 鮮度

この知識ベースは出所リポジトリの clone を持たない自作の調査資料なので、SHA ではなく日付で棚卸しする。各 `references/*.md` の frontmatter が `tracking: review` + `reviewed_at` + `review_interval_days` を持ち (`images.md` / `web-ui.md` は 90 日 — 生成モデルの世代と配色トレンドに依存するため、他は 180 日)、`/yokai-refs-update` が期限切れを `REVIEW` として報告する。とくに `images.md` の「陳腐化」ラベル付き tell は世代交代で無効化されるので、棚卸しのたびに持続性ラベルを見直す。
