/**
 * WhatsApp Channel Configuration for Janet
 * This file configures the WhatsApp integration using whatsapp-web.js
 */

module.exports = {
  // Client configuration
  clientOptions: {
    puppeteer: {
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--no-first-run',
        '--no-zygote',
        '--disable-gpu'
      ],
      executablePath: '/usr/bin/chromium-browser'
    },

    // Session persistence
    authStrategy: 'LocalAuth',
    authPath: '/opt/janet/whatsapp-sessions',

    // Client info
    clientId: 'janet-openclaw',

    // Reconnection settings
    restartOnAuthFail: true,

    // QR code settings
    qrMaxRetries: 5,
    qrRefreshInterval: 20000
  },

  // Message handling
  messageOptions: {
    // Auto-read messages
    autoRead: false,

    // Message queue settings
    queueEnabled: true,
    queueConcurrency: 1,

    // Typing indicator
    showTypingIndicator: true
  },

  // Filters and restrictions
  filters: {
    // Allow messages from these numbers (empty = allow all)
    allowedNumbers: [],

    // Block messages from these numbers
    blockedNumbers: [],

    // Allow group chats
    allowGroups: true,

    // Require mention in groups
    requireMentionInGroups: true
  }
};
