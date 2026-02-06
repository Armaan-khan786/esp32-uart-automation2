@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM ========= USER CONFIG =========
set ARDUINO_CLI=arduino-cli
set FQBN=esp32:esp32:esp32
set PORT_SENDER=COM6
set PORT_RECEIVER=COM7
set BAUD=115200
set LOG_FILE=uart_test.log

REM ========= COMPILE =========
echo ======================================
echo Compiling Sender
echo ======================================
%ARDUINO_CLI% compile --fqbn %FQBN% sender
if errorlevel 1 exit /b 1

echo ======================================
echo Compiling Receiver
echo ======================================
%ARDUINO_CLI% compile --fqbn %FQBN% receiver
if errorlevel 1 exit /b 1

REM ========= FLASH SENDER =========
echo ======================================
echo Flashing ESP32 Sender
echo ======================================
%ARDUINO_CLI% upload -p %PORT_SENDER% --fqbn %FQBN% sender
if errorlevel 1 exit /b 1

REM ========= FLASH RECEIVER =========
echo ======================================
echo Flashing ESP32 Receiver
echo ======================================
%ARDUINO_CLI% upload -p %PORT_RECEIVER% --fqbn %FQBN% receiver
if errorlevel 1 exit /b 1

REM ========= WAIT FOR BOOT =========
echo Waiting for ESP32 boot...
timeout /t 6 >nul

REM ========= UART TOGGLE TEST =========
echo ======================================
echo Running UART TOGGLE test
echo ======================================

REM Capture serial output for 10 seconds
%ARDUINO_CLI% monitor -p %PORT_RECEIVER% -c baudrate=%BAUD% ^
  > %LOG_FILE% & timeout /t 10 >nul & taskkill /IM arduino-cli.exe /F >nul 2>&1

findstr /C:"UART TOGGLE TEST PASS" %LOG_FILE% >nul
if errorlevel 1 (
    echo ======================================
    echo UART TOGGLE TEST FAILED
    echo ======================================
    exit /b 1
)

echo ======================================
echo UART TOGGLE TEST PASSED
echo ======================================
exit /b 0