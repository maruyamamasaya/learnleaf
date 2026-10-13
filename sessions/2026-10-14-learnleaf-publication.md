# Learnleaf名称統一と公開

- GitHub正式名をstudyAppからmaruyamamasaya/learnleafへ改名。originのlearnleaf URLとPagesのworkflow方式・新公開URLを確認。
- 既存未コミット移行変更と390記事をe55c511に保護。移行ブランチの既存push（2741321）を確認。Mac検証226f060・7947ad6・0cdb6fbおよびリモートmain追加5コミットを保持して統合。
- package/lockfile、Mac起動スクリプト、iOS取得先とURL検証テスト、現行配信文書をLearnleafへ統一。履歴資料・内部識別子・保存形式は維持。
- Node 24のkegを優先。原本照合完了のユーザー確認に基づきLEARNLEAF_VAULT_VERIFIEDの移行条件を終了。wiki存在、main/origin限定、同期上書き・削除・hash保護を維持。
- Web24テスト、見出しID検証、索引生成、diff check成功。索引再生成差分なし。Vault checkは390記事・差分0。以前の381記事のID/path/hash/metadataをすべて維持し9記事を追加。
- iOS初回ビルドで取り込んだVisualSlides.Controller.nextがUIResponder.nextと衝突。クロージャ名をadvanceSlideへ変更して修正。初回記録: /var/folders/91/r9h2q_ys771bmhhb_x9z46gw0000gn/T/studyapp-verification.JqziY1。初回XCTest新規複製0、ビルド段階で停止。
- 最終iOS検証・公開結果は追記する。インストール済みiOSアプリは別途更新が必要。Windows原本・Vault・バックアップは変更/削除していない。
