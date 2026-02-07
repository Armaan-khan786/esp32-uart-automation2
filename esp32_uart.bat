@echo off
setlocal enabledelayedexpansion

set ARDUINO_CLI=arduino-cli
set FQBN=esp32:esp32:esp32

echo ======================================
echo Detecting ESP32 ports
echo ======================================

set COUNT=0
for /f "tokens=1" %%A in ('%ARDUINO_CLI% board list ^| find "ESP32"') do (
    set /a COUNT+=1
    if !COUNT!==1 set PORT1=%%A
    if !COUNT!==2 set PORT2=%%A
)

if "%PORT1%"=="" (
    echo ❌ No ESP32 detected
    exit /b 1
)

echo Sender Port   : %PORT1%
echo Receiver Port : %PORT2%

echo ======================================
echo Compiling Sender
echo ======================================
%ARDUINO_CLI% compile --fqbn %FQBN% sender || exit /b 1

echo ======================================
echo Compiling Receiver
echo ======================================
%ARDUINO_CLI% compile --fqbn %FQBN% receiver || exit /b 1

echo ======================================
echo Flashing Sender
echo ======================================
%ARDUINO_CLI% upload -p %PORT1% --fqbn %FQBN% sender || exit /b 1

if not "%PORT2%"=="" (
    echo ======================================
    echo Flashing Receiver
    echo ======================================
    %ARDUINO_CLI% upload -p %PORT2% --fqbn %FQBN% receiver || exit /b 1
)

echo Waiting for ESP32 boot...
timeout /t 6 >nul

echo ======================================
echo Running UART TOGGLE test
echo ======================================
python tools\uart_read.py %PORT1% || exit /b 1

echo ======================================
echo UART TEST COMPLETED SUCCESSFULLY
echo ======================================
exit /b 0
