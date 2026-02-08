# Janet - OpenClaw AI Assistant

Janet is an AI assistant powered by [OpenClaw](https://openclaw.ai/) with full WordPress administrative access. She can communicate via Telegram and Gmail, and has expert knowledge of WordPress development through the [Automattic Agent Skills](https://github.com/Automattic/agent-skills).

## Features

- **🤖 AI-Powered**: Uses Claude Opus 4.6 for intelligent responses
- **📱 Telegram Integration**: Communicate via Telegram bot
- **📧 Gmail Integration**: Send and receive emails, process email requests
- **🌐 WordPress Management**: Full admin access to WordPress site
- **🛠️ Agent Skills**: Expert WordPress knowledge from Automattic
- **🐳 Docker-based**: Isolated, portable, easy to deploy on any VPS

## Architecture

```
┌─────────────────────────────────────────────┐
│         Docker Container (Ubuntu)           │
│                                             │
│  ┌──────────────┐      ┌────────────────┐  │
│  │   OpenClaw   │◄────►│   WordPress    │  │
│  │   Gateway    │      │   + Apache     │  │
│  └──────┬───────┘      └────────┬───────┘  │
│         │                       │           │
│         │              ┌────────▼───────┐   │
│         │              │   MySQL DB     │   │
│         │              └────────────────┘   │
│         │                                    │
│         ├─► Telegram (via Telegram Web)     │
│         ├─► Gmail (via IMAP/SMTP)           │
│         └─► Agent Skills (WordPress)        │
│                                             │
└─────────────────────────────────────────────┘
```

## Prerequisites

- Docker and Docker Compose installed
- Anthropic API key ([Get one here](https://console.anthropic.com/))
- Gmail account with App Password or OAuth2 credentials
- Telegram account (to create a bot via @BotFather)

## Quick Start

### 1. Clone and Configure

```bash
# Clone or download this repository
cd janet

# Copy the example environment file
cp .env.example .env

# Edit .env with your credentials
nano .env  # or use your preferred editor
```

**Required Configuration:**
- `ANTHROPIC_API_KEY`: Your Anthropic API key
- `GMAIL_USER`: Your Gmail address
- `GMAIL_APP_PASSWORD`: Gmail app password ([Generate here](https://myaccount.google.com/apppasswords))
- WordPress passwords (change from defaults)

### 2. Build and Start

```bash
# Build the Docker image
docker-compose build

# Start the containers
docker-compose up -d

# Check logs
docker-compose logs -f
```

### 3. Access WordPress

Open your browser and go to:
- **WordPress Site**: http://localhost:8080
- **WordPress Admin**: http://localhost:8080/wp-admin/

**Default Credentials:**
- Username: `admin` (or whatever you set in .env)
- Password: Set in `WORDPRESS_ADMIN_PASSWORD`

**Janet's Credentials:**
- Username: `janet`
- Password: Set in `JANET_API_PASSWORD`

### 4. Setup Telegram

First, create a bot on Telegram:
1. Open Telegram and search for @BotFather
2. Send `/newbot` and follow the prompts
3. Copy the bot token
4. Add `TELEGRAM_BOT_TOKEN=your-token-here` to your `.env` file
5. Restart: `docker-compose restart`

Then run the setup script:
```bash
docker exec -it janet-assistant ./setup-telegram.sh
```

### 5. Test Gmail Integration

```bash
# Inside the container
./setup-gmail.sh
```

Send a test email to your Gmail address and Janet will process it.

## Usage

### Communicating with Janet

**Via Telegram:**
```
Search for your bot on Telegram and send it a message.

In groups, add your bot and mention it to get Janet's attention.
```

**Via Gmail:**
```
Send an email to the Gmail address you configured.
Janet will read and respond to your emails.
```

### WordPress Commands

Janet has full access to WordPress via WP-CLI. You can ask her to:

**Content Management:**
- "Create a new blog post about AI technology"
- "Update the homepage content"
- "Delete all draft posts"
- "List all published posts"

**Plugin Management:**
- "Install and activate the Yoast SEO plugin"
- "List all active plugins"
- "Update all plugins"

**User Management:**
- "Create a new editor user"
- "List all users"
- "Change admin password"

**Site Configuration:**
- "Change the site title"
- "Update permalink structure"
- "Enable XML-RPC"

### Example Conversations

**Creating Content:**
```
You: Create a blog post about Docker containers
Janet: I'll create that post for you. One moment...
      [executes: wp post create --post_title="Understanding Docker Containers" ...]
      Done! I've created and published the post. You can view it at:
      http://localhost:8080/understanding-docker-containers/
```

**Managing Plugins:**
```
You: What plugins are currently installed?
Janet: Let me check...
      [executes: wp plugin list ...]
      You have 5 plugins installed:
      - Akismet (active)
      - Hello Dolly (inactive)
      - Contact Form 7 (active)
      ...
```

## Deployment to VPS

### Option 1: Direct Docker Deployment

```bash
# On your VPS (Ubuntu/Debian)
sudo apt update
sudo apt install -y docker.io docker-compose git

# Clone the repository
git clone <your-repo-url> janet
cd janet

# Configure environment
cp .env.example .env
nano .env  # Update with production values

# Build and start
docker-compose build
docker-compose up -d

# Setup firewall
sudo ufw allow 8080/tcp
sudo ufw enable
```

### Option 2: Transfer Docker Image

```bash
# On your local machine
docker save janet-assistant:latest | gzip > janet-assistant.tar.gz

# Copy to VPS
scp janet-assistant.tar.gz user@your-vps:/tmp/

# On VPS
docker load < /tmp/janet-assistant.tar.gz
cd /path/to/janet
docker-compose up -d
```

### Production Considerations

1. **Use a reverse proxy** (nginx/Caddy) for SSL/TLS
2. **Change all default passwords** in production
3. **Set up automatic backups** for WordPress and database
4. **Monitor logs** regularly
5. **Keep OpenClaw and WordPress updated**

## File Structure

```
janet/
├── Dockerfile                 # Main container definition
├── docker-compose.yml         # Docker orchestration
├── .env.example              # Environment variables template
├── README.md                 # This file
├── config/
│   ├── openclaw.json         # OpenClaw configuration
│   ├── telegram-config.js    # Telegram settings
│   └── gmail-config.js       # Gmail settings
├── apache-wordpress.conf     # Apache configuration
├── supervisord.conf          # Service management
├── start.sh                  # Container startup script
├── wp-init.sh               # WordPress initialization
├── install-agent-skills.sh  # Agent Skills installer
├── setup-telegram.sh        # Telegram setup helper
├── setup-gmail.sh           # Gmail setup helper
├── gmail-integration.js     # Gmail integration code
└── package.json            # Node.js dependencies
```

## Configuration Reference

### Environment Variables

See `.env.example` for all available configuration options.

**Core Settings:**
- `ANTHROPIC_API_KEY`: Anthropic API key (required)
- `NODE_ENV`: Environment (production/development)
- `OPENCLAW_LOG_LEVEL`: Logging level (info/debug/error)

**WordPress:**
- `WORDPRESS_DB_*`: Database credentials
- `WORDPRESS_ADMIN_*`: Admin user settings
- `WORDPRESS_URL`: Site URL

**Gmail:**
- `GMAIL_USER`: Gmail address
- `GMAIL_APP_PASSWORD`: App password
- `GMAIL_POLLING_INTERVAL`: Email check interval (seconds)

**Telegram:**
- `WHATSAPP_ENABLED`: Enable/disable Telegram

### OpenClaw Configuration

Edit `config/openclaw.json` to customize:
- Model selection and parameters
- Channel restrictions (allowFrom)
- Group chat behavior
- System prompts
- Skills paths

## Troubleshooting

### Telegram won't connect
- Ensure you're using a real phone number (not VoIP)
- Check that your phone has internet access
- Try regenerating the QR code
- Check logs: `docker-compose logs openclaw`

### Gmail not receiving emails
- Verify App Password is correct
- Check Gmail settings allow IMAP
- Ensure 2FA is enabled on your Google account
- Check firewall isn't blocking IMAP ports

### WordPress database connection failed
- Wait 30 seconds for MySQL to initialize
- Check database credentials in .env
- Restart containers: `docker-compose restart`

### OpenClaw crashes on startup
- Verify ANTHROPIC_API_KEY is valid
- Check available disk space
- Review logs: `docker-compose logs -f`

### Container exits immediately
- Check logs for errors
- Ensure all required files are present
- Verify .env file is properly configured

## Advanced Configuration

### Gmail PubSub (Real-time Notifications)

For instant email processing instead of polling:

1. Create a Google Cloud Project
2. Enable Gmail API and Pub/Sub API
3. Configure Pub/Sub topic and subscription
4. Update .env with PubSub credentials
5. Set `GMAIL_PUBSUB_ENABLED=true`

See [OpenClaw Gmail PubSub documentation](https://docs.openclaw.ai/automation/gmail-pubsub) for details.

### Custom Agent Skills

Add your own skills in `/root/.openclaw/skills/`:

```markdown
# My Custom Skill

Description of what this skill does.

## Usage

Instructions...
```

### Multiple Telegram Numbers

To use multiple Telegram accounts, run separate containers with different configurations.

## Maintenance

### Backup WordPress

```bash
# Backup database
docker exec janet-mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD wordpress > backup.sql

# Backup WordPress files
docker cp janet-assistant:/var/www/wordpress ./wordpress-backup
```

### Update OpenClaw

```bash
# Enter container
docker exec -it janet-assistant bash

# Update OpenClaw
npm update -g openclaw@latest

# Restart
exit
docker-compose restart
```

### View Logs

```bash
# All logs
docker-compose logs -f

# OpenClaw only
docker-compose logs -f janet

# WordPress errors
docker exec janet-assistant tail -f /var/log/apache2/wordpress-error.log
```

## Security Notes

⚠️ **Important Security Considerations:**

1. **Change all default passwords** in production
2. **Never commit .env file** to version control
3. **Use strong passwords** for all accounts
4. **Keep WordPress and plugins updated**
5. **Limit Telegram allowFrom** to trusted numbers
6. **Use OAuth2 instead of App Passwords** for Gmail in production
7. **Enable SSL/TLS** with a reverse proxy
8. **Regular backups** are essential
9. **Monitor logs** for suspicious activity

## Contributing

Janet is configured for your specific use case. To modify:

1. Edit configuration files in `config/`
2. Modify scripts as needed
3. Rebuild: `docker-compose build`
4. Restart: `docker-compose restart`

## Resources

- **OpenClaw Documentation**: https://docs.openclaw.ai/
- **OpenClaw GitHub**: https://github.com/openclaw/openclaw
- **Automattic Agent Skills**: https://github.com/Automattic/agent-skills
- **WordPress Agent Skills**: https://github.com/WordPress/agent-skills
- **WordPress CLI**: https://wp-cli.org/
- **Anthropic API**: https://docs.anthropic.com/

## License

This configuration is provided as-is for personal use. OpenClaw is MIT licensed. WordPress is GPL licensed.

## Support

For issues with:
- **OpenClaw**: https://github.com/openclaw/openclaw/issues
- **WordPress**: https://wordpress.org/support/
- **This setup**: Review logs and check configuration

---

**Janet** - Your AI WordPress Assistant 🦞
