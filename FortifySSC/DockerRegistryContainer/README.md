# 🐳 DockerRegistryContainer (Private Docker Registry)

This directory contains the configuration files, certificates, and management scripts used to deploy and maintain the **private Docker Registry** that stores Fortify-related docker container images.

## 📁 Directory Structure

```
DockerRegistryContainer/
├── auth/                                                       # Authentication files directory.
|     └── .htpasswd                                             # Basic authentication file (htpasswd --> authentication file used by the Docker Registry (nginx) for basic HTTP authentication).
├── certificates/                                               # SSL/TLS self-signed certificates directory for secure HTTPS access to the Docker Registtry (BackEnd and FrontEnd).
|       ├── registryui/                                         # Docker Registry UI (FrontEnd) certificates directory.
|       |       ├── fileui.key                                  # Private key file of the Docker Registry UI.
|       |       ├── fileui.crt                                  # Certificate file of the Docker Registry UI.
|       |       └── fileui.pem                                  # PEM file of the Docker Registry UI.
|       └── registry/                                           # Docker Registry (BackEnd) certificates directory.
|       |       ├── filereg.key                                 # Private key file of the Docker Registry.
|       |       ├── filereg.crt                                 # Certificate file of the Docker Registry.
|       |       └── filereg.pem                                 # PEM file of the Docker Registry.
├── docker_management_scripts/                                  # Shell scripts to build and destroy the Docker Registry containers (BackEnd and FrontEnd).
|               ├── builder/                                    # Build script directory.
|               |      ├── nacho_docker_registry_builder.sh     # Script that builds the Docker Registry Containers (BackEnd and FrontEnd).
|               |      └── .env                                 # Environment variables file used by the build script. 
|               └── destroyer/                                  # Destroyer script directory.
|               |      ├── nacho_docker_registry_destroyer.sh   # Script that destroy the Docker Registry Containers (BackEnd and FrontEnd).
|               |      └── .env                                 # Environment variables file used by the destroy script. 
└── registry_ui_https_config/                                   # Configuration file for the Docker Registry UI directory.
|               └── default.conf                                # Configuration file for the Docker Registry UI over HTTPS (nginx).
└────────────────────────────────────────────────────────────
```

---

## ⚙️ Purpose

The **Private Docker Registry Container** provides a self-hosted, secured Docker Registry used to:

* Store Fortify SSC, ScanCentral, and related Docker images privately.
* Authenticate users via the `auth/` configuration (Basic one).
* Serve the registry and its UI over HTTPS using the `certificates/` and `registry_ui_https_config/` directories.
* Automate the Docker Registry containers/images management (build and destroy) using the scripts in `docker_management_scripts/` directory.

---

## 🚀 Usage Overview

1. **Generate or update certificates**

   * Already done by the `nacho_docker_registry_builder.sh` script that places the `.crt`, `.key` and `.pem` files in the `certificates/` directory for each environment of the Docker Private Registry. 

2. **Configure authentication**

   * The `nacho_docker_registry_builder.sh` script creates a `.htpasswd` file and places it on the `auth/` directory to have a basic authentication login on the Docker Private Registry.

3. **Creates the Docker Registry BackEnd and Docker Registry FrontEnd docker containers**

   * When running the script:

     ```bash
     ./nacho_docker_registry_builder.sh
     ```
   * It creates both Docker Containers with the previous settings + a network and assigns an IP for each Docker Container *

4. **Access the Registry UI (Docker Registry UI)**

   * Open: `https://<server_ip>or<server_hostname>` (configured)
   * Log in with your configured credentials with basic authentication (twice if you don't log in in the Docker Registry Back End before).

5. **Access the Registry BackEnd (Docker Registry)**

   * Open: `https://<server_ip>:5000/v2/_catalog` (or configured port)
   * Log in with your configured credentials with basic authentication.

---

## 🧰 Requirements

* Docker Engine installed and running.
* Valid SSL certificates.
* Proper authentication and nginx config file.
* Proper permissions on the directories.

---

## 🧹 Maintenance Tips

* Renew SSL certificates before expiration.
* Rotate the basic authentication credentials periodically.
* Destroy and rebuild the Docker Containers with the updated docker registry image.
* Keep `docker_management_scripts/` synchronized with the automated GitHub repository.

---

## 🔌 nginx config file used to set up the Docker Registry UI (generic example)

```
server {
    listen 443 ssl;
    server_name dockerregistryuihostname;

    # disable any limits to avoid HTTP 413 for large image uploads
    client_max_body_size 0;
    client_body_buffer_size     32k;
    client_header_buffer_size   8k;
    large_client_header_buffers 8 64k;

    # required to avoid HTTP 411: see Issue #1486 (https://github.com/moby/moby/issues/1486)
    chunked_transfer_encoding on;

    # required for strict SNI checking: see Issue #70 (https://github.com/Joxit/docker-registry-ui/issues/70)
    proxy_ssl_server_name on;
    proxy_buffering off;

    # Fix push and pull of large images: see Issue #282 (https://github.com/Joxit/docker-registry-ui/issues/282)
    proxy_request_buffering off;
    proxy_ignore_headers "X-Accel-Buffering";

    ssl_certificate     /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;
    root /usr/share/nginx/html;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Optional security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;

    # Frontend static files
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;

        # Basic Auth on Frontend
    	auth_basic "Restricted Access";
    	auth_basic_user_file /etc/nginx/certs/.htpasswd;
    }

    # Backend Docker Registry
    location /v2/ {
        proxy_pass http://dockerregistrybackendipaddress:5000/v2/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Redirect server error pages to the static page /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}

server {
    listen 80;
    server_name dockerregistryuihostname;

    # Redirect HTTP to HTTPS
    return 301 https://$host$request_uri;
}
```
---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
