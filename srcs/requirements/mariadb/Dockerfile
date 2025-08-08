# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aarponen <aarponen@student.42berlin.de>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/02 14:40:39 by aarponen          #+#    #+#              #
#    Updated: 2025/06/25 12:12:57 by aarponen         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# This Dockerfile sets up a MariaDB server with a custom configuration and initialization script

#  Use the penultimate stable version of Debian as the base image
FROM debian:bullseye-slim

# Update the package list and install necessary packages
# (gettext is used for environment variable substitution in configuration files)
RUN apt-get update && \
	apt-get install -y --no-install-recommends mariadb-server gettext && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Expose port 3306 for MariaDB
EXPOSE 3306

# Add an entrypoint script to initialize the database
COPY tools/docker-entrypoint.sh /usr/local/bin/
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init.sql /tmp/init.sql
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Make sure the socket directory exists and has the correct permissions
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# healthcheck.sh is a script that checks if the MariaDB server is running
COPY tools/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]




