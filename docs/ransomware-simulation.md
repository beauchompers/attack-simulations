# Ransomware Simulation (Atomic Red Team)

**Script:** [atomic-scripts/simple-ransomware-simulation/ransomware_simulation.ps1](../atomic-scripts/simple-ransomware-simulation/ransomware_simulation.ps1)

## Purpose

Simulates a complete ransomware attack chain from initial discovery through impact and defense evasion, using legitimate MITRE ATT&CK techniques via the Atomic Red Team framework. This script is designed for testing endpoint detection and response (EDR/XDR) capabilities, SIEM alerting, and incident response procedures.

## MITRE ATT&CK Techniques

This simulation covers 4 phases with multiple techniques:

### Phase 1: Discovery
- **T1082** - System Information Discovery
- **T1087.001** - Account Discovery: Local Account

### Phase 2: Persistence
- **T1053.005** - Scheduled Task/Job: Scheduled Task
- **T1136.001** - Create Account: Local Account

### Phase 3: Impact
- **T1491.001** - Defacement: Internal Defacement (ransom notes)
- **T1490** - Inhibit System Recovery (delete volume shadow copies)

### Phase 4: Defense Evasion
- **T1070.001** - Indicator Removal: Clear Windows Event Logs

## What This Script Does

### Phase 1: Discovery (Reconnaissance)

1. **System Information Discovery (T1082)**
   - Collects OS version, hostname, domain membership
   - Gathers system architecture information
   - Uses built-in Windows utilities

2. **Local Account Discovery (T1087.001)**
   - Enumerates all local user accounts (`net user`)
   - Lists local users with details (`Get-LocalUser`)
   - Checks local group memberships (Users, Administrators)
   - Examines user directories in `C:\Users\`
   - Lists stored credentials (`cmdkey.exe /list`)

### Phase 2: Persistence (Establishing Foothold)

1. **Scheduled Task Creation (T1053.005)**
   - Creates a scheduled task that runs on system startup
   - Provides attacker with persistence mechanism
   - Uses Windows Task Scheduler

2. **Hidden Admin Account (T1136.001)**
   - Creates a local administrative account
   - Provides alternate access method
   - Account can be used if primary access is lost

### Phase 3: Impact (Ransomware Execution)

1. **Ransom Note Creation (T1491.001)**
   - Creates ransom notes in multiple locations:
     - `C:\Temp\README_DECRYPT.txt`
     - `C:\Users\Public\Desktop\README_DECRYPT.txt`
   - Notes contain simulated ransom demands
   - Clearly marked as SIMULATION

2. **Optional Payload Execution**
   - If ransomware sample exists at `C:\Temp\ransomware.exe`
   - Executes the payload in hidden window
   - Useful for testing with safe ransomware samples (e.g., WildFire test files)

3. **Inhibit System Recovery (T1490)**
   - Deletes volume shadow copies using `vssadmin`
   - Prevents system restore
   - Prevents file recovery from backups
   - **This is destructive - shadow copies are permanently deleted**

### Phase 4: Defense Evasion (Cover Tracks)

1. **Clear Security Logs (T1070.001)**
   - Attempts to clear Windows Security event log
   - Covers attacker tracks
   - Should trigger alerts in properly configured monitoring

## Prerequisites

### Required System

- **Operating System**: Windows 10, Windows 11, or Windows Server 2016+
- **PowerShell**: Version 5.1 or higher
- **Privileges**: Administrator rights (required)
- **Internet Connection**: Required for initial Atomic Red Team installation

### Check PowerShell Version

```powershell
$PSVersionTable.PSVersion
```

Should show version 5.1 or higher.

### Setting Execution Policy

The script requires PowerShell script execution to be enabled:

```powershell
# Check current policy
Get-ExecutionPolicy

# Set for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or for entire machine (requires admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

**Note:** The script will automatically attempt to elevate to Administrator privileges if not already running as admin. If launched without admin rights, it will relaunch itself with elevated privileges.

### Atomic Red Team Installation

The script will automatically install Atomic Red Team if not present, including:

- **NuGet Package Provider** (auto-installed if needed)
- **Invoke-AtomicRedTeam PowerShell module**
- **Atomic test definitions** for all MITRE ATT&CK techniques
- **Test dependencies and prerequisites**

**Installation Location:** `C:\AtomicRedTeam`

Manual pre-installation (optional):
```powershell
# Install NuGet provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Install Atomic Red Team
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing)
Install-AtomicRedTeam -getAtomics -Force
```

### Optional: Ransomware Sample

For advanced testing, you can place a test ransomware sample:

**Location:** `C:\AttackLocation\ransomware.exe`

**WildFire Test Sample:**
The script includes a variable for the WildFire test malware URL:
```powershell
# Included in script
$malwareUrl = "https://wildfire.paloaltonetworks.com/publicapi/test/pe"
```

You can manually download and place at `C:\AttackLocation\ransomware.exe`:
```powershell
# Create directory
New-Item -Path "C:\AttackLocation" -ItemType Directory -Force

# Download WildFire test sample (safe for testing)
Invoke-WebRequest -Uri "https://wildfire.paloaltonetworks.com/publicapi/test/pe" -OutFile "C:\AttackLocation\ransomware.exe"
```

**Other Recommended Sources:**
- Palo Alto WildFire test files (safe malware samples)
- Any.run sandbox samples
- VirusTotal test files
- **NEVER use real ransomware**

If no file exists at this path, the script skips payload execution (other phases still run).

## Usage

### Basic Usage

Run with default settings (120-second delays):

```powershell
# Navigate to script directory
cd C:\path\to\attack-simulations\atomic-scripts\simple-ransomware-simulation\

# Run script
.\ransomware_simulation.ps1
```

### Custom Delay Between Phases

Adjust timing between phases for different testing scenarios:

```powershell
# 60-second delays (faster testing)
.\ransomware_simulation.ps1 -DelayBetweenPhases 60

# 30-second delays (rapid testing)
.\ransomware_simulation.ps1 -DelayBetweenPhases 30

# 300-second delays (5 minutes, more distinct events)
.\ransomware_simulation.ps1 -DelayBetweenPhases 300
```

**Timing Recommendations:**
- **Quick Testing**: 30 seconds - Total runtime ~2-3 minutes
- **Standard Testing**: 120 seconds (default) - Total runtime ~8-10 minutes
- **Realistic Timing**: 300+ seconds - Total runtime ~20+ minutes
- **Detection Training**: Longer delays create more distinct event clusters

### Running from Different Location

```powershell
# Run from any location using full path
C:\attack-simulations\atomic-scripts\simple-ransomware-simulation\ransomware_simulation.ps1 -DelayBetweenPhases 60
```

## Script Output

The script provides color-coded output for each phase:

### Example Output

```
=== Ransomware Simulation Demo ===
Checking Atomic Red Team installation...
Atomic Red Team found, importing module...
Atomic Red Team is ready
Starting ransomware simulation in 5 seconds...

=== Phase 1: Discovery ===
Executing T1082 - System Information Discovery
  Prerequisites met
  Running test...
  Test completed

Executing T1087.001 - Local Account Discovery (Manual)
  Enumerating local accounts...
  Getting detailed user information...
  Checking local group membership...
  Examining user directories...
  Checking stored credentials...
Phase 1 Discovery completed
[Waiting 120 seconds before next phase...]

=== Phase 2: Persistence ===
Executing T1053.005 - Scheduled Task Creation
  Getting prerequisites for T1053.005...
  Prerequisites installed
  Running test...
  Test completed

Executing T1136.001 - Hidden Admin Account Creation
  Getting prerequisites for T1136.001...
  Prerequisites installed
  Running test...
  Test completed
Phase 2 Persistence completed
[Waiting 120 seconds before next phase...]

=== Phase 3: Impact ===
Executing T1491.001 - Creating Ransom Note
  Creating ransom notes...
  Ransom note created: C:\Temp\README_DECRYPT.txt
  Ransom note created: C:\Users\Public\Desktop\README_DECRYPT.txt

Executing Ransomware Payload
  No payload found at C:\Temp\ransomware.exe (skipping)

Executing T1490 - Inhibit System Recovery - Delete Volume Shadow Copies
  Running test...
  Shadow copies deleted
  Test completed
Phase 3 Impact completed

=== Phase 4: Defense Evasion and Cover Tracks ===
Executing T1070.001 - Security Log Clearing
  Getting prerequisites for T1070.001...
  Prerequisites installed
  Running test...
  Security log cleared
  Test completed
Phase 4 Defense Evasion and Cover Tracks completed

=== Ransomware Simulation Complete! ===
Check your XSIAM console for detection alerts
```

### Color Coding

- **Yellow**: Section headers and important notices
- **Cyan**: Phase headers
- **Gray**: Individual test execution
- **Dark Gray**: Detailed operation descriptions
- **Green**: Success messages
- **Red**: Impact phase and critical operations

## Observable Security Events

### Windows Event Logs

**Security Log (if not cleared by Phase 4):**
- **Event ID 4720** - User account created (T1136.001)
- **Event ID 4732** - User added to security-enabled local group
- **Event ID 4698** - Scheduled task created (T1053.005)
- **Event ID 4104** - PowerShell script block logging
- **Event ID 1102** - Security audit log cleared (T1070.001) - May not be logged if log is cleared

**System Log:**
- **Event ID 7045** - Service installation (related to scheduled task)
- **Event ID 104** - Event log cleared

**Application Log:**
- Atomic Red Team execution artifacts
- PowerShell module loading events

### Sysmon Events (if installed)

If Sysmon is installed, expect these events:

- **Event ID 1** - Process creation
  - `powershell.exe`
  - `cmd.exe`
  - `vssadmin.exe`
  - `wevtutil.exe`
  - `net.exe`

- **Event ID 11** - File creation
  - Ransom notes: `README_DECRYPT.txt`
  - Atomic test files

- **Event ID 13** - Registry value set
  - Scheduled task registry entries
  - Persistence mechanisms

- **Event ID 12** - Registry object created
  - New task registrations

### EDR/XDR Alerts

Expected alerts from endpoint security tools:

1. **Suspicious PowerShell Execution**
   - Execution policy bypass
   - Script block logging anomalies
   - Encoded command detection

2. **Shadow Copy Deletion**
   - `vssadmin.exe Delete Shadows`
   - High severity ransomware indicator
   - System recovery prevention

3. **Event Log Clearing**
   - `wevtutil.exe` execution
   - Security log manipulation
   - Defense evasion tactic

4. **Scheduled Task Creation**
   - New task in unusual location
   - Persistence mechanism
   - Auto-start task

5. **Local Account Creation**
   - New administrative account
   - Privilege escalation risk
   - Unauthorized access

6. **File Creation Patterns**
   - `README` files in multiple locations
   - Ransom note indicators
   - Mass file operations (if payload executes)

### SIEM Detection Examples

**Splunk Query - Shadow Copy Deletion:**
```spl
index=windows EventCode=1 Image="*vssadmin.exe*" CommandLine="*Delete Shadows*"
| table _time ComputerName User CommandLine ParentImage
```

**Splunk Query - Event Log Clearing:**
```spl
index=windows (EventCode=104 OR EventCode=1102)
| stats count by ComputerName, EventCode, User
| where count > 0
```

**Elastic Query - Scheduled Task Creation:**
```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "event.code": "4698" }},
        { "match": { "event.action": "scheduled-task-created" }}
      ]
    }
  }
}
```

## Safety and Best Practices

### CRITICAL WARNINGS

⚠️ **This script performs destructive operations:**
- Deletes volume shadow copies (cannot be recovered)
- Clears security event logs (audit trail lost)
- Creates administrative accounts (security risk)

⚠️ **ALWAYS run in isolated test environment:**
- Virtual machine (recommended)
- Isolated test network
- Non-production system
- Disposable environment

⚠️ **Take snapshots before running:**
- VM snapshot before execution
- System restore point (though script deletes shadow copies)
- Backup critical data

### Before Running

1. **Environment Preparation**
   - Use virtual machine or isolated test system
   - Take VM snapshot for easy rollback
   - Disconnect from production network if possible
   - Ensure you have backup access to the system

2. **Monitoring Setup**
   - Verify EDR/XDR agent is operational
   - Enable enhanced PowerShell logging
   - Configure Sysmon if available
   - Verify SIEM is receiving events from test system

3. **Authorization and Notification**
   - Get written approval from management
   - Notify security operations center (SOC)
   - Document test window
   - Assign monitoring personnel

4. **Check Prerequisites**
   ```powershell
   # Verify admin privileges
   ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

   # Verify PowerShell version
   $PSVersionTable.PSVersion

   # Verify internet connectivity
   Test-NetConnection -ComputerName google.com -Port 443
   ```

### During Testing

1. **Monitor Actively**
   - Watch EDR console for alerts
   - Monitor SIEM for events
   - Check Windows Event Viewer
   - Document all observations

2. **Record Timing**
   - Note start time of each phase
   - Record when alerts fire
   - Measure detection lag time
   - Document response actions

3. **Capture Evidence**
   - Screenshot EDR alerts
   - Export relevant event logs
   - Save SIEM query results
   - Document what was/wasn't detected

### After Testing

1. **Run Cleanup** (See [cleanup-script.md](cleanup-script.md))
   ```powershell
   .\cleanup.ps1
   ```

2. **Verify Cleanup**
   - Check for remaining scheduled tasks
   - Verify test accounts removed
   - Confirm ransom notes deleted
   - Check for lingering processes

3. **Restore if Needed**
   - Revert to VM snapshot if artifacts remain
   - Restore from backup if necessary
   - Recreate shadow copies/restore points

4. **Analyze Results**
   - Review all generated events
   - Document detection gaps
   - Identify false negatives
   - Update detection rules
   - Share findings with team

## Troubleshooting

### Error: "Running scripts is disabled on this system"

**Problem:** PowerShell execution policy blocks script execution.

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Temporarily bypass (less secure)
powershell.exe -ExecutionPolicy Bypass -File .\ransomware_simulation.ps1
```

### Error: "This script requires Administrator privileges"

**Problem:** Not running PowerShell as Administrator.

**Solution:**
1. Right-click PowerShell icon
2. Select "Run as Administrator"
3. Navigate to script directory
4. Run script again

### Error: "Atomic Red Team installation failed"

**Problem:** Internet connectivity or download issues.

**Solution:**
```powershell
# Manual installation
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing)
Install-AtomicRedTeam -getAtomics -Force

# Check installation
Test-Path C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1

# Import module
Import-Module C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1
```

### Error: "Prerequisites not met" for specific test

**Problem:** Required files or tools missing for Atomic test.

**Solution:**
```powershell
# Atomic Red Team should auto-install prerequisites
# If it fails, manually install:
Invoke-AtomicTest T1082 -GetPrereqs

# Check prerequisites without running
Invoke-AtomicTest T1082 -CheckPrereqs
```

### Error: "Access Denied" when deleting shadow copies

**Problem:** Insufficient privileges or VSS service not running.

**Solution:**
```powershell
# Verify admin privileges
whoami /groups | findstr "S-1-5-32-544"

# Check VSS service
Get-Service -Name VSS

# Start VSS if stopped
Start-Service -Name VSS

# Verify shadow copies exist
vssadmin list shadows
```

### Shadow Copy Deletion Appears to Succeed But Doesn't

**Problem:** No shadow copies existed to delete.

**Solution:**
```powershell
# Check if shadow copies exist
vssadmin list shadows

# Create a shadow copy for testing
wmic shadowcopy call create Volume='C:\'

# Verify creation
vssadmin list shadows

# Re-run simulation
```

### Event Log Clearing Fails

**Problem:** Event log service protected or access denied.

**Solution:**
```powershell
# Verify admin privileges
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Check Event Log service
Get-Service -Name EventLog

# Alternative method to clear logs
wevtutil.exe cl Security
```

### Script Hangs or Times Out

**Problem:** Atomic test stuck or waiting for input.

**Solution:**
1. Press `Ctrl+C` to terminate
2. Close PowerShell window
3. Revert to VM snapshot
4. Check Windows Defender isn't blocking execution:
   ```powershell
   # Temporarily disable Windows Defender (test environments only)
   Set-MpPreference -DisableRealtimeMonitoring $true
   ```

### Windows Defender Blocks Execution

**Problem:** Antivirus quarantines Atomic Red Team or script.

**Solution:**
```powershell
# Add exclusion for test directory (test environments only)
Add-MpPreference -ExclusionPath "C:\AtomicRedTeam"
Add-MpPreference -ExclusionPath "C:\path\to\attack-simulations"

# Restore after testing
Remove-MpPreference -ExclusionPath "C:\AtomicRedTeam"
```

## Testing Scenarios

### Scenario 1: Comprehensive EDR Testing

**Goal:** Test all EDR detection capabilities.

**Steps:**
1. Run full simulation with default timing
2. Monitor EDR console throughout execution
3. Document which phases trigger alerts
4. Note detection lag times
5. Analyze which techniques weren't detected
6. Run cleanup

**Expected Detections:**
- Shadow copy deletion (high confidence)
- Event log clearing (high confidence)
- Scheduled task creation (medium confidence)
- Account creation (medium confidence)
- PowerShell anomalies (variable)

### Scenario 2: SIEM Alert Tuning

**Goal:** Tune SIEM rules to reduce false positives while catching this attack.

**Steps:**
1. Run simulation
2. Export all event logs generated
3. Import into SIEM
4. Create/tune detection rules
5. Run simulation again
6. Verify rules trigger appropriately
7. Run cleanup

**Expected Outcome:**
- Detection rules created for each technique
- False positive rate <5%
- Alert within 5 minutes of execution

### Scenario 3: Incident Response Exercise

**Goal:** Practice incident response procedures.

**Steps:**
1. Coordinate with IR team without revealing timing
2. Run simulation
3. Wait for IR team to detect and respond
4. Measure response timeline
5. Evaluate response actions
6. Conduct post-incident review
7. Run cleanup

**Expected Timeline:**
- Detection: 5-15 minutes
- Initial response: 15-30 minutes
- Containment actions: 30-60 minutes
- Full analysis: 1-2 hours

### Scenario 4: Ransomware Payload Testing

**Goal:** Test detection with actual ransomware sample.

**Steps:**
1. Obtain safe test ransomware (WildFire sample)
2. Place at `C:\Temp\ransomware.exe`
3. Run simulation
4. Monitor EDR for payload execution detection
5. Verify payload contained/blocked
6. Run cleanup
7. Delete test payload

**Expected Outcome:**
- Payload detected on execution
- EDR blocks or quarantines payload
- Alert triggered immediately
- Automated containment actions

## Additional Resources

### MITRE ATT&CK References
- [T1082 - System Information Discovery](https://attack.mitre.org/techniques/T1082/)
- [T1087.001 - Local Account Discovery](https://attack.mitre.org/techniques/T1087/001/)
- [T1053.005 - Scheduled Task](https://attack.mitre.org/techniques/T1053/005/)
- [T1136.001 - Create Local Account](https://attack.mitre.org/techniques/T1136/001/)
- [T1491.001 - Internal Defacement](https://attack.mitre.org/techniques/T1491/001/)
- [T1490 - Inhibit System Recovery](https://attack.mitre.org/techniques/T1490/)
- [T1070.001 - Clear Windows Event Logs](https://attack.mitre.org/techniques/T1070/001/)

### Atomic Red Team
- [Atomic Red Team GitHub](https://github.com/redcanaryco/atomic-red-team)
- [Invoke-AtomicRedTeam Documentation](https://github.com/redcanaryco/invoke-atomicredteam/wiki)
- [Getting Started with Atomic Red Team](https://atomicredteam.io/)

### Windows Security
- [PowerShell Script Block Logging](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging)
- [Sysmon Configuration](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- [Windows Event Forwarding](https://docs.microsoft.com/en-us/windows/security/threat-protection/use-windows-event-forwarding-to-assist-in-intrusion-detection)

---

[← Back to Main README](../README.md) | [Cleanup Script Documentation →](cleanup-script.md)
