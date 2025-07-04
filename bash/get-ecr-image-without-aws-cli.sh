#!/bin/bash

AWS_REGION=""
AWS_ACCESS_KEY=""
AWS_SECRET_KEY=""
AWS_ACCOUNT_ID=""

DATE="$(date -u "+%Y%m%dT%H%M%SZ")"
DATE_SHORT="$(date -u "+%Y%m%d")"

# JSON request body
BODY='{}'

# Calculate SHA256 hash of the request body
BODY_HASH=$(echo -n "$BODY" | openssl dgst -sha256 | awk '{print $2}')

# Construct the Canonical Request
CANONICAL_REQUEST="POST
/

content-type:application/x-amz-json-1.1
host:ecr.$AWS_REGION.amazonaws.com
x-amz-date:$DATE
x-amz-target:AmazonEC2ContainerRegistry_V20150921.GetAuthorizationToken

content-type;host;x-amz-date;x-amz-target
$BODY_HASH"

# Create the String to Sign
STRING_TO_SIGN="AWS4-HMAC-SHA256
$DATE
$DATE_SHORT/$AWS_REGION/ecr/aws4_request
$(echo -n "$CANONICAL_REQUEST" | openssl dgst -sha256 | awk '{print $2}')"

# Generate Signing Key using AWS Signature v4
DATE_KEY=$(echo -n "$DATE_SHORT" | openssl dgst -sha256 -hmac "AWS4$AWS_SECRET_KEY" -binary | xxd -p -c 256)
DATE_REGION_KEY=$(echo -n "$AWS_REGION" | openssl dgst -sha256 -hmac "$(echo -n $DATE_KEY | xxd -r -p)" -binary | xxd -p -c 256)
DATE_REGION_SERVICE_KEY=$(echo -n "ecr" | openssl dgst -sha256 -hmac "$(echo -n $DATE_REGION_KEY | xxd -r -p)" -binary | xxd -p -c 256)
SIGNING_KEY=$(echo -n "aws4_request" | openssl dgst -sha256 -hmac "$(echo -n $DATE_REGION_SERVICE_KEY | xxd -r -p)" -binary | xxd -p -c 256)

# Calculate the final signature
SIGNATURE=$(echo -n "$STRING_TO_SIGN" | openssl dgst -sha256 -hmac "$(echo -n $SIGNING_KEY | xxd -r -p)" | awk '{print $2}')

# Construct the Authorization header
AUTH_HEADER="AWS4-HMAC-SHA256 Credential=$AWS_ACCESS_KEY/$DATE_SHORT/$AWS_REGION/ecr/aws4_request, SignedHeaders=content-type;host;x-amz-date;x-amz-target, Signature=$SIGNATURE"

# echo "Authorization Header: $AUTH_HEADER"

# Send API request to AWS ECR to get the authorization token
TOKEN_RESPONSE=$(curl -s -X POST "https://ecr.$AWS_REGION.amazonaws.com/" \
    -H "Content-Type: application/x-amz-json-1.1" \
    -H "X-Amz-Date: $DATE" \
    -H "X-Amz-Target: AmazonEC2ContainerRegistry_V20150921.GetAuthorizationToken" \
    -H "Authorization: $AUTH_HEADER" \
    --data "$BODY")

# echo "Full API response: $TOKEN_RESPONSE"

# Extract Base64-encoded authorization token
TOKEN_BASE64=$(echo $TOKEN_RESPONSE | jq -r '.authorizationData[0].authorizationToken')

# Decode the token
TOKEN=$(echo "$TOKEN_BASE64" | base64 --decode | cut -d: -f2)

# Extract the ECR registry URL
ECR_REGISTRY=$(echo $TOKEN_RESPONSE | jq -r '.authorizationData[0].proxyEndpoint')

echo $TOKEN | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com
