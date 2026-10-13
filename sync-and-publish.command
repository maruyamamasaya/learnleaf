#!/bin/bash
set -euo pipefail
# Finder起動と旧nvm環境でも、MacのHomebrew実行環境を利用する。
if [[ -x /opt/homebrew/opt/node@24/bin/node ]]; then
  export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
elif [[ -x /opt/homebrew/bin/node ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [[ -x /usr/local/bin/node ]]; then
  export PATH="/usr/local/bin:$PATH"
fi
cd -- "$(dirname -- "$0")"
export STUDY_APP_VAULT="${STUDY_APP_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Learnleaf}"
printf 'Vault: %s\n' "$STUDY_APP_VAULT"
# 原本コピーとZIP照合は2026-10-14に完了確認済み。
if [[ ! -d "$STUDY_APP_VAULT/wiki" ]]; then
  echo 'wiki/がありません。同期・公開を停止します。' >&2
  exit 1
fi
node scripts/publish-obsidian.mjs "$@"
