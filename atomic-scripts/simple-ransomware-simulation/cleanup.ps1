# Ransomware Simulation Cleanup Script

Write-Host "Ransomware Simulation Cleanup" -ForegroundColor Yellow

# Check if Atomic Red Team is available for cleanup commands
$AtomicPath = "C:\AtomicRedTeam"
$ModulePath = "$AtomicPath\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1"

if (Test-Path $ModulePath) {
    Write-Host "Found Atomic Red Team, importing for cleanup..." -ForegroundColor Green
    Import-Module $ModulePath -Force
    $AtomicAvailable = $true
} else {
    Write-Warning "Atomic Red Team not found - will perform manual cleanup only"
    $AtomicAvailable = $false
}

# Cleanup Phase 1: T1082 System Information Discovery
Write-Host "`nCleaning up Phase 1: Discovery..." -ForegroundColor Cyan
if ($AtomicAvailable) {
    try {
        Write-Host "  Cleaning up T1082..." -ForegroundColor Gray
        Invoke-AtomicTest T1082 -TestNumbers 1 -Cleanup
        Write-Host "  T1082 cleanup completed" -ForegroundColor Green
    } catch {
        Write-Warning "  T1082 cleanup failed: $_"
    }
}

# Manual cleanup for T1087.001 (no atomic cleanup needed - was manual commands)
Write-Host "  T1087.001 was manual commands - no cleanup needed" -ForegroundColor Gray

# Cleanup Phase 2: Persistence
Write-Host "`nCleaning up Phase 2: Persistence..." -ForegroundColor Cyan

# Clean up T1053.005 - Scheduled Task Creation
if ($AtomicAvailable) {
    try {
        Write-Host "  Cleaning up T1053.005..." -ForegroundColor Gray
        Invoke-AtomicTest T1053.005 -TestNumbers 1 -Cleanup
        Write-Host "  T1053.005 cleanup completed" -ForegroundColor Green
    } catch {
        Write-Warning "  T1053.005 cleanup failed: $_"
    }
}

# Manual cleanup of any leftover scheduled tasks
Write-Host "  Checking for leftover scheduled tasks..." -ForegroundColor Gray
$atomicTasks = schtasks /query /fo csv 2>$null | ConvertFrom-Csv | Where-Object {$_.TaskName -like "*Atomic*" -or $_.TaskName -like "*T1053*"}
if ($atomicTasks) {
    foreach ($task in $atomicTasks) {
        Write-Host "    Removing task: $($task.TaskName)" -ForegroundColor Yellow
        schtasks /delete /tn $task.TaskName /f 2>$null
    }
} else {
    Write-Host "    No leftover scheduled tasks found" -ForegroundColor Green
}

# Clean up T1136.001 - Create Local Account
if ($AtomicAvailable) {
    try {
        Write-Host "  Cleaning up T1136.001..." -ForegroundColor Gray
        Invoke-AtomicTest T1136.001 -TestNumbers 5 -Cleanup
        Write-Host "  T1136.001 cleanup completed" -ForegroundColor Green
    } catch {
        Write-Warning "  T1136.001 cleanup failed: $_"
    }
}

# Manual cleanup of any leftover user accounts
Write-Host "  Checking for leftover user accounts..." -ForegroundColor Gray
$suspiciousUsers = Get-LocalUser | Where-Object {$_.Name -like "*Atomic*" -or $_.Name -like "*test*" -or $_.Description -like "*Atomic*"}
if ($suspiciousUsers) {
    foreach ($user in $suspiciousUsers) {
        Write-Host "    Removing user: $($user.Name)" -ForegroundColor Yellow
        Remove-LocalUser -Name $user.Name -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "    No suspicious user accounts found" -ForegroundColor Green
}

# Cleanup Phase 3: Impact
Write-Host "`nCleaning up Phase 3: Impact..." -ForegroundColor Cyan

# Remove ransom notes
Write-Host "  Removing ransom notes..." -ForegroundColor Gray
$ransomNoteLocations = @(
    "C:\Temp\README_DECRYPT.txt",
    "$env:PUBLIC\Desktop\README_DECRYPT.txt"
)
foreach ($ransomNote in $ransomNoteLocations) {
    if (Test-Path $ransomNote) {
        Remove-Item $ransomNote -Force
        Write-Host "    Removed: $ransomNote" -ForegroundColor Yellow
    }
}

# Additional manual cleanup
Write-Host "`nPerforming additional cleanup..." -ForegroundColor Cyan

# Clean up any leftover registry entries
Write-Host "  Checking for atomic registry entries..." -ForegroundColor Gray
try {
    $atomicRegKeys = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Where-Object {$_.Name -like "*Atomic*"}
    if ($atomicRegKeys) {
        foreach ($key in $atomicRegKeys) {
            Write-Host "    Removing registry key: $($key.Name)" -ForegroundColor Yellow
            Remove-Item $key.PSPath -Force -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "    No atomic registry entries found" -ForegroundColor Green
    }
} catch {
    Write-Warning "  Could not check registry entries: $_"
}

# Clean up any leftover processes
Write-Host "  Checking for leftover processes..." -ForegroundColor Gray
$suspiciousProcesses = Get-Process | Where-Object {$_.ProcessName -like "*atomic*" -or $_.ProcessName -like "*mimikatz*" -or $_.ProcessName -like "*ransom*"}
if ($suspiciousProcesses) {
    foreach ($proc in $suspiciousProcesses) {
        Write-Host "    Stopping process: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "    No suspicious processes found" -ForegroundColor Green
}

# Final verification
Write-Host "`nPerforming final verification..." -ForegroundColor Cyan
$remainingIssues = @()

# Check for remaining processes
$remainingProcesses = Get-Process | Where-Object {$_.ProcessName -like "*ransom*" -or $_.ProcessName -like "*atomic*"}
if ($remainingProcesses) {
    $remainingIssues += "Suspicious processes still running"
}

# Check for remaining scheduled tasks
$remainingTasks = schtasks /query /fo csv 2>$null | ConvertFrom-Csv | Where-Object {$_.TaskName -like "*Atomic*" -or $_.TaskName -like "*ransom*"}
if ($remainingTasks) {
    $remainingIssues += "Suspicious scheduled tasks still present"
}

# Check for remaining ransom notes
if (Test-Path "C:\temp\README_DECRYPT*.txt") {
    $remainingIssues += "Ransom notes still present"
}

if ($remainingIssues.Count -eq 0) {
    Write-Host "All ransomware simulation artifacts cleaned up successfully!" -ForegroundColor Green
} else {
    Write-Warning "Some artifacts may still remain:"
    $remainingIssues | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}

Write-Host "`nCleanup Complete!" -ForegroundColor Green
Write-Host "Ransomware simulation environment has been reset." -ForegroundColor Cyan