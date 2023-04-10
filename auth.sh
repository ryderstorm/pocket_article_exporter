#!/bin/bash

# Retrieve the consumer key and redirect URI from environment variables
CONSUMER_KEY="$POCKET_CONSUMER_KEY"
REDIRECT_URI="$POCKET_REDIRECT_URI"

# Make the authorization request
RESPONSE=$(curl -s -X POST https://getpocket.com/v3/oauth/request -d "consumer_key=$CONSUMER_KEY&redirect_uri=$REDIRECT_URI")
REQUEST_TOKEN=$(echo "$RESPONSE" | cut -d "=" -f2)
AUTH_URL="https://getpocket.com/auth/authorize?request_token=$REQUEST_TOKEN&redirect_uri=$REDIRECT_URI"
echo -e "Response from Pocket:\n$RESPONSE\n"
echo "Please authorize the Pocket app by visiting this URL: $AUTH_URL"

# Wait for the user to authorize the app
read -p "Press enter once you have authorized the app: "

# Exchange the authorized code for an access token
RESPONSE=$(curl -s -X POST https://getpocket.com/v3/oauth/authorize -d "consumer_key=$CONSUMER_KEY&code=$REQUEST_TOKEN")
echo -e "Response from Pocket:\n$RESPONSE\n"
ACCESS_TOKEN=$(echo "$RESPONSE" | cut -d "&" -f1 | cut -d "=" -f2)
echo "Your Pocket access token is: $ACCESS_TOKEN"
