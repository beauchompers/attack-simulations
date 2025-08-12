#!/bin/bash

# AWS IAM Privilege Escalation Demo Script
# For cybersecurity demonstration purposes only

set -e  # Exit on any error

# Configuration
DEMO_USER="${1:-demo-suspicious-user}"  # Use first argument or default
DEMO_REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
show_usage() {
    echo "Usage: $0 [username] [cleanup]"
    echo ""
    echo "Arguments:"
    echo "  username    Name of the demo user to create (default: demo-suspicious-user)"
    echo "  cleanup     Clean up demo resources for the specified user"
    echo ""
    echo "Examples:"
    echo "  $0                              # Create demo-suspicious-user"
    echo "  $0 test-user                    # Create test-user"
    echo "  $0 test-user cleanup            # Clean up test-user"
    echo "  $0 cleanup                      # Clean up demo-suspicious-user"
    echo ""
}

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if user exists
check_user_exists() {
    aws iam get-user --user-name "$DEMO_USER" &>/dev/null
}

# Function to create demo user
create_demo_user() {
    print_status "Creating demo user: $DEMO_USER"
    
    if check_user_exists; then
        print_warning "User $DEMO_USER already exists. Skipping creation."
        return 0
    fi
    
    aws iam create-user \
        --user-name "$DEMO_USER" \
        --tags Key=Purpose,Value=SecurityDemo Key=Environment,Value=Demo
    
    if [ $? -eq 0 ]; then
        print_status "User $DEMO_USER created successfully"
    else
        print_error "Failed to create user $DEMO_USER"
        exit 1
    fi
}

# Function to attach initial policy (PowerUser)
attach_power_user_policy() {
    print_status "Attaching PowerUserAccess policy to $DEMO_USER"
    
    aws iam attach-user-policy \
        --user-name "$DEMO_USER" \
        --policy-arn "arn:aws:iam::aws:policy/PowerUserAccess"
    
    if [ $? -eq 0 ]; then
        print_status "PowerUserAccess policy attached successfully"
    else
        print_error "Failed to attach PowerUserAccess policy"
        exit 1
    fi
}

# Function to escalate to admin privileges
escalate_to_admin() {
    print_status "Escalating privileges to AdministratorAccess"
    
    aws iam attach-user-policy \
        --user-name "$DEMO_USER" \
        --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"
    
    if [ $? -eq 0 ]; then
        print_status "AdministratorAccess policy attached successfully"
        print_warning "User $DEMO_USER now has FULL ADMIN access!"
    else
        print_error "Failed to attach AdministratorAccess policy"
        exit 1
    fi
}

# Function to create access keys
create_access_keys() {
    print_status "Creating 2 sets of access keys for $DEMO_USER"
    
    # Initialize credentials file
    echo "# Demo credentials for $DEMO_USER" > "demo_credentials_${DEMO_USER}.txt"
    echo "# Created on $(date)" >> "demo_credentials_${DEMO_USER}.txt"
    echo "" >> "demo_credentials_${DEMO_USER}.txt"
    
    # Create 2 sets of access keys
    for i in {1..2}; do
        print_status "Creating access key set $i/2"
        
        # Create access key and capture output
        ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$DEMO_USER" --output json)
        
        if [ $? -eq 0 ]; then
            # Parse the access key ID and secret
            ACCESS_KEY_ID=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.AccessKeyId')
            SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.SecretAccessKey')
            
            print_status "Access key set $i created successfully"
            echo "  Access Key ID: $ACCESS_KEY_ID"
            echo "  Secret Access Key: $SECRET_ACCESS_KEY"
            
            # Save to file for demo purposes
            echo "# Access Key Set $i" >> "demo_credentials_${DEMO_USER}.txt"
            echo "ACCESS_KEY_ID_$i=$ACCESS_KEY_ID" >> "demo_credentials_${DEMO_USER}.txt"
            echo "SECRET_ACCESS_KEY_$i=$SECRET_ACCESS_KEY" >> "demo_credentials_${DEMO_USER}.txt"
            echo "" >> "demo_credentials_${DEMO_USER}.txt"
            
            # Store key IDs for cleanup
            if [ $i -eq 1 ]; then
                ALL_ACCESS_KEYS="$ACCESS_KEY_ID"
            else
                ALL_ACCESS_KEYS="$ALL_ACCESS_KEYS $ACCESS_KEY_ID"
            fi
            
            # Small delay between key creations to make CloudTrail events more visible
            sleep 1
        else
            print_error "Failed to create access key set $i"
            exit 1
        fi
    done
    
    print_status "Both access key sets created successfully!"
    print_status "Credentials saved to demo_credentials_${DEMO_USER}.txt"
    print_warning "This creates multiple persistent access methods - perfect for demonstrating credential sprawl"
}

# Function to display current user access keys
show_user_access_keys() {
    print_status "Current access keys for $DEMO_USER:"
    aws iam list-access-keys --user-name "$DEMO_USER" --output table
    
    # Count total access keys
    KEY_COUNT=$(aws iam list-access-keys --user-name "$DEMO_USER" --query 'AccessKeyMetadata' --output json | jq length)
    print_warning "Total access keys: $KEY_COUNT (AWS limit is 2 per user - this demo uses the maximum)"
}

# Function to display current user policies
show_user_policies() {
    print_status "Current policies attached to $DEMO_USER:"
    aws iam list-attached-user-policies --user-name "$DEMO_USER" --output table
}

# Function to cleanup (optional)
cleanup() {
    print_warning "Cleaning up demo resources..."
    
    # Detach policies
    aws iam detach-user-policy --user-name "$DEMO_USER" --policy-arn "arn:aws:iam::aws:policy/PowerUserAccess" 2>/dev/null || true
    aws iam detach-user-policy --user-name "$DEMO_USER" --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess" 2>/dev/null || true
    
    # Delete access keys
    ACCESS_KEYS=$(aws iam list-access-keys --user-name "$DEMO_USER" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null)
    for key in $ACCESS_KEYS; do
        aws iam delete-access-key --user-name "$DEMO_USER" --access-key-id "$key" 2>/dev/null || true
    done
    
    # Delete user
    aws iam delete-user --user-name "$DEMO_USER" 2>/dev/null || true
    
    # Remove credentials file
    rm -f "demo_credentials_${DEMO_USER}.txt"
    
    print_status "Cleanup completed"
}

# Main execution
main() {
    print_status "Starting AWS IAM Privilege Escalation Demo"
    print_warning "This script is for DEMONSTRATION purposes only!"
    
    # Check for required tools
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed or not in PATH"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &>/dev/null; then
        print_error "AWS credentials not configured or invalid"
        exit 1
    fi
    
    # Get current identity
    CURRENT_USER=$(aws sts get-caller-identity --query 'Arn' --output text)
    print_status "Running as: $CURRENT_USER"
    
    # Execute demo steps
    create_demo_user
    sleep 2
    attach_power_user_policy
    sleep 2
    escalate_to_admin
    sleep 2
    create_access_keys
    sleep 2
    show_user_access_keys
    sleep 1
    show_user_policies
    
    print_status "Demo completed successfully for user: $DEMO_USER!"
    print_warning "Remember to clean up demo resources when finished"
    echo ""
    echo "To cleanup, run: $0 $DEMO_USER cleanup"
}

# Handle arguments
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_usage
    exit 0
fi

# Check if cleanup is requested (can be first or second argument)
if [ "$1" = "cleanup" ]; then
    DEMO_USER="${2:-demo-suspicious-user}"
    cleanup
    exit 0
elif [ "$2" = "cleanup" ]; then
    cleanup
    exit 0
fi

# Run main function
main