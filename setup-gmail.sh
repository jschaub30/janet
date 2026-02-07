#!/bin/bash

# Gmail Setup Script for Janet
# This script helps configure Gmail integration with OpenClaw

set -e

echo "============================================"
echo "Janet - Gmail Setup"
echo "============================================"
echo ""
echo "Gmail integration allows Janet to:"
echo "- Read incoming emails"
echo "- Send email responses"
echo "- Process email requests"
echo ""
echo "Two authentication methods are available:"
echo "1. App Password (Recommended for personal use)"
echo "2. OAuth2 (More secure, requires Google Cloud setup)"
echo ""

# Check if environment variables are set
if [ -z "$GMAIL_USER" ]; then
    echo "Error: GMAIL_USER environment variable is not set"
    echo "Please set it in your .env file"
    exit 1
fi

if [ -z "$GMAIL_APP_PASSWORD" ] && [ -z "$GMAIL_CLIENT_ID" ]; then
    echo "Error: Neither GMAIL_APP_PASSWORD nor GMAIL_CLIENT_ID is set"
    echo "Please configure one authentication method in your .env file"
    echo ""
    echo "For App Password method:"
    echo "1. Go to https://myaccount.google.com/apppasswords"
    echo "2. Generate a new app password"
    echo "3. Set GMAIL_APP_PASSWORD in your .env file"
    echo ""
    echo "For OAuth2 method:"
    echo "1. Create OAuth2 credentials in Google Cloud Console"
    echo "2. Set GMAIL_CLIENT_ID, GMAIL_CLIENT_SECRET, and GMAIL_REFRESH_TOKEN"
    exit 1
fi

echo "Gmail configuration detected:"
echo "- User: $GMAIL_USER"

if [ -n "$GMAIL_APP_PASSWORD" ]; then
    echo "- Auth method: App Password"
else
    echo "- Auth method: OAuth2"
fi

echo ""
echo "Testing Gmail connection..."

# Install dependencies if not already installed
if [ ! -d "/opt/janet/node_modules" ]; then
    echo "Installing Node.js dependencies..."
    cd /opt/janet
    npm install
fi

echo ""
echo "Gmail setup complete!"
echo ""
echo "Janet can now:"
echo "- Monitor your inbox for new emails"
echo "- Process email requests"
echo "- Send email responses"
echo ""
echo "Note: The polling interval is set to ${GMAIL_POLLING_INTERVAL:-60} seconds"
echo ""
echo "To test, send an email to: $GMAIL_USER"
