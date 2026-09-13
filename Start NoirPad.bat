@echo off
title NOIRPAD server
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0noirpad-server.ps1"
pause
