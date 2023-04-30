#!/bin/bash

set -e

if [ -z "$POCKET_CONSUMER_KEY" ]; then
  echo "POCKET_CONSUMER_KEY environment variable not set"
  exit 1
fi

if [ -z "$POCKET_REDIRECT_URI" ]; then
  echo "POCKET_REDIRECT_URI environment variable not set"
  exit 1
fi
echo "Consumer key: $POCKET_CONSUMER_KEY"
echo "Redirect URI: $POCKET_REDIRECT_URI"
echo -e "\n-----------------------\n"

# Kill any existing server instances
# This is useful when developing the app and running the app
# in the background via something like rerun
process_id=$(cat pocket_auth_app_pid.txt) || true
if [ -z "$process_id" ]; then
  echo "No process id found in pocket_auth_app_pid.txt"
else
  echo "Killing existing server instance with process id: $process_id"
  kill -9 "$process_id" || true
fi

# run the server
echo "Starting the server..."
ruby pocket_auth_app.rb
