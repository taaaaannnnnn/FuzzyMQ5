@echo off
REM MQL5 Build Launcher for FuzzyLogicBasedOnTan
REM This batch file bypasses PowerShell Execution Policy to run the build script.

powershell -ExecutionPolicy Bypass -File ".\build.ps1"

pause
