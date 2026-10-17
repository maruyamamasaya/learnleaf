# Vesperaの読書・音声・資料の実機受入

- ユーザーが実機操作確認と発見した問題の修正を依頼。開始時main 3735cdd、作業ツリー差分なし。
- Vespera（iPhone 17e / iOS 26.6.2）の接続を確認。操作前にApplication Support/StudyApp一式を/private/tmp/learnleaf-device-acceptance-20261017/beforeへ読み出し保護。音声50本、資料未登録。
- 実機XCUITestで記事ホーム→検索（RAG）→聴く→見る→設定を操作し、スクリーンショット・画面階層を取得。入口確認1件成功。証跡: /private/tmp/learnleaf-device-acceptance-20261017/EntryPoints.xcresult、screens/。
- 再利用できるUITest targetと明示実行用StudyAppDeviceAcceptance schemeを追加。通常のStudyApp schemeのunit test対象は維持。実機データを使用するため、端末指定・事前退避・対象選定を要する。
- 続く記事本文/スライド/音声再生の検証は実機ロックのため待機し、ユーザーへ解除を依頼。ロック待ちを停止した。本文・再生・スライド用テストはコンパイル済みだが実行未完了で、成功とは扱わない。解除後に明示実行用schemeで対象を再実行する。

- 現時点でアプリの不具合は確認していない。製品コード変更なし。画面確認は入口のみで、再生の聴感・ロック画面・Office/PDF取込・スライド編集等の受入は未完了。

- 検証: XcodeGen生成成功、索引再生成差分なし、git diff --check成功。実機UI入口1件成功。Interactions.xcresultはTEST INTERRUPTED（ロック待ちをSIGINTで停止）。Simulatorは実行していない。
