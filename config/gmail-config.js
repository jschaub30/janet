/**
 * Gmail Channel Configuration for Janet
 * This file configures the Gmail/Email integration
 *
 * Two authentication methods are supported:
 * 1. App Password (simpler, recommended for personal use)
 * 2. OAuth2 (more secure, recommended for production)
 */

module.exports = {
  // Authentication method: 'app-password' or 'oauth2'
  authMethod: process.env.GMAIL_CLIENT_ID ? 'oauth2' : 'app-password',

  // App Password Authentication (Method 1)
  appPassword: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD
  },

  // OAuth2 Authentication (Method 2)
  oauth2: {
    user: process.env.GMAIL_USER,
    clientId: process.env.GMAIL_CLIENT_ID,
    clientSecret: process.env.GMAIL_CLIENT_SECRET,
    refreshToken: process.env.GMAIL_REFRESH_TOKEN
  },

  // SMTP Settings (for sending emails)
  smtp: {
    host: 'smtp.gmail.com',
    port: 587,
    secure: false, // true for 465, false for other ports
    requireTLS: true
  },

  // IMAP Settings (for receiving emails)
  imap: {
    host: 'imap.gmail.com',
    port: 993,
    secure: true,

    // Polling interval (in seconds)
    pollingInterval: 60,

    // Mailbox to monitor
    mailbox: 'INBOX'
  },

  // Email processing settings
  processing: {
    // Mark emails as read after processing
    markAsRead: false,

    // Maximum emails to process per poll
    maxEmailsPerPoll: 10,

    // Filter: only process unread emails
    unreadOnly: true,

    // Archive processed emails
    archiveAfterProcessing: false
  },

  // Response settings
  response: {
    // Automatically reply to emails
    autoReply: false,

    // Include original message in response
    includeOriginal: true,

    // Signature
    signature: '\n\n---\nSent by Janet - OpenClaw AI Assistant'
  },

  // Gmail PubSub Settings (Advanced - for real-time notifications)
  // Requires Google Cloud Project setup
  pubsub: {
    enabled: false,
    projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
    topic: process.env.GMAIL_PUBSUB_TOPIC,
    subscription: process.env.GMAIL_PUBSUB_SUBSCRIPTION
  }
};
