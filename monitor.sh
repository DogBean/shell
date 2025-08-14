#!/bin/bash

# 获取屏幕分辨率
resolution=$(adb shell wm size | awk '{print $3}')
width=$(echo $resolution | cut -d"x" -f1)
height=$(echo $resolution | cut -d"x" -f2)
deviceIp=192.168.88.47:5555;

# 单击事件
single_click() {
    local x=$1
    local y=$2
    adb -s $deviceIp shell input tap $x $y
}

# 双击事件
double_click() {
    local x=$1
    local y=$2
    single_click $x $y
    sleep 0.2
    single_click $x $y
}

# 获取双击位置（这里使用屏幕中心）
double_click_x=$((width / 2))
double_click_y=$((height / 2))



# 设置重复执行次数
repeat_count=200000

# 循环执行双击事件
for ((i=1; i<=repeat_count; i++))
do
	# 执行双击事件
	single_click 976   615
	sleep 3
	double_click 300   240
	sleep 3
	adb -s $deviceIp shell "input keyevent 4"
	sleep 1
	echo “======$i=====”
	# 判断是否是100的倍数
    if ((i % 100 == 0))
    then
        adb -s $deviceIp shell "dumpsys meminfo com.akuvox.phone >> sdcard/phone_meminfo.txt"
    fi
	sleep 5
	
done
