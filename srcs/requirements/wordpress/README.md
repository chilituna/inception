
# **WordPress Container Setup**

This repository contains a Dockerfile and related scripts to set up a WordPress environment using PHP-FPM, WP-CLI, and a Debian base image.

---

## **Access**

To log in as an admin:
👉 [https://aarponen.42.fr/wp-login.php](https://aarponen.42.fr/wp-login.php)

---

## **Overview**

This container provides a WordPress environment with the following features:

* **Debian Base Image**: Lightweight and stable foundation.
* **PHP-FPM**: Handles PHP requests efficiently.
* **WP-CLI**: Enables WordPress management via command line.
* **Secrets Management**: Secure storage of sensitive credentials.
* **Custom Entrypoint Script**: Ensures proper initialization of WordPress.

---

## **Entrypoint Script: `/usr/local/bin/docker-entrypoint.sh`**

The entrypoint script manages the initialization of the WordPress environment. Here's what it does:

1. **Environment Variable Validation**:

   * Ensures critical variables like `DB_NAME`, `DB_USER`, and `DOMAIN_NAME` are set.
   * Logs errors and halts execution if variables are missing.

2. **Secret File Validation**:

   * Confirms the presence of required secret files:

     * `/run/secrets/db_password`
     * `/run/secrets/wp_admin_pw`
     * `/run/secrets/wp_user_pw`

3. **MariaDB Connectivity**:

   * Waits for the MariaDB server to be ready before proceeding.

4. **WordPress Core Setup**:

   * Downloads WordPress core files if not already present.
   * Generates a `wp-config.php` file using environment variables.

5. **WordPress Installation**:

   * Installs WordPress with the admin and user credentials provided.
   * Creates a custom user with an editor role.

6. **Runtime Directory Preparation**:

   * Ensures the `/run/php` directory exists for PHP-FPM runtime files.

7. **PHP-FPM Execution**:

   * Launches PHP-FPM in the foreground.

---


## **Environment Variables**

| Variable         | Description                          | Example Value        |
| ---------------- | ------------------------------------ | -------------------- |
| `DB_NAME`        | Database name for WordPress          | `wordpress_db`       |
| `DB_USER`        | Database user                        | `wordpress_user`     |
| `DB_HOST`        | Database host (e.g., MariaDB server) | `mariadb`            |
| `DOMAIN_NAME`    | URL for the WordPress site           | `aarponen.42.fr`     |
| `SITE_TITLE`     | Title of the WordPress site          | `My Site`            |
| `WP_ADMIN`       | Admin username                       | `admin`              |
| `WP_ADMIN_EMAIL` | Admin email address                  | `admin@example.com`  |
| `WP_USER`        | WordPress editor username            | `editor`             |
| `WP_USER_EMAIL`  | WordPress editor email address       | `editor@example.com` |




