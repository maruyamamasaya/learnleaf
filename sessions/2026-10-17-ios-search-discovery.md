# iOSの記事探索を検索中心に改善

- ユーザーが記事探索の使いづらさを指摘し、会話内の検索中心の画面案を選択、iOSへの実装を依頼。
- 開始時dc5aacd、作業ツリー差分なし。AGENTS/CURRENT/ARCHITECTURE、ADR-014/016、現行SearchView/LibraryViews/SearchEngine/テストと履歴を確認。
- 下部タブをホーム・探す・保存・聴く・設定へ変更。検索を記事ホームのsheetから独立タブへ移し、資料・フォルダ・タグは探すから利用可能にした。保存タブは既存の本棚機能を使用。
- 上部の検索入力欄、コンパクトな結果行、独立した保存ボタン、別sheetの絞り込み、個別解除チップを実装。対象は初期値を記事にし、すべて/音声/番組/資料にも対応。条件クリア時はキーワードを保持。検索前に実タグ上位6件・件数、検索履歴、最近開いた記事を表示。本文抜粋の自動取得や架空の分類は追加しない。
- 外部入口は検索のNavigationStackを先頭へ戻す。既存の本文検索・保存条件・フォルダ階層・資料管理を維持。設計判断はADR-019。
- 最初のビルドで保存sheetのdismiss参照を誤って除いたコンパイルエラーを確認し復旧。初回ログ: /var/folders/91/r9h2q_ys771bmhhb_x9z46gw0000gn/T/studyapp-verification.UhyeYa。テスト未実行。
- 初回の成功検証: /private/tmp/learnleaf-search-verification.AZlOJF（単体59件・UI 1件成功）。画面確認で絞り込みの項目名を明示する標準Formへ調整し、キーボード表示中の結果・実条件変更・同じ検索タブ内の記事タグからの再検索をUIテストに追加。
- 最終検証: /private/tmp/learnleaf-search-verification.oSmu4g。既存iPhone 17e（EB3A49ED-6553-4D7E-B933-387951643EAB）1台、並列無効。ビルド・単体59件・検索UI 1件成功。公開catalogを使い、RAGの34件の検索結果、入力中の本文入口、絞り込みの選択/クリアとキーワード保持、本文からのタグ検索への復帰、条件チップ解除、ホームからの再検索、結果行の保存sheet、保存タブを確認。screens/に8画面と画面階層を保存し、検索結果・キーボード表示中・最終Formを目視確認。実機データ依存の既存受入テストは導線を更新しコンパイルしたが、今回のSimulatorでは対象外。
- Simulator記録: 各実行のbefore/after-devices.json・processes.txt、最終実行のfinal-devices.json・final-processes.txtを保存。全実行でXCTestDevicesのID差分なし（18台）。最終時にxcodebuild/xctest/UI runnerの残存なし。今回の複製0、削除0。既存18台は作成元不明のため変更しない。通常端末は削除しない。
- その他の検証: npm test 24件成功（/private/tmp/learnleaf-search-web-tests.log）、見出しID検証はnpm testに含む。build_note_index.py実行済み、docs/_note-index.jsonとdocs/_article-master.jsonに差分なし。git diff --check成功。専用lint/typecheck設定なし。CURRENT/ARCHITECTURE/iOS手順書を更新。
- 残課題: 全テーマ/VoiceOver/大きなDynamic Typeでの画面確認は未実施。実機導入と今回の自動操作確認は以下を参照。検索の短い説明文はcatalogにないため追加せず、タイトル・タグ・既存状態を使用。

## Vesperaへの導入と実機確認

- ユーザーがVesperaへのインストールと動作確認を明示依頼。既存のCoreDevice ID F71F4956-FA07-5431-AEDF-9C19094ACFBE、Team U29GY347DY、bundle ID jp.maruyama.studyappを確認し維持。製品コードはSimulatorで検証した版から変更なし。実機入口テストの検索確定時にキーボードを閉じる修正のみ追加。
- 証跡は/private/tmp/learnleaf-search-vespera-20261017/。接続初回のリセットと大量コピーの60秒超過・socket切断を記録。現在のrecords/音声index/資料indexをbefore/へ退避し、設定plistは個別転送成功。途中まで転送したbefore-complete/を、現在のindexと同じSHA-256を持つファイルだけで補完した。補完35本の出典をbackup-supplements.jsonへ記録し、全50本の欠落0・hash不一致0をverify-data.pyで確認。以前の退避を現在の端末へ書き戻してはいない。現状BGM指定なし・資料indexは0件。退避先は一時領域であり長期バックアップではない。
- 同じTeam/bundle IDで実機ビルド・署名成功。devicectlで上書きインストールと起動成功。操作前272学習区間のrecords.v1.jsonはインストール直後とバイト一致。お気に入り・コレクション・読了状態・音声50本のmanifest/hash/原本名/台本/聴取状態/番組と資料indexも一致。installed/とverify-installed.logへ保存。
- 実機UIテストは検索フロー、主要入口、音声再生/バックグラウンド復帰の3件を対象に、並列無効で実行。初回Acceptance.xcresultで主要入口・音声の2件成功。検索フローも最後まで動作したが、空欄のaccessibility valueがSimulatorではplaceholder文字列、実機ではnilであるため2つのassertionが失敗。画面階層と画面を確認し、空欄の判定をnil/空文字/placeholderとplaceholderValueの検証へ修正（既存キーワードが残っていれば失敗する）。製品コードは変更せずSearchFinal.xcresultで検索1件が成功。対象3件を確認完了。Simulatorは今回実行しない。

- 最終照合: after/とverify-after.logで既存272区間の内容を全件保持し、テスト読書分2区間を追加。お気に入り/コレクション/読了状態、音声50本のmanifest/hash/原本名/台本/聴取状態/番組、資料index（0件）を保持。端末上の音声50ファイルの存在と退避原本とのサイズ一致もaudio-files-after.jsonで確認。音声の再生位置と検索履歴は操作に伴い更新。その他の設定plistは全キー一致、保存した検索条件も一致。
- final-screens/へ最終検索テスト8画面と画面階層を保存。実機Blue Cosmosで検索結果とタグ検索復帰を目視確認。最終のdevicectl通常起動も成功。以前成功した単体59件/Web24件は製品コード変更がないため反復しない。git diff --check成功。
- 本件の実機導入・検索/主要入口/音声の操作確認は完了。音声の聴感、全テーマ・アクセシビリティ、既存のWord/PowerPoint等の未確認範囲は別途残る。
