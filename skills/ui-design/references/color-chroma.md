---
tracking: review
reviewed_at: 2026-10-23
review_interval_days: 90
---
# 配色の彩度補正 — くすみ・ベージュへの偏りを外す

このスキルの生成規律 (`hallmark`) のテーマ集から配ると、ライトテーマの地色は過半数がクリーム・ベージュになる。
a11y 検査で比が足りないときも、彩度を削って通す方向に流れやすい。
配色を決めるとき・コントラストを直すときは、hallmark の `craft.md` § 2 とテーマの配色より**先に**この文書を当てる。

確度: **[原典]** hallmark clone (`distilled_commit` は `hallmark.md` の frontmatter) で確認 /
**[計算]** OKLab→sRGB 変換 (Ottosson の式) と WCAG 2.x の相対輝度で算出。`scripts/chroma-check.py` で再現できる /
**[批評]** `visual-slop-review` の web-ui.md が出典付きで挙げる tell。

## 偏りの出どころ

- **[原典] テーマ集のライト地色の過半数が暖色クリーム**。`skills/hallmark/references/themes/*.md` 50 個の `:root` の `--color-paper` (全て OKLCH) を数えると、`themes/index.json` の paper band が light のもの 31 個 (L 91.5〜99.5) のうち 17 個が H 30〜95・C 0.010 以上 (Atelier, Bloom, Broadside, Carnival, Dose, Furrow, Garden, Halftone, Hum, Loom, Newsprint, Overprint, Riso, Solstice, Specimen, Sticker, Vellum)。C 0.006 以下の白に近い地は 10 個 (Brutal, Cobalt, Coral, Grid, Ink, Piste, Refract, Sport, Studio, Wayfind)。シグナルが無いときの既定ジャンル editorial (`genres/editorial.md`、テーマ 20 個のうちライト 16) では 16 個中 10 個。テーマごとの colourway (例: Kiln の `bisque`) は数えていない。deal はプロンプトの keywords と log で 3 個に絞るので (SKILL.md Step 3)、この比はテーマ集の比で、配られる確率ではない
- **[原典] hallmark 自身も cream を生成の既定値とみなし始めた**。gate 65 (Reflex) は custom とテーマ無しのビルドで「cream 地 (L 90 以上・H 55〜105) + high-contrast serif の display + terracotta / clay の accent (H 15〜55)」を named look として落とし、`references/direction.md` § Spent は custom で cream / off-white / beige 地 + high-contrast serif + clay accent を拒む。ただしテーマが持つ場合は keywords で呼ばれたときだけ配る扱いで gate 65 の対象外 (gates.md § 5 の 65)。`ROADMAP.md` § Now は「cream や off-white の地はそれだけで生成の見た目と読まれる。custom では spent 扱い済みで、catalog は keywords 限定の素材として残すか地を塗り替えるか未決定」とする
- **[原典] 3 点揃いは減ったが、地だけの偏りは残る**。gate 65 の 3 条件を数えると、地 (L 90 以上・H 55〜105) を満たすテーマは 24 個 (白に近い Refract `oklch(98.2% 0.006 95)` を含む)、加えて accent H 15〜55 と serif 系の display を持つのは Halftone・Newsprint (slab-serif) と Solstice (high-contrast-serif) の 3 個で、high-contrast serif に限れば Solstice の 1 個 (本文は自ら "not a terracotta-on-cream template" とする)。暖色クリーム 17 個のうち accent が H 15〜55 なのは 6 個。つまり「cream + serif + terracotta に寄る」は custom では hallmark 自身の規則で止まり、テーマ集でも 3 点揃いは少ない。残るのは**テーマから配ったときに地がクリームになりやすい**偏りで、こちらは旧集計 (17 個中 8 個) より強くなった
- **[原典] accent の彩度は中彩度に寄らなくなった**。`craft.md` § 2 は accent を C 0.12〜0.22、focus を 0.18〜0.22 とする。テーマ 50 個の `--color-accent` の C は、0.16 を超えるのが 29 個、0.12 未満が 9 個 (48 個時点の中央値 0.1775。追加の Refract 0.12・Vantage 0.19 はその両側)、0.22 を超えるのが 5 個 (Sticker, Manifesto, Riso, Piste, Ultraviolet)。playful は "soft and low-chroma by default" で、Full palette / Drenched の posture なら 0.24 まで上げる (`genres/playful.md`)。地は L 92〜98・C 0.005〜0.015、ink は C 0.005〜0.014、5〜9 段の neutral は C 0.005〜0.018 で、どちらも anchor の色相へ寄せる (`craft.md` § 2)
- **[原典] 純白の扱い**。gate 7a (Floor、waive 不可) は token block の外に書いた `#000`・`#fff`・`oklch(0% …)`・`oklch(100% …)` を落とし、7b (Reflex) は surface token が純白・純黒に解決されるものを落とす (guard は stamp の `surface: absolute` と gate 40・41 の通過)。modern-minimal は `#fff` の地 (7b) と彩度 0 の neutral (22) を緩め (`genres/modern-minimal.md`)、editorial は純黒・純白の地と ink を拒む (`genres/editorial.md` § Refused here)。`craft.md` § 2 は "Never a pure absolute as a surface or an improvised value" とし、グレーを anchor へ寄せる。anchor が暖色なら地はクリームになる
- **[批評] 題材と無関係に同じ palette が選ばれることが tell**。cream/beige + serif + terracotta は「新世代の AI 既定値」として反復されている (`visual-slop-review/references/web-ui.md` § 色・グラデーション)。hallmark も gate 65 と Spent で同じ判断に立った

## 地色の決め方 (ライトテーマ)

- 既定は **C 0.006 以下の白**。色相は anchor に寄せてよい。彩度は accent と面の色で持たせる
- hallmark の gate が落とすのは彩度 0 の neutral (22) と純白・純黒 (7a/7b) だけで、C 0.003 の Ink テーマも通る。白に寄せるなら地とグレーを **C 0.005〜0.006** にする。これは gate の閾値ではなく、7a の fix の文言と `craft.md` § 2 の帯の下限に合わせた値 (テーマ集の白に近い地 10 個のうち Ink を除く 9 個がこの帯)
- `#fff` (C 0) の地を使うなら `--color-paper` などの token にだけ置き、stamp に `surface: absolute` を書いて 7b を waive する (modern-minimal は 7b が緩むので不要)。editorial (シグナルが無いときの既定 genre) は § Refused here で純白の地を拒むので、waive せず C 0.005〜0.006 の白にする。token の外に `#fff` を直書きするのは 7a (Floor) で waive できないので、必ず token を参照する
- テーマを配られて地が暖色クリーム (H 30〜95 かつ C 0.010 以上) なら、題材に紙・印刷物・食・工芸・老舗といった根拠があるときだけそのまま使い、その根拠を hallmark の Picks block (Theme 行) に 1 行で書く。根拠が書けなければ別のテーマを選ぶか、地を C 0.006 以下に戻す。custom では gate 65 と direction.md § Spent が先に止める
- 「ベージュ禁止」を別の固定既定に置き換えない。直近の生成と同じ配色なら hallmark の 3 軸 (paper / display / accent。`direction.md` § Mechanics の `axes`) のどれかを動かす

## 彩度の決め方

- 配色の前に、brief から**鮮やかさ**を 1 語で決める: 抑制 / 標準 / 鮮明。抑制は brief に落ち着き・高級・業務の長時間利用などの明示があるときだけで、無指定なら標準
- accent の C: 標準は「0.15 か、その L で sRGB が取れる最大 C の 7 割」の高い方以上。鮮明は最大 C の 9 割以上。hallmark の `craft.md` § 2 の 0.12〜0.22 の帯や playful の "soft and low-chroma by default" には縛られない (白地 4.5:1 の L で、紫・マゼンタの最大 C の 9 割は 0.22 を超える)。accent の彩度の上限は gate ではないので waiver も要らない
- 色相は brief と anchor から選ぶ。文字色にできるかどうかで色相を選ばない (青・紫への寄りは別の既定値になる)
- 主要 CTA 1 つを accent で塗るのは hallmark でも許されている (`craft.md` § 2 は accent の役目に "the primary control" を挙げる)。鮮明でセクション帯・大きな面に色を使うときは、stamp で posture を Committed / Full palette / Drenched と宣言し、その色を `--color-field` などの surface token に置く。宣言した surface の色は accent の面積に数えない (`craft.md` § 2、gate 23) ので、gate 23 を waive する必要は無い。accent token のまま 5% を超えて塗らない
- 標準以上なら、ライトテーマの画面に C 0.15 以上の色が少なくとも 1 役割 (accent か面) ある状態を確認する
- この文書に従って hallmark の Reflex gate (7b の純白の地、22 の彩度 0 のグレー) を外すときは、gates.md § 2 の書式で 1 gate 1 行の waiver を stamp に残す。例: `/* Hallmark · waive 7b · surface: absolute, 40 and 41 pass · 病院の予約票と同じ白で、受付で渡す紙と画面の見た目を揃える */`。理由はそのページの語を含む 24 文字以上で、`color-chroma に従う` のような定型や他の waiver の使い回しは却下される。Floor gate (7a、40、41 など) は waive できないので、この文書の方針でも満たす。同じ gate を 3 回続けて waive するならハウススタイルなので `design.md` に書く

## a11y を彩度でなく明度で満たす

- **比が足りないとき動かすのは L**。色相を保ち、新しい L で取れる最大近くまで C を保つ [計算: 白地で H 145・L 55% の緑は C 0.173→0 で 4.52→4.85:1 と上がる。黄・緑系で彩度が削られやすいのはこのため。同じ幅は L を 1.5% 下げる (L 53.5%・C 0.168 で 4.81:1) だけで得られ、C はほぼ保てる。赤 H 35・L 58% は C 0.20→0 で 4.71→4.28:1 と逆に下がる]。`chroma-check.py` が候補を出す
- **[計算] 白地で比を満たす最も明るい L と、そこで取れる最大 C** (sRGB。script の候補は「比を満たす中で C が最大の L」なので、紫などでは表より暗く鮮やかな値が出る):

  | 色相 (H) | 4.5:1 (本文) の L / 最大 C | 例 | 3:1 (大きい文字・非テキスト) の L / 最大 C | 例 |
  |---|---|---|---|---|
  | 赤 25 | 59.5% / 0.241 | `#ed0027` | 69.0% / 0.199 | `#ff5c58` |
  | 橙 50 | 58.0% / 0.153 | `#bf5900` | 68.5% / 0.181 | `#ee7000` |
  | 黄 95 | 56.5% / 0.116 | `#8b7400` | 66.5% / 0.137 | `#ae9200` |
  | 緑 145 | 55.0% / 0.173 | `#008a23` | 64.5% / 0.203 | `#00ab2e` |
  | 青緑 190 | 55.5% / 0.096 | `#00857f` | 65.5% / 0.113 | `#00a6a0` |
  | 青 255 | 57.0% / 0.188 | `#0075e2` | 67.0% / 0.178 | `#3d95ff` |
  | 紫 295 | 59.5% / 0.249 | `#8f4bff` | 68.5% / 0.187 | `#a47dff` |
  | マゼンタ 340 | 60.0% / 0.261 | `#da00af` | 70.0% / 0.263 | `#ff3fd0` |

- **黄 95 と青緑 190 は本文の文字色にすると C が 0.12 未満に落ちるので、面に回す**。最大彩度の明るい面 (黄 `#ffd600` など) に ink (L 18%) を載せれば 13:1 を超える [計算]。文字色は別の役割の色から取る
- **非テキストは 3:1** (WCAG 2.2 SC 1.4.11)。枠線・アイコン・フォーカスリングまで本文と同じ 4.5:1 に合わせて暗く・くすませない
- **[計算] クリーム地はそれだけで比を約 1 割削る**。白地でちょうど 4.5:1 の色は、地 `oklch(96% 0.018 80)` の上で 4.0:1 前後に落ちる。クリーム地を選ぶと文字色をさらに暗くする必要が生じ、くすみの原因が重なる
- 修正後、各色の C が修正前から 0.03 以上下がっていたら、L の調整で済まなかったかを `chroma-check.py` で確かめ直す

## 使い方

```
python3 <ui-design スキルのディレクトリ>/scripts/chroma-check.py "58 0.16 35" "#ffffff"
# ratio 4.61:1 ... fg C 0.160 / sRGB 最大 0.204
# 同じ H で比を満たし C が最大の候補: oklch(59.0% 0.207 35) #dd3800
# → C 0.16 のテラコッタは同じ比のまま C 0.207 まで上げられる
```

第 1 引数は L を動かして探す色、第 2 引数は固定する色。面の色を決めるときは面を第 1 引数、ink を第 2 引数にする。

## 範囲外

- チャートの系列色・連続/発散パレット → built-in の `dataviz`
- APCA の Lc 値 → hallmark `references/gates.md` の gate 40 (本文 4.5:1 か Lc 60、大きい文字・アイコン・focus ring・入力欄の枠 3:1 か Lc 45) と `craft.md` § 2 の Contrast。この文書は WCAG 2.x の比だけで計算している
- Display P3 など sRGB より広い色域の最大彩度。表と script は sRGB に限る

## 棚卸しの当たり先

- hallmark のテーマ集計と色の規則 → hallmark の再蒸留時に `skills/hallmark/references/themes/*.md` の `:root` の `--color-paper`・`--color-accent` (light / mid / dark の band は `themes/index.json`) を数え直し、`craft.md` § 2、`gates.md` の gate 7a・7b・22・23・65、`direction.md` § Spent、`genres/*.md` の Allowed here / Refused here、`ROADMAP.md` § Now の cream の扱いを見直す (テーマ追加や塗り替えで比率が変わる)。2026-10-29 の集計は `8f6969f` 時点 (Refract・Vantage の追加分だけ数え足した)
- cream/beige が tell とされている状況 → `visual-slop-review/references/web-ui.md` の出典
- WCAG のコントラスト定義 → https://www.w3.org/TR/WCAG22/#contrast-minimum , https://www.w3.org/TR/WCAG22/#non-text-contrast
- OKLab の変換式 → https://bottosson.github.io/posts/oklab/
