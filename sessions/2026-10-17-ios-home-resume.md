# 直前の学習を優先するホームと読書位置

- ユーザーが「直前の学習を優先」のホーム案を選び、読書位置保存・復元とVesperaへのインストール/動作確認を依頼。開始時dc5aacd、前タスクの検索UI等の未commit変更を保持して追加実装。
- AGENTS/CURRENT/ARCHITECTURE、ADR-014/017、StudyStore/TrackPlayer/AudioLibrary/ArticleReaderとテストを確認。HomeResumeSelection/ResumeHomeSectionを追加し、続き・履歴・保存・ピックアップの順に配置。音声の再生開始日時を追加し、読書の閲覧/スクロール日時と比較する。
- ReadingPositionを既存記録へoptional追加。hashが同じ本文の相対スクロール位置を復元し、hash変更時は先頭へ戻す。文字サイズ/画面寸法変更に相対位置で追随し、「先頭から読む」も用意。Markdown一体描画とdelegateを維持する。書出し/復元と位置更新日時による統合に対応。詳細はADR-020。
- 初回ビルドはテスト側のMainActor指定不足で停止し修正。/private/tmp/learnleaf-search-verification.RFe7sy。次の検証で単体63件成功。ホームの直近比較を位置保存日時まで含むよう追加調整し、回帰テストを追加。最終結果は以下を参照。
- 実機の操作前退避: /private/tmp/learnleaf-home-vespera-20261017/before/（records、音声/資料index、設定plist）。同じTeam/bundle IDを維持する。raw音声は既存の検証済み退避とのhash照合を行ってから上書きする。
- Simulatorの中間実行 /private/tmp/learnleaf-home-verification.xY3VgY/ は位置保存とホーム反映後のapp.terminateでUI runnerがsignal termにより中断。原因は未特定。成功扱いにせず保持。スクロール中のPublished更新を0.4秒にまとめ、UI観測UIViewから状態をweak参照する調整と、復元後の同じ可視段落の検証を追加。
- Simulator最終確認 /private/tmp/learnleaf-home-verification.uLKx9q/: 単体64件と読書再開UI 1件成功。17%付近で保存→ホーム→アプリ終了/再起動→読むのを再開→同じ段落の表示→先頭から読むを確認し、スクリーンショットも前後で目視確認。前段の検索回帰は /private/tmp/learnleaf-search-verification.OWwguL/ で成功。各Simulator実行前後のXCTestDevices一覧とプロセスを記録し、端末18台でID差分なし。今回の複製0・削除0。既存端末は変更/削除しない。
- 最終調整: 暗いテーマの再開ボタン文字はdesign.onAccentで可読性を確保。音声lastPlayedProgramIDも保持し、直前が単独再生なら古い番組snapshotを再開しない。型・保存契約の単体テストを追加。現行の読書復元と矛盾しないよう見出しリンクの案内文を修正。
- Vespera: 同じTeam U29GY347DY/bundle ID jp.maruyama.studyappで上書き。Regression.xcresultで最終ロジックの実機ビルド・全64件XCTest成功。Acceptance.xcresultはHomeResumeTestsの読書/音声とSearchDiscoveryTestsの合計3件・失敗0（約119秒）。音声開始→15秒送り/一時停止→アプリ終了/再起動→ホームで音声優先→再生、記事の3回スクロール→位置保存→ホームで読む優先→アプリ終了/再起動→同じ段落へ復帰→先頭へ戻す、検索/条件/保存導線を確認。screens/に画面と階層を保存し、Blue Cosmosの読む/聴くカードと復元本文を目視確認。
- 最後の案内文調整後もビルド・上書き導入・devicectlで通常起動成功。final-install.json/final-launch.jsonへ記録。製品の振る舞いが変わらない案内文だけなのでUI全体テストを反復しない。
- after/とverify-after.logの照合で既存274区間を内容まで保持し、今回の読書操作で2区間追加。お気に入り・コレクション・既存読了状態、音声50本のmanifest/hash/localFile/台本/聴取状態/番組と資料index（0件）を保持。端末音声50ファイルの存在とhash確認済み退避原本とのサイズ一致をaudio-files-after.jsonで確認。設定plistの既存キーは検索履歴以外すべて一致、保存した検索条件も一致。読書位置1件と音声の最終再生日時/経路は今回追加、再生位置と検索履歴は操作に伴い更新。
- 既存raw音声退避は /private/tmp/learnleaf-search-vespera-20261017/before-complete/audio/ の50本と現在の音声hashが全件一致し、audio-backup-verified.jsonに記録した。今回は大量転送を繰り返さず、この検証済みコピーと現在のmetadata/設定を保護。端末への過去記録の復元・ユーザーファイルの削除は行わない。退避先は一時領域で長期バックアップではない。
- CURRENT/ARCHITECTURE/iOS手順書とADR-020を更新。build_note_index.py成功、索引2ファイルの差分なし。専用lint/typecheckなし、Swiftコンパイルとgit diff --check成功。Webのコード/記事を変えていないため直前成功済みWeb24件を反復しない。
- 残課題: 各テーマ・大きいDynamic Type・VoiceOverの手動受入、初回Simulator runner中断の原因特定。位置は文書全体の相対位置で、見出しへの厳密な復元ではない。本文更新時の先頭へのfallbackと保存/復元/統合・再同期保持は単体検証済み。音声の聴感/番組全体等の既存未確認範囲はCURRENTの記載を継続。
