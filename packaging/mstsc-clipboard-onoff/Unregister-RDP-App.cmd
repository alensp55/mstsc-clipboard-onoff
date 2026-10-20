@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Unregister-RDP-App.ps1"
if errorlevel 1 pause
