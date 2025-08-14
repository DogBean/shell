@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "VLC_PATH=E:\VLC\vlc.exe"
set "VIDEO_FILE=E:\VLC\test.mp4"
set /A START_PORT=8621
set /A MAX_STREAMS=20
set "XML_FILE=monitors.xml"

echo 正在启动 %MAX_STREAMS% 路 RTSP 流...
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%XML_FILE%"
echo ^<Monitors Total="%MAX_STREAMS%"^> >> "%XML_FILE%"

set /A STREAM_COUNT=0
set /A PORT=%START_PORT%

REM 获取本机 IPv4 地址（自动去掉前后空格）
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP: =!"
)

:next_stream
REM 检查端口是否被占用
netstat -ano | findstr ":!PORT!" >nul
if %errorlevel%==0 (
    REM 端口被占用，跳到下一个
    set /A PORT+=1
    goto next_stream
)

REM 启动 VLC 流
set /A STREAM_COUNT+=1
echo 启动流 !STREAM_COUNT! (端口 !PORT!)...
start "" "!VLC_PATH!" -I dummy -vvv "!VIDEO_FILE!" --loop --sout="#rtp^{sdp=rtsp://:!PORT!/stream^}" :sout-keep

REM 输出到 XML 文件
echo     ^<Monitor Index="!PORT!" DeviceName="!PORT!" RTSPAddress="rtsp://%IP%:!PORT!/stream" User="" Password="" DeviceNumber="!PORT!" DisplayInCall="0"/^> >> "%XML_FILE%"

REM 判断是否达到总路数
if !STREAM_COUNT! lss %MAX_STREAMS% (
    set /A PORT+=1
    goto next_stream
)

echo ^</Monitors^> >> "%XML_FILE%"
echo 所有 %MAX_STREAMS% 路 RTSP 流已启动
echo 已生成 XML 文件: %XML_FILE%
pause
