# MariaDB Setup and Configuration

## Dockerfile

### COPY Instructions

- **`COPY tools/docker-entrypoint.sh /usr/local/bin/`**
  Scripts in `/usr/local/bin/` can be executed directly, e.g., `docker-entrypoint.sh` instead of specifying its full path.

- **`COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf`**
  Places the `my.cnf` configuration file into `/etc/mysql/mariadb.conf.d/`, where MariaDB looks for server-specific configurations. The `50-server.cnf` naming ensures it loads after default configs and can override them.

- **`COPY tools/init.sql /tmp/init.sql`**
  Temporarily stores the `init.sql` file, used for initializing the database during container setup. Since `/tmp` is temporary, it’s a logical place for one-time scripts.

### About the Socket File

- MariaDB (and MySQL) uses a Unix socket file (e.g., `/run/mysqld/mysqld.sock`) for local communication between the server and clients.
- The socket file must reside in a directory writable by the `mysql` user.
- Since `/run/mysqld` often doesn’t exist in minimal base images like `debian:bullseye-slim`, we need to:
  - Create it: `mkdir -p /run/mysqld`
  - Set ownership: `chown -R mysql:mysql /run/mysqld`

### CMD and ENTRYPOINT

#### CMD

- **Purpose:** Specifies the default application or process for the container.
- **Example:** `CMD ["/usr/bin/mysqld_safe"]` starts the MariaDB server after initialization.

#### ENTRYPOINT

- **Purpose:** Defines the main executable or script that always runs in the container.
- **Example:** `ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]` runs the initialization script.

**Best Practice:** Use `ENTRYPOINT` for setup or initialization logic and `CMD` for the default process.

---

## docker-entrypoint.sh

- **Secure MariaDB Initialization:**
  Uses `mysql_install_db --user=mysql --datadir=/var/lib/mysql` instead of `--initialize-insecure` to create a proper MariaDB installation that requires authentication.

- **`mysql` User:**

  - A Linux system user created during MariaDB installation.
  - Runs the MariaDB server process securely (`--user=mysql`), minimizing system-wide security risks.
  - The server should never be run as root user.

- **Socket File Management:**

  - The socket file (`mysqld.sock`) facilitates communication between the database server and local clients.
  - If stale (from crashes or improper shutdown), it can block server restarts. Deleting it ensures clean startup.

- **Environment Variable Substitution:**
  - Uses `envsubst` to replace environment variables in init.sql template with actual values from Docker secrets.
  - Passwords are read from files (`MARIADB_PASSWORD_FILE`, `MARIADB_ROOT_PASSWORD_FILE`) for security.

---

## init.sql

- **Database and User Creation:**

  - Creates the WordPress database if it doesn't exist
  - Creates database user with proper password authentication
  - Grants necessary privileges for WordPress functionality

- **`%` Wildcard:**
  Allows connections from any host.

  - Example: `'${DB_USER}'@'%'` lets `${DB_USER}` connect from any IP address or hostname.
  - Both localhost and remote connections are configured for flexibility.

- **Security Hardening:**

  - `DELETE FROM mysql.user WHERE User='';` - Removes anonymous users
  - `DELETE FROM mysql.user WHERE User='root' AND Host NOT IN (...)` - Restricts root access to localhost only
  - `DROP DATABASE IF EXISTS test;` - Removes test database
  - `DELETE FROM mysql.db WHERE Db='test'...` - Removes test database privileges

- **`FLUSH PRIVILEGES`:**
  Reloads grant tables to apply all changes immediately without restarting the server.

---

## my.cnf

- **[mysqld] Section:**
  Contains settings for the MariaDB server daemon (`mysqld`).

- **Security Configuration:**
  - `bind-address=0.0.0.0` - Allows connections from any IP address
  - `skip-networking=0` - Enables network connections (default, but explicit)
  - `skip-grant-tables=0` - Ensures authentication is required (security critical)
  - `default-authentication-plugin=mysql_native_password` - Sets secure authentication method

---

## Testing

To test if MariaDB container is working securely:

1. **Check container logs**

   ```bash
   docker logs inception_mariadb_1
   ```

   Look for a line like: `mysqld: ready for connections.`

2. **Test password enforcement (should fail without password)**

   ```bash
   docker exec -it inception_mariadb_1 mysql -u root
   ```

   This should be denied. Password is required:

   ```bash
   docker exec -it inception_mariadb_1 mysql -u root -p
   ```

   Enter the root password from your secrets.

3. **Connect to MariaDB and run test queries**
   Once connected with proper credentials:

   ```sql
   SHOW DATABASES;
   ```

   Should see databases listed (e.g., wordpress, mysql, etc.).

4. **Verify security hardening**

   ```sql
   SELECT User, Host FROM mysql.user;
   ```

   Should NOT see:

   - Anonymous users (empty User field)
   - Root users from remote hosts
   - Test database

5. **Check password authentication**

   ```sql
   SELECT user, host, plugin, authentication_string FROM mysql.user WHERE user='root';
   ```

   Should show non-empty authentication_string (password hash).

6. **Exit**
   ```sql
   exit
   ```

### Security Notes:

- **No passwordless login should be possible**
- **All users must authenticate with proper passwords**
- **Anonymous users and test database are removed**
- **Root access is restricted to localhost only**

### Container Access:

```bash
docker exec -it inception_mariadb_1 bash
```
