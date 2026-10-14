# LearnleafへのMac移行

更新: 2026-10-14

## 配置と原本保護

- 開発コード: `~/Development/learnleaf`
- 原本Vault: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Learnleaf`
- 原本コピーとZIPの照合、Obsidian起動はユーザーが完了確認済み。390記事の同期変更を保持した。
- Windows原本とバックアップは保持する。今回それらを変更・削除していない。
- 移行開始時の未コミット変更はe55c511に保存し、既存Mac検証コミット226f060・7947ad6・0cdb6fbとリモートmainの追加5コミットを統合した。

## 起動と公開

`start-learnleaf.command`は既存docsをローカルHTTP配信する。`sync-and-publish.command`はVault同期・索引生成・テスト・commit・pushを実行する。両方ともMacのLearnleaf Vaultを`STUDY_APP_VAULT`の既定値とし、指定済みの値を優先する。Nodeは`/opt/homebrew/opt/node@24/bin`、`/opt/homebrew/bin`、`/usr/local/bin`の順で利用する。

照合完了済みのため移行時の`LEARNLEAF_VAULT_VERIFIED`条件を終了した。wiki存在、main限定、origin許可先、同期の上書き・削除保護、Frontmatter/ID/hash検証は維持する。

GitHub repositoryは`maruyamamasaya/learnleaf`へ改名済み。originは`https://github.com/maruyamamasaya/learnleaf.git`。PagesはActions方式で`docs/`を配信する。

公開URL: https://maruyamamasaya.github.io/learnleaf/

iOSのArticleClientと現行配信文書も新URLを使用する。旧URLリダイレクトへ依存しない。履歴資料の旧名称、bundle ID、scheme、型名、記録・音声・offline保存先は維持する。

## 検証と残課題

最終検証結果・公開Actions・390記事のHTTP/hash検証は[公開検証記録](sessions/2026-10-14-learnleaf-publication.md)を参照する。

Vesperaのインストール済みiOSアプリは2026-10-14に新取得先を含む版へ上書き更新・起動済み。学習記録の保持と390記事の端末catalog一致を確認した。証跡は[実機更新記録](sessions/2026-10-14-ios-device-update.md)。実機での読書・音声・資料操作の手動確認は残る。
