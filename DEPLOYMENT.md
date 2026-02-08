# Janet Deployment Guide

This guide covers deploying Janet to a VPS (Virtual Private Server) for production use.

## Recommended VPS Providers

- **DigitalOcean** - $6/month droplet is sufficient
- **Linode** - Good performance and support
- **Vultr** - Affordable with many locations
- **AWS Lightsail** - If you're already on AWS
- **Hetzner** - Great value for Europe

## Minimum Requirements

- **OS**: Ubuntu 22.04 LTS
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 20GB minimum
- **CPU**: 1 vCPU minimum, 2+ recommended

## Step-by-Step Deployment

### 1. Provision Your VPS

Create a new server with Ubuntu 22.04 LTS. Note your:
- Server IP address
- SSH login credentials

### 2. Initial Server Setup

```bash
# SSH into your server
ssh root@your-server-ip

# Update system packages
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose
apt install -y docker-compose

# Install git
apt install -y git

# Create a non-root user (recommended)
adduser janet
usermod -aG docker janet
usermod -aG sudo janet

# Switch to new user
su - janet
```

### 3. Clone and Configure Janet

```bash
# Clone the repository (or upload files via SCP)
git clone <your-repo-url> ~/janet
cd ~/janet

# Or, if transferring from local machine:
# On local: scp -r janet/ janet@your-server-ip:~/
# On server: cd ~/janet

# Copy and configure environment
cp .env.example .env
nano .env
```

**Production .env Configuration:**

```bash
# Update these with production values
ANTHROPIC_API_KEY=your-real-api-key

# Use your actual domain or IP
WORDPRESS_URL=http://your-domain.com

# Strong passwords
WORDPRESS_ADMIN_PASSWORD=very-strong-password-here
WORDPRESS_DB_PASSWORD=another-strong-password
MYSQL_ROOT_PASSWORD=yet-another-strong-password
JANET_API_PASSWORD=strong-api-password

# Your Gmail
GMAIL_USER=your-email@gmail.com
GMAIL_APP_PASSWORD=your-app-password

# Production settings
NODE_ENV=production
OPENCLAW_LOG_LEVEL=info
```

### 4. Configure Firewall

```bash
# Install UFW if not installed
sudo apt install -y ufw

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP (WordPress)
sudo ufw allow 80/tcp

# Allow HTTPS (if using SSL)
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

### 5. Build and Start Janet

```bash
cd ~/janet

# Build the Docker image
docker-compose build

# Start in background
docker-compose up -d

# Check if running
docker-compose ps

# View logs
docker-compose logs -f
```

### 6. Setup Telegram

```bash
# Enter the container
docker exec -it janet-assistant bash

# Run Telegram setup
./setup-telegram.sh

# Scan the QR code with your phone
# Press Ctrl+C when done

exit
```

### 7. Verify WordPress

Open your browser:
- Visit: `http://your-server-ip:8080`
- Login to admin: `http://your-server-ip:8080/wp-admin`

## Setting Up a Domain Name

### Option 1: Direct Access via IP

Use your server IP with port 8080:
```
http://your-server-ip:8080
```

### Option 2: Domain with Nginx Reverse Proxy

```bash
# Install Nginx
sudo apt install -y nginx

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/janet
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/janet /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Option 3: Domain with SSL (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Certificate will auto-renew
```

Update your .env:
```bash
WORDPRESS_URL=https://your-domain.com
```

Restart Janet:
```bash
cd ~/janet
docker-compose restart
```

## Monitoring and Maintenance

### View Logs

```bash
# All logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# OpenClaw only
docker-compose logs -f janet

# Database logs
docker-compose logs -f db
```

### Restart Services

```bash
cd ~/janet

# Restart everything
docker-compose restart

# Restart only Janet
docker-compose restart janet

# Stop everything
docker-compose down

# Start everything
docker-compose up -d
```

### Update Janet

```bash
cd ~/janet

# Pull latest changes (if using git)
git pull

# Rebuild
docker-compose build

# Restart
docker-compose up -d
```

### Backup Data

```bash
# Create backup directory
mkdir -p ~/backups

# Backup WordPress database
docker exec janet-mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD wordpress > ~/backups/wordpress-$(date +%Y%m%d).sql

# Backup WordPress files
docker cp janet-assistant:/var/www/wordpress ~/backups/wordpress-files-$(date +%Y%m%d)

# Backup OpenClaw data
docker cp janet-assistant:/root/.openclaw ~/backups/openclaw-$(date +%Y%m%d)
```

### Automated Backups

Create a backup script:

```bash
nano ~/backup-janet.sh
```

Add:

```bash
#!/bin/bash
BACKUP_DIR=~/backups
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker exec janet-mysql mysqldump -u root -pYOUR_ROOT_PASSWORD wordpress | gzip > $BACKUP_DIR/db-$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "db-*.sql.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

Make it executable:
```bash
chmod +x ~/backup-janet.sh
```

Schedule daily backups:
```bash
crontab -e
```

Add:
```
0 2 * * * /home/janet/backup-janet.sh >> /home/janet/backup.log 2>&1
```

### Monitor Resources

```bash
# Container stats
docker stats

# Disk usage
docker system df

# Clean up unused Docker data
docker system prune -a
```

## Security Best Practices

### 1. Secure SSH

```bash
# Disable root login
sudo nano /etc/ssh/sshd_config

# Set: PermitRootLogin no
# Set: PasswordAuthentication no (after setting up SSH keys)

sudo systemctl restart sshd
```

### 2. Setup SSH Keys

On your local machine:
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
ssh-copy-id janet@your-server-ip
```

### 3. Automatic Security Updates

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 4. Install Fail2Ban

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 5. Restrict WordPress Login

Edit `config/openclaw.json` to limit Telegram access:

```json
channels: {
  telegram: {
    allowFrom: ["+1234567890"],  // Only your number
    ...
  }
}
```

## Troubleshooting Production Issues

### Container won't start

```bash
# Check logs
docker-compose logs

# Check disk space
df -h

# Check memory
free -m

# Restart Docker
sudo systemctl restart docker
```

### Out of disk space

```bash
# Clean Docker
docker system prune -a

# Clean old logs
sudo journalctl --vacuum-time=7d

# Check large files
du -sh /* | sort -h
```

### High memory usage

```bash
# Add swap if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### WordPress is slow

```bash
# Increase PHP memory limit
docker exec -it janet-assistant bash
nano /etc/php/8.1/apache2/php.ini

# Set: memory_limit = 256M

# Restart Apache
apache2ctl restart
```

## Monitoring Tools

### Simple Uptime Monitoring

Use external services:
- **UptimeRobot** (free): https://uptimerobot.com
- **StatusCake** (free): https://www.statuscake.com
- **Pingdom** (paid): https://www.pingdom.com

### Server Monitoring

```bash
# Install htop
sudo apt install -y htop

# Install glances
sudo apt install -y glances

# Run monitoring
htop
# or
glances
```

## Disaster Recovery

### Full System Restore

1. **Provision new VPS** with same specs
2. **Install Docker** and dependencies
3. **Restore backups**:

```bash
# Copy backup files to new server
scp ~/backups/* janet@new-server-ip:~/backups/

# On new server
cd ~/janet
docker-compose up -d

# Stop services
docker-compose stop

# Restore database
docker exec -i janet-mysql mysql -u root -pPASSWORD wordpress < ~/backups/db-YYYYMMDD.sql

# Restore WordPress files
docker cp ~/backups/wordpress-files-YYYYMMDD/. janet-assistant:/var/www/wordpress

# Restore OpenClaw
docker cp ~/backups/openclaw-YYYYMMDD/. janet-assistant:/root/.openclaw

# Start services
docker-compose start
```

## Performance Tuning

### Optimize MySQL

Create `mysql-custom.cnf`:

```ini
[mysqld]
innodb_buffer_pool_size = 256M
max_connections = 50
query_cache_size = 16M
query_cache_type = 1
```

Update docker-compose.yml:
```yaml
db:
  volumes:
    - ./mysql-custom.cnf:/etc/mysql/conf.d/custom.cnf
```

### Optimize WordPress

Install caching plugin:
```bash
docker exec -it janet-assistant wp plugin install w3-total-cache --activate --allow-root --path=/var/www/wordpress
```

## Cost Optimization

### Estimated Monthly Costs

- **VPS**: $5-12/month
- **Domain**: $10-15/year (~$1/month)
- **SSL**: Free (Let's Encrypt)
- **Anthropic API**: Pay-per-use (~$20-50/month for moderate use)

**Total**: ~$26-63/month

### Reduce Costs

1. Use smaller VPS during testing
2. Implement rate limiting on OpenClaw
3. Use Haiku model for simple queries
4. Set API usage limits in Anthropic console

## Support

If you encounter issues:

1. Check logs: `docker-compose logs -f`
2. Review this guide's troubleshooting section
3. Search [OpenClaw issues](https://github.com/openclaw/openclaw/issues)
4. Check [WordPress forums](https://wordpress.org/support/)

---

**Happy Deploying!** 🚀
