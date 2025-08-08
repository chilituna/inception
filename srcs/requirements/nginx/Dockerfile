# This Dockerfile sets up an NGINX server with TLSv1.2 or TLSv1.3 only


#  Use the penultimate stable version of Debian as the base image
FROM debian:bullseye-slim

# Install NGINX, OpenSSL (for TLS) and curl (for health checks)
# Clean up unnecessary files to reduce image size
RUN apt-get update && \
	apt-get install -y --no-install-recommends nginx openssl curl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Copy the custom NGINX configuration file
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Create self-signed SSL certificates if they do not exist
RUN [ -d "/etc/nginx/ssl" ] || ( \
    mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -sha256 -days 365 -nodes -newkey rsa:2048 \
        -subj "/CN=aarponen.42.fr" \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
)

# Expose port 443 for HTTPS
EXPOSE 443

# Remove the default server block configuration (which listens on port 80)
RUN rm /etc/nginx/sites-enabled/default

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
