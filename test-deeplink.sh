#!/bin/bash

# Test Deep Link Script for Dash App
# Usage: ./test-deeplink.sh [LIST_ID]

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LIST_ID=${1:-"550e8400-e29b-41d4-a716-446655440000"}

echo -e "${BLUE}🚀 Testing Deep Link for Dash${NC}"
echo -e "List ID: ${GREEN}${LIST_ID}${NC}"
echo ""

# Test custom URL scheme
CUSTOM_URL="dash://join/${LIST_ID}"
echo -e "${BLUE}Testing custom URL scheme:${NC}"
echo -e "${GREEN}${CUSTOM_URL}${NC}"
echo ""

xcrun simctl openurl booted "$CUSTOM_URL"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Deep link sent successfully!${NC}"
    echo ""
    echo "Check your simulator/device for the app to open."
    echo ""
    echo "To test with a real list ID, create a list in the app first,"
    echo "then run: ./test-deeplink.sh YOUR-LIST-ID"
else
    echo -e "❌ Failed to send deep link"
    echo "Make sure simulator is running and booted"
fi
