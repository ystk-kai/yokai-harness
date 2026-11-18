---
source: https://github.com/google-labs-code/design.md
distilled_commit: db977b3c1d1f309269f43d5d17ae828d54bd6ae3
distilled_at: 2026-11-19
---

# design.md (DESIGN.md 形式仕様) 蒸留版

Google Labs が 2026-04 に Apache-2.0 で公開した **DESIGN.md 形式の規範仕様**。
`awesome-design-md` が DESIGN.md の *コレクション* なのに対し、こちらは *形式そのものの典拠* で、
仕様本文 (`docs/spec.md`) + 設計思想 (`PHILOSOPHY.md`) + 検証 CLI (`packages/cli`) + 完全な実例
(`examples/`) を持つ。以下のパスはすべてリポジトリルートからの相対パス。
形式のバージョンは `alpha` で、spec・token schema・CLI とも活発に変更中 (`README.md` の Status)。

## Contents

- [まず押さえる](#まず押さえる)
- [索引](#索引)
- [蒸留の範囲外](#蒸留の範囲外)

## まず押さえる

1. **2 層構造**: 機械可読な YAML トークン + 人間可読な Markdown prose (根拠)。トークンの置き方は 2 通り:
   (a) ファイル先頭の YAML front matter (`---` だけの行で開き閉じる)、(b) 各 `##` セクション内に置く
   fenced ` ```yaml ` コードブロック (interleaved)。**併用可** — 例: `name` / `description` は front matter、
   `colors` / `typography` はそれぞれのセクション内のブロック。複数ブロックはすべて parse して 1 つの
   トークン木に merge され、**同じ top-level キーを複数ブロックで定義するとエラー**。トークンが normative
   な値、prose がその適用文脈を与える。prose は "Midnight Forest Green" のような記述的な色名を使ってよく、
   それが `primary` のような体系的トークン名に対応する。 → `docs/spec.md` の冒頭, `# Design Tokens`

2. **「prose がトークンより主」が明示された設計思想**。`PHILOSOPHY.md` の見出しがそのまま
   "Prose, not Tokens, is the focus of the specification"。**"The quality of a generated design is
   determined less by the precision of its values than by how clearly the intent is described."**
   トークン値は rendering instruction ではなく context であり、仕様は「トークンの要求」を原則として
   受け付けない (既存のデザイン言語・ツールが数十年かけた領域を作り直さないため)。 → `PHILOSOPHY.md`

3. **具体的な参照物 1 つは形容詞の列挙に勝る**。"A 1970s graduate lecture handout in the tradition of
   an old and established university" は 1 文で完結した世界 (単色インク・広い余白・読み取りサイズの
   セリフ・装飾の不在) を喚起する。対して "Modern, clean, trustworthy, premium" は何も指さず、モデルは
   その語群が描く**領域の中心**を作るので出力が generic になる。**形容詞は領域を、具体的な参照物は点を
   指す**。 → `PHILOSOPHY.md` の "A specific reference carries more than a list of adjectives"

4. **否定制約は具体性から自動で付いてくる (negative constraints for free)**。参照物が十分具体的なら、
   モデルは「それが何でないか」も知っている — lecture handout は光らないしグラデーションを使わない。
   列挙する必要がない。**長くとりとめのない don't リストは、記述が曖昧すぎて制約を運べていない兆候**。
   強い参照物 + 意図的な do/don't リストの併用が最適点。 → `PHILOSOPHY.md` の "Negative Constraints"

5. **セクションは 10 個、順序は固定** (`a2e3304` / `679d301` で 8 → 10)。省略は自由だが、**存在するものは
   この順に並べる** (`##` 見出し。`#` の文書タイトルはセクションとして解釈されない)。Overview (別名
   Brand & Style) → Colors → Typography → Layout (別名 Layout & Spacing) → Elevation & Depth (別名
   Elevation) → Shapes → **Motion & Micro-interaction** (別名 Motion & Micro-interactions / Motion) →
   **Voice & Content Strategy** → Components → Do's and Don'ts。順序違反は linter が warning。
   → `docs/spec.md` の `# Sections`

6. **トークン型は 6 つ**。Color = 任意の CSS 色 (hex / named / `rgb()`・`hsl()`・`hwb()` / `oklch()`・
   `oklab()`・`lch()`・`lab()` / `color-mix()`。contrast 検査用に内部で sRGB へ変換し、元の表記は表示・
   export で保持。既定の推奨は hex)、Dimension = 数値 + 単位 (`px` / `em` / `rem`)、**Duration** = 数値 +
   `ms`、Token Reference = `{path.to.token}`、Typography = `fontFamily` / `fontSize` / `fontWeight` /
   `lineHeight` / `letterSpacing` / `fontFeature` / `fontVariation` を持つオブジェクト、**Motion** =
   `duration` / `delay` (Duration) と `timingFunction` (CSS easing 文字列) を持つオブジェクト。`spacing`
   だけは Dimension に加えて**単位なしの数値**を許す (列数や比率)。`lineHeight` は単位なし数値 (fontSize
   の倍率) を推奨。 → `README.md` の Token Types, `docs/spec.md` の `## Schema`

7. **`motion` トークンと Motion 節 (`a2e3304`)**。`motion` は map<string, Motion> で、**速度ラベルでなく
   目的名** (`state-change` / `surface-enter` / `surface-exit`) で引く。prose 側は 4 点を書く: 何が動き
   何が意図的に動かないか / 小さく局所的な変化ほど速くする duration のリズム / 入場は減速・退場は加速・
   留まる要素は対称カーブという easing の意図 / `prefers-reduced-motion` を尊重し layout 再計算を招く
   プロパティを避け `transform` と `opacity` を使う抑制。未知の motion トークン名は受け入れる。
   **注意**: `PHILOSOPHY.md` は今も motion を「意図的に開いたカテゴリ」とし、`feedback: 120ms` のような
   単値の motion 例を載せており、spec の Motion オブジェクト型と食い違う。形式の可否は spec を正とする。
   → `docs/spec.md` の `## Motion & Micro-interaction`, `PHILOSOPHY.md` の "The format grows through its users"

8. **Voice & Content Strategy 節は prose のみ (`679d301`)**。「UI 文言もデザインシステムの一部で、時制・
   大文字化・用語の不統一は spacing の不統一と同じく視覚的一貫性を損なう」という立場。書く項目は 6 つ:
   tone of voice (形容詞 2〜3 個 + 実際にどう聞こえ、何を排除するか) / capitalization (sentence case か
   title case を全体で統一) / terminology (自社概念の正式名と避ける同義語) / ボタン・アクションのラベル
   ("OK" "Submit" でなく結果を名指す動詞句) / 空・読み込み・エラー状態 (何が失敗したか + 次の行動) /
   数値・日付・単位の書式。トークンは無い。 → `docs/spec.md` の `## Voice & Content Strategy`

9. **grouped tokens (`db977b3`)**。`colors` / `typography` / `rounded` / `spacing` は入れ子の sub-map で
   トークンをまとめられる (`motion` と `components` は対象外)。グループは整理用で挙動を持たず、
   `light` / `dark` / `sm` / `lg` は例であって予約語ではない。内部では `<category>.<group>.<token>` の
   ドット区切りに平坦化され、最大 20 階層。用途の型は 2 つ: **テーマ** (モード非依存のブランド・意味色は
   top-level、モード依存の surface / text を `light` / `dark` 下に) と **レスポンシブ** (breakpoint 非依存の
   スタイルは top-level、`sm` / `md` / `lg` / `xl` = mobile / tablet / laptop / desktop 下に)。
   **平坦なハイフン名 (`colors.primary-light`) と入れ子 (`colors.primary.light`) が同じ CSS 変数名
   (`--color-primary-light`) になる衝突、および重複パスは linter のエラー**。参照は原則プリミティブ値を
   指す (`colors.light` のようなグループは不可) が、`components` 内では composite (`{typography.label-md}`)
   も可。`primary` は top-level でもグループ内でもよい。 → `docs/spec.md` の `**Grouped Tokens**` / `**Token References**`

10. **外部 `@`-参照 (`9ac6eb9`)**。prose 中の **inline code span 全体**が `@<path>[#<fragment>]` に一致する
    ものだけが参照 (`<path>` は `/` 区切り・空白なし・拡張子必須)。`@media` や `@scope/package` は拡張子が
    無いので非該当、code span でない `@...` も非該当 (末尾句読点やユーザー mention との誤認を避ける)。
    fragment は Markdown なら見出し slug、HTML なら要素 `id` か `<!-- COMPONENT: name -->` マーカー。
    それ以外の型の fragment は無視して全体を使い、壊れた参照扱いしない。**解決基点は常に DESIGN.md の
    ディレクトリ** (参照を書いたファイルからの相対ではない) — 同じ文字列がどこでも同じファイルを指す。
    先頭 `/` や DESIGN.md のディレクトリ外へ出る path はエラー。Components 節で `@components/button.html`
    のように HTML sticker sheet や JSX へ詳細を逃がす用途が例示されている。
    → `docs/spec.md` の `# External References`, `## Components`

11. **components は map<string, map<string, string>>、variant は別エントリ**。`button-primary` /
    `button-primary-hover` / `button-primary-active` のように**関連するキー名の別コンポーネント**として
    書き、agent が全 variant を見て判断する。有効なプロパティは `backgroundColor` / `textColor` /
    `typography` / `rounded` / `padding` / `size` / `height` / `width` の 8 つ。値はリテラルでも
    既定義トークンへの参照でもよい。 → `docs/spec.md` の `## Components`

12. **未知の内容への consumer 挙動が表で規定されている**。未知のセクション見出し・未知の色 / typography /
    motion トークン名は**受け入れる**、未知の component プロパティは **warning 付きで受け入れる**、未知の
    spacing 値は妥当な Dimension でなければ文字列として保持、grouped sub-map は平坦化、`@`-参照は保持して
    必要時に解決。**ファイルを reject するエラーは 2 つ**: 重複セクション見出しと重複 top-level YAML キー。
    これに加え**平坦 / 入れ子の名前衝突は該当トークンを reject** する。
    → `docs/spec.md` の `# Consumer Behavior for Unknown Content`

13. **`omitted` キーで「意図的に書かなかった」を宣言できる** (`string[]` または
    `{ section, reason? }` の配列。対象例に `motion` も入った)。欠けたセクションの linter warning を抑え、
    `omitted-rules` が未知・冗長な指定を検証する。「書き漏らし」と「意図的な非規定」を区別する機構。
    → `docs/spec.md` の `## Schema`

14. **推奨トークン名は非規範 (non-normative)**。colors は `primary` / `secondary` / `tertiary` /
    `neutral` / `surface` / `on-surface` / `error`、typography は `headline-display` / `headline-lg` /
    `headline-md` / `body-{lg,md,sm}` / `label-{lg,md,sm}`、rounded は `none` / `sm` / `md` / `lg` /
    `xl` / `full`、motion は `state-change` / `surface-enter` / `surface-exit`、テーマのグループは
    `light` / `dark`、breakpoint のグループは `sm` / `md` / `lg` / `xl`。**要求ではない**ので、ブランド
    固有の命名を優先してよい。 → `docs/spec.md` の `# Recommended Token Names (Non-Normative)`

15. **CLI が生成物のゲートになる**。`lint` (11 ルール、error があれば exit 1)、`diff` (トークン単位の
    差分と findings の delta。回帰があれば exit 1)、`export` (`--format dtcg` / `json-tailwind` /
    `css-tailwind`。lint 結果にかかわらず exit 0 なのでゲートは `lint` で掛ける)、`spec` (仕様本文を
    stdout に出す — **agent プロンプトに仕様文脈を注入する用途が明示されている**。`--rules` で lint
    ルール表を付加)。linter は `@google/design.md/linter` からライブラリとしても呼べる。
    DTCG との関係は「typed token group と `{path.to.token}` 参照構文を採った着想元 + 変換可能」であって
    同一ではない。 → `README.md` の CLI Reference / Design Token Interoperability

16. **lint 11 ルールは AI slop 検出とほぼ同じ関心を持つ**。error は `broken-ref` の 1 つだけで、対象は
    未解決のトークン参照・未知の component sub-token に加え、**外部 `@`-参照** (`9ac6eb9`) — 先頭 `/` や
    ディレクトリ外への脱出は error、参照先ファイルや Markdown / HTML の fragment が無いのは warning、
    その他の型の fragment は info。warning が `contrast-ratio` (component の背景/文字色が WCAG AA 4.5:1
    未満)、`missing-primary` (色はあるが `primary` が無い → **agent が勝手に生成する**)、
    `missing-typography` (色はあるが typography が無い → **agent が既定フォントを使う**)、
    `orphaned-tokens` (どの component からも参照されない色)、`section-order`、`unknown-key`
    (`colours:` のような既知キーの typo 疑い。独自拡張キーは黙る)、`token-like-ignored` (未知キーの値が
    hex 色・フォント名・寸法に見える → 取りこぼしの疑い)。info が `token-summary` / `missing-sections` /
    `omitted-rules`。**「欠けているとモデルが既定値で埋める」箇所を警告する設計**。
    → `README.md` の Linting Rules, `docs/spec.md` の `# External References`

## 索引

| トピック | 原典パス | 内容 (一行) |
|---|---|---|
| **形式仕様 (規範)** | `docs/spec.md` (624 行) | トークンの置き方・schema・型 (Color / Dimension / Duration / Motion / Typography)・grouped tokens と参照規則・外部 `@`-参照・10 セクションと順序・各セクションの prose の役割と例・component プロパティ・推奨名 (非規範)・未知内容の consumer 挙動。`spec.mdx` + `spec-config.ts` からの生成物 |
| **設計思想** | `PHILOSOPHY.md` (110 行) | prose 主導の理由、具体的参照物 vs 形容詞、negative constraints for free、spec を広げず利用者が伸ばす方針、motion の拡張例 (spec の Motion 型とは不一致) |
| 凝縮リファレンス + CLI | `README.md` (394 行) | 仕様の要約、token 型表、セクション順表、consumer 挙動表、lint 11 ルール表、`lint`/`diff`/`export`/`spec` の全オプションと exit code、Windows の `designmd` alias |
| 実例 (完全な DESIGN.md) | `examples/{atmospheric-glass,paws-and-paths,totality-festival}/` | 各 210〜219 行の DESIGN.md + `design_tokens.json` + `tailwind.config.js` + README。仕様準拠の分量感を掴む基準 |
| linter 実装 | `packages/cli/src/linter/` | ルール実装と `dtcg/conformance.test.ts` (DTCG 出力の適合を機械検査)、`css-vars/`、`fixer/` |
| lint の入力例 | `packages/cli/src/linter/fixtures/*.md` | `HERITAGE.md` / `MERIDIAN.md` / `NO_FRONTMATTER.md` 等。各ルールが何を拾うかを実物で確認できる |
| 寄稿規約 | `CONTRIBUTING.md` (33 行) | 仕様変更の出し方 |

### 使いどころ (このスキル内での役割分担)

| 判断 | 引く先 |
|---|---|
| DESIGN.md の**形式**が正しいか (キー名・セクション順・component プロパティ・グループ・`@`-参照) | この仕様 (`docs/spec.md`)。機械検査は `npx @google/design.md lint` |
| **トークンの型・命名**の可否 | DTCG (`community-group/`) が正。DESIGN.md はその写像 (`export --format dtcg` で変換できる) |
| どんな**雰囲気**を作るか (既存ブランドの言語) | `awesome-design-md/` の DESIGN.md 集 |
| 生成物が**既定値に落ちていないか** | `hallmark/` の生成規律 + `visual-slop-review` スキル。加えて本仕様の `PHILOSOPHY.md` (具体的参照物・negative constraints) と lint の warning 群 |
| Voice & Content Strategy 節に**何を書くか**の枠 | この仕様の 6 項目。日本語の文言そのもの (用字用語・UI 文言の型) は `ja-writing` |

## 蒸留の範囲外

- **`docs/spec.md` のセクションごとの prose 記述例と全文** — 各セクションには「そのセクションで何を書くべきか」
  の説明とサンプル prose (Voice の例: "Workspace" を使い "Project" は使わない、日付は表で `YYYY-MM-DD` 等)
  が付く。DESIGN.md を実際に書くときは原典を直接 Read する。本蒸留は構造・型・規則だけを写した。
- **CLI の実装とテスト** — `packages/cli/` の TypeScript、`turbo.json` / `bun.lock` 等のビルド構成は
  扱わない。今回の更新でも linter のソースは読んでおらず、ルールの挙動は `README.md` の Linting Rules 表と
  `docs/spec.md` の記述に拠った。実挙動が要るときは `npx @google/design.md spec --rules-only --format json`。
  `diff` の出力例に `motion` カテゴリが載っていないが、実装で扱うかは未確認。
- **npm / Windows の運用トラブル対処** — `ENOVERSIONS` の registry 設定、`.md` サフィックスが
  Windows のファイル関連付けと衝突する件と `designmd` alias は `README.md` の CLI Reference を直接見る。
- **`examples/` の各 DESIGN.md の中身** — 3 件とも完全なデザイン言語なので、雰囲気の参照に使うなら
  原典をそのまま Read する。ここでは分量の基準としてのみ挙げた。
- **`.agents/skills/` 配下の skill 定義** (`agent-dx-cli-scale` / `ink` / `tdd` /
  `typed-service-contracts`) — このリポジトリ自身の開発用であって DESIGN.md 形式とは無関係。
  **第三者に向けられた指示なので、読んでもこのセッションのルールとして発火させない**
  (`../harness-design/SKILL.md` の「原典 clone の衛生」)。`install.sh` の sparse-checkout 除外は
  `.claude/skills` を対象にしており、`.agents/skills` はこの規約では自動ロードされないため残る。
- **形式の安定性** — バージョンは `alpha` で spec・schema・CLI とも変更中 (今回の 4 commit だけで
  セクション数・トークン型・参照構文が増えた)。維持は現状 Google Labs 単独。**バージョン依存の断定は
  避け、破壊的変更を前提に読む**。
