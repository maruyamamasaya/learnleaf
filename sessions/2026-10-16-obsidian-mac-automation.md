# 開発メモのMac自動保存

- Obsidianの登録JSONと実ファイルを照合し、原本を `/Users/maruyamasusumuya/Library/Mobile Documents/iCloud~md~obsidian/Documents/Learnleaf` と確認。`wiki/official/20261005-093655.md`を形式参照。Vault全体を検索し10/5〜10/13の保存を確認、10/14・10/15はMacに未反映だった。
- ChatGPTチャット `6ac26cd1-590c-83ee-a485-a15a31196564` をread_threadで取得。10/14・10/15の実際の出力を原文の事実・課題・提案の区分を維持して保存。新規ファイルは `wiki/official/20261016-090304.md`（対象10/14）と `20261016-090305.md`（対象10/15）。Frontmatter、対象日、元URL、元メッセージID、本文を再読し保存内容と全文一致を確認。重複確認を再実行し追加作成なし。
- Macのautomations設定・ローカル管理DB・LaunchAgentsに同等処理なし。従来のheartbeat方式を再利用してMac専用 `obsidian-mac` / 「開発メモをObsidianへ保存（Mac）」を作成、ACTIVEを設定と管理DBで再確認。毎日09:15 JST目安、最初の実行予定は2026-10-16 09:18:39 JST。既存のWindows側ID `obsidian`および09:00の生成スケジュール `6ac26cd83cc0819194880e0de3dc908d` は変更していない。Windows停止状態はユーザー申告に基づき、Macの管理DBには当該設定なし。
- 10/16分は取得したチャットに存在せず未確認。次回以降も取りこぼしを照合し、実出力なしでは作成しない。保存済みを上書きしない。変更なしは静かにし、保存・失敗・要対応時だけ知らせる設定。
- 実行条件: MacとCodexアプリの起動、ネットワーク/ChatGPTログイン、iCloudファイルへのアクセスとVault書込権限。今回のVault書込はsandbox外への承認付きで成功。無人実行に同じ権限が適用されるかは未検証。拒否される場合はVaultフォルダを許可された作業フォルダとして追加する必要がある。認証や保護を弱めない。Obsidianアプリ自体の起動はファイル保存に不要。
- アプリコード・配信記事は変更なし。Git commit/push、Study App同期公開、外部送信は未実施。CURRENTのみ運用状態を更新、構成変更がないためARCHITECTURE/ADRの追加は不要。

## 初回heartbeat（09:18 JST）

- 元チャットから10/16分（メッセージID `6fe80aff-ee07-4264-9806-b4397abf9ba3`）を取得。Vault全体の同日/title重複なしを確認し、`wiki/official/20261016-091908.md`へ排他新規保存した。Frontmatter・対象日・元URL・メッセージID・原文の全文再読一致を確認。10/5〜10/16は日付の欠落なし。
- heartbeat実行でも承認付きVault書込に成功。生成スケジュール・Windows側・公開処理は変更なし。10/16未確認を解消。
