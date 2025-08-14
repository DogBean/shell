#!/bin/bash

# 定义迭代次数
ITERATIONS=10000

# 循环执行所需的次数
for ((i = 0; i < $ITERATIONS; i++)); do
    # 等待 4 秒
    sleep 5

    # 记录当前迭代
    echo "Number: $i"

    # 发起 HTTP 请求（请将 URL 替换为实际的端点）
    curl -s "http://192.168.88.211/fcgi/do?action=MakeCall&number=5112100340&name=567&lineID=0&_=1710122003045"

    # 等待 6 秒
    sleep 6

    # 发起另一个 HTTP 请求
    curl -s "http://192.168.88.211/fcgi/do?action=CallEnd&_=1710136674982"
done
