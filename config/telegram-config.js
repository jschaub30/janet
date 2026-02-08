/**
 * Telegram Channel Configuration for Janet
 * This file configures the Telegram integration
 */

module.exports = {
  // Bot configuration
  bot: {
    token: process.env.TELEGRAM_BOT_TOKEN,

    // Bot username (optional, for display purposes)
    username: process.env.TELEGRAM_BOT_USERNAME || 'janet_bot'
  },

  // Message handling
  messageOptions: {
    // Parse mode for messages (Markdown, HTML, or none)
    parseMode: 'Markdown',

    // Disable web page previews
    disableWebPagePreview: true,

    // Disable notifications for messages
    disableNotification: false
  },

  // Filters and restrictions
  filters: {
    // Allow messages from these user IDs (empty = allow all)
    allowedUsers: [],

    // Block messages from these user IDs
    blockedUsers: [],

    // Allow group chats
    allowGroups: true,

    // Require bot mention in groups
    requireMentionInGroups: true,

    // Private chat only mode
    privateChatOnly: false
  },

  // Commands
  commands: {
    // Enable default commands (/start, /help)
    enableDefaults: true,

    // Custom commands
    custom: [
      {
        command: 'start',
        description: 'Start chatting with Janet'
      },
      {
        command: 'help',
        description: 'Get help and see available commands'
      },
      {
        command: 'wordpress',
        description: 'Manage WordPress site'
      }
    ]
  },

  // Webhook configuration (if using webhooks instead of polling)
  webhook: {
    enabled: false,
    url: process.env.TELEGRAM_WEBHOOK_URL,
    port: process.env.TELEGRAM_WEBHOOK_PORT || 8443
  },

  // Polling configuration (default mode)
  polling: {
    enabled: true,
    interval: 1000, // ms
    timeout: 30 // seconds
  }
};
