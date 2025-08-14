#!/system/bin/sh
# monitor_link.sh - 持续监控 eth0 网口速率和链路状态

IFACE="eth0"
INTERVAL=5  # 监控间隔，单位秒

echo "开始监控网口 $IFACE 的链路状态和速率，每 $INTERVAL 秒刷新一次。"
echo "按 Ctrl+C 结束。"
echo

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    SPEED=$(cat /sys/class/net/$IFACE/speed 2>/dev/null)
    DUPLEX=$(cat /sys/class/net/$IFACE/duplex 2>/dev/null)
    CARRIER=$(cat /sys/class/net/$IFACE/carrier 2>/dev/null)
    AUTO_NEG=$(./ethtool $IFACE 2>/dev/null | grep "Auto-negotiation" | awk -F": " '{print $2}')
    LINK_DET=$(./ethtool $IFACE 2>/dev/null | grep "Link detected" | awk -F": " '{print $2}')

    echo "[$TIMESTAMP] 速率: ${SPEED}Mb/s, 双工: $DUPLEX, 链路状态: $( [ "$CARRIER" = "1" ] && echo 已连接 || echo 未连接 ), 自动协商: $AUTO_NEG, Link Detected: $LINK_DET"

    sleep $INTERVAL
done
