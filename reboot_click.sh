#!/bin/bash
# reboot_random_click.sh - 重启后随机点击屏幕10次，间隔1秒

LOOP_COUNT=1000       # 循环次数
CLICK_TIMES=10       # 每次重启后点击次数
CLICK_DELAY=1        # 点击间隔秒数

# 屏幕宽高（请根据设备实际分辨率修改）
SCREEN_WIDTH=1080
SCREEN_HEIGHT=1920

for ((i=1; i<=LOOP_COUNT; i++)); do
    echo "===== 第 $i 次测试 ====="

    echo "[*] 正在重启设备..."
    adb reboot

    adb wait-for-disconnect
    adb wait-for-device

    echo "[*] 等待系统启动完成..."
    while true; do
        boot_completed=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
        if [ "$boot_completed" == "1" ]; then
            echo "[*] 系统已启动"
            break
        fi
        sleep 0.5
    done

    echo "[*] 开始随机点击屏幕 $CLICK_TIMES 次，间隔 $CLICK_DELAY 秒"
    for ((j=1; j<=CLICK_TIMES; j++)); do
        # 生成随机坐标
        X=$((RANDOM % SCREEN_WIDTH))
        Y=$((RANDOM % SCREEN_HEIGHT))
        echo "    点击 #$j: ($X, $Y)"
        adb shell input tap $X $Y
        sleep $CLICK_DELAY
    done

    echo "[*] 第 $i 次完成"
    echo
done
