#!/bin/bash
set -e

# Log helper function
log() {
    echo "[INFO] $1"
}

# Validate required environment variables
required_vars=("DB_NAME" "DB_USER" "DB_HOST" "DOMAIN_NAME" "SITE_TITLE" "WP_ADMIN" "WP_ADMIN_EMAIL" "WP_USER" "WP_USER_EMAIL")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "[ERROR] Environment variable $var is not set."
        exit 1
    fi
done

# Validate secret files
if [ ! -f /run/secrets/db_password ] || [ ! -f /run/secrets/wp_admin_pw ] || [ ! -f /run/secrets/wp_user_pw ]; then
    echo "[ERROR] Required secret files are missing."
    exit 1
fi

# Wait for MariaDB to be ready
log "Waiting for MariaDB to be ready..."
until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" --password="$(cat "$WORDPRESS_DB_PASSWORD_FILE")" --silent; do
    sleep 2
done

# Download WordPress core if missing
if [ ! -f /var/www/html/wp-load.php ]; then
    wp core download --path=/var/www/html --allow-root
fi

# Create wp-config.php if missing
if [ ! -f /var/www/html/wp-config.php ]; then
    log "Creating wp-config.php with DB settings..."
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$(cat "$WORDPRESS_DB_PASSWORD_FILE")" \
        --dbhost="$DB_HOST" \
        --path=/var/www/html \
        --allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --path=/var/www/html --allow-root; then
    log "Installing WordPress core..."
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --admin_password="$(cat "$WORDPRESS_ADMIN_PASSWORD_FILE")" \
        --path=/var/www/html \
        --allow-root
    log "Creating WordPress user..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$(cat "$WORDPRESS_USER_PASSWORD_FILE")" \
        --role=editor \
		--path=/var/www/html \
        --allow-root
fi

# Ensure /run/php exists for the FPM socket
mkdir -p /run/php

exec php-fpm7.4 -F