@echo off
:: ==============================================================================
:: LAN & DNS Split Tunneling Launcher
:: This script requests Administrator privileges and runs the PowerShell script.
:: ==============================================================================

:: Check if we already have Administrator privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    :: Create a temporary VBScript to elevate privileges
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Ensure the script runs in the same directory where it is located
cd /d "%~dp0"

echo Running Network Configuration Script...
:: Launch the PowerShell script, bypassing execution policy restrictions
powershell -NoProfile -ExecutionPolicy Bypass -File "FixNetwork.ps1"
