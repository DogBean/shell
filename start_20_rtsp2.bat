@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "VLC_PATH=E:\VLC\vlc.exe"
set "VIDEO_FILE=E:\VLC\test.mp4"
set /A START_PORT=8621
set /A MAX_STREAMS=20
set "XML_FILE=Monitor.xml"

rem ==== 启动前杀掉旧 VLC 进程，防止端口占用 ====
taskkill /F /IM vlc.exe >nul 2>&1

echo 正在启动 %MAX_STREAMS% 路 RTSP 流...
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%XML_FILE%"
echo ^<Monitors Total="%MAX_STREAMS%"^> >> "%XML_FILE%"

set /A STREAM_COUNT=0
set /A PORT=%START_PORT%

rem 获取本机 IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP: =!"
)

:next_stream
rem 检查端口是否被占用
netstat -ano | findstr ":!PORT!" >nul
if %errorlevel%==0 (
    set /A PORT+=1
    goto next_stream
)

set /A STREAM_COUNT+=1
set "RTSP_URL=rtsp://%IP%:!PORT!/stream"

rem 启动 VLC
echo 启动流 !STREAM_COUNT! (端口 !PORT!)...
start "" "!VLC_PATH!" -I dummy -vvv "!VIDEO_FILE!" --loop --sout="#rtp^{sdp=rtsp://:!PORT!/stream^}" :sout-keep

rem 打印 RTSP 地址
echo [RTSP] !RTSP_URL!

rem 写入 XML
echo     ^<Monitor Index="!PORT!" DeviceName="!PORT!" RTSPAddress="!RTSP_URL!" User="" Password="" DeviceNumber="!PORT!" DisplayInCall="0"/^> >> "%XML_FILE%"

if !STREAM_COUNT! lss %MAX_STREAMS% (
    set /A PORT+=1
    goto next_stream
)

echo ^</Monitors^> >> "%XML_FILE%"
echo 所有 %MAX_STREAMS% 路 RTSP 流已启动
echo 已生成 XML 文件: %XML_FILE%
pause
