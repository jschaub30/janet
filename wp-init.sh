#!/bin/bash

# WordPress Initialization Script for Janet
# This script sets up WordPress after the database is ready

set -e

echo "Initializing WordPress for Janet..."

# Wait for WordPress to be accessible
sleep 5

# Check if WordPress is already installed
if ! wp core is-installed --allow-root --path=/var/www/wordpress 2>/dev/null; then
    echo "WordPress not yet installed. Setting up..."

    # Install WordPress
    wp core install \
        --url="${WORDPRESS_URL:-http://localhost:8080}" \
        --title="${WORDPRESS_SITE_TITLE:-Janet's WordPress Site}" \
        --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD:-change_this_password}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email \
        --allow-root \
        --path=/var/www/wordpress

    echo "WordPress installed successfully!"

    # Install useful plugins for AI assistant
    echo "Installing recommended plugins..."

    # REST API enhancements
    wp plugin install rest-api-toolbox --activate --allow-root --path=/var/www/wordpress || true

    # Application passwords for programmatic access
    wp plugin install application-passwords --activate --allow-root --path=/var/www/wordpress || true

    echo "Plugins installed!"

    # Set pretty permalinks
    wp rewrite structure '/%postname%/' --allow-root --path=/var/www/wordpress

    # Flush rewrite rules
    wp rewrite flush --allow-root --path=/var/www/wordpress

    echo "Permalinks configured!"

else
    echo "WordPress is already installed."
fi

# Create an API user for Janet
if ! wp user get janet --allow-root --path=/var/www/wordpress 2>/dev/null; then
    echo "Creating Janet API user..."
    wp user create janet janet@openclaw.local \
        --role=administrator \
        --user_pass="${JANET_API_PASSWORD:-janet_api_password}" \
        --display_name="Janet AI Assistant" \
        --allow-root \
        --path=/var/www/wordpress || true
    echo "Janet API user created!"
fi

echo "WordPress initialization complete!"
