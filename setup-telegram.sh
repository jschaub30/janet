#!/bin/bash

# Telegram Setup Script for Janet
# This script helps configure Telegram integration with OpenClaw

set -e

echo "============================================"
echo "Janet - Telegram Setup"
echo "============================================"
echo ""
echo "OpenClaw uses Telegram Bot API to connect to Telegram."
echo "You'll need a bot token from @BotFather."
echo ""
echo "Requirements:"
echo "- Telegram account"
echo "- Bot token from @BotFather"
echo ""

# Check if environment variables are set
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "Error: TELEGRAM_BOT_TOKEN environment variable is not set"
    echo "Please set it in your .env file"
    echo ""
    echo "To get a bot token:"
    echo "1. Open Telegram and search for @BotFather"
    echo "2. Send /newbot and follow the prompts"
    echo "3. Copy the bot token"
    echo "4. Add TELEGRAM_BOT_TOKEN=your-token-here to your .env file"
    echo "5. Restart the container: docker-compose restart"
    exit 1
fi

echo "Telegram bot token detected!"
echo ""
echo "Configuring Telegram channel..."

# Enable Telegram plugin if not already enabled
if ! openclaw plugins list | grep -q "telegram.*enabled"; then
    echo "Enabling Telegram plugin..."
    openclaw plugins enable telegram
    echo "Telegram plugin enabled!"
    echo ""
    echo "Please restart the container to apply changes:"
    echo "  docker-compose restart janet"
    exit 0
fi

# Add Telegram channel
echo "Adding Telegram channel..."
openclaw channels add --channel telegram --token "$TELEGRAM_BOT_TOKEN"

echo ""
echo "============================================"
echo "Telegram Setup Complete!"
echo "============================================"
echo ""
echo "Your Telegram bot is now connected to Janet."
echo ""
echo "To start chatting:"
echo "1. Open Telegram and search for your bot"
echo "2. Send /start to begin"
echo "3. Send any message to interact with Janet"
echo ""
echo "Bot commands:"
echo "  /start - Start the bot"
echo "  /help - Get help"
echo ""
