@echo off
REM Standalone batch file to execute cleanup script from GitHub
REM FOR AUTHORIZED SECURITY TESTING AND DEMONSTRATION ONLY

REM GitHub raw URL for the cleanup script
set SCRIPT_URL=https://raw.githubusercontent.com/beauchompers/attack-simulations/main/atomic-scripts/simple-ransomware-simulation/cleanup.ps1

echo.
echo ========================================
echo Ransomware Simulation Cleanup Launcher
echo ========================================
echo.
echo Downloading cleanup script from GitHub...
echo.

REM Execute the PowerShell cleanup script directly from GitHub
REM Downloads and executes in memory without saving to disk
powershell.exe -ExecutionPolicy Bypass -Command "& {Invoke-Expression ((New-Object Net.WebClient).DownloadString('%SCRIPT_URL%'))}"

echo.
echo ========================================
echo Cleanup Complete
echo ========================================
echo.
pause
