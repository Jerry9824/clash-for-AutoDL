#!/bin/bash

# 策略组名称（你的是“🔰 节点选择”）
GROUP_NAME="🔰 节点选择"
ENCODED_GROUP=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$GROUP_NAME'''))")
CLASH_API="http://127.0.0.1:6006"

echo "📌 当前正在使用的节点："
curl -s "$CLASH_API/proxies" | jq -r ".proxies[\"$GROUP_NAME\"].now"

echo ""
echo "📋 可选节点列表："
# 获取所有节点
mapfile -t NODES < <(curl -s "$CLASH_API/proxies" | jq -r ".proxies[\"$GROUP_NAME\"].all[]")

# 打印编号和节点名
for i in "${!NODES[@]}"; do
    printf "%2d. %s\n" "$i" "${NODES[$i]}"
done

echo ""
read -p "请输入要切换的节点编号: " IDX
TARGET_NODE="${NODES[$IDX]}"

if [ -z "$TARGET_NODE" ]; then
    echo "❌ 输入无效，未切换节点。"
    exit 1
fi

# 切换节点
curl -s -X PUT "$CLASH_API/proxies/$ENCODED_GROUP" \
     -H "Content-Type: application/json" \
     -d "{\"name\":\"$TARGET_NODE\"}" > /dev/null

echo ""
echo "✅ 已切换到：$TARGET_NODE"
echo "📌 当前正在使用的节点："
curl -s "$CLASH_API/proxies" | jq -r ".proxies[\"$GROUP_NAME\"].now"
