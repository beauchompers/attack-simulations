# Attack Simulations for Security Testing

A collection of controlled attack simulation scripts designed for cybersecurity professionals to test detection capabilities, validate security controls, and train incident response teams.

## Legal Disclaimer and Usage Terms

**IMPORTANT: READ BEFORE USE**

This repository contains security testing tools that simulate malicious behavior for **DEFENSIVE PURPOSES ONLY**.

### Authorized Use Only

These scripts are provided exclusively for:
- Security professionals testing detection and response capabilities
- Organizations validating their security monitoring and alerting
- Security teams developing and testing detection rules
- Incident response teams conducting training exercises
- Penetration testers with written authorization from the target organization
- Security researchers in controlled, authorized environments

### Prohibited Uses

**DO NOT USE THESE SCRIPTS**:
- Against systems you do not own or have explicit written authorization to test
- In production environments without proper approval and safety measures
- For malicious purposes or unauthorized access
- To cause harm, disruption, or data loss
- In violation of any applicable laws or regulations

### Legal Notice

By using these scripts, you acknowledge and agree that:

1. You have proper authorization to test the target systems
2. You understand the potential impact of running these simulations
3. You accept full responsibility for any consequences of use or misuse
4. The repository maintainers are not liable for any damages, legal consequences, or other issues arising from the use of these tools
5. You will comply with all applicable laws, regulations, and organizational policies

**Unauthorized access to computer systems is illegal under laws including but not limited to:**
- Computer Fraud and Abuse Act (CFAA) in the United States
- Computer Misuse Act in the United Kingdom
- Equivalent legislation in other jurisdictions

**Use at your own risk. Always obtain proper authorization before testing.**

---

## Repository Overview

This repository contains two main categories of attack simulations:

1. **AWS Attack Simulations** - Cloud-based security testing scenarios
2. **Atomic Red Team Simulations** - Endpoint-based MITRE ATT&CK technique simulations

All scripts are designed to generate observable security events that can be detected by properly configured security tools such as SIEM, EDR/XDR, CloudTrail, GuardDuty, and other monitoring solutions.

## Use Cases

### 1. Detection Rule Validation
Test whether your security monitoring tools can detect common attack patterns:
- IAM privilege escalation attempts
- Public S3 bucket misconfigurations
- Ransomware behavior patterns
- Defense evasion techniques

### 2. Security Team Training
Provide realistic attack scenarios for:
- SOC analyst training and skill development
- Incident response team exercises
- Purple team operations
- Security awareness demonstrations

### 3. Tool Testing and Tuning
Validate and optimize security tools:
- SIEM rule effectiveness
- EDR/XDR detection capabilities
- Cloud security posture management (CSPM)
- Alert tuning and false positive reduction

### 4. Compliance and Audit Support
Demonstrate security control effectiveness:
- Validate monitoring coverage for compliance frameworks
- Provide evidence of detection capabilities
- Test incident response procedures
- Document security control validation

---

## Available Scripts

### AWS Attack Simulations

| Script | Description | Documentation |
|--------|-------------|---------------|
| **aws-iam-attack.sh** | IAM privilege escalation demo | [📖 Full Documentation](docs/aws-iam-attack.md) |
| **aws-create-bucket.sh** | Public S3 bucket misconfiguration | [📖 Full Documentation](docs/aws-create-bucket.md) |
| **aws-create-bucket-2.sh** | Public S3 bucket with mock sensitive data (DLP testing) | [📖 Full Documentation](docs/aws-create-bucket-2.md) |

### Atomic Red Team Simulations

| Script | Description | Documentation |
|--------|-------------|---------------|
| **ransomware_simulation.ps1** | Multi-phase ransomware attack simulation | [📖 Full Documentation](docs/ransomware-simulation.md) |
| **cleanup.ps1** | Cleanup script for ransomware simulation | [📖 Full Documentation](docs/cleanup-script.md) |

---

## Quick Start Guide

### 1. IAM Privilege Escalation (AWS)

**[📖 Full Documentation](docs/aws-iam-attack.md)**

Simulates IAM privilege escalation from PowerUser to AdministratorAccess.

**Quick Start:**
```bash
# Install prerequisites (macOS)
brew install awscli jq

# Configure AWS CLI
aws configure

# Run simulation
./aws/aws-iam-attack.sh

# Cleanup
./aws/aws-iam-attack.sh cleanup
```

**Detection Opportunities:** CloudTrail events, GuardDuty findings, privilege escalation patterns

---

### 2. Public S3 Bucket (AWS)

**[📖 Full Documentation](docs/aws-create-bucket.md)**

Creates a publicly accessible S3 bucket to test misconfiguration detection.

**Quick Start:**
```bash
# Install prerequisites (macOS)
brew install awscli

# Configure AWS CLI
aws configure

# Run simulation
./aws/aws-create-bucket.sh

# Cleanup
aws s3 rb s3://<bucket-name> --force
```

**Detection Opportunities:** AWS Config violations, Security Hub findings, public bucket policies

---

### 3. Public S3 Bucket with Sensitive Data (AWS)

**[📖 Full Documentation](docs/aws-create-bucket-2.md)**

Creates a publicly accessible S3 bucket containing mock sensitive data (PII) for DLP testing.

**Quick Start:**
```bash
# Same prerequisites as aws-create-bucket.sh

# Run simulation
./aws/aws-create-bucket-2.sh

# Cleanup
aws s3 rb s3://<bucket-name> --force
```

**Detection Opportunities:** DLP alerts, Amazon Macie findings, sensitive data exposure, CASB detection

---

### 4. Ransomware Simulation (Windows)

**[📖 Full Documentation](docs/ransomware-simulation.md)**

Multi-phase ransomware attack using Atomic Red Team framework.

**Quick Start:**
```powershell
# Set execution policy (as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run simulation
.\atomic-scripts\simple-ransomware-simulation\ransomware_simulation.ps1

# Cleanup
.\atomic-scripts\simple-ransomware-simulation\cleanup.ps1
```

**Detection Opportunities:** EDR/XDR alerts, Sysmon events, shadow copy deletion, event log clearing

---

## Detailed Documentation

Each script has comprehensive documentation including:
- Detailed prerequisites and setup
- Step-by-step usage instructions
- Required permissions
- Observable security events and SIEM queries
- Troubleshooting guides
- Testing scenarios

See the [docs/](docs/) directory or click the "📖 Full Documentation" links above.

---

## AWS Prerequisites Summary

**Required Software:**
- AWS CLI
- jq (for IAM attack script)

**Installation:**
```bash
# macOS
brew install awscli jq

# Linux
sudo apt-get install awscli jq

# Windows
choco install awscli jq
```

**Configuration:**
```bash
aws configure
```

---

## Windows Prerequisites Summary

**Required:**
- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1+ with Administrator privileges
- Internet connection (for Atomic Red Team installation)

**Setup:**
```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Script Overview

### AWS: IAM Privilege Escalation

**Purpose:** Test IAM privilege escalation detection
**Techniques:** T1078, T1098, T1136
**Duration:** ~2-3 minutes
**Cleanup:** Built-in
**[📖 Full Docs](docs/aws-iam-attack.md)**

### AWS: Public S3 Bucket

**Purpose:** Test S3 misconfiguration detection
**Techniques:** T1530
**Duration:** ~1-2 minutes
**Cleanup:** Manual
**[📖 Full Docs](docs/aws-create-bucket.md)**

### AWS: Public S3 Bucket with Sensitive Data

**Purpose:** Test DLP and data exposure detection
**Techniques:** T1530, Data Exfiltration
**Duration:** ~1-2 minutes
**Cleanup:** Manual
**[📖 Full Docs](docs/aws-create-bucket-2.md)**

### Windows: Ransomware Simulation

**Purpose:** Test endpoint detection and response
**Techniques:** T1082, T1087.001, T1053.005, T1136.001, T1491.001, T1490, T1070.001
**Duration:** ~8-10 minutes (default)
**Cleanup:** Automated script
**[📖 Full Docs](docs/ransomware-simulation.md)**

---

## Monitoring and Detection

After running simulations, check your security tools for detection:

### AWS CloudTrail Events
- IAM: `CreateUser`, `AttachUserPolicy`, `CreateAccessKey`
- S3: `CreateBucket`, `PutBucketPolicy`, `PutPublicAccessBlock`

### Windows Event Logs
- Security: Event IDs 4720, 4732, 4698, 1102
- Sysmon: Process creation, file creation, registry modifications

### SIEM/EDR Alerts
- Privilege escalation patterns
- Public S3 buckets
- Shadow copy deletion
- Event log clearing
- Scheduled task creation

**See individual script documentation for detailed SIEM queries and detection patterns.**

---

## Best Practices

### Before Running

1. **Get Authorization**: Written approval from management/system owners
2. **Use Test Environment**: Dedicated test AWS account or isolated VM
3. **Take Snapshots**: VM snapshots before running Windows simulations
4. **Notify Teams**: Alert SOC/security teams about test window
5. **Configure Monitoring**: Verify security tools are operational

### During Testing

1. **Monitor Actively**: Watch for alerts in real-time
2. **Document Events**: Record timestamps and event IDs
3. **Capture Evidence**: Screenshots of detections
4. **Note Response Times**: Track detection lag

### After Testing

1. **Run Cleanup**: Always execute cleanup scripts/commands
2. **Verify Cleanup**: Confirm all resources removed
3. **Analyze Results**: Review generated events and detections
4. **Document Findings**: Record gaps and improvement opportunities
5. **Update Rules**: Improve detections based on results

---

## Troubleshooting

For detailed troubleshooting, see individual script documentation:
- [AWS IAM Attack Troubleshooting](docs/aws-iam-attack.md#troubleshooting)
- [AWS S3 Bucket Troubleshooting](docs/aws-create-bucket.md#troubleshooting)
- [Ransomware Simulation Troubleshooting](docs/ransomware-simulation.md#troubleshooting)
- [Cleanup Script Troubleshooting](docs/cleanup-script.md#troubleshooting)

### Common Issues

**AWS: "AWS CLI not installed"**
```bash
brew install awscli  # macOS
```

**AWS: "Credentials not configured"**
```bash
aws configure
```

**Windows: "Scripts disabled"**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Windows: "Access Denied"**
- Run PowerShell as Administrator

---

## Contributing

When adding new attack simulations:

1. Follow existing script structure and conventions
2. Include comprehensive comments
3. Provide cleanup functionality
4. **Update documentation:**
   - Create detailed markdown file in [docs/](docs/)
   - Update this README with script summary
   - Update [CLAUDE.md](CLAUDE.md) with development guidance
5. Test in isolated environment
6. Document MITRE ATT&CK techniques

See [CLAUDE.md](CLAUDE.md) for detailed development guidelines.

---

## Resources

### MITRE ATT&CK Framework
- [MITRE ATT&CK Website](https://attack.mitre.org/)
- [Enterprise Tactics](https://attack.mitre.org/tactics/enterprise/)

### Atomic Red Team
- [Atomic Red Team GitHub](https://github.com/redcanaryco/atomic-red-team)
- [Invoke-AtomicRedTeam](https://github.com/redcanaryco/invoke-atomicredteam)

### AWS Security
- [AWS CloudTrail](https://docs.aws.amazon.com/cloudtrail/)
- [Amazon GuardDuty](https://docs.aws.amazon.com/guardduty/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

### Windows Security
- [Sysmon](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- [Windows Event Logging](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/security-auditing-overview)

---

## License

These scripts are provided for educational and defensive security testing purposes. Use responsibly and ethically.

**Always obtain proper authorization before testing and comply with all applicable laws and regulations.**
