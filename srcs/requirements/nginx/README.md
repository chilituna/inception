# NGINX Docker Setup with TLS

This Dockerfile sets up an NGINX server with the following features:
- **TLSv1.2 and TLSv1.3 support only:**
  - TLS (Transport Layer Security) ensures secure communication over the internet by providing encryption, authentication, and data integrity.
  - TLSv1.2 and TLSv1.3 are modern, secure versions of the protocol and successors to the older SSL (Secure Sockets Layer).

---

## Base Image

- **Debian Bullseye Slim:**
  - A minimal version of Debian, optimized for lightweight container environments.
  - The "slim" variant reduces the image size by omitting unnecessary files and packages, making it efficient for deployment.

---

## Key Dockerfile Instructions

### RUN
- Executes shell commands during the image build process.
- Used to:
  - Install required packages.
  - Set up directories and files.
  - Perform other tasks necessary for building the image.
- Each `RUN` instruction creates a new layer in the Docker image. Commands are executed in sequence.

### CMD
- Specifies the default command that runs when the container starts.
- Can be overridden at runtime if needed.

---

## SSL Configuration (done in the Makefile)

 **Generate a Self-Signed SSL Certificate and Private Key:**
   - Command breakdown:
     - **`req`**: A utility for creating and managing X.509 certificates, CSRs (Certificate Signing Requests), and private keys.
     - **`-x509`**: Generates a self-signed certificate.
     - **`-sha256`**: Uses the SHA-256 hash algorithm.
     - **`-days 365`**: Validity of the certificate in days (1 year in this case).
     - **`-nodes`**: Skips encrypting the private key (stands for "no DES").
     - **`-newkey rsa:2048`**: Generates a new RSA private key with a 2048-bit key size.
     - **`-subj`**: Specifies certificate details, e.g., domain name (`CN`) and organization.
     - **`-keyout`**: Output file for the private key.
     - **`-out`**: Output file for the self-signed certificate.

---

## Configuration and Execution

1. **Copy Custom Configuration:**
   - NGINX is configured via a custom configuration file.
   - The file is copied to the container to customize its behavior, such as enabling TLS.

2. **Open Required Ports:**
   - Ensures that the container allows incoming connections on ports required by the application (e.g., 443 for HTTPS).

3. **Start NGINX in the Foreground:**
   - The `-g "daemon off;"` option ensures NGINX runs in the foreground, keeping the container active.

---

## Additional Notes

- **Security:**
  While self-signed certificates are useful for testing or internal purposes, consider using certificates from a trusted CA (Certificate Authority) for production.

- **Port Configuration:**
  Ensure the correct ports are exposed in both the Dockerfile and Docker Compose (if used) to match your use case.


