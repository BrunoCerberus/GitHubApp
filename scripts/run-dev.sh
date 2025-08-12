#!/bin/bash

# Script to run the GitHubApp with API_KEY environment variable set
# Usage: ./scripts/run-dev.sh [API_KEY_VALUE]

# Check if API_KEY is provided as argument
if [ -n "$1" ]; then
    export API_KEY="$1"
    echo "Using provided API_KEY: $API_KEY"
elif [ -n "$API_KEY" ]; then
    echo "Using existing API_KEY from environment: $API_KEY"
else
    echo "Error: No API_KEY provided!"
    echo "Usage: ./scripts/run-dev.sh [API_KEY_VALUE]"
    echo "Or set API_KEY environment variable: export API_KEY='your_api_key_here'"
    echo ""
    echo "To get an API key:"
    echo "1. Go to https://www.themoviedb.org/settings/api"
    echo "2. Create an account and request an API key"
    echo "3. Use that key with this script"
    exit 1
fi

echo "Starting GitHubApp with API_KEY set..."
echo "You can now run the app in Xcode or use: open GitHubApp.xcodeproj"
echo ""
echo "Note: The API_KEY environment variable is now set for this terminal session."
echo "To make it permanent, add 'export API_KEY=\"$API_KEY\"' to your ~/.zshrc file"
