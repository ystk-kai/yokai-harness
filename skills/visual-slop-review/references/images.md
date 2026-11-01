---
tracking: review
reviewed_at: 2026-10-13
review_interval_days: 90
---
# AI 画像・イラストの tell — 陳腐化と持続の区別つき

モデル改善で消える tell と構造的に残る tell を区別する。2023 年頃の目視 tell (指の本数など) だけで判定すると false negative を量産する。英語圏のガイドは「見た目」から「来歴 (provenance)」へ軸足を移している。

## 判定の優先順位 (メタ助言)

1. **provenance を先に見る** — C2PA / SynthID 等の来歴情報を目視より先に確認する。2026-05 に OpenAI も C2PA 準拠と SynthID 埋め込みを表明した (検証ツールは自社生成物のみ対象)。C2PA はメタデータなので剥がせる — 来歴情報の不在は実写の証拠にならない
2. 目視 tell は単独で断定せず、複数の合致で判断する
3. 「完璧な手」「正しい綴りの看板」は実写の証拠にならない (中立情報として扱う)

## tell 一覧 (持続性ラベル付き)

| tell | 持続性 | 内容 |
|---|---|---|
| 解剖学的破綻 (手指・歯・目・四肢) | **陳腐化** | 指の過不足・融合、重なる歯、丸くない瞳孔、人物間の身体比率差。2025-26 モデルでほぼ解消 (2026 年の上位モデルは手を破綻なく描き、画像内テキストも 90% 台半ばの精度、と felloai 2026-09 版)。CHI 2025 の artifact 分類の一項目 |
| 英語テキストの崩れ | **陳腐化** | 最新モデルはほぼ正しく綴る。ただし長い語句の一貫性には限界が残る (EMNLP 2025 STRICT) |
| **日本語 (漢字) の崩れ** | **弱まりつつ持続** | 学習データ不足と画数の多さによる構造的問題。GPT Image 2 (2026-04) 以降、常用漢字の短い語句 (目安 20 字未満) は読める水準になった。残るのは複合語の一部の画の誤り、希少な漢字、長文、ふりがな等の小さい文字 (潰れる)。OpenAI の公式ガイドも文字の正確な配置と鮮明さを依然として制約に挙げる。短い見出しが正しいことは実写・人手の証拠にならず、本文・注記・小さい文字で判定する |
| waxy skin・過剰シネマティック | 部分的に陳腐化 | 毛穴のない glossy skin、日常シーンの映画ポスター調ライティング。スタイルを抑えた生成は人間の検知を回避できる (作為的に外せる) |
| **光源・影・反射の物理破綻** | **持続** | 影の角度と光源の不一致、鏡・水面・眼鏡・目 (catchlight) の反射内容の矛盾。CVPR 2024 が生成モデルの projective geometry の系統的破綻を実証 |
| **透視・奥行き・幾何の崩れ** | **持続** | 消失点に収束しない直線、行き止まりの階段、不可能な前後関係・縮尺 |
| 機能しない物体・不自然な操作 | 持続気味 | 成立しない留め具、物にめり込む手、衣服に融合するストラップ。「実際に使えるか」で見る |
| 個数・属性・位置関係の取り違え | 持続気味 | 指定数と合わない、色・材質が別物体へ移る、左右逆転。GenEval で spatial relations / attribute binding は継続的弱点 |
| 反復・クローン現象 | 弱まりつつ観察 | 群衆の顔が全員似る、煉瓦・格子・芝の stamp 状反復と規則の突然の変化、境界の smudge/halo・局所的な解像度差 |
| 社会文化・歴史的文脈の矛盾 | 持続 | 場所や時代に合わない制服・旗・標識・慣習。「視覚的に自然だがその社会では不自然」 |
| Midjourney デフォルトルック | 美的マーカーとして持続 | hyper-saturated・glossy・dreamy な「algorithmically-pleasing style」への収束。スタイル参照で外せるため不在は証拠にならない |
| "visual elevator music" への収束 | 背景知識 | 人間を介さない image→caption→image 反復は lighthouse・豪華な室内・夜景など 12 種の安全で商業的な motif に収束した (Patterns 誌)。stock 的構図の均質性の実証 |
| Corporate Memphis 調 | AI 固有ではない | フラット原色・長い手足のイラスト。起源は人間 (2017 年 Facebook "Alegria")。AI が統計平均に回帰するとこの種のジェネリック調に収束しやすい、という文脈で登場 |

## 生成時の処方 (詳細は prescriptions.md)

- デフォルトルックのまま出さない: prompt を composition / lighting / materials / mood / lens / imperfections に分解し、権利を持つ参照画像 1-3 枚と brand color を渡す (art direction として扱う)
- 画像内に日本語テキストを焼き込まない。テキストはレイヤーで載せる
- 光源を 1 つ決めて指示し、影・反射の一貫性を 100% 表示で確認、採用後は手・文字・境界を手修正する
- 「それっぽい装飾イラスト」より先に、実写・実プロダクトのスクショ・実データの図で置き換えられないか問う

## 出典

- https://arxiv.org/abs/2502.11989 (CHI 2025: photorealism/artifact の分類)
- https://openaccess.thecvf.com/content/CVPR2024/html/Sarkar_Shadows_Dont_Lie_and_Lines_Cant_Bend_Generative_Models_dont_CVPR_2024_paper.html (CVPR 2024: 影と直線)
- https://aclanthology.org/2025.emnlp-main.1070/ (EMNLP 2025 STRICT: 画像内テキスト)
- https://proceedings.neurips.cc/paper_files/paper/2023/hash/a3bf71c7c63f0c3bcb7ff67c67b1e7b1-Abstract-Datasets_and_Benchmarks.html (NeurIPS 2023 GenEval)
- https://openaccess.thecvf.com/content/ICCV2025W/APAI/papers/Sharma_Explainable_AI-Generated_Image_Forensics_A_Low-Resolution_Perspective_with_Novel_Artifact_ICCVW_2025_paper.pdf (テクスチャ反復)
- https://pmc.ncbi.nlm.nih.gov/articles/PMC12827715/ (Patterns: 生成ループの motif 収束)
- https://insight.kellogg.northwestern.edu/article/ai-photos-identification (目視 tell の 5 分類: 解剖・スタイル・機能・物理・社会文化。provenance には触れない)
- https://felloai.com/how-to-tell-if-a-photo-is-ai-generated/ (provenance-first。2026-09 更新)
- https://thenextweb.com/news/openai-c2pa-synthid-ai-image-detection-watermark (OpenAI の C2PA / SynthID 採用、2026-05)
- https://roblaughter.medium.com/is-that-image-ai-here-are-14-telltale-signs-to-look-for-d40e5cff2d0a / https://apnews.com/article/one-tech-tip-spotting-deepfakes-ai-8f7403c7e5a738488d74cf2326382d8c
- https://adobe.design/ideas/creative-direction-the-secret-to-great-ai-images (art direction)
- https://en.wikipedia.org/wiki/Corporate_Memphis
- 日本語 (漢字崩れ): https://www.theaiventure.com/ai-image-generation-text-garbled/ / https://zenn.dev/satofun/articles/8fa0283ccd4e74 / https://aifromjapan.com/chatgpt-images-2-0-japan-review/ (GPT Image 2 の実地検証、2026-07 更新) / https://developers.openai.com/api/docs/guides/image-generation (Limitations 節)

## 棚卸しの当たり先

期限が来たら、モデル世代で動くこの 4 点だけ再検証する。光源・透視・社会文化の tell は機構に根ざすので、反証研究が出ない限り据え置く。

1. 日本語 (漢字) の崩れ — 主要モデル (GPT Image / Nano Banana / Seedream 等) の新世代で長文・小さい文字が通るか。OpenAI 公式ガイドの Limitations 節の文言
2. 手・英語テキストの精度の数値 — felloai の更新版
3. provenance の普及範囲 — C2PA / SynthID の採用社と検証ツールの対象範囲
4. waxy skin・過剰シネマティック — 新世代で既定ルックが変わったか
