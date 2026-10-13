# Learnleaf名称統一と公開

- GitHub正式名をstudyAppからmaruyamamasaya/learnleafへ改名。originのlearnleaf URLとPagesのworkflow方式・新公開URLを確認。
- 既存未コミット移行変更と390記事をe55c511に保護。移行ブランチの既存push（2741321）を確認。Mac検証226f060・7947ad6・0cdb6fbおよびリモートmain追加5コミットを保持して統合。
- package/lockfile、Mac起動スクリプト、iOS取得先とURL検証テスト、現行配信文書をLearnleafへ統一。履歴資料・内部識別子・保存形式は維持。
- Node 24のkegを優先。原本照合完了のユーザー確認に基づきLEARNLEAF_VAULT_VERIFIEDの移行条件を終了。wiki存在、main/origin限定、同期上書き・削除・hash保護を維持。
- Web24テスト、見出しID検証、索引生成、diff check成功。索引再生成差分なし。Vault checkは390記事・差分0。以前の381記事のID/path/hash/metadataをすべて維持し9記事を追加。
- iOS初回ビルドで取り込んだVisualSlides.Controller.nextがUIResponder.nextと衝突。クロージャ名をadvanceSlideへ変更して修正。初回記録: /var/folders/91/r9h2q_ys771bmhhb_x9z46gw0000gn/T/studyapp-verification.JqziY1。初回XCTest新規複製0、ビルド段階で停止。
- 最終iOSビルドと55件XCTest成功（既存iPhone 17 Pro F26F773A-A316-4610-9228-84217FEEB82A、並列無効）。結果: /var/folders/91/r9h2q_ys771bmhhb_x9z46gw0000gn/T/studyapp-verification.uSvtTu。ZIPFoundationテストの整数型曖昧性もInt64指定で解消。main切替と重なったビルドの一時読取り失敗後、確定mainで検証した。全4実行の新規XCTest複製0、削除0、最終device set全体18台。
- mainと移行ブランチを9a64cd0まで通常push。Pages Actions run 38419163491成功。公開ルートとtrainingはHTTP 200。`npm run app:verify -- https://maruyamamasaya.github.io/learnleaf/`で390記事のHTTP取得・一覧形式・全本文hash一致。公開catalog revisionはローカルと一致（a37e2ef06a66cc44b82ec55c75d97978cd4490670076310992a9e521189fa693）。インストール済みiOSアプリは別途更新が必要。Windows原本・Vault・バックアップは変更/削除していない。
