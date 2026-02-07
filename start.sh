#!/bin/bash

# Wait for database to be ready
echo "Waiting for database to be ready..."
while ! mysqladmin ping -h"db" --silent; do
    sleep 1
done
echo "Database is ready!"

# Configure WordPress if not already configured
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Configuring WordPress..."
    cd /var/www/wordpress

    # Create wp-config.php
    cat > wp-config.php << EOF
<?php
define('DB_NAME', getenv('WORDPRESS_DB_NAME') ?: 'wordpress');
define('DB_USER', getenv('WORDPRESS_DB_USER') ?: 'wordpress');
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD') ?: 'wordpress_password');
define('DB_HOST', getenv('WORDPRESS_DB_HOST') ?: 'db:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('AUTH_KEY',         '$(openssl rand -base64 32)');
define('SECURE_AUTH_KEY',  '$(openssl rand -base64 32)');
define('LOGGED_IN_KEY',    '$(openssl rand -base64 32)');
define('NONCE_KEY',        '$(openssl rand -base64 32)');
define('AUTH_SALT',        '$(openssl rand -base64 32)');
define('SECURE_AUTH_SALT', '$(openssl rand -base64 32)');
define('LOGGED_IN_SALT',   '$(openssl rand -base64 32)');
define('NONCE_SALT',       '$(openssl rand -base64 32)');

\$table_prefix = 'wp_';
define('WP_DEBUG', false);

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

    chown www-data:www-data wp-config.php
    chmod 644 wp-config.php
    echo "WordPress configured!"

    # Run WordPress initialization script
    /opt/janet/wp-init.sh
fi

# Initialize OpenClaw configuration directory
mkdir -p /root/.openclaw/channels
mkdir -p /root/.openclaw/skills
mkdir -p /opt/janet/whatsapp-sessions
mkdir -p /opt/janet/logs

# Install Agent Skills if not already installed
if [ ! -f "/root/.openclaw/skills/janet-wordpress.md" ]; then
    echo "Installing Agent Skills..."
    /opt/janet/install-agent-skills.sh
fi

# Wait a bit for everything to settle
sleep 5

# Start OpenClaw
cd /opt/janet
echo "Starting OpenClaw..."
exec openclaw start
