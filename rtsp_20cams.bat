@echo off
set VLC_PATH=E:\VLC\vlc.exe
set VIDEO_PATH=E:\VLC\test.mp4
set PORT=8554
set /a COUNT=20

rem 获取本机 IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set LOCAL_IP=%%a
set LOCAL_IP=%LOCAL_IP: =%

echo [INFO] 本机 IP: %LOCAL_IP%
echo [INFO] 启动 20 路低码率 RTSP 推流...

for /L %%i in (1,1,%COUNT%) do (
    start "" "%VLC_PATH%" ^
    "%VIDEO_PATH%" ^
    --sout=#transcode{vcodec=h264,vb=800,scale=0.5,acodec=mp4a,ab=64,channels=1,samplerate=44100}:rtp{sdp=rtsp://:%PORT%/cam%%i} ^
    --loop --no-audio --rtsp-port=%PORT% --quiet
    echo 推流地址：rtsp://%LOCAL_IP%:%PORT%/cam%%i
)
pause
