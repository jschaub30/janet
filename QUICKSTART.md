# Janet - Quick Start Guide

Get Janet up and running in 5 minutes!

## Prerequisites

✅ Docker and Docker Compose installed
✅ Anthropic API key ([Get one](https://console.anthropic.com/))
✅ Gmail with App Password ([Generate](https://myaccount.google.com/apppasswords))
✅ Telegram account

## Step 1: Configure Environment (2 min)

```bash
cd janet

# Copy environment template
cp .env.example .env

# Edit with your credentials
nano .env
```

**Required values:**
```bash
ANTHROPIC_API_KEY=sk-ant-api03-your-key-here
GMAIL_USER=your-email@gmail.com
GMAIL_APP_PASSWORD=your-app-password-here
WORDPRESS_ADMIN_PASSWORD=choose-a-strong-password
```

## Step 2: Build and Start (2 min)

```bash
# Build the containers
docker-compose build

# Start everything
docker-compose up -d

# Check status
docker-compose ps
```

Wait about 30 seconds for services to initialize.

## Step 3: Verify Installation (1 min)

```bash
# Run quick test
./quick-test.sh
```

Should see all green checkmarks ✅

**Or test manually:**
- Open http://localhost:8080 (WordPress)
- Login to http://localhost:8080/wp-admin (admin/your-password)

## Step 4: Connect Telegram (Optional)

First, create a bot:
1. Search for @BotFather on Telegram
2. Send `/newbot` and follow prompts
3. Copy the bot token
4. Add to `.env`: `TELEGRAM_BOT_TOKEN=your-token`
5. Restart: `docker-compose restart`

Then setup:
```bash
docker exec -it janet-assistant ./setup-telegram.sh
```

## Step 5: Start Using Janet!

### Via Telegram
Search for your bot and send a message:
```
Hello Janet, list my WordPress posts
```

### Via Gmail
Send an email to your configured Gmail:
```
Subject: WordPress Task
Body: Create a new post titled "Hello World"
```

### Direct WordPress Access
Janet is always available in WordPress with username `janet`.

## Common First Commands

**Check WordPress status:**
```
What's the status of my WordPress site?
```

**Create content:**
```
Create a blog post about [topic]
```

**List content:**
```
Show me all my recent posts
```

**Install plugin:**
```
Install the Yoast SEO plugin
```

## Troubleshooting

### Containers won't start
```bash
docker-compose logs
# Check for errors, ensure ports 8080 not in use
```

### WordPress database error
```bash
# Wait 30 seconds for MySQL, then restart
docker-compose restart janet
```

### Can't access WordPress
```bash
# Check if running
docker-compose ps

# Verify port
curl http://localhost:8080
```

### Telegram bot not responding
```bash
# Check if bot token is set
docker exec janet-assistant printenv | grep TELEGRAM

# Check OpenClaw logs
docker-compose logs janet

# Verify plugin is enabled
docker exec janet-assistant openclaw plugins list | grep telegram
```

## Next Steps

- 📖 Read [README.md](README.md) for full documentation
- 🚀 See [DEPLOYMENT.md](DEPLOYMENT.md) for VPS deployment
- 🧪 Review [TESTING.md](TESTING.md) for comprehensive testing
- ⚙️ Customize `config/openclaw.json` for your needs

## Useful Commands

```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop everything
docker-compose down

# Start everything
docker-compose up -d

# Enter container
docker exec -it janet-assistant bash

# Backup WordPress
docker exec janet-mysql mysqldump -u root -p wordpress > backup.sql

# Run WordPress command
docker exec janet-assistant wp post list --allow-root --path=/var/www/wordpress
```

## Getting Help

- Check logs first: `docker-compose logs -f`
- Review [TESTING.md](TESTING.md) troubleshooting section
- Check [OpenClaw docs](https://docs.openclaw.ai/)
- Check [WordPress forums](https://wordpress.org/support/)

## Quick Reference

| Component | URL/Access |
|-----------|------------|
| WordPress Site | http://localhost:8080 |
| WordPress Admin | http://localhost:8080/wp-admin |
| Container Shell | `docker exec -it janet-assistant bash` |
| Logs | `docker-compose logs -f` |
| Config | `config/openclaw.json` |

---

**You're all set! Start chatting with Janet!** 🦞
