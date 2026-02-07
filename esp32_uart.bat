@echo off
setlocal

set ARDUINO_CLI=arduino-cli
set FQBN=esp32:esp32:esp32

echo ======================================
echo Compiling Sender
echo ======================================
%ARDUINO_CLI% compile --fqbn %FQBN% sender || exit /b 1

echo ======================================
echo Compiling Receiver
echo ======================================
%ARDUINO_CLI% compile --fqbn %FQBN% receiver || exit /b 1

echo ======================================
echo Flashing ESP32 boards
echo ======================================
%ARDUINO_CLI% upload --fqbn %FQBN% sender || exit /b 1
%ARDUINO_CLI% upload --fqbn %FQBN% receiver || exit /b 1

echo Waiting for ESP32 boot...
timeout /t 6 >nul

echo ======================================
echo Running UART TOGGLE test
echo ======================================
python uart_monitor.py || exit /b 1

echo ======================================
echo UART TEST COMPLETED SUCCESSFULLY
echo ======================================
exit /b 0
