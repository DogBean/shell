@echo off
chcp 65001 >nul
set DEVICE_ID=192.168.88.162:5555

:loop
echo [INFO] Connecting to device %DEVICE_ID% ...
adb connect %DEVICE_ID%
timeout /t 5 >nul

echo [INFO] Simulating 10 screen taps (1 per second)...
for /L %%i in (1,1,10) do (
    adb -s %DEVICE_ID% shell input tap 500 1000
    timeout /t 1 >nul
)

echo [INFO] Waiting 20 seconds before reboot...
timeout /t 20 >nul

echo [INFO] Rebooting device...
adb -s %DEVICE_ID% shell reboot

echo [INFO] Waiting 60 seconds before next round...
timeout /t 60 >nul
goto loop
