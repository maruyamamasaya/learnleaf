# 新URL版Learnleafの実機更新

- ユーザーがインストール済みiOSアプリの更新を依頼。main 41a7e26の新URL版をVespera（F71F4956-FA07-5431-AEDF-9C19094ACFBE）へ反映。
- 既存プロファイルのTeam U29GY347DYとbundle ID jp.maruyama.studyappを維持し、Xcodeの自動開発署名で実機ビルド成功。個人Teamを共有設定へ固定していない。
- 更新前のrecords.v1.jsonを一時退避し、devicectlで上書きインストール・起動成功。アンインストールや端末データ削除は実施しない。
- 更新前後の学習記録はバイト一致（SHA-256 6486b1b2ed444378e5fb27bcab92383cdee88c5281f95e99b6c34d9c27df518c）。起動後の端末catalogは390記事、revision a37e2ef06a66cc44b82ec55c75d97978cd4490670076310992a9e521189fa693で公開/ローカルと一致。
- ビルドログ: /private/tmp/learnleaf-device-update-build.log。成果物: /private/tmp/learnleaf-device-update-20261014/Build/Products/Debug-iphoneos/StudyApp.app。導入・起動JSON: /private/tmp/learnleaf-device-update-install.json、/private/tmp/learnleaf-device-update-launch.json。記録退避: /private/tmp/learnleaf-records-before-update-20261014.json。一時領域なので長期バックアップとは別扱い。
- 直前の最終iOS55テスト成功済み、ソース変更なしのためSimulatorテストを反復しない。文書追加による索引生成差分なし、diff check成功。
- 新URL版への実機更新は完了。画面上の読書・音声・資料操作の手動評価は未実施。Windows原本・Vault・バックアップの変更/削除なし。
