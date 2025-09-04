#!/bin/bash
# AudioSink stuck 调试脚本（在电脑端执行）
# 用法: chmod +x check_audiosink_pc.sh
#       ./check_audiosink_pc.sh

OUTDIR="audiosink_debug_$(date +%Y%m%d_%H%M%S)"
mkdir -p $OUTDIR

echo "==== [1] 检查设备连接 ===="
adb get-state || { echo "设备未连接"; exit 1; }

echo "==== [2] audioserver 进程信息 ====" | tee $OUTDIR/summary.txt
adb shell ps -A | grep audioserver | tee -a $OUTDIR/summary.txt

echo "==== [3] dumpsys media.audio_flinger ====" | tee -a $OUTDIR/summary.txt
adb shell dumpsys media.audio_flinger > $OUTDIR/audio_flinger.txt
grep -E "Client|Track|State|frame" $OUTDIR/audio_flinger.txt | tee -a $OUTDIR/summary.txt

echo "==== [4] dumpsys media.audio_policy ====" | tee -a $OUTDIR/summary.txt
adb shell dumpsys media.audio_policy > $OUTDIR/audio_policy.txt
grep -E "Output|Device|Active" $OUTDIR/audio_policy.txt | tee -a $OUTDIR/summary.txt

echo "==== [5] AudioTrack traces ====" | tee -a $OUTDIR/summary.txt
pid=$(adb shell ps -A | grep audioserver | awk '{print $2}')
if [ ! -z "$pid" ]; then
    adb shell kill -SIGQUIT $pid
    echo "已触发 audioserver trace (查看 logcat)" | tee -a $OUTDIR/summary.txt
else
    echo "未找到 audioserver 进程" | tee -a $OUTDIR/summary.txt
fi

echo "==== [6] logcat 关键信息 (最近200行) ====" | tee -a $OUTDIR/summary.txt
adb logcat -d -t 200 | grep -E "NuPlayerRenderer|AudioFlinger|AudioTrack" | tee -a $OUTDIR/summary.txt

echo "==== 日志收集完成，结果保存在 $OUTDIR ===="
