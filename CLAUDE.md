# CLAUDE.md — シアレ株式会社 コーポレートサイト 引き継ぎ

このファイルはセッション開始時に自動読込される。新しいセッションはまずこれを読めば状態を把握できる。

## 1. 概要
- **シアレ株式会社**（マンション運営コンサルタント）の**静的サイト**（HTML/CSS/JS、ビルド不要）。
- **本番URL（公開済み）**: https://www.siare.co.jp （HTTPS強制ON。`siare.co.jp` は www へ自動転送）
- GitHubリポジトリ: `atsushi20101010-cyber/siare`（**Public**）。ブランチ `main`。Git user: atsushi。
- ホスティング: **GitHub Pages**（無料）。`main` に push すると自動デプロイ。

## 2. ファイル構成
- `index.html` … トップページ（全セクション）
- `privacy.html` … プライバシーポリシー（`<body class="page-legal">` でヘッダーをソリッド表示）
- `css/style.css` … デザインシステム＋全レイアウト（CSS変数・BEM風・末尾に後付けセクションのCSS）
- `js/main.js` … ハンバーガー開閉／ヘッダー切替（is-scrolled）／**問い合わせフォーム送信（Web3Forms・JSON送信）**
- `images/` … hero-1〜4.jpg, ceo.png, concept-1/2.jpg, target.jpg, company.jpg(自社ビル), logo.png(透過), favicon.png, og-image.jpg ／ `会社ロゴ.png`・`堂島アクシスビル.jpg` は加工元（**未コミット・重い**）
- `CNAME` … `www.siare.co.jp`（GitHub Pages独自ドメイン。**ドメイン操作時にGitHub botが書き換える**ことあり）
- `robots.txt` / `sitemap.xml` … SEO用
- `.claude/launch.json` … プレビュー設定 ／ `.claude/serve.ps1` … PowerShell製静的サーバ

## 3. ローカルプレビュー（重要・クセあり）
- **この環境には Perl が無い**。プレビューは launch.json の **`siare` 設定＝PowerShell製 `serve.ps1`** を使う（`preview_start` で name="siare"）。
- Python は導入済み（`py` ランチャー）。Pillow/numpy も導入済み（画像最適化に使用）。ただし**MCPホストのPATHが古く** `python`/`py` 名前解決が効かない場合があるため、プレビューは serve.ps1 が確実。
- **プレビューの描画が頻繁にハングする**（`preview_screenshot` だけ30秒タイムアウト。原因はヘッドレス描画/重い画像）。**対処＝サーバを stop→start で再起動**。ページ自体は正常なので、確認は **`preview_eval` で行う**のが確実（screenshotは不安定）。
- `preview_eval` の `scrollTop` 設定と `preview_screenshot` の表示位置が**ずれる**ことがある（スクロール同期の問題）。検証は eval の数値で行う。
- **公開済みなので、確認は本番 https://www.siare.co.jp を直接見るのが最速**（要 Ctrl+F5）。

## 4. デプロイ／更新ワークフロー
- 編集 → `git add` → `git commit` → `git push`。GitHub Pages が自動ビルド（約1分）。
- **コミット規約**: 末尾に `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`。
- **注意**: 独自ドメイン操作後など、リモートに GitHub bot の `Create/Delete CNAME` コミットが入り **push が reject** されることがある → `git pull --rebase` してから push。
- CRLF警告は無視可（Windows環境）。

## 5. 重要な事実・設定値
- 会社: シアレ株式会社 ／ 代表取締役 新川 淳史 ／ 所在地: 大阪市北区堂島浜2-2-28 堂島アクシスビル4階 SYNTH
- **代表電話: 050-1785-0480**（会社概要・フッター・JSON-LDに掲載。`tel:05017850480`）
- メール: **info@siare.co.jp**（フッターに `mailto:`）
- 資本金 300万円 ／ 創業 2025年1月 ／ 設立 2026年6月 ／ 保有資格: マンション管理士・管理業務主任者・宅地建物取引士
- 顧問料: 最低月額6万円〜 ／ スポット: 長期修繕計画30万〜・規約改定9.5万〜・リプレイス支援10万〜・積立金運用設計10万〜

## 6. 問い合わせフォーム（Web3Forms）
- `index.html` の `#contact-form`。`action=https://api.web3forms.com/submit`、**main.js で JSON(UTF-8) 送信**（multipartだと日本語フィールド名が文字化けするため）。
- アクセスキー: `95aca8a2-994a-4ebf-9baf-b83a67bfbae2`（**a.shinkawa@siare.co.jp で発行**）。
- **送信先は a.shinkawa@siare.co.jp**（info@ はWeb3Formsの抑制リストで発行不可だったため。最終的に info@ へ寄せたい場合はメール転送 or FormSubmit有効化で対応）。
- スパム対策: ハニーポット `botcheck` あり。**未対応の推奨: Web3Forms側で Allowed Domains を `siare.co.jp` に制限**。

## 7. DNS / ドメイン（お名前.com 登録・GMOサーバーNS）
- レジストラ: お名前.com。**権威NSは `ns-rs1/rs2.gmoserver.jp`**（＝DNS編集はGMOサーバー側パネル。お名前のDNS設定パネルではない点に注意）。
- apex `siare.co.jp` A: `185.199.108-111.153`（GitHub Pages）。`www` CNAME → `atsushi20101010-cyber.github.io`。
- メール: MX = Google Workspace（`smtp.google.com`）。SPFは1本に統合済み `v=spf1 include:_spf.google.com ~all`。`google-site-verification` TXT あり（消さない）。
- 公開DNSのキャッシュ反映は最大1時間。真値確認は権威NSへ直接 `nslookup`。

## 8. デザイン／構成
- CSS変数（テラコッタ基調 `--color-terracotta:#D9805C` 等）、フォント: Zen Old Mincho(見出し)/Zen Kaku Gothic New(本文)/Cormorant Garamond(英)。
- レスポンシブ: base(モバイル) → `@media(min-width:768px)` → `@media(min-width:1024px)`。`--header-height:72px`。
- セクション順（index）: hero → concept → brand-story(SIARE頭字語) → value → service → flow → strength → **case(対応実績)** → pricing → target → message(代表) → company → cta → contact。ヘッダー/フッターnav: サービス/強み/実績/料金/会社概要/お問い合わせ。
- ロゴは透過PNG。ヘッダー上部(暗背景)＝CSS filterで白、スクロール後/フッター＝色切替。
- **画像は必ずWeb用に最適化**（Pillowで長辺〜1600px・JPEG q80前後）。重い画像はプレビューのハング・表示速度悪化の原因。

## 9. 未完了・今後のタスク
- [ ] Google Search Console: `sitemap.xml` 送信＋トップのインデックス登録リクエスト（プロパティ登録は済み）
- [ ] **Bing Webmaster Tools 登録**（Edge＝Bing。GSCからインポートが最速）
- [ ] Web3Forms の Allowed Domains を `siare.co.jp` に制限
- [ ] Google ビジネスプロフィール登録（ローカル検索）
- [ ] （任意）`https://siare.co.jp` 直アクセスの証明書反映確認（www は完了済み）

## 10. 将来の事業（管理組合サイト制作）
- 管理組合向け**公開型お知らせ/アーカイブサイト**を業務化する検討中。方針: **更新はシアレ代行・年数回 → 手組み静的サイト（本サイトと同方式）が最適**（ホスティング無料・高利益）。
- 料金案: 構築 LP15万〜（複数ページ/アーカイブ型は上位ティア）＋ 顧問先は月額+5,000円〜（顧問なしは1.5〜2万/月でフック化）。ドメイン実費別。**更新範囲(回数/件数/SLA)を契約に明記**。
- 成功の鍵は**標準化（テンプレ＋更新手順書）**で事務員に展開できるパッケージ化。フルカスタム受託にしないこと。

## 11. 作業の心得
- 変更後は `preview_eval` で検証（screenshotは不安定）。レイアウトは「横溢れ無し・想定の行数/カラム数」を数値で確認。
- 画像追加時は最適化を忘れない。一時スクリプトは `.claude/` に置いて使用後削除。
- push は明示依頼があった時、または「公開して」の文脈で実施。reject時は `git pull --rebase`。
