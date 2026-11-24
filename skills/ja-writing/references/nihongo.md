---
source: https://github.com/AnIT012/nihongo
distilled_commit: 465bb6fa183bb21f438e72a1b16291eb7cfcdf62
distilled_at: 2026-11-24
---

# nihongo 蒸留版

AI が書いた日本語の仕上げと確認をするスキル (v3.0.0、AnIT012 作、MIT)。場面ごとの書き分け (メール・チャット・お知らせ・技術文書・ES など) を 21 本の references に持ち、標準ライブラリだけで動く意味ズレ検査 CLI (`nihongo-check`) を同梱する。最初のコミットは 2026-11-17 で、1 週間で 1.0.0 から 3.0.0 まで進んだ (CHANGELOG.md)。

**この蒸留版は ja-writing の中で「補」の位置づけ**。AI 臭の判定と修正の規律は `natural-japanese` と `yomiyasu` を先に当たり、nihongo は次の 3 つの出所としてだけ引く。

1. 前の 2 本が扱わない場面の書き方 (業務の書き言葉の段・敬語・メール・お知らせ・チャット・載る場所ごとの記法)
2. 修正の歯止め (依頼の言葉で決める直す深さ、直さないもの) と、修正後に原文と照らす観点
3. 規則を足して負けた記録 (採らなかった案と勝ち負けの数)

**根拠の限界** (evaluations/README.md § 気をつけてほしいこと、evaluations/technical.md § 気をつけてほしいこと、README.md § 評価):

- 課題はすべて AI が書いた合成文で、課題も「変わってはいけない点」の一覧も作者が作った。人が書いた文での測定は無い
- 判定は作者 1 人か Claude (直す側も Claude)。1 組 4〜16 題、各 1〜2 回
- 比較相手の「推敲用に作られた別の公開スキル」の名前は書かれていない。出力と判定プロンプトは公開されていない
- 評価の数字は v2.2.0 時点。v3.0.0 で SKILL.md を 275 行から 93 行に書き直した後は測り直していない (README.md § 評価、CHANGELOG.md § 3.0.0)

引けるのは「作者の実験ではこうだった」まで。nihongo だけを根拠に `ja-slop-review` の直す箇所を増やさない。

## Contents

- まず押さえる (1〜14)
- 意味ズレ検査スクリプトの中身
- 索引テーブル
- 蒸留の範囲外

## まず押さえる

1. **構成は Lite と Full の 2 段**。Lite (`nihongo/ALWAYS.md`、約 1,200 字) を常時読み込み、Full (`nihongo/SKILL.md` 93 行 + `nihongo/references/` 21 本) は人に出す文章を書くときに読む。Full は Kernel 8 項目、判断の優先順位 (明示指示 → 会話・資料の事実 → プロフィール → 媒体の慣習 → 一般の慣習 → モデルの推定)、場面別の資料の振り分けからなる (nihongo/SKILL.md)
2. **Kernel 1: 迷ったら低い方・少ない方**。AI の文は敬語が 1 段高く、説明が 1 文多く、まとめが 1 つ多くなりやすい、とする。正式文書の型と頼まれた丁寧さは削らない。これは**新しく書くときの指針**で、修正時は `keigo.md` 末尾の「敬語を直す時は、原文の丁寧さを下げない」と `ja-slop-review` 手順 0 が先に立つ (nihongo/SKILL.md Kernel 1、nihongo/references/keigo.md)
3. **Kernel 2: 作らないものの列挙**。数字・理由・経験・感想・会話の中身・約束や申し出 (〜します、調整いたします)・人名・場所・連絡先・仕様・手順・宛先部署名。2.3.1 で、延長のお願いメールに提出の約束が足された事例から「約束」と「宛先部署名の推測」を加えた (nihongo/SKILL.md Kernel 2、CHANGELOG.md § 2.3.1)
4. **Kernel 4: 情報不足の 3 分岐**。値だけ不明なら【理由】のような空欄にして下書きを出す / 条件 (関係性・硬さ) が不明なら無難な方で書いて前提を一言添える / 中身そのもの (本人の体験・原文) が無ければ 3 つまで聞く。ただし出来事が 1 つでもあれば聞き返さずに書く (nihongo/SKILL.md Kernel 4)。値の空欄は新規執筆の話で、修正時に原文に無い空欄を作るのは `ja-slop-review` の banlist「仮置きの残り」と逆向きになる
5. **直す深さ 0〜3 を依頼の言葉で決める**。0「一字も変えないで」→ 変えない / 1「誤字だけ」→ 誤字・助詞・敬語の誤用・表記の誤りだけ / 2「自然にして」「推敲して」→ 読み手が止まる表現・語順・情報の位置まで / 3「書き直して」→ 構成から。指定の無い「直して」「見て」は 2。範囲を指定されたら (「2段落目だけ」) その外を触らない (nihongo/references/review.md § 直す深さ)
6. **修正の第一原則は直しすぎないこと**。目隠しテストで負けた文はどれも直しすぎ (口語に崩しすぎ、宣伝文の勢いを消した、敬語を普通にした) だった、とする。「自分なら別の言い方にする」は直す理由にしない。お知らせ・お詫び・行政の文・目上宛ての文は言葉をほぼ触らない。演出の言葉 (徹底的に) は仕事の文書では削るだけで別の言葉に替えない。宣伝文とエッセイでは残す (nihongo/references/review.md § 修正の原則)
7. **技術文書で修正後に照らす 6 観点**。否定・例外・条件 / 数値・単位・範囲・既定値 / 義務の強さ (「必須ではない」と「不要」、「〜する必要があります」と「〜をお願いします」は別の強さ。誰がするかも落とさない) / 主体 / 確かさ (「確認されていない」を「無い」に、「推定」を「原因」にしない) / 識別子とコード。1 つでも変わったら原文の言い方に戻す (nihongo/references/technical-writing.md § 意味を守る)。この観点は `yomiyasu` v3.2.0 が「nihongo に学んだ」として diff に取り込んでいる (yomiyasu 蒸留版 項目 29)
8. **書き言葉の段** (`register.md`)。ポートフォリオ・ES・報告書・README・会社から出す文は、依頼がくだけていても書き言葉の動詞にする (出す→表示する、止める→停止する、要る→必要)。動詞は主語で選ぶ (システムは停止する、電車は止まる)。物やデータに人の動作の比喩を使わない。調べる・見る・使うのような和語は直さない。社内チャット・Slack・友達あてには使わない (nihongo/references/register.md)。**新規執筆の規則**で、修正時に人の文へ当てて言い回しを変えないかは確かめられていない
9. **「〜し、」と「〜して」の見分け**。前の動詞を「〜しながら」に言い換えられれば「〜して」、「〜した後に」に言い換えられれば「〜し、」。「〜し、」を 3 つ以上続けない (nihongo/references/register.md § つなぎ方)
10. **敬語の線引き**。尊敬語と謙譲語を逆にしない、重ねない (おっしゃられる)、「〜させていただく」は許可や恩恵があるときだけで 1 通に何度も使わない (本人が硬い敬語を選んでいる先生・企業宛ては残す)、メールの定型は飾りではなく型なので残す (nihongo/references/keigo.md)
11. **読点は「ないと読み違える所」と「長い前置きの後」だけ**。短い文の文頭の短い語句の後と「を」の後には打たない。場面 (LINE / メール / 正式文書) で重みの段を変える。「直したのが読点だけでも直す理由になる」とする (nihongo/references/orthography.md § 読点の重みと打ち方)。**ここは `yomiyasu` v3.2.0 と `ja-slop-review` syntax-patterns.md §12 を正とする**。「とは、」を nihongo は外す側 (`trim_commas.py` の `HEAD` に `とは` を含む)、yomiyasu 3.2.0 は残す側に移した
12. **規則の文だけを足しても勝てなかった**。足そうとした 6 案 (発話意図と文末を保つ、前後のつながりを確かめる、情報の順番を確かめる など) のうち 5 案が旧版に勝てず、例文を付けた「句点と文章全体のリズム」だけが 5-2 で勝った (evaluations/README.md § ルールを足した時の比較)
13. **常時読む部分に 1 文足すと、対象外の場面で負ける**。SKILL.md に「予定・推定・可能性を確定の言い方に変えない」を足した版は、予定や推定を含む 6 題で 4 勝 0 敗 2 分けだったが、技術文書以外の 7 題で 2 勝 5 敗だったので採らなかった。代わりに「推敲の進め方」の最後に原文と照らす 1 行を置いた v14 が、19 題 × 2 回で 16 勝 12 敗 10 分け、意味の崩れが 8 から 4 に減って採用された (evaluations/technical.md § スキルを使わないAIとの比較、§ 推敲の最後に原文と照らす手順)
14. **歯止めが強すぎるとスキルなしに負ける**。技術文書を強化した直後の v10 は、スキルを使わない AI に dev 16 題で 6 勝 10 敗だった。直しすぎを避けるルールが強すぎ、直すべき硬い言い回しや形まで残したため。評価は dev (規則を直しながら使った組) と holdout-1〜3 (規則を決めた後に作った組) に分けて報告している。v11 は dev で 10 勝 6 敗、holdout-1 で 2 勝 4 敗 (evaluations/technical.md § やり方・§ スキルを使わないAIとの比較)

## 意味ズレ検査スクリプトの中身

`nihongo/scripts/` の 4 本。標準ライブラリだけで動き、出すのは「見直す候補」で、意味が変わったと決めつけないと原典自身が書く (check_meaning.py 冒頭)。**このハーネスでは原典 clone から実行しない**。読む対象として、検出の観点と除外条件を引く。

| スクリプト | すること | 主な観点・除外 |
|---|---|---|
| `check_meaning.py` | 原文と直した文を比べて候補を出す | 確かさ・強さの語 (`MODALITY`: 予定・見込み・必須・必要・推奨・任意・不要・お願い・未定 など) の増減、程度・約束の語 (`DEGREE`: 必ず・のみ・だけ・まで・以上・未満・約 など) の脱落、数値 (`NUM`: 単位つき、負の数の符号まで 1 つの値)、否定、曜日、インラインコード、発信者・組織名と公式らしさの語 (`ORG`・`AUTHORITY`) の追加、消えた中身。「予約」「契約」の「約」、「以上です」の「以上」、「いただけ」の「だけ」は `DEGREE_SKIP` で除外。「14:00」と「14時」、午前・午後の表記の違いは `norm` でそろえてから比べる |
| `revert_broken.py` | 候補が出た文だけを原文の文に戻す (最大 6 回) | `--request` で依頼文を読み、変更を頼む語 (`CHANGE`: 変更・置き換・伏せ・削除 など) と変えないでほしい語 (`KEEP`: 維持・そのまま・変えない など) で、依頼どおりの編集 (番号の伏字化、指定された日時への変更) を戻さない (`value_ok`)。依頼で足した文を「分割の片割れ」とみなして消さない (2.3.2) |
| `trim_commas.py` | 要らない読点を外す | 36 字以下の短い文で文頭 9 字以下の「〜は」「〜で」「〜から」の後にある唯一の読点と、「を」の直後の読点だけ。定型の前置き・文頭の接続詞・並び・コードと URL の中は外さない。閾値は 2026-11-18 の作者の目隠し判定 20 問で決めた (ファイル冒頭コメント) |
| `cli.py` | 上の 3 本をまとめた `nihongo-check` (`diff` / `fix` / `git`) | `git --hook` は Claude Code の PostToolUse から呼び、候補があれば終了コード 2 を返す。依頼文なしで HEAD と比べるので、意図した数値の変更でも止まる (examples/hooks/claude-code-hook.json、`cmd_git`) |

同じ役目の検査は `yomiyasu_diff.py` (約 11,600 行) のほうが広い。nihongo に固有なのは、依頼文を読んで依頼どおりの変更を候補から外す仕組み (`revert_broken.py` の `KEEP` / `CHANGE` / `value_ok`) と、その回帰テスト (`tests/test_request_*.py`)。

## 索引テーブル

| トピック | 原典パス | 一行説明 |
|---|---|---|
| Kernel と優先順位 | nihongo/SKILL.md | Kernel 8 項目、判断の優先順位 6 段、場面別の資料の振り分け、生成と推敲の進め方 |
| 常時読む短縮版 | nihongo/ALWAYS.md | 約 1,200 字の Lite。事実保持・場と形・水増し防止・ユーザー指示優先 |
| 直す深さと修正の原則 | nihongo/references/review.md | 深さ 0〜3 の表、直しすぎない原則、仕上げの点検 10 項目 |
| 技術文書 | nihongo/references/technical-writing.md | 意味を守る 6 観点、構造で読みやすくする (文書種別ごとの情報の順)、直さないもの |
| 書き言葉の段 | nihongo/references/register.md | 動詞の書き言葉化、主語に合う動詞、文の型の硬さの表、「〜し、」と「〜して」、理由の位置 |
| 敬語 | nihongo/references/keigo.md | 尊敬語・謙譲語の取り違え、二重敬語、「させていただく」、定型を残す |
| 文の組み立て | nihongo/references/craft.md | 構成と中身、文の組み立て、そろいすぎの点検、文と文のつながり (長文だけに当てる)、句点のリズム、長さと中身の量、言葉の選び方、測った目安 |
| 表記・読点 | nihongo/references/orthography.md | 補助的な語のひらがな、読点の重みと場面ごとの目安、記号と表記の細部 |
| AI っぽい癖の索引 | nihongo/references/ai-patterns.md | 始め方・終わり方・型・記号・保険・言葉・足しすぎ・そろいすぎ・整いすぎ。1 つの癖だけで AI が書いたと決めない |
| 見出し・件名 | nihongo/references/titles.md | 見出し・題名・件名・キャッチコピーの使わない型と中身 |
| 載る場所の記法 | nihongo/references/media.md | 媒体ごとの Markdown の可否など |
| メール | nihongo/references/business-email.md | ビジネス・大学宛てのメール |
| お知らせ | nihongo/references/notices.md | お知らせ・案内・お詫び・行政の文・規約 |
| チャット | nihongo/references/messaging.md | 友達・目上への LINE、Slack・社内チャット、SNS |
| その他の場面 | nihongo/references/ui-copy.md, nihongo/references/slides-and-documents.md, nihongo/references/conversation.md, nihongo/references/essays-and-promotion.md | UI 文言、スライド・議事録、会話の返事、エッセイ・宣伝文 (UI と議事録は `smarthr-design-system` と `natural-japanese` のほうが厚い) |
| 評価の記録 | evaluations/README.md | 比べ方 (目隠し、変わってはいけない点の一覧)、版ごとの結果、採らなかった案、参考文献 |
| 技術文書の評価 | evaluations/technical.md | dev と holdout の分離、スキルなしとの比較、v14 の採用経緯 |
| 評価課題 | evaluations/tasks/ | certainty・technical (dev / holdout-1〜3)・meaning・rewrite・punctuation・long・essay・everyday・general・safety。`*/checklist.md` が変わってはいけない点の一覧 |
| 意味ズレ検査 | nihongo/scripts/check_meaning.py, nihongo/scripts/revert_broken.py | 上の節を参照 |
| 変更履歴 | CHANGELOG.md | 版ごとに「何が崩れたから何を足したか」 |

## 蒸留の範囲外

- **Personal** (`~/.nihongo/profile.md` の 4 つの区分と「絶対に言わない表現」、1 行学習): `nihongo/references/make-profile.md`、`nihongo/references/personal-profile.md`、`cli.py` の `parse_profile`。本人名義の文の書き分けで、このハーネスの文書には当たらない
- **安全・なりすまし対策**: Kernel 3、`SECURITY.md`、`evaluations/tasks/safety/`
- **個人の文の場面**: `nihongo/references/entry-sheet.md`、`nihongo/references/speech.md`、`nihongo/references/translation.md`。必要なら原典を直接読む
- **導入手順と配布物**: README.md の インストール、`nihongo/WEB.md`、`pyproject.toml`、`.github/`
- **hook の例と CI の例**: `examples/hooks/`。上の表のとおり依頼文を見ずに止めるので、文書を意図して書き換える repo には向かない
- **テストの細部**: `tests/` (依頼の読み方の回帰テストだけ上で触れた)
