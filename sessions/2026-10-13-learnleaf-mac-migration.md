# Learnleaf Mac移行の準備

- 開始時の未コミット変更なし。現在の0cdb6fbからcodex/learnleaf-mac-migrationを作成。既存の移行ブランチ/文書は取得できないため新規に作業。
- StudyApp Vaultの7ファイルを一時領域へ退避しhash照合、衝突なしでLearnleafへ名前変更、変更後も一致。原本ZIPは未受領。詳細と受け入れ手順はMAC_MIGRATION.md。
- Mac起動/公開スクリプトを追加。STUDY_APP_VAULTとHomebrew Nodeを設定。公開は明示した照合完了とwiki存在を要求。公開CLIのorigin検証・Actions案内をlearnleaf向けに準備。
- 公開URL/iOS記事取得先/保存先/workflowを調査。新配信確認前のiOS URL変更は保留。記録保存先・bundle IDは維持。CURRENT/ARCHITECTURE/CONTENT_AUTHORINGを更新。
- 検証: Node 16ではnpm testが起動不可、Homebrew Node 24.2.0で24件成功。bash構文検証成功。公開スクリプトは照合指定なし・wikiなしの各条件でNode呼出前に停止。ローカル起動成功、ルート/研修HTMLのHTTP 200を確認しサーバーを停止。ブラウザー描画は未確認。iOSコード変更なし、Simulatorテストは未実施。
- build_note_index.py再生成で既存索引・記事ID差分なし。Vault同期・記事削除・公開・pushは未実施。テストの同期処理は一時fixtureのみ。
- 残課題: Windows ZIP受入と照合、リモートmain追加5commitの統合、GitHub改名/origin切替、Pages新URL検証、iOS配信先切替。実装は未コミット。
