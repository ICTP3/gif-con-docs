#!/bin/bash

action=$(jq -r '.action' "$GITHUB_EVENT_PATH")
title=$(jq -r '.issue.title' "$GITHUB_EVENT_PATH")
user=$(jq -r '.issue.user.login' "$GITHUB_EVENT_PATH")
url=$(jq -r '.issue.html_url' "$GITHUB_EVENT_PATH")
repo=$(jq -r '.repository.full_name' "$GITHUB_EVENT_PATH")

payload=$(jq -n \
  --arg action "$action" \
  --arg title "$title" \
  --arg user "$user" \
  --arg url "$url" \
  --arg repo "$repo" \
  '{
    "content": "**🗒️ Issue 通知**\n\n📦 **リポジトリ:** \($repo)\n🧑 **作成者:** \($user)\n📝 **タイトル:** \($title)\n⚙️ **アクション:** \($action)\n🔗 [GitHubで確認](\($url))"
  }')

curl -H "Content-Type: application/json" \
     -d "$payload" \
     "$WEBHOOK_URL"
