#!/bin/bash

# Configuration
BUCKET_NAME="my-fun-public-bucket-$(date +%s)"
REGION="ca-central-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🎉 Creating a fun public S3 bucket with jokes and quotes!${NC}"
echo "Bucket name: $BUCKET_NAME"

# Create the bucket
echo -e "${YELLOW}Creating S3 bucket...${NC}"
aws s3 mb s3://$BUCKET_NAME --region $REGION

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create bucket. Make sure AWS CLI is configured.${NC}"
    exit 1
fi

# Create temporary directory for files
TEMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TEMP_DIR"

# Create joke file
echo -e "${YELLOW}Creating joke files...${NC}"

cat > "$TEMP_DIR/dad_jokes.txt" << 'EOF'
🤣 Dad Jokes Collection 🤣

Why don't scientists trust atoms?
Because they make up everything!

I invented a new word: Plagiarism!

Why don't eggs tell jokes?
They'd crack each other up!

What do you call a fake noodle?
An impasta!

Why did the scarecrow win an award?
He was outstanding in his field!

I used to hate facial hair, but then it grew on me.

What's the best thing about Switzerland?
I don't know, but the flag is a big plus!
EOF

# Create sensitive data file
echo -e "${YELLOW}Creating sensitive data file...${NC}"
cat > "$TEMP_DIR/sensitive-data.csv" << 'EOF'
$(curl -s https://gist.githubusercontent.com/adilio/5eecae3f1def7bf9fbc3507f49ff7701/raw/f1b78b08f5168ccc0ac2c6b3b2f350c3d0269e91/mock-mixed-sensitive-data.csv)
EOF

# Upload files to S3
echo -e "${YELLOW}Uploading files to S3...${NC}"
aws s3 cp "$TEMP_DIR/" s3://$BUCKET_NAME/ --recursive

# Remove block public access
echo -e "${YELLOW}Removing block public access settings...${NC}"
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Create and apply bucket policy for public read access
echo -e "${YELLOW}Creating public read policy...${NC}"
cat > "$TEMP_DIR/bucket-policy.json" << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://$TEMP_DIR/bucket-policy.json

# Clean up temporary files
rm -rf $TEMP_DIR

# Save to file for demo purposes
echo "Writing $BUCKET_NAME to file" >> "${BUCKET_NAME}.txt"

echo -e "${GREEN}✅ Success! Your fun public S3 bucket is ready!${NC}"
echo ""
echo "🔗 Access your files at:"
echo "   https://$BUCKET_NAME.s3.amazonaws.com/dad_jokes.txt"
echo "   https://$BUCKET_NAME.s3.amazonaws.com/sensitive_data.txt"
echo ""
echo "📝 List all files:"
echo "   aws s3 ls s3://$BUCKET_NAME/"
echo ""
echo "🗑️  To delete the bucket later:"
echo "   aws s3 rb s3://$BUCKET_NAME --force"
echo ""
echo -e "${YELLOW}Note: This bucket is publicly accessible. Remember to clean it up when done!${NC}"