#!/bin/bash

# Configuration
AWS_REGION=""
AWS_ACCOUNT_ID=""
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""

# Export credentials for the AWS CLI to use
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# Get the login password (authorization token) from AWS
TOKEN=$(aws ecr get-login-password --region "$AWS_REGION")

# Output the docker login command for the restricted machine
echo ""
echo "Copy the following command and run it on your restricted machine:"
echo ""
echo "echo '$TOKEN' | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
echo ""
