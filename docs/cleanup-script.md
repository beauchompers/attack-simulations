# Ransomware Simulation Cleanup Script

**Script:** [atomic-scripts/simple-ransomware-simulation/cleanup.ps1](../atomic-scripts/simple-ransomware-simulation/cleanup.ps1)

## Purpose

Removes all artifacts created by the ransomware simulation script to restore the system to its pre-test state. This cleanup script is essential for ensuring test environments are properly sanitized after security testing.

## What This Script Does

The cleanup script performs comprehensive artifact removal across multiple system areas:

### 1. Atomic Red Team Cleanup

Runs built-in Atomic Red Team cleanup commands for each technique:
- **T1082** - System Information Discovery cleanup
- **T1053.005** - Scheduled Task cleanup
- **T1136.001** - Local Account cleanup

### 2. Scheduled Task Removal

- Queries all scheduled tasks on the system
- Identifies tasks with "Atomic" or "T1053" in the name
- Deletes matching tasks
- Verifies removal

### 3. User Account Cleanup

- Lists all local user accounts
- Identifies accounts matching patterns:
  - Names containing "Atomic"
  - Names containing "test"
  - Descriptions containing "Atomic"
- Removes matching accounts
- Confirms deletion

### 4. File Cleanup

Removes ransom notes from:
- `C:\Temp\README_DECRYPT.txt`
- `C:\Users\Public\Desktop\README_DECRYPT.txt`

Removes ransomware payload directory:
- `C:\AttackLocation\` (entire directory and contents)

### 5. Registry Cleanup

- Checks `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
- Identifies Atomic-related registry entries
- Removes persistence registry keys
- Verifies cleanup

### 6. Process Termination

Kills running processes matching:
- `*atomic*`
- `*mimikatz*`
- `*ransom*`

### 7. Final Verification

Performs comprehensive verification:
- Checks for remaining suspicious processes
- Verifies scheduled tasks are removed
- Confirms ransom notes are deleted
- Reports any remaining artifacts

## Prerequisites

### Required System

- **Operating System**: Windows 10, Windows 11, or Windows Server 2016+
- **PowerShell**: Version 5.1 or higher
- **Privileges**: Administrator rights (required - script auto-elevates if needed)

**Note:** The script will automatically attempt to elevate to Administrator privileges if not already running as admin. If launched without admin rights, it will relaunch itself with elevated privileges.

### Atomic Red Team

If Atomic Red Team is installed, the script uses it for automated cleanup. If not installed, the script performs manual cleanup only.

**Installation Check:**
```powershell
Test-Path C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1
```

## Usage

### Option 1: Standalone Batch File (Recommended for Demos)

The easiest way to run cleanup is using the standalone batch file, which downloads and executes the PowerShell script directly from GitHub:

**Script:** [atomic-scripts/simple-ransomware-simulation/run_cleanup.bat](../atomic-scripts/simple-ransomware-simulation/run_cleanup.bat)

```batch
# Download the batch file from GitHub and save it anywhere on your Windows system
# Then simply double-click it or run from Command Prompt:

run_cleanup.bat
```

**Benefits:**
- ✅ No local PowerShell files needed
- ✅ Always runs the latest cleanup version from GitHub
- ✅ Perfect for security demonstrations and training
- ✅ Simpler for non-technical users

**How it works:**
1. Downloads cleanup script from GitHub raw URL
2. Executes script in memory using `Invoke-Expression`
3. Script automatically elevates to Administrator (UAC prompt)
4. Performs comprehensive cleanup

**GitHub URL:** `https://raw.githubusercontent.com/beauchompers/attack-simulations/main/atomic-scripts/simple-ransomware-simulation/cleanup.ps1`

### Option 2: PowerShell Direct Execution

Run the cleanup script after completing the ransomware simulation:

```powershell
# Navigate to script directory
cd C:\path\to\attack-simulations\atomic-scripts\simple-ransomware-simulation\

# Run cleanup
.\cleanup.ps1
```

### Run from Any Location

```powershell
# Use full path
C:\attack-simulations\atomic-scripts\simple-ransomware-simulation\cleanup.ps1
```

### Run as Administrator

If not already running as admin:

```powershell
# Start elevated PowerShell session
Start-Process powershell -Verb RunAs

# Then navigate and run cleanup
cd C:\path\to\attack-simulations\atomic-scripts\simple-ransomware-simulation\
.\cleanup.ps1
```

## Script Output

### Example Output

```
Ransomware Simulation Cleanup

Cleaning up Phase 1: Discovery...
  Cleaning up T1082...
  T1082 cleanup completed
  T1087.001 was manual commands - no cleanup needed

Cleaning up Phase 2: Persistence...
  Cleaning up T1053.005...
  T1053.005 cleanup completed
  Checking for leftover scheduled tasks...
    No leftover scheduled tasks found

  Cleaning up T1136.001...
  T1136.001 cleanup completed
  Checking for leftover user accounts...
    Removing user: AtomicAdministrator
    No suspicious user accounts found

Cleaning up Phase 3: Impact...
  Removing ransom notes...
    Removed: C:\Temp\README_DECRYPT.txt
    Removed: C:\Users\Public\Desktop\README_DECRYPT.txt

Performing additional cleanup...
  Checking for atomic registry entries...
    No atomic registry entries found
  Checking for leftover processes...
    No suspicious processes found

Performing final verification...
All ransomware simulation artifacts cleaned up successfully!

Cleanup Complete!
Ransomware simulation environment has been reset.
```

### Color Coding

- **Yellow**: Section headers and warnings
- **Cyan**: Phase headers
- **Gray**: Individual cleanup operations
- **Green**: Successful cleanup operations
- **Red**: Errors or items requiring manual cleanup

## What Gets Cleaned Up

### Complete Cleanup List

| Artifact Type | Locations | Methods |
|--------------|-----------|---------|
| Scheduled Tasks | Task Scheduler | `schtasks /delete` |
| User Accounts | Local SAM database | `Remove-LocalUser` |
| Ransom Notes | `C:\Temp\`, Public Desktop | `Remove-Item` |
| Payload Directory | `C:\AttackLocation\` | `Remove-Item -Recurse` |
| Registry Keys | `HKCU:\...\Run` | `Remove-Item` |
| Processes | Running processes | `Stop-Process` |
| Atomic Artifacts | Various | `Invoke-AtomicTest -Cleanup` |

### Atomic Red Team Artifacts

The following Atomic test artifacts are cleaned:

**T1082 (System Information Discovery):**
- Temporary output files
- System enumeration scripts

**T1053.005 (Scheduled Task):**
- Created scheduled tasks
- Task XML definitions
- Associated scripts

**T1136.001 (Create Account):**
- Test user accounts
- Group memberships

## Manual Cleanup (If Script Fails)

If automated cleanup fails or you prefer manual cleanup:

### 1. Remove Scheduled Tasks

```powershell
# List all scheduled tasks
schtasks /query /fo list

# Find Atomic-related tasks
schtasks /query /fo csv | ConvertFrom-Csv | Where-Object {$_.TaskName -like "*Atomic*"}

# Delete specific task
schtasks /delete /tn "AtomicTask" /f

# Or use PowerShell
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Atomic*"} | Unregister-ScheduledTask -Confirm:$false
```

### 2. Remove User Accounts

```powershell
# List local users
Get-LocalUser

# Remove specific user
Remove-LocalUser -Name "AtomicAdministrator"

# Or using net command
net user AtomicAdministrator /delete
```

### 3. Delete Ransom Notes and Payload Directory

```powershell
# Remove from Temp
Remove-Item "C:\Temp\README_DECRYPT.txt" -Force -ErrorAction SilentlyContinue

# Remove from Public Desktop
Remove-Item "C:\Users\Public\Desktop\README_DECRYPT.txt" -Force -ErrorAction SilentlyContinue

# Remove attack location directory (ransomware payload)
Remove-Item "C:\AttackLocation" -Recurse -Force -ErrorAction SilentlyContinue

# Find all README_DECRYPT files
Get-ChildItem -Path C:\ -Recurse -Filter "*README_DECRYPT*" -ErrorAction SilentlyContinue
```

### 4. Clean Registry Entries

```powershell
# Check Run keys
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

# Remove specific entry
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AtomicEntry" -ErrorAction SilentlyContinue

# Check HKLM Run keys (requires admin)
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
```

### 5. Kill Processes

```powershell
# Find suspicious processes
Get-Process | Where-Object {$_.ProcessName -like "*atomic*" -or $_.ProcessName -like "*ransom*"}

# Kill specific process
Stop-Process -Name "atomic" -Force -ErrorAction SilentlyContinue

# Kill by PID
Stop-Process -Id 1234 -Force
```

### 6. Atomic Red Team Manual Cleanup

```powershell
# Import Atomic module
Import-Module C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1

# Cleanup specific tests
Invoke-AtomicTest T1082 -TestNumbers 1 -Cleanup
Invoke-AtomicTest T1053.005 -TestNumbers 1 -Cleanup
Invoke-AtomicTest T1136.001 -TestNumbers 5 -Cleanup
Invoke-AtomicTest T1490 -TestNumbers 1 -Cleanup
Invoke-AtomicTest T1070.001 -TestNumbers 1 -Cleanup
```

## Verification After Cleanup

### Comprehensive Verification

Run these commands to verify cleanup:

```powershell
# 1. Check for scheduled tasks
schtasks /query /fo csv | ConvertFrom-Csv | Where-Object {$_.TaskName -like "*Atomic*" -or $_.TaskName -like "*test*"}

# 2. Check for user accounts
Get-LocalUser | Where-Object {$_.Name -like "*Atomic*" -or $_.Name -like "*test*"}

# 3. Check for ransom notes
Get-ChildItem "C:\Temp\*DECRYPT*" -ErrorAction SilentlyContinue
Get-ChildItem "C:\Users\Public\Desktop\*DECRYPT*" -ErrorAction SilentlyContinue

# 4. Check for suspicious processes
Get-Process | Where-Object {$_.ProcessName -like "*atomic*" -or $_.ProcessName -like "*ransom*"}

# 5. Check registry
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue | Format-List

# 6. Check for Atomic directories (optional - keep if using Atomic Red Team)
Test-Path C:\AtomicRedTeam
```

### Expected Results

All verification commands should return empty results (no matches found), indicating successful cleanup.

### Verification Script

Create a quick verification script:

```powershell
# verify-cleanup.ps1
Write-Host "`nVerifying cleanup..." -ForegroundColor Cyan

$issues = @()

# Check tasks
$tasks = schtasks /query /fo csv 2>$null | ConvertFrom-Csv | Where-Object {$_.TaskName -like "*Atomic*"}
if ($tasks) { $issues += "Found scheduled tasks: $($tasks.TaskName)" }

# Check users
$users = Get-LocalUser | Where-Object {$_.Name -like "*Atomic*" -or $_.Name -like "*test*"}
if ($users) { $issues += "Found user accounts: $($users.Name)" }

# Check files
if (Test-Path "C:\Temp\*DECRYPT*.txt") { $issues += "Found ransom notes in C:\Temp" }
if (Test-Path "C:\Users\Public\Desktop\*DECRYPT*.txt") { $issues += "Found ransom notes on Desktop" }

# Check processes
$procs = Get-Process | Where-Object {$_.ProcessName -like "*atomic*" -or $_.ProcessName -like "*ransom*"}
if ($procs) { $issues += "Found processes: $($procs.ProcessName)" }

# Report
if ($issues.Count -eq 0) {
    Write-Host "✓ All artifacts cleaned successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠ Issues found:" -ForegroundColor Yellow
    $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
```

## Troubleshooting

### Error: "Access Denied" During Cleanup

**Problem:** Insufficient privileges to remove artifacts.

**Solution:**
```powershell
# Verify admin privileges
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Re-run PowerShell as Administrator
Start-Process powershell -Verb RunAs
```

### Error: "Cannot remove user - user is currently logged on"

**Problem:** Test account is currently logged in.

**Solution:**
```powershell
# List logged-on users
query user

# Log off specific session
logoff <session-id>

# Or force delete user
net user AtomicAdministrator /delete /y
```

### Script Reports Remaining Artifacts

**Problem:** Some artifacts not cleaned by script.

**Solution:**
1. Review the script output for specific items
2. Use manual cleanup commands from section above
3. Consider VM snapshot rollback if extensive artifacts remain

### Scheduled Task Won't Delete

**Problem:** Task is running or protected.

**Solution:**
```powershell
# Stop task first
Stop-ScheduledTask -TaskName "AtomicTask"

# Then delete
Unregister-ScheduledTask -TaskName "AtomicTask" -Confirm:$false

# Or force delete with schtasks
schtasks /delete /tn "AtomicTask" /f
```

### Registry Key Won't Delete

**Problem:** Registry key protected or in use.

**Solution:**
```powershell
# Take ownership (advanced)
$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$acl = Get-Acl $key
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
Set-Acl $key $acl

# Then delete
Remove-ItemProperty -Path $key -Name "AtomicEntry" -Force
```

### Process Won't Terminate

**Problem:** Process protected or system process.

**Solution:**
```powershell
# Force kill
Stop-Process -Id <PID> -Force

# If still running, check if it's a service
Get-Service | Where-Object {$_.DisplayName -like "*Atomic*"}

# Stop service
Stop-Service -Name "AtomicService" -Force
```

### Atomic Red Team Not Found

**Problem:** Script can't find Atomic Red Team for automated cleanup.

**Solution:**
```powershell
# Check if installed
Test-Path C:\AtomicRedTeam

# If not installed, script falls back to manual cleanup
# No action needed - manual cleanup will run

# To install Atomic Red Team:
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing)
Install-AtomicRedTeam -getAtomics -Force
```

## Alternative Cleanup: VM Snapshot Rollback

If cleanup is incomplete or you want to ensure full restoration:

### VMware Workstation/ESXi

1. Power off the VM
2. In VM settings, navigate to Snapshots
3. Select the pre-test snapshot
4. Click "Restore" or "Revert"
5. Power on the VM

### Hyper-V

```powershell
# List snapshots
Get-VMSnapshot -VMName "TestVM"

# Restore snapshot
Restore-VMSnapshot -VMName "TestVM" -Name "Pre-Ransomware-Test" -Confirm:$false

# Start VM
Start-VM -VMName "TestVM"
```

### VirtualBox

```bash
# List snapshots
VBoxManage snapshot "TestVM" list

# Restore snapshot
VBoxManage snapshot "TestVM" restore "Pre-Test"

# Start VM
VBoxManage startvm "TestVM"
```

## Shadow Copies Cannot Be Restored

**Important Note:** The ransomware simulation deletes Windows shadow copies (volume snapshots). This cleanup script **CANNOT** restore deleted shadow copies.

### Options for Shadow Copy Restoration

**Option 1: Create New Shadow Copies**
```powershell
# Create new shadow copy
wmic shadowcopy call create Volume='C:\'

# Verify creation
vssadmin list shadows
```

**Option 2: Enable System Protection**
```powershell
# Enable System Protection for C: drive
Enable-ComputerRestore -Drive "C:\"

# Configure restore point settings
vssadmin resize shadowstorage /for=C: /on=C: /maxsize=10GB
```

**Option 3: VM Snapshot Rollback**
- If shadow copies are critical, restore from VM snapshot taken before simulation

## Security Event Logs Cannot Be Fully Restored

The simulation clears the Security event log. While the cleanup script doesn't affect logs, be aware:

- Cleared events are permanently lost
- Event ID 1102 (log cleared) may be the only remaining evidence
- Backup event logs before testing if retention is important

### Export Logs Before Testing

```powershell
# Export Security log before testing
wevtutil epl Security C:\Backup\Security-Backup.evtx

# Restore after testing (appends, doesn't overwrite)
# Cannot restore - Windows doesn't support log import
# This is for reference only
```

## Best Practices

### After Every Test

1. **Run Cleanup Immediately**
   - Don't leave test artifacts in place
   - Security risk if forgotten

2. **Verify Cleanup**
   - Use verification commands
   - Manually check for artifacts

3. **Document Issues**
   - Note any cleanup failures
   - Report bugs in cleanup script

4. **Update Cleanup Script**
   - If new artifacts found, update script
   - Keep cleanup in sync with simulation

### Periodic Deep Cleaning

Even with cleanup script, perform periodic deep cleaning:

```powershell
# Full system scan for Atomic artifacts
Get-ChildItem C:\ -Recurse -Filter "*Atomic*" -ErrorAction SilentlyContinue

# Check all Run locations
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"

# Review all scheduled tasks
Get-ScheduledTask | Where-Object {$_.TaskPath -notlike "\Microsoft\*"}

# List all local users
Get-LocalUser
```

## Additional Resources

- [Atomic Red Team Cleanup Documentation](https://github.com/redcanaryco/invoke-atomicredteam/wiki/Cleanup)
- [PowerShell Scheduled Tasks](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/)
- [Local User Management](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/)
- [Windows Registry Management](https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-keys)

---

[← Back to Ransomware Simulation Documentation](ransomware-simulation.md) | [Back to Main README](../README.md)
