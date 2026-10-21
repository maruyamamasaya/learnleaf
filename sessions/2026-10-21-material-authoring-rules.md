# 資料作成ルールの整理

## 調査と変更

- ユーザーが挙げた重複説明、ページ下部のグレーの補足、参照リンクの未整理をもとに、`MATERIAL_AUTHORING.md`へ資料作成ルールを保存した。
- 構成作成、補足の移動先、図表の余白、調査時の出典記録、参考資料一覧、完成前チェックを定義した。必要な適用条件と出典は補足削除時も残す。
- `AGENTS.md`に資料作成・改訂時の参照を追加した。
- 先に作成した[資料作成ルールのPage](https://chatgpt.com/space/page_970db4a5c5208191bbb80f74c6756462)を再読し、本文をリポジトリへ保存。今後このリポジトリでの運用は`MATERIAL_AUTHORING.md`を参照する。

## 検証と範囲

- 文書と参照導線のみの変更。実行コード・記事・構成・データフローの変更はなく、CURRENT・ARCHITECTURE・ADRの更新は不要。
- PATH既定の古いNodeでは`--test`が未対応だったため、既存運用に従いHomebrew Node 24を指定して`npm test`を実行し、24件成功（見出しID検証を含む）。
- `python3 build_note_index.py`成功。`docs/_note-index.json`と`docs/_article-master.json`は差分なし、既存IDの変更なし。
- 本文と参照リンクを確認し、`git diff --check`成功。Pageの表示プレビューは未確認。
- 既存資料の改訂は今回の対象外。未解決事項なし。
