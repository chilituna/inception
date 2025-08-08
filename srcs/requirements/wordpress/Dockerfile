# This Dockerfile sets up a WordPress environment with PHP-FPM
# and WP-CLI, using a Debian base image.

#  Use the penultimate stable version of Debian as the base image
FROM debian:bullseye-slim

# Update the package list and install necessary packages
# Install WordPress, PHP-FPM, PHP MySQL extension to connet to MariaDB
# and curl for WP-CLI installation
RUN apt-get update && \
	apt-get install -y --no-install-recommends wordpress php-fpm php-mysql curl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Edit PHP-FPM pool config to listen on TCP port 9000
RUN sed -i 's|^listen =.*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf \
 && sed -i 's|^listen.owner|;listen.owner|' /etc/php/7.4/fpm/pool.d/www.conf \
 && sed -i 's|^listen.group|;listen.group|' /etc/php/7.4/fpm/pool.d/www.conf


# Install WP-CLI, a command-line interface for WordPress
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
RUN grep ^listen /etc/php/7.4/fpm/pool.d/www.conf

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Copy and Set Up Entry Point Script
COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]



