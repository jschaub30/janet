/**
 * Gmail Integration for Janet
 * This module provides email capabilities using Gmail's IMAP/SMTP
 */

const nodemailer = require('nodemailer');
const Imap = require('imap');
const { simpleParser } = require('mailparser');
const fs = require('fs').promises;
const path = require('path');

// Load configuration
const config = require('./config/gmail-config.js');

class GmailIntegration {
  constructor() {
    this.transporter = null;
    this.imap = null;
    this.isConnected = false;
    this.processedEmails = new Set();
    this.loadProcessedEmails();
  }

  /**
   * Initialize the Gmail integration
   */
  async initialize() {
    try {
      // Setup SMTP transporter for sending emails
      this.setupTransporter();

      // Setup IMAP for receiving emails
      this.setupImap();

      console.log('Gmail integration initialized successfully');
      return true;
    } catch (error) {
      console.error('Failed to initialize Gmail integration:', error);
      return false;
    }
  }

  /**
   * Setup SMTP transporter
   */
  setupTransporter() {
    const auth = config.authMethod === 'oauth2' ? {
      type: 'OAuth2',
      user: config.oauth2.user,
      clientId: config.oauth2.clientId,
      clientSecret: config.oauth2.clientSecret,
      refreshToken: config.oauth2.refreshToken
    } : {
      user: config.appPassword.user,
      pass: config.appPassword.pass
    };

    this.transporter = nodemailer.createTransport({
      host: config.smtp.host,
      port: config.smtp.port,
      secure: config.smtp.secure,
      requireTLS: config.smtp.requireTLS,
      auth: auth
    });

    console.log('SMTP transporter configured');
  }

  /**
   * Setup IMAP connection
   */
  setupImap() {
    const auth = config.authMethod === 'oauth2' ? {
      user: config.oauth2.user,
      xoauth2: this.generateXOAuth2Token()
    } : {
      user: config.appPassword.user,
      password: config.appPassword.pass
    };

    this.imap = new Imap({
      ...config.imap,
      ...auth,
      tlsOptions: { rejectUnauthorized: false }
    });

    // Setup event handlers
    this.imap.on('ready', () => {
      console.log('IMAP connection ready');
      this.isConnected = true;
      this.startMonitoring();
    });

    this.imap.on('error', (err) => {
      console.error('IMAP error:', err);
      this.isConnected = false;
    });

    this.imap.on('end', () => {
      console.log('IMAP connection ended');
      this.isConnected = false;
    });
  }

  /**
   * Connect to Gmail
   */
  connect() {
    if (!this.imap) {
      console.error('IMAP not configured');
      return;
    }

    try {
      this.imap.connect();
    } catch (error) {
      console.error('Failed to connect to IMAP:', error);
    }
  }

  /**
   * Start monitoring inbox for new emails
   */
  startMonitoring() {
    if (!this.isConnected) {
      console.error('Not connected to IMAP');
      return;
    }

    this.imap.openBox(config.imap.mailbox, false, (err, box) => {
      if (err) {
        console.error('Failed to open mailbox:', err);
        return;
      }

      console.log('Monitoring mailbox:', config.imap.mailbox);

      // Search for unread emails
      this.checkNewEmails();

      // Poll for new emails
      setInterval(() => {
        this.checkNewEmails();
      }, config.imap.pollingInterval * 1000);
    });
  }

  /**
   * Check for new emails
   */
  async checkNewEmails() {
    if (!this.isConnected) return;

    const searchCriteria = config.processing.unreadOnly ? ['UNSEEN'] : ['ALL'];

    this.imap.search(searchCriteria, async (err, results) => {
      if (err) {
        console.error('Email search failed:', err);
        return;
      }

      if (!results || results.length === 0) {
        return;
      }

      console.log(`Found ${results.length} new email(s)`);

      // Limit processing
      const emailsToProcess = results.slice(0, config.processing.maxEmailsPerPoll);

      const fetch = this.imap.fetch(emailsToProcess, {
        bodies: '',
        markSeen: config.processing.markAsRead
      });

      fetch.on('message', (msg, seqno) => {
        msg.on('body', (stream, info) => {
          simpleParser(stream, async (err, parsed) => {
            if (err) {
              console.error('Failed to parse email:', err);
              return;
            }

            // Skip already processed emails
            const emailId = parsed.messageId;
            if (this.processedEmails.has(emailId)) {
              return;
            }

            // Process the email
            await this.processEmail(parsed);

            // Mark as processed
            this.processedEmails.add(emailId);
            await this.saveProcessedEmails();
          });
        });
      });

      fetch.on('error', (err) => {
        console.error('Fetch error:', err);
      });
    });
  }

  /**
   * Process an email with OpenClaw
   */
  async processEmail(email) {
    console.log('Processing email from:', email.from.text);
    console.log('Subject:', email.subject);

    // Format email data for OpenClaw
    const emailData = {
      from: email.from.text,
      to: email.to ? email.to.text : '',
      subject: email.subject,
      body: email.text || email.html,
      date: email.date,
      messageId: email.messageId
    };

    // Here you would integrate with OpenClaw's processing pipeline
    // For now, we'll just log it
    // TODO: Integrate with OpenClaw hook system

    console.log('Email processed:', emailData);

    // Send to OpenClaw for processing
    // This would typically involve calling an OpenClaw webhook or hook
  }

  /**
   * Send an email
   */
  async sendEmail(to, subject, body, options = {}) {
    try {
      const mailOptions = {
        from: config.appPassword.user,
        to: to,
        subject: subject,
        text: body + (config.response.signature || ''),
        ...options
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Email sent:', info.messageId);
      return info;
    } catch (error) {
      console.error('Failed to send email:', error);
      throw error;
    }
  }

  /**
   * Load processed emails from file
   */
  async loadProcessedEmails() {
    try {
      const filePath = path.join('/opt/janet/logs', 'processed-emails.json');
      const data = await fs.readFile(filePath, 'utf8');
      this.processedEmails = new Set(JSON.parse(data));
    } catch (error) {
      // File doesn't exist or is invalid, start fresh
      this.processedEmails = new Set();
    }
  }

  /**
   * Save processed emails to file
   */
  async saveProcessedEmails() {
    try {
      const filePath = path.join('/opt/janet/logs', 'processed-emails.json');
      await fs.writeFile(
        filePath,
        JSON.stringify(Array.from(this.processedEmails)),
        'utf8'
      );
    } catch (error) {
      console.error('Failed to save processed emails:', error);
    }
  }

  /**
   * Generate OAuth2 token (if using OAuth2)
   */
  generateXOAuth2Token() {
    // This would generate an OAuth2 token
    // Implementation depends on your OAuth2 setup
    return '';
  }

  /**
   * Disconnect from Gmail
   */
  disconnect() {
    if (this.imap) {
      this.imap.end();
    }
  }
}

// Export singleton instance
module.exports = new GmailIntegration();
