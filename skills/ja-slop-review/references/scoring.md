---
tracking: review
reviewed_at: 2026-07-12
review_interval_days: 180
---
# Scoring — 5 axes (diagnostic, not a gate)

Rate each axis 1–10. Total below **35/50 → rewrite** when you are the writer; when revising someone else's text it means "fix the low axes where they show", never a wholesale rewrite (revise-mode rules in SKILL.md). At 35+ you may still ship, but **fix any critical syntax slop** (false agency, propositional-heading pile-up, empty false contrast) regardless of score. Use the score to find *where* to work, not to pass/fail mechanically.

| 軸 | 問い | 低い (slop) | 高い |
|----|------|------------|------|
| 立場 (position) | 反証可能な主張があるか | 両論併記・ヘッジで逃げる | 根拠を置いて言い切る |
| リズム (rhythm) | 文長・文末・段落に変化があるか | 全文が同じ長さ・同じ語尾 | 短文と長文、語尾が混ざる |
| 主体性 (agency) | 誰がやったか明示か | 無生物主語・大きな主語 | 行為主体が具体 |
| 具体性 (concreteness) | 固有名・数値・例があるか | 抽象語の連発 | 名前・数字・実例で支える |
| 削減 (reduction) | 削れる語を削ったか | フィラー・装飾・前置きが残る | 端的、無駄がない |

## 採点のコツ

- **立場 ≠ 無根拠な断言。** 望ましいのは「根拠を置いたうえで、判断を曖昧にしない」。根拠なしの「非常に有効」は立場ではなく slop。
- リズムは「声に出して読む」で測る。息が続かない/広告に聞こえる/誰でも言える文は減点。
- 主体性は「この文の主語は判断や意志を持てるか」で見る。「データが示す」「課題が浮き彫りになる」は減点。
- 具体性は段落あたり最低 1 つの固有名・数値・例を目安に。ただし具体は材料（原文・依頼・提供資料・会話で示された事実）から取る。材料に無い数値や例を足して点を上げない — 修正時なら空白のまま書き手に聞く。
- 削減は「この一文を消して意味が変わるか」。変わらないなら消す。

## 例（簡易採点）

- ✗「近年、セキュリティの重要性が高まっており、適切な対策が求められています。」→ 立場2 リズム3 主体性2 具体性1 削減2 = 10/50 → 全面書き直し。
- ✓「公開 API に過大な IAM 権限が付いた状態は、画像処理ライブラリ 1 個の欠陥でも本番停止につながる。だから到達可能性と権限を先に削る。」→ 立場8 リズム7 主体性7 具体性8 削減8 = 38/50。
