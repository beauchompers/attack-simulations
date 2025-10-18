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
│   └── aws-create-bucket.sh      # Public S3 bucket misconfiguration demo
└── atomic-scripts/                # Atomic Red Team based simulations
    └── simple-ransomware-simulation/
        ├── ransomware_simulation.ps1  # Windows ransomware simulation
        └── cleanup.ps1                # Cleanup script for simulation
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
5. Creates a `.txt` file with bucket name for tracking

**Cleanup**:
```bash
aws s3 rb s3://<bucket-name> --force
```

## Atomic Red Team Simulations

### ransomware_simulation.ps1
Windows-based ransomware simulation using Atomic Red Team framework.

**Usage**:
```powershell
# Run with default 120 second delays between phases
.\atomic-scripts\simple-ransomware-simulation\ransomware_simulation.ps1

# Run with custom delay (in seconds)
.\atomic-scripts\simple-ransomware-simulation\ransomware_simulation.ps1 -DelayBetweenPhases 60
```

**Prerequisites**:
- Windows system
- PowerShell with Administrator privileges
- Internet connection (for Atomic Red Team installation)
- Optional: Ransomware payload file at `C:\Temp\ransomware.exe`

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

### cleanup.ps1
Cleanup script to remove all artifacts from ransomware simulation.

**Usage**:
```powershell
.\atomic-scripts\simple-ransomware-simulation\cleanup.ps1
```

**What it cleans**:
- Atomic Red Team test artifacts
- Scheduled tasks
- User accounts created during simulation
- Ransom notes
- Registry entries
- Lingering processes

## Development Guidelines

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
   - Add a new section to [README.md](README.md) with:
     - Script purpose and use case
     - MITRE ATT&CK techniques covered
     - Complete usage instructions with examples
     - All prerequisites and dependencies
     - Required permissions (IAM for AWS, local admin for Windows)
     - Observable security events generated
     - Cleanup instructions
     - Safety notes and warnings
   - Add corresponding section to this CLAUDE.md file with:
     - Quick reference usage
     - Key technical details
     - Development patterns used

2. **When Modifying Existing Scripts**:
   - Update README.md to reflect any changes in:
     - Usage syntax or parameters
     - Prerequisites or dependencies
     - Generated events or artifacts
     - Cleanup procedures
   - Update CLAUDE.md if architectural patterns change
   - Update code comments explaining the modifications

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
