# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains defensive security testing scripts for simulating various attack techniques. These scripts are designed for cybersecurity demonstration, testing detection capabilities, and training purposes only.

**IMPORTANT**: All scripts in this repository are for defensive security purposes only:
- Security team testing and validation
- Detection rule development and testing
- Security awareness and training demonstrations
- Incident response team practice

## Repository Structure

```
attack-simulations/
├── aws/                           # AWS-based attack simulations
│   ├── aws-iam-attack.sh         # IAM privilege escalation demo
│   ├── aws-create-bucket.sh      # Public S3 bucket misconfiguration demo
│   └── aws-create-bucket-2.sh    # Public S3 bucket with mock sensitive data (DLP testing)
└── atomic-scripts/                # Atomic Red Team based simulations
    └── simple-ransomware-simulation/
        ├── ransomware_simulation.ps1       # Windows ransomware simulation
        ├── cleanup.ps1                     # Cleanup script for simulation
        ├── run_ransomware_simulation.bat   # Standalone batch launcher (downloads from GitHub)
        └── run_cleanup.bat                 # Standalone cleanup batch launcher (downloads from GitHub)
```

## AWS Attack Simulations

### aws-iam-attack.sh
Demonstrates IAM privilege escalation patterns for detection testing.

**Usage**:
```bash
# Run demo with default user
./aws/aws-iam-attack.sh

# Run with custom username
./aws/aws-iam-attack.sh custom-user-name

# Cleanup resources
./aws/aws-iam-attack.sh demo-suspicious-user cleanup
# or
./aws/aws-iam-attack.sh cleanup
```

**Prerequisites**:
- AWS CLI installed and configured
- jq installed for JSON parsing
- Valid AWS credentials with IAM permissions

**What it does**:
1. Creates a demo IAM user with tags
2. Attaches PowerUserAccess policy
3. Escalates privileges to AdministratorAccess
4. Creates 2 sets of access keys (demonstrates credential sprawl)
5. Saves credentials to `demo_credentials_<username>.txt`
6. Displays current access keys and policies

**CloudTrail Events Generated**: This script creates multiple suspicious CloudTrail events including privilege escalation and access key creation patterns.

### aws-create-bucket.sh
Creates a publicly accessible S3 bucket with sample content for testing bucket misconfiguration detection.

**Usage**:
```bash
./aws/aws-create-bucket.sh
```

**Prerequisites**:
- AWS CLI installed and configured
- Valid AWS credentials with S3 permissions

**What it does**:
1. Creates S3 bucket with timestamped name
2. Uploads sample files (jokes, quotes, facts)
3. Removes block public access settings
4. Applies public read policy
5. Creates a `.txt` file with bucket name and cleanup commands

**Cleanup**:
```bash
aws s3 rb s3://<bucket-name> --force
```

### aws-create-bucket-2.sh
Enhanced version that creates a publicly accessible S3 bucket with mock sensitive data for DLP and data exposure testing.

**Usage**:
```bash
./aws/aws-create-bucket-2.sh
```

**Prerequisites**:
- AWS CLI installed and configured
- curl (for downloading mock data)
- Valid AWS credentials with S3 permissions

**What it does**:
1. Creates S3 bucket with timestamped name
2. Downloads mock sensitive data CSV (names, SSNs, emails, credit cards - all fake)
3. Uploads mock data and sample joke file
4. Removes block public access settings
5. Applies public read policy
6. Creates a `.txt` file with bucket name for tracking

**Use Cases**:
- DLP detection testing
- Amazon Macie testing
- Data classification testing
- CASB detection
- Incident response exercises for data exposure

**Cleanup**:
```bash
aws s3 rb s3://<bucket-name> --force
```

## Atomic Red Team Simulations

### ransomware_simulation.ps1
Windows-based ransomware simulation using Atomic Red Team framework.

**Usage (Option 1: Standalone Batch File - Recommended for Demos)**:
```batch
# Download and run the batch file - it will automatically download the PowerShell script from GitHub
# Perfect for security demonstrations and training

# Run with default 120 second delays between phases
run_ransomware_simulation.bat

# Run with custom delay (in seconds)
run_ransomware_simulation.bat 60
```

**Usage (Option 2: PowerShell Direct)**:
```powershell
# Run with default 120 second delays between phases
.\atomic-scripts\simple-ransomware-simulation\ransomware_simulation.ps1

# Run with custom delay (in seconds)
.\atomic-scripts\simple-ransomware-simulation\ransomware_simulation.ps1 -DelayBetweenPhases 60
```

**Prerequisites**:
- Windows system
- PowerShell 5.1+ (script auto-elevates to Administrator if needed)
- Internet connection (for Atomic Red Team installation)
- Optional: Ransomware payload file at `C:\AttackLocation\ransomware.exe`

**Auto-Configuration**:
- Automatically requests admin privileges if not already elevated
- Auto-installs NuGet package provider if needed
- Auto-installs Atomic Red Team if not present

**Simulation Phases**:
1. **Discovery** (Phase 1):
   - T1082: System Information Discovery
   - T1087.001: Local Account Discovery (manual enumeration)

2. **Persistence** (Phase 2):
   - T1053.005: Scheduled Task Creation
   - T1136.001: Hidden Admin Account Creation

3. **Impact** (Phase 3):
   - T1491.001: Ransom Note Creation
   - Optional: Execute ransomware payload (if present)
   - T1490: Inhibit System Recovery (delete shadow copies)

4. **Defense Evasion** (Phase 4):
   - T1070.001: Clear Windows Event Logs

**Atomic Red Team Installation**: Script auto-installs Atomic Red Team if not present at `C:\AtomicRedTeam`.

### run_ransomware_simulation.bat
Standalone batch file launcher for security demonstrations and training.

**Key Features**:
- Downloads PowerShell script directly from GitHub raw URL
- Executes script in memory (no local PowerShell files needed)
- Supports custom delay parameter
- Perfect for quick security demonstrations
- Mimics real-world attack delivery methods

**Usage**:
```batch
# Run with default 120-second delay
run_ransomware_simulation.bat

# Run with custom delay (60 seconds)
run_ransomware_simulation.bat 60
```

**Technical Details**:
- GitHub URL: `https://raw.githubusercontent.com/beauchompers/attack-simulations/main/atomic-scripts/simple-ransomware-simulation/ransomware_simulation.ps1`
- Uses PowerShell `-ExecutionPolicy Bypass` to avoid policy restrictions
- Downloads and executes script using `New-Object Net.WebClient` and `Invoke-Expression`
- Automatically triggers UAC elevation via the PowerShell script

### run_cleanup.bat
Standalone batch file launcher for cleanup operations.

**Key Features**:
- Downloads cleanup script directly from GitHub raw URL
- Executes script in memory
- Simplifies cleanup process for demonstrations

**Usage**:
```batch
run_cleanup.bat
```

**Technical Details**:
- GitHub URL: `https://raw.githubusercontent.com/beauchompers/attack-simulations/main/atomic-scripts/simple-ransomware-simulation/cleanup.ps1`
- Uses same execution approach as ransomware simulation launcher
- Automatically triggers UAC elevation via the PowerShell script

### cleanup.ps1
Cleanup script to remove all artifacts from ransomware simulation.

**Usage (Option 1: Standalone Batch File - Recommended for Demos)**:
```batch
# Download and run the batch file - it will automatically download the cleanup script from GitHub
run_cleanup.bat
```

**Usage (Option 2: PowerShell Direct)**:
```powershell
.\atomic-scripts\simple-ransomware-simulation\cleanup.ps1
```

**Auto-Configuration**:
- Automatically requests admin privileges if not already elevated

**What it cleans**:
- Atomic Red Team test artifacts
- Scheduled tasks
- User accounts created during simulation
- Ransom notes
- `C:\AttackLocation\` directory (ransomware payload location)
- Registry entries
- Lingering processes

## Development Guidelines

**⚠️ MANDATORY DOCUMENTATION REQUIREMENT**:
Before considering ANY script addition or modification complete, you MUST:
1. Create or update the corresponding `docs/<script-name>.md` file
2. Update README.md with the script information
3. Update this CLAUDE.md file
Failure to update all three locations means the task is NOT complete.

### Adding New AWS Simulations

1. Place scripts in `aws/` directory
2. Include colored output using the standard color variables:
   ```bash
   RED='\033[0;31m'
   GREEN='\033[0;32m'
   YELLOW='\033[1;33m'
   NC='\033[0m'
   ```
3. Include usage information via `show_usage()` function
4. Implement cleanup functionality
5. Check for required tools at script start
6. Use descriptive variable names with `DEMO_` or similar prefix

### Adding New Atomic Simulations

1. Place scripts in `atomic-scripts/<simulation-name>/`
2. Always include a cleanup script
3. Use the Atomic Red Team framework when possible
4. Include prerequisite checks with `-CheckPrereqs` and `-GetPrereqs`
5. Structure in phases with clear output
6. Add delays between phases to create distinct CloudTrail/event log entries
7. Document all MITRE ATT&CK techniques used

### Script Standards

- Always include clear warnings about demonstration/testing purpose
- Include prerequisite checks before execution
- Provide cleanup instructions or scripts
- Use color-coded output for better readability
- Add error handling and validation
- Document what events/logs will be generated

## Documentation Maintenance

**CRITICAL**: Whenever you modify scripts or add new ones to this repository, you MUST update documentation:

### Required Documentation Updates

1. **When Adding New Scripts**:
   - **ALWAYS create a detailed documentation file** in `docs/<script-name>.md` with:
     - Script purpose and detailed description
     - MITRE ATT&CK techniques covered
     - Prerequisites and installation instructions
     - Step-by-step usage instructions with examples
     - Required permissions (IAM policies for AWS, admin rights for Windows)
     - Observable security events and SIEM queries
     - Comprehensive troubleshooting guide
     - Testing scenarios and use cases
     - Safety notes and warnings

   - **Update [README.md](README.md)**:
     - Add script to "Available Scripts" table with link to detailed docs
     - Add script to "Quick Start Guide" section with basic usage
     - Add script to "Script Overview" section with summary

   - **Update this [CLAUDE.md](CLAUDE.md) file**:
     - Add to Repository Structure section
     - Add quick reference usage section
     - Document key technical details
     - Note any development patterns used

2. **When Modifying Existing Scripts**:
   - **Update the script's documentation file** in `docs/<script-name>.md`:
     - Update usage syntax or parameters
     - Update prerequisites or dependencies
     - Update generated events or artifacts
     - Update cleanup procedures
     - Add new troubleshooting sections if needed

   - **Update [README.md](README.md)** if changes affect:
     - Quick start commands
     - Script description or purpose
     - Prerequisites summary

   - **Update [CLAUDE.md](CLAUDE.md)** if:
     - Architectural patterns change
     - New auto-configuration features added
     - Script behavior significantly changes

   - **Update code comments** explaining the modifications

3. **Documentation Standards**:
   - Keep README.md user-focused (how to use, what it does)
   - Keep CLAUDE.md developer-focused (how to maintain, patterns to follow)
   - Include practical examples in both files
   - Document both happy path and error scenarios
   - Specify exact versions for critical dependencies

4. **Testing Documentation**:
   - After updating documentation, verify:
     - All commands are copy-paste ready
     - File paths are accurate
     - Prerequisites list is complete
     - Cleanup instructions work as documented

### Documentation File Purposes

- **README.md**: High-level overview and quick start guide
  - Legal disclaimers and usage terms
  - Script summaries with links to detailed docs
  - Quick start commands
  - Prerequisites summaries
  - Best practices overview

- **docs/[script-name].md**: Detailed per-script documentation
  - Complete usage instructions with examples
  - Prerequisites and installation steps
  - Required permissions (IAM policies, admin rights)
  - Observable events and SIEM queries
  - Comprehensive troubleshooting guides
  - Testing scenarios and use cases

- **CLAUDE.md**: Developer guide for Claude Code and maintainers
  - Quick reference for script usage
  - Development patterns and conventions
  - Architecture and design decisions
  - Code maintenance guidelines

## Testing Detection Rules

These scripts are designed to generate observable security events:
- **AWS**: CloudTrail events, GuardDuty findings, Config rule violations
- **Windows**: Event logs, EDR/XDR alerts, Sysmon events

After running simulations, check your security monitoring tools for detection of the simulated techniques.
