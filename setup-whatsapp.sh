#!/bin/bash

# WhatsApp Setup Script for Janet
# This script helps configure WhatsApp integration with OpenClaw

set -e

echo "============================================"
echo "Janet - WhatsApp Setup"
echo "============================================"
echo ""
echo "OpenClaw uses the WhatsApp Web protocol to connect to WhatsApp."
echo "You'll need to scan a QR code with your phone to authenticate."
echo ""
echo "Requirements:"
echo "- A real mobile number (VoIP numbers are usually blocked)"
echo "- WhatsApp installed on your phone"
echo "- Your phone connected to the internet"
echo ""

read -p "Press Enter to continue with WhatsApp setup..."

# Ensure OpenClaw is installed
if ! command -v openclaw &> /dev/null; then
    echo "Error: OpenClaw is not installed. Please install it first."
    exit 1
fi

# Create WhatsApp credentials directory
mkdir -p /root/.openclaw/credentials/whatsapp

echo ""
echo "Starting WhatsApp channel setup..."
echo ""
echo "A QR code will be displayed. To authenticate:"
echo "1. Open WhatsApp on your phone"
echo "2. Go to Settings > Linked Devices"
echo "3. Tap 'Link a Device'"
echo "4. Scan the QR code displayed below"
echo ""

# Start OpenClaw with WhatsApp channel
# This will display a QR code for authentication
openclaw channel add whatsapp

echo ""
echo "============================================"
echo "WhatsApp Setup Complete!"
echo "============================================"
echo ""
echo "Your WhatsApp session is now connected to Janet."
echo "You can now message your WhatsApp number to interact with Janet."
echo ""
echo "Note: The session credentials are stored in:"
echo "/root/.openclaw/credentials/whatsapp/"
echo ""
echo "To test the connection, send a message to your WhatsApp number."
