# 現在の状態

更新: 2026-10-16

## 配置と公開

- 開発コードは`~/Development/learnleaf`。現行方式は静的Docsifyで、Astro・Sites・Codex CLIによる公開経路は廃止済み。
- 記事の唯一の正本は`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Learnleaf`の`wiki/`。Windows原本コピー・ZIP展開元との照合・Obsidian起動は完了確認済み。Windows原本とバックアップは保持する。
- `docs/`は生成ミラー。390記事を同期・公開済み。保存フォルダと記事種別は独立し、任意の文字列typeと未指定を受け入れる。既存記事ID・相対path・Frontmatterを維持する。
- GitHubは公開repository `maruyamamasaya/learnleaf`。originは`https://github.com/maruyamamasaya/learnleaf.git`。mainへのpush後、`.github/workflows/pages.yml`がdocsをGitHub Pagesへ配信する。
- 公開URLは https://maruyamamasaya.github.io/learnleaf/ 。ルートと研修サイトはHTTP 200を確認済み。閲覧制限は設けず、旧クライアント側password gateは認証として使用しない。

## 日常の編集・同期

- 開発メモのVault自動保存はMacのheartbeat `obsidian-mac`（開発メモをObsidianへ保存（Mac））を有効化。毎日09:15 JST目安で実出力と過去の未保存分を照合する。Windows側`obsidian`は変更せず停止を維持。10/14〜10/16分をMac原本へ保存・再読確認済み。初回heartbeatで10/16分の取得・承認付き書込が成功。Mac/Codex起動とVault書込権限が必要。これは保存のみで同期・公開は行わない。詳細は[sessions記録](sessions/2026-10-16-obsidian-mac-automation.md)。

- 編集はVaultで行い、docsを直接編集しない。`npm run vault:prepare`で同期・索引生成・テストを行う。公開はMacの`sync-and-publish.command`、Windowsの`sync-and-publish.cmd`または`npm run vault:publish`を使う。
- Macの`start-learnleaf.command`は既存docsのローカルHTTP配信のみ。両MacスクリプトはLearnleaf Vaultを既定値とし、Nodeは`/opt/homebrew/opt/node@24/bin`を優先する。
- 原本照合完了に伴い`LEARNLEAF_VAULT_VERIFIED`の移行条件は終了。wiki存在、main/origin限定、Frontmatter/ID/hash、上書き・削除保護は維持する。詳細ログは`--verbose`。
- 直接CLIを使う場合は`STUDY_APP_VAULT`またはVault引数を指定する。PythonがPATHにない場合は`STUDY_APP_PYTHON`で指定できる。日常の同期・公開にAI呼び出しは不要。
- 2026-10-08に記録した同期停止は、現在のMac環境では再現していない。2026-10-14のVault checkは390記事・差分0で、個人開発メモを含め同期・公開済み。以前の停止原因は未特定で、原因修正済みとは扱わない。

運用は[CONTENT_AUTHORING.md](CONTENT_AUTHORING.md)、Mac移行の結果は[MAC_MIGRATION.md](MAC_MIGRATION.md)を参照する。

## iOSの現行機能と実機状態

- 表示名はLearnleaf。下部タブは記事・聴く・見る・フォルダ・設定。検索は記事ホーム内から開く。「見る」はプレゼン/PDF/Word/PowerPointを扱い、SVG/画像は記事用素材として管理する。
- 記事は新Pages URLの`app-articles.v1.json`とMarkdownをHTTPS取得し、path・Schema・本文hashを検証する。自由なtypeと未指定にも対応済み。
- ホームのピックアップ・お気に入り・コレクション、タグ/階層フォルダ検索、関連記事、4テーマ、記事単位の学習履歴を実装。記事カードはタイトルとmetadataを表示し、本文抜粋の自動取得は行わない。
- 本文検索は明示操作で取得し、取消・進捗・失敗件数を表示する。検証済みcatalog/本文は端末へ永続保存し、全記事保存と通信不可時の利用に対応。全文検索用の永続索引は持たない。
- 学習記録はv1 JSONで保存し、書出し・復元・別端末記録の手動統合に対応。bundle IDと保存先は名称変更後も維持する。Webの記録とは独立し、旧Astroの学習状態version 2は自動移行しない。
- 事前生成音声・台本・番組をFiles/iCloud Driveから取り込み、再生位置・聴取済み・倍速・BGM・連続再生・曲間・ロック画面操作・個人番組編集を実装。音声生成はアプリ外で行う。
- 端末内のSVG/PDF/Word/PowerPoint原本管理、記事関連付け、記事からの構造分割スライド・編集・出力を実装。PPTX表示は別途作成したPDFを登録する方式。範囲と制限は[ios/VISUAL_RESOURCES.md](ios/VISUAL_RESOURCES.md)。
- Vespera（iPhone 17e）は2026-10-14に新URL版へ既存Team・同bundle IDで上書き更新し、起動成功。更新前後の学習記録はバイト一致。起動後の端末catalogは390記事で公開/ローカルrevisionと一致。端末更新は完了し、画面上の操作確認は残る。

## 最新の検証

2026-10-14にWeb24テスト、見出しID検証、索引再生成、diff check、iOSビルドと55件XCTestが成功。索引再生成差分なし。従来381記事のID/path/hash/metadataを保持して9記事を追加した。

Pages Actions run [38419163491](https://github.com/maruyamamasaya/learnleaf/actions/runs/38419163491)成功。`app:verify`で公開390記事のHTTP取得・一覧形式・全本文hash一致を確認し、公開catalog revisionもローカルと一致した。

証跡は[公開検証記録](sessions/2026-10-14-learnleaf-publication.md)と[実機更新記録](sessions/2026-10-14-ios-device-update.md)。過去の調査・実装・検証は`sessions/`、設計判断は`decisions/`に保持する。

## 残課題と次の候補

- 実機の読書・自由なtypeの記事本文・検索・コレクションの操作、音声の実再生/ロック中再生/Files・iCloud取り込み、資料の表示・編集・共有を一通り確認する。ビルド・自動テスト・起動成功だけで手動受入完了とは扱わない。
- 大容量音声・資料の実機メモリと処理時間、VoiceOver/Dynamic Typeを確認する。音声同期の検証は別タスクへ移したが、確定時のファイルI/Oと全音声Data保持は残る。
- Vaultの画像・添付ファイル同期とWeb/iOS共通の添付配信基盤は未対応。統合学習設計のiOS端末内実装は着手済みで、公開manifest・変換基盤等の提案は[design/integrated-learning](design/integrated-learning/README.md)に残る。
- 学習記録・音声・資料の自動端末間同期と資料全体バックアップは未対応。Vaultの長期バックアップ方針は未決定。一時退避は長期バックアップと区別する。
- 記事のスクロール位置復元・見出しへの移動、日別集計/日付またぎ配分、復習モードは未対応。Docsifyは外部CDN依存のため完全offline閲覧は未対応。
- 移行記事の内容の事実確認は未実施。保留リンク集・除外重複の経緯は[取込記録](sessions/2026-10-05-standalone-import.md)を参照する。
- 旧Sitesリモートサイトの残存は過去に記録されている。削除・現状再確認は未実施。
