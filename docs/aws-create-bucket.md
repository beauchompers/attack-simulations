# Public S3 Bucket Misconfiguration Demo

**Script:** [aws/aws-create-bucket.sh](../aws/aws-create-bucket.sh)

## Purpose

Demonstrates a common cloud security misconfiguration by creating a publicly accessible S3 bucket with sample content. This script is designed for testing detection capabilities for S3 bucket policy violations and public exposure risks.

## MITRE ATT&CK Techniques

- **T1530** - Data from Cloud Storage Object
- **Cloud Misconfiguration** leading to data exposure
- **Publicly Accessible Resources**

## What This Script Does

1. Creates an S3 bucket with a timestamped unique name (e.g., `my-fun-public-bucket-1729267890`)
2. Creates sample content files locally (jokes, quotes, random facts, puns)
3. Uploads sample content to the bucket
4. Removes S3 block public access settings
5. Applies a bucket policy granting public read access to all objects
6. Creates a local `.txt` file tracking the bucket name for cleanup reference
7. Displays direct URLs to access the public content

## Prerequisites

### Required Software

- **AWS CLI** - Command-line tool for AWS management
- **bash** - Shell interpreter (standard on macOS/Linux)
- **mktemp** - Temporary file creation (standard on macOS/Linux)
- **cat** - File concatenation utility (standard on macOS/Linux)

### Installation Instructions

**macOS:**
```bash
brew install awscli
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install awscli
```

**Windows (Git Bash or WSL):**
```bash
# Use WSL (Windows Subsystem for Linux) or Git Bash
# Install AWS CLI for Windows
choco install awscli
```

### AWS Configuration

Configure AWS CLI with valid credentials:
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (e.g., ca-central-1)
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
        "s3:CreateBucket",
        "s3:PutObject",
        "s3:PutBucketPolicy",
        "s3:PutPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
        "s3:DeleteBucket",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-fun-public-bucket-*",
        "arn:aws:s3:::my-fun-public-bucket-*/*"
      ]
    }
  ]
}
```

**Note:** For production testing, you may want to further restrict the resource ARNs.

## Usage

### Basic Usage

Run the script to create a public S3 bucket:

```bash
./aws/aws-create-bucket.sh
```

The script will automatically:
- Generate a unique bucket name
- Create and populate the bucket
- Make it publicly accessible
- Display access URLs

### Script Output

Example output:
```
🎉 Creating a fun public S3 bucket with jokes and quotes!
Bucket name: my-fun-public-bucket-1729267890
Creating S3 bucket...
make_bucket: my-fun-public-bucket-1729267890
Using temporary directory: /var/folders/tmp/mktemp.XXXXXX
Creating joke files...
Uploading files to S3...
upload: ./dad_jokes.txt to s3://my-fun-public-bucket-1729267890/dad_jokes.txt
upload: ./programming_jokes.txt to s3://my-fun-public-bucket-1729267890/programming_jokes.txt
upload: ./motivational_quotes.txt to s3://my-fun-public-bucket-1729267890/motivational_quotes.txt
upload: ./random_facts.txt to s3://my-fun-public-bucket-1729267890/random_facts.txt
upload: ./puns.txt to s3://my-fun-public-bucket-1729267890/puns.txt
Removing block public access settings...
Creating public read policy...
Writing my-fun-public-bucket-1729267890 to file
✅ Success! Your fun public S3 bucket is ready!

🔗 Access your files at:
   https://my-fun-public-bucket-1729267890.s3.amazonaws.com/dad_jokes.txt
   https://my-fun-public-bucket-1729267890.s3.amazonaws.com/programming_jokes.txt
   https://my-fun-public-bucket-1729267890.s3.amazonaws.com/motivational_quotes.txt
   https://my-fun-public-bucket-1729267890.s3.amazonaws.com/random_facts.txt
   https://my-fun-public-bucket-1729267890.s3.amazonaws.com/puns.txt

📝 List all files:
   aws s3 ls s3://my-fun-public-bucket-1729267890/

🗑️  To delete the bucket later:
   aws s3 rb s3://my-fun-public-bucket-1729267890 --force

Note: This bucket is publicly accessible. Remember to clean it up when done!
```

## Generated Resources

### S3 Bucket

**Bucket Name Pattern:** `my-fun-public-bucket-<unix-timestamp>`

**Region:** `ca-central-1` (Canada Central)

**Bucket Policy:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-fun-public-bucket-*/*"
        }
    ]
}
```

### Uploaded Files

The bucket contains five text files with harmless content:

1. **dad_jokes.txt** - Collection of dad jokes
2. **programming_jokes.txt** - Programming humor
3. **motivational_quotes.txt** - Inspirational quotes
4. **random_facts.txt** - Interesting trivia
5. **puns.txt** - Pun collection

**Note:** All content is intentionally harmless and safe for testing. No sensitive data is included.

### Local Tracking File

**File:** `my-fun-public-bucket-<timestamp>.txt`

Contains the bucket name and helpful cleanup commands. This file is created in the current directory and should be deleted after cleanup.

**File Contents:**
```
Writing my-fun-public-bucket-1234567890 to file
List all files:
aws s3 ls s3://my-fun-public-bucket-1234567890/

To delete the bucket later:
aws s3 rb s3://my-fun-public-bucket-1234567890 --force
```

## Observable Security Events

Running this script generates multiple security events that should be detected by properly configured monitoring:

### AWS CloudTrail Events

Monitor for these events in CloudTrail:

1. **CreateBucket**
   - EventName: `CreateBucket`
   - Bucket creation event

2. **PutObject** (5 events)
   - EventName: `PutObject`
   - File upload to bucket

3. **PutPublicAccessBlock** - **HIGH SEVERITY**
   - EventName: `PutPublicAccessBlock`
   - Disabling block public access settings
   - Major security configuration change

4. **PutBucketPolicy** - **CRITICAL SEVERITY**
   - EventName: `PutBucketPolicy`
   - Adding public read policy
   - Creates publicly accessible bucket

### AWS Config Rules

Should trigger the following Config rule violations:

- **s3-bucket-public-read-prohibited** - Bucket allows public read access
- **s3-bucket-public-write-prohibited** - Bucket configuration check
- **s3-bucket-level-public-access-prohibited** - Block public access disabled

### Amazon GuardDuty

May trigger findings such as:

- **Policy:S3/BucketAnonymousAccessGranted** - Bucket policy allows anonymous access
- **Policy:S3/BucketPublicAccessGranted** - Bucket made publicly accessible
- **UnauthorizedAccess:S3/MaliciousIPCaller.Custom** - If public URLs are accessed

### AWS Security Hub

Check for:

- **S3.1** - S3 Block Public Access setting should be enabled
- **S3.2** - S3 buckets should prohibit public read access
- **S3.3** - S3 buckets should prohibit public write access
- **S3.8** - S3 Block Public Access setting should be enabled at bucket level

### Example SIEM Query (Splunk)

```spl
index=aws sourcetype=aws:cloudtrail eventName IN (PutBucketPolicy, PutPublicAccessBlock)
| search requestParameters.bucketPolicy="*Principal*:*" OR
         requestParameters.publicAccessBlockConfiguration.BlockPublicAcls=false
| table _time userIdentity.principalId eventName requestParameters.bucketName
```

### Example SIEM Query (Elastic)

```json
{
  "query": {
    "bool": {
      "should": [
        {
          "bool": {
            "must": [
              { "match": { "event.action": "PutBucketPolicy" }},
              { "match": { "aws.cloudtrail.request_parameters": "*Principal*:*" }}
            ]
          }
        },
        {
          "bool": {
            "must": [
              { "match": { "event.action": "PutPublicAccessBlock" }},
              { "match": { "aws.cloudtrail.request_parameters": "BlockPublicAcls=false" }}
            ]
          }
        }
      ]
    }
  }
}
```

## Cleanup

### Using AWS CLI

Delete the bucket and all contents:

```bash
# Replace with your actual bucket name
aws s3 rb s3://my-fun-public-bucket-1729267890 --force
```

The `--force` flag deletes all objects in the bucket before removing the bucket itself.

### Delete Local Tracking File

```bash
# Remove the tracking file
rm my-fun-public-bucket-*.txt
```

### Using AWS Console

1. Navigate to [S3 Console](https://console.aws.amazon.com/s3/)
2. Find bucket starting with `my-fun-public-bucket-`
3. Select the bucket
4. Click **Delete**
5. Confirm by typing the bucket name
6. Click **Delete bucket**

### Verification After Cleanup

```bash
# List S3 buckets (your test bucket should not appear)
aws s3 ls | grep my-fun-public-bucket

# If empty output, cleanup successful
```

### Automated Cleanup Script

You can create a simple cleanup script:

```bash
#!/bin/bash
# cleanup-s3-demo.sh

# Find all my-fun-public-bucket tracking files
for file in my-fun-public-bucket-*.txt; do
    if [ -f "$file" ]; then
        BUCKET_NAME=$(cat "$file" | tail -n 1 | awk '{print $2}')
        echo "Deleting bucket: $BUCKET_NAME"
        aws s3 rb "s3://$BUCKET_NAME" --force
        rm "$file"
        echo "Cleaned up $BUCKET_NAME and $file"
    fi
done
```

## Safety and Best Practices

### Before Running

1. **Use Test Account**: Run in a dedicated test/sandbox AWS account when possible
2. **Understand Costs**: S3 storage and data transfer may incur costs
   - Storage: ~$0.023 per GB per month (ca-central-1)
   - Data transfer: Free for first 100GB out per month
   - Test files are very small (<1MB total)
3. **Get Authorization**: Obtain written approval to create public resources
4. **Notify Teams**: Alert security monitoring teams to expect test activity

### During Testing

1. **Monitor Access**: Watch S3 access logs for unexpected access patterns
2. **Test Detections**: Verify CloudTrail events appear in monitoring tools
3. **Document Events**: Record event IDs and timestamps
4. **Test Public Access**: Access the URLs to generate access logs

### After Testing

1. **Delete Immediately**: Public buckets pose security risk if left unattended
2. **Verify Deletion**: Confirm bucket no longer appears in S3 console
3. **Review Events**: Analyze CloudTrail logs and Config timeline
4. **Document Findings**: Record which detections worked and improvement areas

### Security Considerations

- **Public Access**: Anyone on the internet can access these files
  - Use only harmless content (already provided)
  - Never upload sensitive data
  - Delete promptly after testing

- **Bucket Enumeration**: Bucket names are globally unique
  - Timestamp makes name somewhat predictable
  - This is intentional for testing detection of public buckets

- **Cost Management**: While minimal, long-running buckets can incur costs
  - Delete after testing session
  - Set up billing alerts
  - Use AWS Budgets for cost controls

## Testing Scenarios

### Scenario 1: Public Bucket Detection

**Goal:** Verify your CSPM/SIEM detects public S3 buckets.

**Steps:**
1. Run the script to create public bucket
2. Wait 10-15 minutes for AWS Config evaluation
3. Check AWS Config for rule violations
4. Verify Security Hub findings appear
5. Check if SIEM alerts on PutBucketPolicy event
6. Run cleanup

**Expected Detections:**
- AWS Config rule violation within 15 minutes
- Security Hub finding
- SIEM alert for public bucket policy
- GuardDuty finding (possible)

### Scenario 2: Response Time Testing

**Goal:** Measure security team response to public bucket.

**Steps:**
1. Coordinate with security operations team
2. Run script without notifying exact timing
3. Measure time from creation to detection to response
4. Document who responded and what actions taken
5. Run cleanup after exercise

**Expected Outcome:**
- Detection within 15-30 minutes
- Security team contacts within 1 hour
- Verification or remediation initiated

### Scenario 3: Automated Remediation

**Goal:** Test automated S3 remediation controls.

**Steps:**
1. Run the script
2. Monitor for automatic remediation (if configured)
3. Check if bucket policy is automatically reverted
4. Check if block public access is re-enabled
5. Document remediation timing and method
6. Run cleanup if not auto-remediated

**Expected Outcome:**
- Automatic policy reversion (if configured)
- SNS notification to security team
- CloudTrail events showing remediation
- Bucket returned to private state

### Scenario 4: Public Access Testing

**Goal:** Verify bucket is actually publicly accessible.

**Steps:**
1. Run the script
2. Copy one of the provided URLs
3. Open URL in incognito browser window (no AWS session)
4. Verify file content is displayed
5. Check S3 access logs for the request
6. Run cleanup

**Expected Outcome:**
- File content accessible without authentication
- Access logged in S3 access logs
- Public IP address recorded
- Possible GuardDuty alert if suspicious IP

## Troubleshooting

### Error: "Failed to create bucket. Make sure AWS CLI is configured."

**Problem:** AWS CLI is not configured or lacks permissions.

**Solution:**
```bash
# Configure AWS CLI
aws configure

# Test configuration
aws sts get-caller-identity

# Test S3 access
aws s3 ls
```

### Error: "BucketAlreadyExists" or "BucketAlreadyOwnedByYou"

**Problem:** Bucket name collision (unlikely with timestamps but possible).

**Solution:**
- Wait a few seconds and run again (new timestamp will be generated)
- Or manually delete the existing bucket:
```bash
aws s3 rb s3://my-fun-public-bucket-<timestamp> --force
```

### Error: "An error occurred (AccessDenied) when calling the CreateBucket operation"

**Problem:** IAM user/role lacks s3:CreateBucket permission.

**Solution:**
- Review required IAM permissions section
- Contact AWS administrator to grant necessary permissions
- Verify you're in the correct AWS account

### Error: "An error occurred (IllegalLocationConstraintException)"

**Problem:** Region mismatch or bucket creation issue.

**Solution:**
- Check the `REGION` variable in the script (default: `ca-central-1`)
- Verify your AWS CLI default region matches or change script region
- Some regions require additional configuration

### Bucket Created But Not Public

**Problem:** Bucket exists but URLs return Access Denied.

**Solution:**
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket my-fun-public-bucket-<timestamp>

# Check public access block
aws s3api get-public-access-block --bucket my-fun-public-bucket-<timestamp>

# Re-apply public policy manually
aws s3api put-bucket-policy --bucket my-fun-public-bucket-<timestamp> --policy file://policy.json

# Disable public access block
aws s3api put-public-access-block --bucket my-fun-public-bucket-<timestamp> \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

### Cleanup Fails - "BucketNotEmpty"

**Problem:** Bucket has objects that must be deleted first.

**Solution:**
```bash
# Use --force flag to delete all objects
aws s3 rb s3://my-fun-public-bucket-<timestamp> --force

# Or manually delete objects first
aws s3 rm s3://my-fun-public-bucket-<timestamp> --recursive
aws s3 rb s3://my-fun-public-bucket-<timestamp>
```

### Cannot Find Bucket Name

**Problem:** Lost track of bucket name for cleanup.

**Solution:**
```bash
# Check for tracking files
ls -la my-fun-public-bucket-*.txt

# List all S3 buckets
aws s3 ls | grep my-fun-public-bucket

# List all buckets in the account
aws s3 ls
```

## Advanced Usage

### Customize Bucket Region

Edit the script to change the region:

```bash
# Open script in editor
nano aws/aws-create-bucket.sh

# Change this line:
REGION="ca-central-1"

# To your preferred region, e.g.:
REGION="us-east-1"
```

### Customize Bucket Name Prefix

```bash
# Change this line:
BUCKET_NAME="my-fun-public-bucket-$(date +%s)"

# To:
BUCKET_NAME="my-test-bucket-$(date +%s)"
```

### Add Custom Content

You can modify the script to upload your own test files:

```bash
# Create your own test file
echo "Custom test content" > /tmp/custom-file.txt

# Add to script upload section
aws s3 cp /tmp/custom-file.txt s3://$BUCKET_NAME/
```

### Monitor Access Logs

Enable S3 access logging to track who accesses public files:

```bash
# Create logging bucket
aws s3 mb s3://my-logging-bucket

# Enable logging on test bucket
aws s3api put-bucket-logging --bucket my-fun-public-bucket-<timestamp> \
  --bucket-logging-status file://logging.json
```

**logging.json:**
```json
{
  "LoggingEnabled": {
    "TargetBucket": "my-logging-bucket",
    "TargetPrefix": "public-bucket-logs/"
  }
}
```

## Additional Resources

- [AWS S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [Blocking Public Access to S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- [S3 Bucket Policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
- [AWS Config S3 Rules](https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-public-read-prohibited.html)
- [MITRE ATT&CK: T1530 - Data from Cloud Storage](https://attack.mitre.org/techniques/T1530/)

---

[← Back to Main README](../README.md)
