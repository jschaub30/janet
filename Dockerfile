FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    supervisor \
    apache2 \
    php8.1 \
    php8.1-cli \
    php8.1-fpm \
    php8.1-mysql \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-gd \
    php8.1-zip \
    php8.1-intl \
    libapache2-mod-php8.1 \
    mysql-client \
    unzip \
    chromium-browser \
    chromium-chromedriver \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
RUN mkdir -p /opt/janet
WORKDIR /opt/janet

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Copy package.json for dependencies
COPY package.json /opt/janet/package.json
RUN cd /opt/janet && npm install

# Configure Apache
RUN a2enmod rewrite \
    && a2enmod php8.1 \
    && a2enmod headers

# Create WordPress directory
RUN mkdir -p /var/www/wordpress
WORKDIR /var/www/wordpress

# Download and install WordPress
RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz \
    && chown -R www-data:www-data /var/www/wordpress \
    && chmod -R 755 /var/www/wordpress

# Install WP-CLI for WordPress management
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy Apache configuration
COPY apache-wordpress.conf /etc/apache2/sites-available/wordpress.conf
RUN a2dissite 000-default.conf \
    && a2ensite wordpress.conf

# Create OpenClaw config directory
RUN mkdir -p /root/.openclaw /root/.openclaw/skills

# Copy OpenClaw configuration
COPY config/openclaw.json /root/.openclaw/openclaw.json

# Create supervisor configuration directory
RUN mkdir -p /var/log/supervisor

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy application files
COPY gmail-integration.js /opt/janet/gmail-integration.js

# Copy startup scripts
COPY start.sh /opt/janet/start.sh
COPY wp-init.sh /opt/janet/wp-init.sh
COPY install-agent-skills.sh /opt/janet/install-agent-skills.sh
COPY setup-telegram.sh /opt/janet/setup-telegram.sh
COPY setup-gmail.sh /opt/janet/setup-gmail.sh
RUN chmod +x /opt/janet/start.sh /opt/janet/wp-init.sh /opt/janet/install-agent-skills.sh /opt/janet/setup-telegram.sh /opt/janet/setup-gmail.sh

# Expose ports
# 80: WordPress
# 3000: OpenClaw (if needed)
EXPOSE 80 3000

# Set working directory back to janet
WORKDIR /opt/janet

# Start supervisor to manage all services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
