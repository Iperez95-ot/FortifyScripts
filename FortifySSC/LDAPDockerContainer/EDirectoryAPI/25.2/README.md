# 🔌⚙️ EDirectory API Docker Containers Environment Variables (build and destroy scripts)

This directory contains automation scripts to **build** and **destroy** Docker containers for **LDAP eDirectory API** and **Swagger eDirectory API Documentation** version **25.2** in a Linux environment.
The scripts manage SSL certificate extraction, network setup, Swagger authentication creation, and complete container lifecycle automation.

---

## 🚀 Features

- 🐳 Builds and runs the **EDirectory API Docker container**.
- 🌐 Configures **custom network routing** using `nmcli`.
- 🔐 Extracts **TLS certificate & private key** from a PFX file.
- 🔑 Generates **Basic Auth credentials** for Swagger UI.
- 📘 Deploys **Swagger UI** container linked to the API container.
- 🎨 Colorized terminal output for better readability.

## 🧩 Prerequisites

Before running these scripts, ensure that:

- 🐧 Linux system with **NetworkManager**.
- 🐳 Docker installed and running.
- 🔧 Tools available in PATH:
  - `docker`.
  - `nmcli`.
  - `openssl`.
  - `htpasswd`.
- 📄 `.env` file properly configured (see below).
- ⚙️ `edirapi.conf` file to configure EDirectory API (got from the DockerInstallationFilesPull script).
- 🔐 `swagger_ssl.conf` file to configure the SSL and Network config from EDirectory API Swagger UI Documentation (see below).
- 🖥 `OpenText NetIQ Identity Console Application` docker container properly deployed and installed (keys.fpx file from Identity Console is required for eDirectory API deploytment).

---

## ⚙️ Environment Variables

### 🔧 General Configuration

| Variable                                | Description                                                  |
| --------------------------------------- | ------------------------------------------------------------ |
| `EDIRECTORY_API_VERSION`                | EDirectory API version (e.g., `25.2`)                        |
| `EDIRECTORY_API_VERSION_FULL`           | API version without dots (e.g., `252`)                       |
| `EDIRECTORY_VERSION`                    | Base EDirectory version (e.g., `9.3.1`)                      |
| `EDIRECTORY_API_IMAGE_NAME`             | Docker image name for the EDirectory API                     |
| `EDIRECTORY_API_CONTAINER_NAME`         | Name of the EDirectory API Docker container                  |
| `EDIRECTORY_API_CONTAINER_HOSTNAME`     | Hostname assigned to the API container                       |
| `EDIRECTORY_API_SWAGGER_IMAGE_NAME`     | Docker image used for the Swagger UI API Documentation       |
| `EDIRECTORY_API_SWAGGER_CONTAINER_NAME` | Name of the Swagger UI API Documentation Docker container    |

---

### 🔐 SSL Certificate and Authentication Configuration 

| Variable                                               | Description                                                                                  
| ------------------------------------------------------ | ----------------------------------------------- |
| `EDIRECTORY_API_PFX_FILE`                              | PFX file containing TLS certificate and key     |
| `EDIRECTORY_API_PFX_PASSWORD`                          | Password for the PFX file                       |
| `EDIRECTORY_API_SWAGGER_NGINX_CERTTIFCATES_DIRECTORY`  | Certificates directory in Swagger container     |
| `EDIRECTORY_API_SWAGGER_CERT_FILE_PATH`                | Certificate file path inside Swagger container  |
| `EDIRECTORY_API_SWAGGER_KEY_FILE_PATH`                 | Private key file path inside Swagger container  |
| `HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE`          | Basic Auth file for Swagger UI                  |
| `EDIRECTORY_API_SWAGGER_AUTH_USER`                     | Swagger UI Basic Auth username                  |
| `EDIRECTORY_API_SWAGGER_AUTH_PASSWORD`                 | Swagger UI Basic Auth password                  |

---

### 🐳 Docker Configuration

| Variable                                              | Description                                      |
| ----------------------------------------------------- | ------------------------------------------------ |
| `HOST_EDIRECTORY_API_SWAGGER_YAML_FILE_PATH`          | Host Swagger YAML file path                      |
| `EDIRECTORY_API_SWAGGER_YAML_FILE_PATH`               | Swagger YAML path inside the container           |
| `HOST_EDIRECTORY_API_SWAGGER_NGINX_CONFIG_FILE_PATH`  | Host NGINX config for Swagger                    |
| `EDIRECTORY_API_SWAGGER_NGINX_CONFIG_FILE_PATH`       | NGINX config path inside Swagger container       |
| `EDIRECTORY_API_SWAGGER_URL`                          | Public URL for Swagger UI                        |

---

### 📂 Directories & Configuration Files

| Variable                                              | Description                                      |
| ----------------------------------------------------- | ------------------------------------------------ |
| `EDIRECTORY_API_DATA_DIRECTORY`                       | Data directory inside the API container          |
| `HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY`        | Host directory with required build files         |
| `HOST_EDIRECTORY_API_CONF_FILE`                       | Host eDirAPI configuration file                  |

---

## 🏗️ `builder` Script

**Path:** `builder/edirectory_api_docker_container_builder.sh`

### 📜 Purpose

Builds and configures:

* Extracts Self-signed certificates from original PFX file from EDirectory.
* Swagger basic authentication config.
* Static routes and Docker network settings.
* EDirectory API and EDirectory Swagger API Documentation containers based on the configuration files.

### ▶️ Usage

```bash
cd builder
chmod +x edirectory_api_docker_container_builder.sh
./edirectory_api_docker_container_builder.sh
```

### 🪄 Steps Performed

1. Load variables from `.env`.
2. Extracts and install SSL certificates.
3. Create the Docker containers (BackEnd and FrontEnd).
4. Configure static routes.
5. Run containers with defined environment and network settings.
6. Display build summary and verification info.

---

## 💣 `destroyer` Script

**Path:** `destroyer/edirectory_api_docker_container_destroyer.sh`

### 📜 Purpose

Cleans up:

* The Docker containers.
* Certificates files and authenticate files.
* Static routes.

### ▶️ Usage

```bash
cd destroyer
chmod +x edirectory_api_docker_container_destroyer.sh
./edirectory_api_docker_container_destroyer.sh
```

### 🪄 Steps Performed

1. Stop and remove containers.
2. Delete certificate and basic authentication files.
3. Remove static IP routes.
4. Verify cleanup completion.

---

## 🧾 Notes

* Run the **builder** script before the **destroyer** script.
* All SSL certificates extracted are **self-signed** and meant for internal or testing use.
* Modify `.env` before execution to match your environment.
* Each script provides a timestamped and color-coded output for traceability.

---

## 📄 .env file used to use on the eDirectory API (BackEnd and FrontEnd) Docker Containers Builder script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
EDIRECTORY_API_VERSION=                                                      # EDirectory API version to deploy on a container
EDIRECTORY_VERSION=                                                          # EDirectory version deployed on a Docker Container
EDIRECTORY_API_VERSION_FULL=                                                 # EDirectory API version number without dots
EDIRECTORY_API_IMAGE_NAME=                                                   # EDirectory Image API name
EDIRECTORY_API_CONTAINER_IPADDRESS=                                          # EDirectory API Container IP Address
EDIRECTORY_API_CONTAINER_NAME=                                               # EDirectory API Container Name
EDIRECTORY_API_CONTAINER_HOSTNAME=                                           # Hostname of the Edirectory Docker Container
DOCKER_NETWORK_NAME=                                                         # Docker Containers Network aName
HOST_CUSTOM_NETWORK_INTERFACE=                                               # Host custom network interface used to communicate with the Docker Containers
EDIRECTORY_API_DATA_DIRECTORY=                                               # EDirectory API data directory inside the Docker Container
EDIRECTORY_API_PORT=                                                         # EDirectory API port
HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY=                                # Host local directory of the required files to build the EDirectory API Docker Container
HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE=                                 # Basic Authentication file for the EDirectory API Swagger Docker Container
EDIRECTORY_API_SWAGGER_AUTH_USER=                                            # Basic Authenticaction User for the EDirectory API Swagger Docker Container
EDIRECTORY_API_SWAGGER_AUTH_PASSWORD=                                        # Basic Authenticaction Password for the EDirectory API Swagger Docker Container
EDIRECTORY_API_SWAGGER_NGINX_CERTTIFCATES_DIRECTORY=                         # Nginx certificates directory located on the Swaggger Docker Container
HOST_EDIRECTORY_API_CONF_FILE=                                               # Host eDirAPI conf file used to configure the EDirectory API Docker Container
EDIRECTORY_API_SWAGGER_CONTAINER_NAME=                                       # EDirectory API Swagger Container Name
EDIRECTORY_API_SWAGGER_IMAGE_NAME=                                           # EDirectory API Swagger Image Name
HOST_EDIRECTORY_API_SWAGGER_YAML_FILE_PATH=                                  # Host EDirectory API Swagger YAML file that builds the API documentation UI
EDIRECTORY_API_SWAGGER_YAML_FILE_PATH=                                       # EDirectory API Swagger YAML file located on the Swagger Docker Container
HOST_EDIRECTORY_API_SWAGGER_NGINX_CONFIG_FILE_PATH=                          # Host EDirectory API Swagger Config file to config the Nginx web server
EDIRECTORY_API_SWAGGER_NGINX_CONFIG_FILE_PATH=                               # EDirectory API Swagger Config file on the Swagger Docker Container
EDIRECTORY_API_PFX_FILE=                                                     # EDirectory API pfx file
EDIRECTORY_API_PFX_PASSWORD=                                                 # EDirectory API pfx file password
EDIRECTORY_API_SWAGGER_CERT_FILE_PATH=                                       # EDirectory API Swagger Certificate file on the Swagger Docker Container
EDIRECTORY_API_SWAGGER_KEY_FILE_PATH=                                        # EDirectory API Swagger Key file on the Swagger Docker Container
EDIRECTORY_API_SWAGGER_URL=                                                  # EDirectory API Swagger url where the Swagger documentation FrontEnd is resolving
```

---

## 📄 .env file used to use on the eDirectory API (BackEnd and FrontEnd) Docker Containers Destroyer script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
EDIRECTORY_API_VERSION=                                                      # EDirectory API version to deployed on a container
EDIRECTORY_API_VERSION_FULL=                                                 # EDirectory API version number without dots
EDIRECTORY_API_CONTAINER_NAME=                                               # EDirectory API Docker Container Name
EDIRECTORY_API_CONTAINER_IPADDRESS=                                          # EDirectory API Container IP Address
EDIRECTORY_API_SWAGGER_CONTAINER_NAME=                                       # EDirectory API Docker Swagger Container Name
HOST_CUSTOM_NETWORK_INTERFACE=                                               # Host custom network interface used to communicate with the Docker Containers
HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY=                                # Host local directory of the required files used by the EDirectory API Docker Containers
HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE=                                 # Basic Authentication file used by the EDirectory API Swagger Docker Container
HOST_EDIRECTORY_API_SWAGGER_CERTIFICATE_FILE=                                # Certificate file used by the EDirectory API Swagger Docker Container
HOST_EDIRECTORY_API_SWAGGER_KEY_FILE=                                        # Key file used by the EDirectory API Swagger Docker Container
```

---

## 🔌 nginx config file (swagger_ssl.conf) used to set up the EDirectory API Swagger Documentation (generic example)

```makefile
server {
    ##################################################################
    # Public HTTPS entrypoint for Swagger UI
    #
    # This server listens on 9444 and acts as a browser-safe gateway:
    #  - Serves the Swagger UI frontend
    #  - Proxies API calls to the internal eDirectory API on port 9443
    ##################################################################

    # Port and host definition
    listen 9444 ssl;
    server_name dockerswaggerapidochostname (the same as the EDirectory API);

    ########################################################################
    # SSL configuration for browser access
    #
    # The browser connects ONLY to this server.
    # The backend API uses a self-signed cert and is never exposed directly.
    ########################################################################

    # Certificate and key files
    ssl_certificate     /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    # Allows modern TLS only
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers   HIGH:!aNULL:!MD5;

    ###############################################################
    # 1. Swagger UI + OpenAPI YAML
    #
    # Serves the Swagger UI static files and the swagger.yaml file.
    # This is what the browser loads at https://host:9444/
    ###############################################################

    location / {
        # Swagger UI static files
        root  /usr/share/nginx/html;
        index index.html index.htm;

        # Basic Auth on Swagger API Documentation
    	  auth_basic "Restricted Access";
    	  auth_basic_user_file /etc/nginx/certs/.htpasswd;

        # Single-page-app fallback (required by Swagger UI)
        try_files $uri $uri/ /index.html;

        # These are safe because no credentials are involved.
        # CORS headers for static files (swagger.yaml)
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
    }
    
    ######################################################
    # 2. Reverse proxy to eDirectory API (9443)
    #
    # All API calls from Swagger UI go through THIS block.
    # This eliminates:
    #  - CORS issues
    #  - Self-signed certificate problems
    #  - Cross-origin browser restrictions
    #
    # Because we use:
    #   --network container:<edir-api-container>
    #
    # "localhost:9443" effectively means:
    #   the eDirectory API container itself
    ######################################################
    
    location /eDirAPI/ {
        # If the URI is exactly /eDirAPI/ or /eDirAPI, change it to /
        # This makes the Discovery JSON (All eDirAPI endpoints list) work.
        rewrite ^/eDirAPI/?$ / break;
       
        # Forwards the requests to the real eDirectory API
        # Keep the proxy_pass WITHOUT the trailing slash.
        # This ensures functional calls (v1/session) keep the /eDirAPI prefix.
        proxy_pass https://127.0.0.1:9443;

        ####################################################
        # Backend SSL handling
        #
        # The eDirectory API uses a self-signed certificate.
        # We explicitly disable verification because:
        #  - This connection is internal
        #  - The browser never sees this certificate
        ####################################################        

        proxy_ssl_verify off;
        proxy_ssl_server_name on;

        ##########################################
        # Preserves client request metadata
        #
        # These headers allow the backend to know:
        #  - Original host
        #  - Real client IP
        #  - Original protocol (https)
        ##########################################

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        #########################################################
        # CORS headers for API responses
        #
        # These headers allow Swagger UI (running in the browser)
        # to successfully consume the API responses.
        #########################################################

        # CORS Headers (Crucial for Credentials/Cookies)
        add_header 'Access-Control-Allow-Origin' 'https://dockerswaggerapidochostname:9444' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range,X-CSRF-Token,Cookie' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range,Set-Cookie' always;

        #add_header 'Access-Control-Allow-Origin' '*' always;
        #add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH' always;
        #add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range,X-CSRF-Token,Cookie' always;
        #add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;

        ##################################################################
        # Handles CORS preflight (OPTIONS) requests
        #
        # Browsers send OPTIONS before non-simple requests.
        # We terminate them here and do NOT forward them to the API.
        ##################################################################

        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
            add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range,X-CSRF-Token,Cookie';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
    }
}
```
