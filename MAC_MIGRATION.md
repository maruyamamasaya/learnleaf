# LearnleafへのMac移行

更新: 2026-10-13

## 現在の配置と保護

- 開発コード: `/Users/maruyamasusumuya/Development/learnleaf`
- 作業ブランチ: `codex/learnleaf-mac-migration`。現在のチェックアウト`0cdb6fb`から作成。開始時の未コミット変更なし。リモートmainの追加5commitは未統合。
- 原本Vault: `/Users/maruyamasusumuya/Library/Mobile Documents/iCloud~md~obsidian/Documents/Learnleaf`
- 旧StudyAppには`.obsidian/`の設定5ファイル、`.DS_Store`、初期ノート`ようこそ.md`だけがあった。移行先不存在を確認して名前変更し、全7ファイルのSHA-256一致を確認した。
- 名前変更前の全内容は`/private/tmp/learnleaf-vault-before-rename-20261013`に退避済み。一時領域のため、Windows原本の長期バックアップとは別扱い。
- Windows原本ZIPは準備中。`wiki/`なし。既存docsとmanifestは保持。

**Windows原本コピー・照合完了までVault同期、記事削除、公開を実行しない。**

## Mac用起動スクリプト

`start-learnleaf.command`は既存docsだけをローカルHTTP配信する。`sync-and-publish.command`は同期・公開用。両方が`STUDY_APP_VAULT`を上記Learnleafへ設定し、既に指定された環境変数を優先する。空白を含むパスに対応。NodeはHomebrewの`/opt/homebrew/bin`、Intel Macでは`/usr/local/bin`を優先し、なければPATHを利用する。このMacは標準PATHのNode 16では`--test`が使えないためHomebrew版で検証する。

公開用スクリプトは`LEARNLEAF_VAULT_VERIFIED=1`と`wiki/`の存在の両方を要求する。これは原本照合を自動で証明するものではなく、照合完了後に利用者が明示する操作条件。既存npmコマンド自体にはこの条件がないので、移行中は直接`vault:sync`・`vault:prepare`・`vault:publish`を実行しない。

## Windows原本の受け入れ（未実施）

1. ZIPをVault外の別フォルダへ展開し、原本のファイル数・相対パス・hashをWindows側の記録と比較する。ZIPと比較記録を保全する。
2. 現在のLearnleafと同名ファイルの衝突を一覧化する。`.obsidian/`と初期ノートを無条件に上書きしない。既存内容を別の安全な場所にも退避する。
3. 確認済みの原本をLearnleafへ配置し、配置後も相対パス・hash・IDを照合する。iCloudのローカルダウンロード完了を確認する。
4. 照合後だけ`STUDY_APP_VAULT`を指定した`npm run vault:check`で予定差分を確認する。削除候補とID変更を確認するまで同期しない。
5. 同期後の差分・索引ID・テストを確認し、公開条件が整ってからmainへ統合する。

## GitHub名・公開URLの切替（未実施）

目標repositoryは`maruyamamasaya/learnleaf`、目標Pages URLは`https://maruyamamasaya.github.io/learnleaf/`。現在のoriginは`https://github.com/maruyamamasaya/studyApp.git`のまま。リモートrepositoryの改名・origin変更・pushは今回行わない。

公開CLIのorigin許可先とActions案内はlearnleaf向けへ変更済み。旧originでは公開CLIが同期前に停止する。公開は従来どおりmainのみ。

repository改名後にoriginを変更し、Pages設定とActionsを確認する。実際の新URLでcatalogと全本文hashを検証してからiOSの取得先を切り替える。Pagesの旧URLリダイレクトに依存しない（iOSとHTTP検証器はredirectを拒否）。

切替対象:

- `ios/Sources/ArticleClient.swift`の`ArticleClient.baseURL`: 現在は旧studyApp。新配信確認まで維持。
- `APP_ARTICLE_DELIVERY.md`・`IOS_APP_CONCEPT.md`・`ios/README.md`の配信URL例: 新配信確認と同時に更新。
- `CURRENT.md`の公開URL: 実際の公開先確認後に更新。
- `.github/workflows/pages.yml`: repository名の固定参照なし。改名後のPages設定確認が必要。

iOSのbundle ID、scheme、型名、`StudyApp/records.v1.json`・音声・offline保存先は名称だけで変更しない。ユーザー記録とキャッシュの継続性を維持する。URL例を使うテストは旧パスでも汎用URL処理を検証できるため改名不要。
