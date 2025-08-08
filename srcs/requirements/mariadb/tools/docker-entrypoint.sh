#!/bin/bash
set -e

# Initialize the MariaDB data directory if it does not exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    echo "Initialization complete."
fi

# Substitute environment variables in the init file
export MARIADB_PASSWORD=$(cat "$MARIADB_PASSWORD_FILE")
export MARIADB_ROOT_PASSWORD=$(cat "$MARIADB_ROOT_PASSWORD_FILE")
envsubst < /tmp/init.sql > /tmp/init_expanded.sql

# Remove any existing socket file to avoid conflicts
rm -f /run/mysqld/mysqld.sock

# Run the MariaDB server with the init file
exec mysqld --user=mysql --console --init-file="/tmp/init_expanded.sql"
