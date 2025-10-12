#!/bin/bash
set -e

# ===== GitHub情報の取得 =====
repo=$(jq -r '.repository.full_name' "$GITHUB_EVENT_PATH")
user=$(jq -r '.sender.login' "$GITHUB_EVENT_PATH")
action=$(jq -r '.action' "$GITHUB_EVENT_PATH")
issue_title=$(jq -r '.issue.title' "$GITHUB_EVENT_PATH")
issue_url=$(jq -r '.issue.html_url' "$GITHUB_EVENT_PATH")
issue_number=$(jq -r '.issue.number' "$GITHUB_EVENT_PATH")

# ===== アクションの日本語化 =====
case $action in
  opened) action_jp="🆕 新しいIssueが作成されました" ;;
  edited) action_jp="✏️ Issueが編集されました" ;;
  closed) action_jp="✅ Issueがクローズされました" ;;
  reopened) action_jp="🔁 Issueが再オープンされました" ;;
  *) action_jp="📢 Issueイベントが発生しました" ;;
esac

# ===== Discord用のメッセージ本文 =====
payload=$(jq -n \
  --arg title "$issue_title" \
  --arg repo "$repo" \
  --arg user "$user" \
  --arg url "$issue_url" \
  --arg num "$issue_number" \
  --arg action "$action_jp" \
  '{
    "username": "GitHub Issue Bot 🤖",
    "embeds": [
      {
        "title": $action,
        "color": 5814783,
        "fields": [
          {"name": "🧾 リポジトリ", "value": $repo, "inline": true},
          {"name": "🙋 作成者", "value": $user, "inline": true},
          {"name": "📌 Issue", "value": "[#\($num)] \($title)\n\n🔗 [GitHubで見る](\($url))"}
        ],
        "footer": {"text": "Gif-Con Project | 自動通知 by GitHub Actions"}
      }
    ]
  }'
)

# ===== Discordへ送信 =====
curl -H "Content-Type: application/json" \
     -d "$payload" \
     "$WEBHOOK_URL"
