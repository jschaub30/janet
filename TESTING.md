# Janet Testing Guide

This guide helps you verify that all components of Janet are working correctly.

## Pre-Test Checklist

Before testing, ensure:
- [ ] Docker and Docker Compose are installed
- [ ] `.env` file is configured with valid credentials
- [ ] All required services are running: `docker-compose ps`
- [ ] No port conflicts (8080, 3000, 3306)

## Testing Phases

### Phase 1: Container Health Check

```bash
# Check all containers are running
docker-compose ps

# Expected output:
# NAME                STATUS              PORTS
# janet-assistant     Up                  0.0.0.0:8080->80/tcp, 0.0.0.0:3000->3000/tcp
# janet-mysql         Up                  3306/tcp

# Check logs for errors
docker-compose logs --tail=50

# Should see:
# - "WordPress configured!"
# - "Agent Skills installed successfully!"
# - "Starting OpenClaw..."
# - No critical errors
```

**✅ Pass Criteria:**
- Both containers show "Up" status
- No error messages in logs
- Services started successfully

### Phase 2: WordPress Installation Test

```bash
# Check WordPress is accessible
curl -I http://localhost:8080

# Expected: HTTP/1.1 200 OK or 302 (redirect)

# Enter the container
docker exec -it janet-assistant bash

# Check WordPress installation
wp core is-installed --allow-root --path=/var/www/wordpress
echo $?  # Should output: 0

# Check WordPress version
wp core version --allow-root --path=/var/www/wordpress

# List users
wp user list --allow-root --path=/var/www/wordpress

# Should see:
# - admin user
# - janet user (with administrator role)

exit
```

**✅ Pass Criteria:**
- WordPress responds to HTTP requests
- WordPress is installed and configured
- Both admin and janet users exist
- Janet has administrator role

**Test in Browser:**
1. Open http://localhost:8080
2. Should see WordPress site
3. Open http://localhost:8080/wp-admin
4. Login with admin credentials
5. Verify you can access dashboard

### Phase 3: OpenClaw Integration Test

```bash
# Enter container
docker exec -it janet-assistant bash

# Check OpenClaw is installed
which openclaw
# Should output: /usr/local/bin/openclaw or similar

# Check OpenClaw version
openclaw --version

# Check configuration exists
ls -la /root/.openclaw/
# Should see: openclaw.json, skills/, credentials/, etc.

# Check OpenClaw config
cat /root/.openclaw/openclaw.json
# Verify configuration is loaded correctly

# Test API key
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-opus-4-6",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hi"}]
  }'

# Should get a valid response (not "invalid_api_key" error)

exit
```

**✅ Pass Criteria:**
- OpenClaw is installed and accessible
- Configuration file exists and is valid
- Anthropic API key works
- No permission errors

### Phase 4: Agent Skills Test

```bash
docker exec -it janet-assistant bash

# Check skills directory
ls -la /root/.openclaw/skills/

# Should see:
# - janet-wordpress.md
# - Other WordPress-related skills
# - README.md

# Verify janet-wordpress.md exists
cat /root/.openclaw/skills/janet-wordpress.md | head -20

# Check skills are accessible
ls -la /root/.claude/skills/

exit
```

**✅ Pass Criteria:**
- Skills directory exists and contains files
- janet-wordpress.md is present and readable
- Skills are in correct locations

### Phase 5: WordPress CLI Test

```bash
docker exec -it janet-assistant bash

# Test basic WP-CLI commands
wp --version

# Test WordPress connection
wp option get siteurl --allow-root --path=/var/www/wordpress
# Should output: your WordPress URL

# Create a test post
wp post create \
  --post_title="Test Post from Janet" \
  --post_content="This is a test post to verify WP-CLI integration." \
  --post_status=publish \
  --allow-root \
  --path=/var/www/wordpress

# List posts
wp post list --allow-root --path=/var/www/wordpress

# Should see the test post

# Delete test post
wp post delete <POST_ID> --force --allow-root --path=/var/www/wordpress

exit
```

**✅ Pass Criteria:**
- WP-CLI commands execute successfully
- Can create, read, and delete posts
- Janet has WordPress admin access

### Phase 6: Telegram Integration Test

```bash
docker exec -it janet-assistant bash

# Check Telegram credentials directory
ls -la /root/.openclaw/credentials/telegram/ || echo "Not configured yet"

# If not configured, run setup
./setup-telegram.sh

# Follow prompts to scan QR code
# After successful connection, check credentials
ls -la /root/.openclaw/credentials/telegram/

# Should see: creds.json and other session files

exit
```

**Manual Test:**
1. Send a message to your Telegram number (the one you connected)
2. Message should say: "Hello Janet"
3. Wait for response from Janet
4. Verify Janet responds appropriately

**✅ Pass Criteria:**
- Telegram credentials exist after QR scan
- Can send message to Telegram
- Janet receives and responds to messages
- Responses are relevant and use Claude

**Group Chat Test:**
1. Add Janet's Telegram to a group
2. Send: "@janet what can you do?"
3. Verify Janet responds only when mentioned

### Phase 7: Gmail Integration Test

```bash
docker exec -it janet-assistant bash

# Verify Gmail configuration
./setup-gmail.sh

# Check environment variables
echo $GMAIL_USER
echo $GMAIL_APP_PASSWORD | sed 's/./*/g'  # Masked

# Test Node.js dependencies
cd /opt/janet
npm list

# Should see: nodemailer, imap, mailparser

exit
```

**Manual Test:**
1. Send an email to your configured Gmail address
2. Subject: "Test - Janet Integration"
3. Body: "Hello Janet, can you read this email?"
4. Wait up to 60 seconds (polling interval)
5. Check logs: `docker-compose logs openclaw | grep -i email`

**✅ Pass Criteria:**
- Gmail credentials are configured
- Node.js dependencies installed
- Can connect to Gmail IMAP/SMTP
- Emails are detected and logged

**Send Email Test:**
```bash
docker exec -it janet-assistant bash

# Test sending email (if implemented)
node -e "
const gmail = require('./gmail-integration.js');
gmail.initialize().then(() => {
  gmail.sendEmail(
    'your-test-email@example.com',
    'Test from Janet',
    'This is a test email from Janet AI Assistant'
  );
});
"

exit
```

### Phase 8: End-to-End WordPress Management Test

This tests Janet's ability to manage WordPress through Telegram or email.

**Via Telegram:**
1. Message Janet: "List all WordPress posts"
2. Expected: Janet executes WP-CLI and returns list
3. Message Janet: "Create a new blog post titled 'AI Testing' with content 'This post was created by AI'"
4. Expected: Janet creates the post and confirms
5. Check WordPress admin to verify post exists
6. Message Janet: "Delete the post titled 'AI Testing'"
7. Expected: Janet deletes the post

**Via Email:**
1. Send email with subject "WordPress Task"
2. Body: "Please create a new page titled 'About Us' with content 'We are an AI-powered company'"
3. Wait for Janet to process (check logs)
4. Verify page exists in WordPress admin

**✅ Pass Criteria:**
- Janet can execute WordPress commands via Telegram
- Janet can execute WordPress commands via email
- Commands produce expected results in WordPress
- Janet provides confirmation of actions

### Phase 9: Integration Stress Test

```bash
# Monitor resources while running
docker stats

# In another terminal, generate some activity:

# 1. Send multiple Telegram messages
# 2. Send multiple emails
# 3. Make WordPress changes through admin panel
# 4. Execute WP-CLI commands

# Check logs for errors
docker-compose logs -f

# Check container health
docker-compose ps
```

**✅ Pass Criteria:**
- Containers remain stable under load
- No memory leaks (memory usage stable)
- CPU usage returns to baseline
- No error spikes in logs
- All services remain responsive

### Phase 10: Persistence Test

```bash
# Stop containers
docker-compose down

# Start again
docker-compose up -d

# Wait for startup
sleep 30

# Verify data persisted:

# 1. Check WordPress
curl http://localhost:8080
# Should still work

# 2. Check WordPress data
docker exec -it janet-assistant wp post list --allow-root --path=/var/www/wordpress
# Posts should still exist

# 3. Check OpenClaw credentials
docker exec -it janet-assistant ls -la /root/.openclaw/credentials/
# Telegram session should persist

# 4. Test Telegram connection
# Send a message - should work without re-scanning QR

# 5. Check database
docker exec janet-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW DATABASES;"
# WordPress database should exist
```

**✅ Pass Criteria:**
- All data survives container restart
- Telegram stays connected
- WordPress content intact
- Database data persists
- No re-configuration needed

## Test Results Checklist

Use this checklist to track your testing progress:

- [ ] Phase 1: Container Health Check
- [ ] Phase 2: WordPress Installation Test
- [ ] Phase 3: OpenClaw Integration Test
- [ ] Phase 4: Agent Skills Test
- [ ] Phase 5: WordPress CLI Test
- [ ] Phase 6: Telegram Integration Test
- [ ] Phase 7: Gmail Integration Test
- [ ] Phase 8: End-to-End WordPress Management Test
- [ ] Phase 9: Integration Stress Test
- [ ] Phase 10: Persistence Test

## Common Issues and Solutions

### Issue: WordPress database connection error

**Solution:**
```bash
# Wait 30 seconds for MySQL to fully start
sleep 30
docker-compose restart janet
```

### Issue: OpenClaw API key invalid

**Solution:**
```bash
# Verify API key in .env
cat .env | grep ANTHROPIC_API_KEY
# Test API key manually
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR_KEY_HERE" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model": "claude-opus-4-6", "max_tokens": 10, "messages": [{"role": "user", "content": "Hi"}]}'
```

### Issue: Telegram QR code not showing

**Solution:**
```bash
# Check OpenClaw logs
docker-compose logs openclaw | grep -i telegram

# Try adding channel manually
docker exec -it janet-assistant openclaw channel add telegram
```

### Issue: Gmail not receiving emails

**Solution:**
```bash
# Check Gmail credentials
docker exec -it janet-assistant bash
echo $GMAIL_USER
echo $GMAIL_APP_PASSWORD

# Verify App Password is enabled in Google account
# Go to: https://myaccount.google.com/apppasswords

# Check IMAP is enabled in Gmail settings
```

### Issue: Port 8080 already in use

**Solution:**
```bash
# Find what's using port 8080
lsof -i :8080

# Either stop that process or change Janet's port in docker-compose.yml:
ports:
  - "8888:80"  # Use 8888 instead

# Update WORDPRESS_URL in .env accordingly
```

## Performance Benchmarks

Expected performance metrics:

| Metric | Expected Value |
|--------|---------------|
| WordPress page load | < 2 seconds |
| Telegram response time | 3-10 seconds |
| Email processing time | 5-15 seconds |
| WP-CLI command execution | < 1 second |
| Container memory usage | < 1GB (Janet), < 300MB (MySQL) |
| Container CPU usage (idle) | < 5% |

## Automated Testing Script

```bash
#!/bin/bash
# Quick test script

echo "=== Janet Quick Test ==="
echo ""

echo "1. Testing containers..."
docker-compose ps | grep -q "Up" && echo "✅ Containers running" || echo "❌ Containers not running"

echo "2. Testing WordPress..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|302" && echo "✅ WordPress accessible" || echo "❌ WordPress not accessible"

echo "3. Testing WordPress CLI..."
docker exec janet-assistant wp core is-installed --allow-root --path=/var/www/wordpress 2>/dev/null && echo "✅ WordPress CLI works" || echo "❌ WordPress CLI failed"

echo "4. Testing OpenClaw..."
docker exec janet-assistant which openclaw >/dev/null 2>&1 && echo "✅ OpenClaw installed" || echo "❌ OpenClaw not found"

echo "5. Testing Agent Skills..."
docker exec janet-assistant test -f /root/.openclaw/skills/janet-wordpress.md && echo "✅ Agent Skills installed" || echo "❌ Agent Skills missing"

echo ""
echo "=== Test Complete ==="
```

Save as `quick-test.sh`, make executable (`chmod +x quick-test.sh`), and run it.

## Next Steps After Testing

Once all tests pass:

1. **Document your setup**: Note any customizations you made
2. **Create a backup**: Follow backup procedures in DEPLOYMENT.md
3. **Test recovery**: Restore from backup to ensure it works
4. **Monitor for 24 hours**: Watch logs and resource usage
5. **Set up monitoring**: Configure uptime monitoring service
6. **Train Janet**: Start with simple tasks and build up complexity
7. **Deploy to production**: Follow DEPLOYMENT.md guide

## Support

If tests fail:
1. Check logs: `docker-compose logs -f`
2. Review configuration files
3. Verify all credentials are correct
4. Check Prerequisites section
5. Review Common Issues above
6. Check OpenClaw GitHub issues

---

**Happy Testing!** 🧪
