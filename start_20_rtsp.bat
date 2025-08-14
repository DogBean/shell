@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "VLC_PATH=E:\VLC\vlc.exe"
set "VIDEO_FILE=E:\VLC\test.mp4"
set /A START_PORT=8554
set /A MAX_STREAMS=25

echo 正在启动 %MAX_STREAMS% 路 RTSP 流...

set /A STREAM_COUNT=0
set /A PORT=%START_PORT%

:next_stream
REM 检查端口是否被占用
netstat -ano | findstr ":!PORT!" >nul
if %errorlevel%==0 (
    REM 端口被占用，尝试下一个端口
    set /A PORT+=1
    goto next_stream
)

REM 启动 VLC RTSP 流
set /A STREAM_COUNT+=1
echo 启动流 !STREAM_COUNT! (端口 !PORT!)...
start "" "!VLC_PATH!" -I dummy -vvv "!VIDEO_FILE!" --loop --sout="#rtp^{sdp=rtsp://:!PORT!/stream^}" :sout-keep

REM 输出完整 RTSP 地址
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP: =!"
    echo 流 !STREAM_COUNT! RTSP 地址: rtsp://!IP!:!PORT!/stream
)

REM 判断是否达到总路数
if !STREAM_COUNT! lss %MAX_STREAMS% (
    set /A PORT+=1
    goto next_stream
)

echo 所有 %MAX_STREAMS% 路 RTSP 流已启动
pause
