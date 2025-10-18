# IAM Privilege Escalation Demo

**Script:** [aws/aws-iam-attack.sh](../aws/aws-iam-attack.sh)

## Purpose

Simulates an IAM privilege escalation attack where a user with PowerUser access escalates to AdministratorAccess and creates multiple access keys to establish persistence. This script is designed for testing detection capabilities for IAM-based privilege escalation patterns.

## MITRE ATT&CK Techniques

- **T1078** - Valid Accounts
- **T1098** - Account Manipulation
- **T1136** - Create Account
- **Privilege Escalation** via IAM Policy Manipulation

## What This Script Does

1. Creates a demo IAM user with security tags (`Purpose=SecurityDemo`, `Environment=Demo`)
2. Attaches PowerUserAccess managed policy to the user
3. Escalates privileges by attaching AdministratorAccess managed policy
4. Creates 2 sets of access keys (demonstrating credential sprawl and AWS's 2-key limit)
5. Saves credentials to a local file `demo_credentials_<username>.txt`
6. Displays current access keys and attached policies for verification

## Prerequisites

### Required Software

- **AWS CLI** - Command-line tool for AWS management
- **jq** - JSON processor for parsing AWS CLI output
- **bash** - Shell interpreter (standard on macOS/Linux)

### Installation Instructions

**macOS:**
```bash
brew install awscli jq
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install awscli jq
```

**Windows:**
```powershell
# Using Chocolatey
choco install awscli jq
```

### AWS Configuration

Configure AWS CLI with valid credentials:
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (e.g., us-east-1)
# Enter default output format (json recommended)
```

Verify configuration:
```bash
aws sts get-caller-identity
```

### Required IAM Permissions

The user/role running this script needs the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateUser",
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:GetUser",
        "iam:DeleteAccessKey",
        "iam:DetachUserPolicy",
        "iam:DeleteUser",
        "iam:TagUser"
      ],
      "Resource": "*"
    }
  ]
}
```

**Note:** For production testing, scope the `Resource` field to specific ARNs instead of `"*"`.

## Usage

### Basic Usage

Run with default username (`demo-suspicious-user`):
```bash
./aws/aws-iam-attack.sh
```

### Custom Username

Specify a custom username for the demo user:
```bash
./aws/aws-iam-attack.sh my-test-user
```

### View Help

Display usage information:
```bash
./aws/aws-iam-attack.sh --help
# or
./aws/aws-iam-attack.sh -h
# or
./aws/aws-iam-attack.sh help
```

### Cleanup

Remove all created resources:

```bash
# Cleanup default user
./aws/aws-iam-attack.sh cleanup

# Cleanup specific user
./aws/aws-iam-attack.sh my-test-user cleanup

# Alternative syntax
./aws/aws-iam-attack.sh demo-suspicious-user cleanup
```

## Script Output

The script provides color-coded output:

- **GREEN**: Successful operations
- **YELLOW**: Warnings and important information
- **RED**: Errors

Example output:
```
[INFO] Starting AWS IAM Privilege Escalation Demo
[WARNING] This script is for DEMONSTRATION purposes only!
[INFO] Running as: arn:aws:iam::123456789012:user/admin
[INFO] Creating demo user: demo-suspicious-user
[INFO] User demo-suspicious-user created successfully
[INFO] Attaching PowerUserAccess policy to demo-suspicious-user
[INFO] PowerUserAccess policy attached successfully
[INFO] Escalating privileges to AdministratorAccess
[INFO] AdministratorAccess policy attached successfully
[WARNING] User demo-suspicious-user now has FULL ADMIN access!
[INFO] Creating 2 sets of access keys for demo-suspicious-user
[INFO] Creating access key set 1/2
[INFO] Access key set 1 created successfully
  Access Key ID: AKIAIOSFODNN7EXAMPLE
  Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
[INFO] Creating access key set 2/2
[INFO] Access key set 2 created successfully
  Access Key ID: AKIAI44QH8DHBEXAMPLE
  Secret Access Key: je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
[INFO] Both access key sets created successfully!
[INFO] Credentials saved to demo_credentials_demo-suspicious-user.txt
[WARNING] This creates multiple persistent access methods - perfect for demonstrating credential sprawl
```

## Generated Files

### Credentials File

The script creates a file named `demo_credentials_<username>.txt` containing:

```
# Demo credentials for demo-suspicious-user
# Created on Sat Oct 18 10:30:00 PDT 2025

# Access Key Set 1
ACCESS_KEY_ID_1=AKIAIOSFODNN7EXAMPLE
SECRET_ACCESS_KEY_1=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Access Key Set 2
ACCESS_KEY_ID_2=AKIAI44QH8DHBEXAMPLE
SECRET_ACCESS_KEY_2=je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
```

**IMPORTANT:** Treat this file as highly sensitive. It contains valid AWS credentials with administrator access.

## Observable Security Events

Running this script generates multiple security events that should be detected by properly configured monitoring:

### AWS CloudTrail Events

Monitor for these events in CloudTrail:

1. **CreateUser**
   - EventName: `CreateUser`
   - Indicates new IAM user creation
   - Tags include `Purpose=SecurityDemo`

2. **AttachUserPolicy** (PowerUserAccess)
   - EventName: `AttachUserPolicy`
   - PolicyArn: `arn:aws:iam::aws:policy/PowerUserAccess`

3. **AttachUserPolicy** (AdministratorAccess) - **HIGH SEVERITY**
   - EventName: `AttachUserPolicy`
   - PolicyArn: `arn:aws:iam::aws:policy/AdministratorAccess`
   - This is the privilege escalation event

4. **CreateAccessKey** (2 events)
   - EventName: `CreateAccessKey`
   - Multiple key creations in short timeframe
   - Indicates potential credential persistence

### Detection Patterns

**Privilege Escalation Pattern:**
- Multiple `AttachUserPolicy` events for same user within short timeframe
- Escalation from lower privileges (PowerUser) to higher privileges (Administrator)
- User attaching high-privilege policies to themselves or other users

**Credential Sprawl Pattern:**
- Multiple `CreateAccessKey` events for same user
- Creation of maximum allowed access keys (2 per user)
- Access key creation immediately after privilege escalation

### Amazon GuardDuty

May trigger findings such as:
- `Policy:IAMUser/RootCredentialUsage`
- `Persistence:IAMUser/AnomalousBehavior`
- Custom findings based on your GuardDuty configuration

### AWS Security Hub

Check for:
- IAM.1 - Avoid the use of root account
- IAM.2 - Ensure MFA is enabled for all IAM users
- Custom insights based on CloudTrail events

### Example SIEM Query (Splunk)

```spl
index=aws sourcetype=aws:cloudtrail eventName IN (AttachUserPolicy, PutUserPolicy)
| stats count values(requestParameters.policyArn) as policies by userIdentity.principalId eventTime
| where count > 1
| search policies="*AdministratorAccess*"
```

### Example SIEM Query (Elastic)

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "event.action": "AttachUserPolicy" }},
        { "match": { "aws.cloudtrail.request_parameters": "*AdministratorAccess*" }},
        { "range": { "@timestamp": { "gte": "now-1h" }}}
      ]
    }
  }
}
```

## Cleanup

The script includes comprehensive cleanup functionality:

### What Gets Cleaned Up

1. **IAM Policies**: Detaches both PowerUserAccess and AdministratorAccess policies
2. **Access Keys**: Deletes both sets of created access keys
3. **IAM User**: Removes the demo user completely
4. **Local Files**: Deletes the credentials file

### Cleanup Commands

```bash
# Automated cleanup using script
./aws/aws-iam-attack.sh cleanup

# Manual cleanup (if needed)
# List access keys
aws iam list-access-keys --user-name demo-suspicious-user

# Delete each access key
aws iam delete-access-key --user-name demo-suspicious-user --access-key-id AKIAIOSFODNN7EXAMPLE
aws iam delete-access-key --user-name demo-suspicious-user --access-key-id AKIAI44QH8DHBEXAMPLE

# Detach policies
aws iam detach-user-policy --user-name demo-suspicious-user --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
aws iam detach-user-policy --user-name demo-suspicious-user --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Delete user
aws iam delete-user --user-name demo-suspicious-user

# Remove credentials file
rm demo_credentials_demo-suspicious-user.txt
```

### Verification After Cleanup

```bash
# Verify user is deleted (should return error)
aws iam get-user --user-name demo-suspicious-user

# Expected output:
# An error occurred (NoSuchEntity) when calling the GetUser operation:
# The user with name demo-suspicious-user cannot be found.
```

## Safety and Best Practices

### Before Running

1. **Get Authorization**: Obtain written approval from appropriate stakeholders
2. **Use Test Account**: Run in a dedicated test/sandbox AWS account when possible
3. **Document Test Window**: Record when the test will be executed
4. **Notify Teams**: Alert security monitoring teams to expect test activity
5. **Check Costs**: Be aware that CloudTrail logging and GuardDuty may incur costs

### During Testing

1. **Monitor in Real-Time**: Watch for security alerts and detections
2. **Document Events**: Record CloudTrail event IDs and timestamps
3. **Capture Screenshots**: Save evidence of detections (or lack thereof)
4. **Note Response Times**: Track how long it takes for alerts to fire

### After Testing

1. **Run Cleanup**: Always execute cleanup to remove test resources
2. **Verify Cleanup**: Confirm all resources were deleted
3. **Review Events**: Analyze CloudTrail logs for the test session
4. **Document Findings**: Record which detections worked and which didn't
5. **Update Detections**: Improve monitoring based on test results

### Security Considerations

- **Credentials File**: The generated credentials file contains ADMIN credentials
  - Store securely or delete immediately after testing
  - Never commit to version control
  - Included in `.gitignore` by default (pattern: `*.txt`)

- **Active Admin User**: While the demo user exists, it has full AWS access
  - Can create/modify/delete ANY AWS resource
  - Monitor actively during test window
  - Clean up immediately after testing

- **Access Keys**: Created keys are permanent until deleted
  - Can be used from anywhere with internet access
  - Are not tied to MFA
  - Should be treated as highly sensitive

## Troubleshooting

### Error: "AWS CLI is not installed or not in PATH"

**Problem:** AWS CLI is not installed or not accessible.

**Solution:**
```bash
# macOS
brew install awscli

# Linux
sudo apt-get install awscli

# Verify installation
which aws
aws --version
```

### Error: "jq is not installed or not in PATH"

**Problem:** jq JSON processor is not installed.

**Solution:**
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq

# Verify installation
which jq
jq --version
```

### Error: "AWS credentials not configured or invalid"

**Problem:** AWS CLI credentials are not set up or have expired.

**Solution:**
```bash
# Configure AWS CLI
aws configure

# Or check existing configuration
cat ~/.aws/credentials
cat ~/.aws/config

# Test credentials
aws sts get-caller-identity
```

### Error: "User with name X already exists"

**Problem:** A previous test run didn't clean up properly.

**Solution:**
```bash
# Run cleanup
./aws/aws-iam-attack.sh <username> cleanup

# Or manually delete via console
# AWS Console → IAM → Users → Select user → Delete
```

### Error: "Access Denied" when running script

**Problem:** Your IAM user/role lacks required permissions.

**Solution:**
- Review required IAM permissions section above
- Contact AWS administrator to grant necessary permissions
- Verify you're using the correct AWS account/profile

### Error: "LimitExceeded" when creating access keys

**Problem:** The user already has 2 access keys (AWS limit).

**Solution:**
```bash
# List existing keys
aws iam list-access-keys --user-name demo-suspicious-user

# Delete one or both existing keys
aws iam delete-access-key --user-name demo-suspicious-user --access-key-id <KEY_ID>
```

### Cleanup Fails with Errors

**Problem:** Cleanup script encounters errors.

**Solution:**
```bash
# Try manual cleanup steps in order:

# 1. Delete access keys first
aws iam list-access-keys --user-name demo-suspicious-user
aws iam delete-access-key --user-name demo-suspicious-user --access-key-id <KEY_ID>

# 2. Detach policies
aws iam detach-user-policy --user-name demo-suspicious-user --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
aws iam detach-user-policy --user-name demo-suspicious-user --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# 3. Delete user
aws iam delete-user --user-name demo-suspicious-user

# 4. Alternative: Use AWS Console
# Navigate to IAM → Users → Select user → Delete (Console handles dependencies)
```

## Testing Scenarios

### Scenario 1: Basic Privilege Escalation Detection

**Goal:** Verify your SIEM detects privilege escalation.

**Steps:**
1. Run the script with default settings
2. Monitor CloudTrail for `AttachUserPolicy` events
3. Check if SIEM generates alert for AdministratorAccess attachment
4. Document detection time and alert details
5. Run cleanup

**Expected Detections:**
- Alert for privilege escalation within 5-15 minutes
- CloudTrail event visible in SIEM
- Possible GuardDuty finding

### Scenario 2: Credential Persistence Detection

**Goal:** Verify detection of multiple access key creation.

**Steps:**
1. Run the script
2. Monitor for `CreateAccessKey` CloudTrail events
3. Check for alerts about unusual access key activity
4. Verify correlation between privilege escalation and key creation
5. Run cleanup

**Expected Detections:**
- Alert for multiple access key creation
- Possible alert for max access keys created
- Temporal correlation with privilege escalation

### Scenario 3: Response Time Testing

**Goal:** Measure how quickly security team responds.

**Steps:**
1. Coordinate with security operations team
2. Run script without notifying them of exact timing
3. Measure time from execution to detection to response
4. Document communication chain
5. Run cleanup

**Expected Outcome:**
- Detection within 15 minutes
- Initial response within 30 minutes
- Full investigation within 1 hour

## Additional Resources

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS CloudTrail Documentation](https://docs.aws.amazon.com/cloudtrail/)
- [Amazon GuardDuty User Guide](https://docs.aws.amazon.com/guardduty/)
- [MITRE ATT&CK: T1098 - Account Manipulation](https://attack.mitre.org/techniques/T1098/)
- [MITRE ATT&CK: T1078 - Valid Accounts](https://attack.mitre.org/techniques/T1078/)

---

[← Back to Main README](../README.md)
