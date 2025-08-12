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

# Create joke files
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

cat > "$TEMP_DIR/programming_jokes.txt" << 'EOF'
💻 Programming Humor 💻

Why do programmers prefer dark mode?
Because light attracts bugs!

There are only 10 types of people in the world:
Those who understand binary and those who don't.

A SQL query goes into a bar, walks up to two tables and asks:
"Can I join you?"

Why do Java developers wear glasses?
Because they can't C#!

How many programmers does it take to change a light bulb?
None, that's a hardware problem!

"Knock knock"
"Who's there?"
"Recursion"
"Recursion who?"
"Knock knock"

99 little bugs in the code,
99 little bugs,
Take one down, patch it around,
117 little bugs in the code!
EOF

cat > "$TEMP_DIR/motivational_quotes.txt" << 'EOF'
✨ Motivational Quotes ✨

"The only way to do great work is to love what you do." - Steve Jobs

"Innovation distinguishes between a leader and a follower." - Steve Jobs

"Life is what happens to you while you're busy making other plans." - John Lennon

"The future belongs to those who believe in the beauty of their dreams." - Eleanor Roosevelt

"It is during our darkest moments that we must focus to see the light." - Aristotle

"Success is not final, failure is not fatal: it is the courage to continue that counts." - Winston Churchill

"The only impossible journey is the one you never begin." - Tony Robbins

"In the middle of difficulty lies opportunity." - Albert Einstein
EOF

cat > "$TEMP_DIR/random_facts.txt" << 'EOF'
🧠 Random Fun Facts 🧠

Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly edible!

A group of flamingos is called a "flamboyance."

Octopuses have three hearts and blue blood.

The shortest war in history lasted only 38-45 minutes. It was between Britain and Zanzibar in 1896.

Bananas are berries, but strawberries aren't.

A shrimp's heart is in its head.

The human brain uses about 20% of the body's total energy.

There are more possible games of chess than atoms in the observable universe.

Wombat poop is cube-shaped.

The Great Wall of China isn't visible from space with the naked eye.
EOF

cat > "$TEMP_DIR/puns.txt" << 'EOF'
😄 Pun-derful Collection 😄

I wondered why the baseball kept getting bigger. Then it hit me.

I'm reading a book about anti-gravity. It's impossible to put down!

Did you hear about the mathematician who's afraid of negative numbers?
He'll stop at nothing to avoid them.

I told my wife she was drawing her eyebrows too high. She looked surprised.

What do you call a bear with no teeth? A gummy bear!

I used to be a banker, but I lost interest.

Time flies like an arrow. Fruit flies like a banana.

I'm terrified of elevators, so I'm going to start taking steps to avoid them.

The math teacher called in sick with algebra. I think it's a logarithm.

I'm friends with 25 letters of the alphabet. I don't know Y.
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
echo "   https://$BUCKET_NAME.s3.amazonaws.com/programming_jokes.txt"
echo "   https://$BUCKET_NAME.s3.amazonaws.com/motivational_quotes.txt"
echo "   https://$BUCKET_NAME.s3.amazonaws.com/random_facts.txt"
echo "   https://$BUCKET_NAME.s3.amazonaws.com/puns.txt"
echo ""
echo "📝 List all files:"
echo "   aws s3 ls s3://$BUCKET_NAME/"
echo ""
echo "🗑️  To delete the bucket later:"
echo "   aws s3 rb s3://$BUCKET_NAME --force"
echo ""
echo -e "${YELLOW}Note: This bucket is publicly accessible. Remember to clean it up when done!${NC}"