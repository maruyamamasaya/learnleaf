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
echo 'Learnleaf: http://127.0.0.1:8000/ （停止: Ctrl+C）'
npm run dev
