#!/bin/bash

set -euo pipefail

# Define formatting helpers
WHITE='\033[1;37m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
SPACER="\n${WHITE}================================================================================${NC}\n"

# Define a function to handle errors
function handle_error {
  echo -e "${RED}$1${NC}"
  exit 1
}

# Set a trap to call the error handler function on any non-zero exit status
trap 'handle_error "Error: command exited with non-zero status: $?"' ERR

# Retrieve the consumer key from environment variables
CONSUMER_KEY="$POCKET_CONSUMER_KEY"

# Set the redirect URI to localhost since the API requires a valid URI
REDIRECT_URI="http://localhost"

# Make the authorization request
echo -e "${SPACER}\n${WHITE}Requesting authorization from Pocket...${NC}"
command="curl --fail --no-progress-meter -X POST https://getpocket.com/v3/oauth/request -d \"consumer_key=$CONSUMER_KEY&redirect_uri=$REDIRECT_URI\""
echo -e "${BLUE}$command${NC}\n"
RESPONSE=$(eval "$command")
REQUEST_TOKEN=$(echo "$RESPONSE" | cut -d "=" -f2)
AUTH_URL="https://getpocket.com/auth/authorize?request_token=$REQUEST_TOKEN&redirect_uri=$REDIRECT_URI"
echo -e "${WHITE}Response from Pocket:\n${YELLOW}$RESPONSE${NC}\n"
echo -e "${SPACER}\n${WHITE}Please authorize the app via this URL:\n${YELLOW}$AUTH_URL${NC}"

# Wait for the user to authorize the app
echo -e "${WHITE}\nPress enter once you have authorized the app...${NC}"
read

# Exchange the authorized code for an access token
echo -e "\n${WHITE}Exchanging authorization code for access token...${NC}"
command="curl --fail --no-progress-meter -X POST https://getpocket.com/v3/oauth/authorize -d \"consumer_key=$CONSUMER_KEY&code=$REQUEST_TOKEN\""
echo -e "${BLUE}$command${NC}\n"
RESPONSE=$(eval "$command")
echo -e "${WHITE}Response from Pocket:\n${YELLOW}$RESPONSE${NC}\n"
ACCESS_TOKEN=$(echo "$RESPONSE" | cut -d "&" -f1 | cut -d "=" -f2)
echo -e "${SPACER}\n${GREEN}Success! Your Pocket access token is:\n${YELLOW}$ACCESS_TOKEN${NC}\n"
