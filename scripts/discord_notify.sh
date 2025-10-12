#!/bin/bash
set -e

# ===== GitHub情報の取得 =====
COMMIT_MESSAGE=$(jq -r '.head_commit.message' $GITHUB_EVENT_PATH)
COMMIT_AUTHOR=$(jq -r '.head_commit.author.name' $GITHUB_EVENT_PATH)
REPO_NAME=$(jq -r '.repository.name' $GITHUB_EVENT_PATH)
COMMIT_URL=$(jq -r '.head_commit.url' $GITHUB_EVENT_PATH)
BRANCH=$(jq -r '.ref' $GITHUB_EVENT_PATH | sed 's/refs\/heads\///')

# ===== メッセージ色をブランチで変更 =====
COLOR=5793266 # デフォルト：青緑
if [[ "$BRANCH" == feature/* ]]; then
  COLOR=16776960  # 黄色（新機能）
elif [[ "$BRANCH" == fix/* ]]; then
  COLOR=16733525  # 赤（修正）
elif [[ "$BRANCH" == docs/* ]]; then
  COLOR=10070709  # グレー（ドキュメント）
fi

# ===== Discord埋め込みメッセージを構築 =====
DESCRIPTION=$(cat <<EOF
**━━━━━━━━━━━━━━━━━━**
🧾 **リポジトリ:** ${REPO_NAME}
🌿 **ブランチ:** ${BRANCH}
👤 **コミッター:** ${COMMIT_AUTHOR}
**━━━━━━━━━━━━━━━━━━**
💬 **コミットメッセージ:**
\`\`\`
${COMMIT_MESSAGE}
\`\`\`
🔗 [コミットを確認する](${COMMIT_URL})
EOF
)

payload=$(jq -n \
  --arg desc "$DESCRIPTION" \
  --argjson color "$COLOR" \
  '{
    "username": "🐣 Gif-Con CI Bot",
    "avatar_url": "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png",
    "embeds": [{
      "title": "🚀 新しいプッシュを検知しました！",
      "description": $desc,
      "color": $color,
      "footer": { "text": "Gif-Con 開発チーム | 自動通知" },
      "timestamp": (now | todate)
    }]
  }')

# ===== Discordへ送信 =====
curl -H "Content-Type: application/json" \
     -d "$payload" \
     "$WEBHOOK_URL"
