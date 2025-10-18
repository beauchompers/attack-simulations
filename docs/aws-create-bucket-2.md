# Public S3 Bucket with Sensitive Data (Enhanced Demo)

**Script:** [aws/aws-create-bucket-2.sh](../aws/aws-create-bucket-2.sh)

## Purpose

Enhanced version of the S3 bucket misconfiguration demo that creates a publicly accessible S3 bucket containing mock sensitive data. This script is designed for testing detection capabilities for data exposure incidents and sensitive data leakage.

## MITRE ATT&CK Techniques

- **T1530** - Data from Cloud Storage Object
- **Cloud Misconfiguration** leading to data exposure
- **Publicly Accessible Resources**
- **Sensitive Data Exposure**

## What This Script Does

1. Creates an S3 bucket with a timestamped unique name
2. Downloads mock sensitive data from GitHub (CSV with mock PII)
3. Creates sample joke content (dad jokes)
4. Uploads both files to the bucket
5. Removes S3 block public access settings
6. Applies a bucket policy granting public read access to all objects
7. Creates a local `.txt` file tracking the bucket name
8. Provides direct URLs to access the public content

## Differences from aws-create-bucket.sh

| Feature | aws-create-bucket.sh | aws-create-bucket-2.sh |
|---------|---------------------|------------------------|
| Sample Files | 5 joke/quote files | 1 joke file + 1 CSV with mock sensitive data |
| Data Type | Harmless entertainment | Mock PII (names, SSNs, emails, etc.) |
| Use Case | Basic misconfiguration testing | Data exposure/DLP testing |
| File Size | Very small (~5KB) | Larger CSV file (~50KB+) |

## Prerequisites

### Required Software

- **AWS CLI** - Command-line tool for AWS management
- **bash** - Shell interpreter (standard on macOS/Linux)
- **curl** - For downloading mock data (standard on macOS/Linux)
- **mktemp** - Temporary file creation (standard on macOS/Linux)

### Installation Instructions

**macOS:**
```bash
brew install awscli
# curl and mktemp are built-in
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install awscli curl
```

**Windows (Git Bash or WSL):**
```bash
# Use WSL (Windows Subsystem for Linux) or Git Bash
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

Same as aws-create-bucket.sh - see [aws-create-bucket.md](aws-create-bucket.md#required-iam-permissions)

## Usage

### Basic Usage

Run the script to create a public S3 bucket with mock sensitive data:

```bash
./aws/aws-create-bucket-2.sh
```

The script will automatically:
- Generate a unique bucket name
- Download mock sensitive data
- Create and populate the bucket
- Make it publicly accessible
- Display access URLs

### Script Output

Example output:
```
🎉 Creating a fun public S3 bucket with jokes and quotes!
Bucket name: my-fun-public-bucket-1729268000
Creating S3 bucket...
make_bucket: my-fun-public-bucket-1729268000
Using temporary directory: /var/folders/tmp/mktemp.XXXXXX
Creating joke files...
Uploading files to S3...
upload: ./dad_jokes.txt to s3://my-fun-public-bucket-1729268000/dad_jokes.txt
upload: ./sensitive-data.csv to s3://my-fun-public-bucket-1729268000/sensitive-data.csv
Removing block public access settings...
Creating public read policy...
Writing my-fun-public-bucket-1729268000 to file
✅ Success! Your fun public S3 bucket is ready!

🔗 Access your files at:
   https://my-fun-public-bucket-1729268000.s3.amazonaws.com/dad_jokes.txt
   https://my-fun-public-bucket-1729268000.s3.amazonaws.com/sensitive_data.txt

📝 List all files:
   aws s3 ls s3://my-fun-public-bucket-1729268000/

🗑️  To delete the bucket later:
   aws s3 rb s3://my-fun-public-bucket-1729268000 --force

Note: This bucket is publicly accessible. Remember to clean it up when done!
```

## Generated Resources

### S3 Bucket

**Bucket Name Pattern:** `my-fun-public-bucket-<unix-timestamp>`

**Region:** `ca-central-1` (Canada Central)

**Bucket Policy:** Same as aws-create-bucket.sh - grants public read access

### Uploaded Files

The bucket contains two files:

1. **dad_jokes.txt** - Collection of dad jokes (harmless content)
2. **sensitive-data.csv** - Mock sensitive data including:
   - Names
   - Email addresses
   - Phone numbers
   - Social Security Numbers (mock/fake)
   - Addresses
   - Credit card numbers (mock/fake)
   - Other PII

**Data Source:** https://gist.githubusercontent.com/adilio/5eecae3f1def7bf9fbc3507f49ff7701/raw/f1b78b08f5168ccc0ac2c6b3b2f350c3d0269e91/mock-mixed-sensitive-data.csv

**Important:** All sensitive data is MOCK/FAKE. This is test data only for demonstrating data exposure detection.

### Local Tracking File

**File:** `my-fun-public-bucket-<timestamp>.txt`

Contains the bucket name for cleanup reference.

## Observable Security Events

This script generates the same CloudTrail events as aws-create-bucket.sh, plus additional opportunities for:

### Data Loss Prevention (DLP) Detection

- **Sensitive Data Exposure**: CSV file with PII patterns
- **DLP Tools**: Should detect SSN, credit card, email patterns
- **CASB Alerts**: Cloud Access Security Broker detection

### AWS Macie Detection

Amazon Macie can detect:
- **PII Discovery**: Names, addresses, SSNs in CSV
- **Sensitive Data Findings**: Credit card numbers
- **Public Bucket with Sensitive Data**: High-severity finding

**Enable Macie:**
```bash
# Enable Amazon Macie (one-time setup)
aws macie2 enable-macie

# Create classification job for bucket
aws macie2 create-classification-job \
  --job-type ONE_TIME \
  --s3-job-definition '{
    "bucketDefinitions": [{
      "accountId": "YOUR_ACCOUNT_ID",
      "buckets": ["my-fun-public-bucket-TIMESTAMP"]
    }]
  }' \
  --name "PublicBucketScan"
```

### Additional Monitoring

Check for:
- Public access to sensitive data patterns
- DLP policy violations
- Data classification alerts
- Macie sensitive data findings
- GuardDuty findings for sensitive data access

## Cleanup

### Using AWS CLI

Delete the bucket and all contents:

```bash
# Replace with your actual bucket name
aws s3 rb s3://my-fun-public-bucket-1729268000 --force
```

The `--force` flag deletes all objects (including the sensitive data CSV) before removing the bucket.

### Delete Local Tracking File

```bash
# Remove the tracking file
rm my-fun-public-bucket-*.txt
```

### Verification

```bash
# Verify bucket deleted
aws s3 ls | grep my-fun-public-bucket

# Should return no results
```

## Testing Scenarios

### Scenario 1: DLP Detection Testing

**Goal:** Verify DLP tools detect sensitive data in public S3 buckets.

**Steps:**
1. Run the script to create public bucket with mock PII
2. Wait for DLP scanning (may take 5-30 minutes)
3. Check DLP console for detections:
   - SSN patterns detected
   - Credit card patterns detected
   - Email addresses detected
   - PII classification applied
4. Verify alerts generated
5. Run cleanup

**Expected Detections:**
- DLP finding within 30 minutes
- High severity classification
- Alert to security team
- Possible automatic remediation

### Scenario 2: Amazon Macie Testing

**Goal:** Test Macie's sensitive data discovery.

**Steps:**
1. Enable Amazon Macie in your account
2. Run the script
3. Create Macie classification job for the bucket
4. Wait for scan completion (10-30 minutes)
5. Review Macie findings
6. Run cleanup

**Expected Findings:**
- PII finding (HIGH severity)
- Publicly accessible bucket with sensitive data
- Detailed inventory of PII types found
- Recommendation to make bucket private

### Scenario 3: Public Data Access Monitoring

**Goal:** Monitor access to publicly exposed sensitive data.

**Steps:**
1. Enable S3 access logging
2. Run the script
3. Access the sensitive-data.csv URL from external IP
4. Check access logs for public access
5. Verify SIEM captures access event
6. Run cleanup

**Expected Outcome:**
- Access logs show public IP accessing CSV
- SIEM alert for sensitive data access
- Geolocation of accessor recorded
- Anomaly if accessed from unusual location

### Scenario 4: Incident Response Exercise

**Goal:** Practice incident response for data exposure.

**Steps:**
1. Coordinate with IR team (don't tell them timing)
2. Run script
3. Simulate discovering the public bucket
4. Report to IR team
5. Measure response:
   - Time to acknowledge
   - Time to assess
   - Time to remediate
   - Communication effectiveness
6. Post-incident review
7. Run cleanup

**Expected Timeline:**
- Detection: 15-30 minutes
- Acknowledgment: 30-60 minutes
- Assessment: 1-2 hours
- Remediation: 2-4 hours
- Full report: 24-48 hours

## Safety and Best Practices

### Before Running

1. **Test Environment**: Use dedicated test AWS account
2. **Understand Impact**: Public bucket with "sensitive" data (even though it's mock)
3. **Enable Monitoring**: Macie, DLP, access logging
4. **Get Approval**: Written authorization for data exposure testing
5. **Notify Stakeholders**: DLP team, security operations, compliance

### During Testing

1. **Monitor Detection**: Watch for DLP alerts, Macie findings
2. **Test Public Access**: Verify data is actually publicly accessible
3. **Capture Evidence**: Screenshots of findings and alerts
4. **Document Timing**: When alerts fired, detection lag

### After Testing

1. **Delete Immediately**: Public sensitive data (even mock) is a risk
2. **Verify Deletion**: Confirm bucket and data fully removed
3. **Review Findings**: Analyze what was detected
4. **Update DLP Rules**: Improve based on test results
5. **Document Gaps**: Note what wasn't detected

### Critical Safety Notes

⚠️ **Even though the data is MOCK:**
- Treat as if it were real during testing
- Delete immediately after testing
- Don't leave public for extended periods
- Monitor for unauthorized access

⚠️ **Compliance Considerations:**
- Some compliance frameworks treat test data as real data
- Ensure mock data is clearly labeled as test
- Document test activities for audit trail

## Comparison with Original Script

Use **aws-create-bucket-2.sh** when you want to test:
- ✅ DLP detection capabilities
- ✅ Amazon Macie sensitive data discovery
- ✅ Data classification tools
- ✅ Incident response for data exposure
- ✅ CASB detection of sensitive data in cloud

Use **aws-create-bucket.sh** when you want to test:
- ✅ Basic S3 misconfiguration detection
- ✅ Public bucket policy detection
- ✅ AWS Config rule violations
- ✅ Simple CSPM testing
- ✅ Faster/lighter testing scenario

## Troubleshooting

### Error: "Failed to download sensitive data"

**Problem:** curl cannot download the mock data CSV.

**Solution:**
```bash
# Test connectivity
curl -I https://gist.githubusercontent.com

# Try manual download
curl -s https://gist.githubusercontent.com/adilio/5eecae3f1def7bf9fbc3507f49ff7701/raw/f1b78b08f5168ccc0ac2c6b3b2f350c3d0269e91/mock-mixed-sensitive-data.csv

# Check proxy settings if behind corporate firewall
echo $http_proxy
echo $https_proxy
```

### Macie Not Detecting Sensitive Data

**Problem:** Macie scan completes but no findings.

**Solution:**
- Ensure Macie is fully enabled (can take 10-15 minutes)
- Verify classification job ran successfully
- Check bucket policy allows Macie access
- Review Macie managed data identifiers are enabled
- Wait longer - some scans take 30+ minutes

### DLP Tool Not Triggering

**Problem:** DLP tool doesn't detect the sensitive data.

**Solution:**
- Verify DLP tool monitors S3
- Check if DLP scans public buckets
- Ensure DLP has S3 read permissions
- Review DLP rules include CSV file scanning
- Check if data patterns match DLP signatures
- Verify DLP is enabled for the region

## Additional Resources

- [Original S3 Bucket Script Documentation](aws-create-bucket.md)
- [Amazon Macie Documentation](https://docs.aws.amazon.com/macie/)
- [AWS DLP Best Practices](https://aws.amazon.com/blogs/security/)
- [S3 Access Logging](https://docs.aws.amazon.com/AmazonS3/latest/userguide/ServerLogs.html)
- [MITRE ATT&CK: T1530](https://attack.mitre.org/techniques/T1530/)

---

[← Back to Main README](../README.md)
