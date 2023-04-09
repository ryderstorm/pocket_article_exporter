#!/bin/bash

# Replace YOUR_CONSUMER_KEY with your Pocket API consumer key
CONSUMER_KEY=""

# Replace YOUR_REDIRECT_URI with your registered redirect URI
REDIRECT_URI=""

# Generate a unique state parameter
STATE=$(openssl rand -hex 16)

# Build the authorization URL
AUTH_URL="https://getpocket.com/auth/authorize?\
request_token=$(curl -sS \
-XPOST \
-H 'Content-Type: application/json' \
-H "X-Accept: application/json" \
-d "{\"consumer_key\":\"$CONSUMER_KEY\",\"redirect_uri\":\"$REDIRECT_URI\",\"state\":\"$STATE\"}" \
'https://getpocket.com/v3/oauth/request')\
&redirect_uri=$REDIRECT_URI&state=$STATE"

# Open the authorization URL in the default web browser
xdg-open $AUTH_URL

# Prompt the user to enter the authorized code
read -p "Enter the authorized code: " AUTH_CODE

# Exchange the authorized code for an access token
ACCESS_TOKEN=$(curl -sS \
-XPOST \
-H 'Content-Type: application/json' \
-H "X-Accept: application/json" \
-d "{\"consumer_key\":\"$CONSUMER_KEY\",\"code\":\"$AUTH_CODE\"}" \
'https://getpocket.com/v3/oauth/authorize' | jq -r '.access_token')

# Print the access token
echo "Access Token: $ACCESS_TOKEN"
