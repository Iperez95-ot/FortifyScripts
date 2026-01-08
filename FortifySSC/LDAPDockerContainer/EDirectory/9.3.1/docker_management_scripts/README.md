# 🧱 EDirectory Docker Container Environment Variables (build and destroy scripts)

This directory contains automation scripts to **build** and **destroy** Docker containers for **LDAP eDirectory** and **EDirectory API** version **9.3.1** in a Linux environment.
The scripts manage SSL certificate creation, Docker volume and network setup, and complete container lifecycle automation.

---

## 🧩 Prerequisites

Before running these scripts, ensure that:

* **Docker Engine** is installed and running.
* **NetworkManager (`nmcli`)** is available on the system.
* You have **root** privileges.
* A `.env` file is present in the same directory as the scripts, defining the environment variables detailed below.

---

## ⚙️ Environment Variables

### 🔧 General Configuration

| Variable                        | Description                                                  |
| ------------------------------- | ------------------------------------------------------------ |
| `EDIRECTORY_VERSION`            | EDirectory application version (e.g., `9.3.1`)               |
| `EDIRECTORY_API_VERSION`        | EDirectory API version                                       |
| `EDIRECTORY_CONTAINER_NAME`     | Name of the main EDirectory Docker container                 |
| `EDIRECTORY_API_CONTAINER_NAME` | Name of the EDirectory API Docker container                  |
| `EDIRECTORY_IMAGE_NAME`         | Name of the Docker image used to build the container         |
| `EDIRECTORY_IMAGE_TAG`          | Tag of the Docker image (e.g., `latest` or `9.3.1`)          |
| `EDIRECTORY_TREE_NAME`          | Name of the EDirectory tree                                  |
| `EDIRECTORY_ORGANIZATION_NAME`  | Organization name used in the directory structure            |
| `EDIRECTORY_SERVER_NAME`        | Name of the EDirectory server                                |
| `EDIRECTORY_COMMON_NAME`        | Common Name (CN) used for the LDAP administrator             |
| `EDIRECTORY_ADMIN_PASSWORD`     | Administrator password for the EDirectory instance           |
| `EDIRECTORY_DATA_DIRECTORY`     | Directory inside the container where LDAP data is stored     |
| `ALL_INTERFACES_PORT`           | IP or wildcard address binding used for NCP port connections |

---

### 🔐 SSL Certificate Configuration

| Variable                                               | Description                                                                                     |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| `EDIRECTORY_PRIVATE_KEY_FILE`                          | Private key filename for the self-signed certificate                                            |
| `EDIRECTORY_CERTIFICATE_FILE`                          | Certificate filename generated from the private key                                             |
| `EDIRECTORY_PEM_FILE`                                  | PEM file combining the key and certificate                                                      |
| `EDIRECTORY_CERTIFICATE_KEY_SIZE`                      | Key size for SSL (e.g., `2048`)                                                                 |
| `EDIRECTORY_CERTIFICATE_DAYS_VALID`                    | Validity of the SSL certificate in days                                                         |
| `EDIRECTORY_CERTIFICATE_SUBJECT`                       | Full subject string for the certificate (e.g., `/C=AR/ST=Buenos Aires/O=Telecom/CN=edirectory`) |
| `EDIRECTORY_CERTIFICATE_SAN_VALUE`                     | Subject Alternative Name (SAN) entries for the certificate (DNS and IP)                         |
| `HOST_EDIRECTORY_CERTIFICATES_DIRECTORY`               | Directory on the host where the certificate files are stored                                    |
| `HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY` | Directory for Docker client certificates                                                        |
| `HOST_TRUSTED_CA_DIRECTORY`                            | Directory for system trusted CA certificates                                                    |

---

### 🐳 Docker Configuration

| Variable                                  | Description                                                                  |
| ----------------------------------------- | ---------------------------------------------------------------------------- |
| `EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME` | Name of the Docker volume for LDAP data persistence                          |
| `DOCKER_NETWORK_NAME`                     | Name of the Docker network used to connect containers                        |
| `EDIRECTORY_CONTAINER_HOSTNAME`           | Hostname assigned to the EDirectory container                                |
| `EDIRECTORY_CONTAINER_IPADDRESS`          | Static IP address assigned to the container within the custom Docker network |
| `EDIRECTORY_INSECURE_LDAP_PORT`           | Insecure LDAP port (default: `389`)                                          |
| `EDIRECTORY_SECURE_LDAP_PORT`             | Secure LDAP port (default: `636`)                                            |
| `EDIRECTORY_NCP_PORT`                     | NCP port (default: `524`)                                                    |
| `EDIRECTORY_HTTP_PORT`                    | HTTP port (default: `8080`)                                                  |
| `EDIRECTORY_HTTPS_PORT`                   | HTTPS port (default: `8443`)                                                 |

---

### 🌐 Network Configuration

| Variable                             | Description                                                                      |
| ------------------------------------ | -------------------------------------------------------------------------------- |
| `HOST_CUSTOM_NETWORK_INTERFACE`      | Host network interface name (e.g., `eth0` or `ens192`) used to add static routes |
| `EDIRECTORY_CONTAINER_IPADDRESS`     | Static IP address used by the EDirectory container                               |
| `EDIRECTORY_API_CONTAINER_IPADDRESS` | Static IP address used by the API container, if applicable                       |

---

## 🏗️ `builder` Script

**Path:** `builder/edirectory_docker_container_builder.sh`

### 📜 Purpose

Builds and configures:

* Self-signed certificates
* LDAP data Docker volume
* Static routes and Docker network settings
* EDirectory and API containers

### ▶️ Usage

```bash
cd builder
chmod +x edirectory_docker_container_builder.sh
./edirectory_docker_container_builder.sh
```

### 🪄 Steps Performed

1. Load variables from `.env`.
2. Generate and install SSL certificates.
3. Create Docker volumes.
4. Configure static routes.
5. Run containers with defined environment and network settings.
6. Display build summary and verification info.

---

## 💣 `destroyer` Script

**Path:** `destroyer/edirectory_docker_container_destroyer.sh`

### 📜 Purpose

Cleans up:

* Docker containers and volumes
* Certificates from trusted stores
* Static routes
* Docker client certificate directories

### ▶️ Usage

```bash
cd destroyer
chmod +x edirectory_docker_container_destroyer.sh
./edirectory_docker_container_destroyer.sh
```

### 🪄 Steps Performed

1. Stop and remove containers.
2. Delete certificate files.
3. Remove static IP routes.
4. Delete the LDAP data Docker volume.
5. Verify cleanup completion.

---

## 🧾 Notes

* Run the **builder** script before the **destroyer** script.
* All SSL certificates generated are **self-signed** and meant for internal or testing use.
* Modify `.env` before execution to match your environment.
* Each script provides a timestamped and color-coded output for traceability.

---

## 🔐 .env file used to use on the eDirectory LDAP and API Docker Containers Builder script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
EDIRECTORY_VERSION=                                               # EDirectory version to deploy on a container
EDIRECTORY_VERSION_FULL=                                          # EDirectory version number without dots
EDIRECTORY_API_VERSION=                                           # EDirectory API version to deploy on a container
EDIRECTORY_API_VERSION_FULL=                                      # EDirectory API version number without dots
EDIRECTORY_IMAGE_NAME=                                            # EDirectory Docker Image name
EDIRECTORY_IMAGE_TAG=                                             # EDirectory Docker Tag name
EDIRECTORY_API_IMAGE_NAME=                                        # EDirectory Image API name
EDIRECTORY_CONTAINER_IPADDRESS=                                   # EDirectory Container IP Address
DOCKER_NETWORK_NAME=                                              # Docker Containers Network name
HOST_CUSTOM_NETWORK_INTERFACE=                                    # Host custom network interface used to communicate with the Docker Containers
EDIRECTORY_CONTAINER_NAME=                                        # EDirectory Docker Container name
EDIRECTORY_API_CONTAINER_NAME=                                    # EDirectory API Container Name
EDIRECTORY_CONTAINER_HOSTNAME=                                    # Hostname of the Edirectory Docker Container
EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME=                          # EDirectory LDAP data Docker Volume name
EDIRECTORY_DATA_DIRECTORY=                                        # EDirectory data directory inside the Docker Container
EDIRECTORY_TREE_NAME=                                             # EDirectory Tree name
EDIRECTORY_ORGANIZATION_NAME=                                     # EDirectory Organization name
EDIRECTORY_SERVER_NAME=                                           # EDirectory Server name
EDIRECTORY_COMMON_NAME=                                           # EDirectory Common name
EDIRECTORY_ADMIN_PASSWORD=                                        # EDirectory Admin password
EDIRECTORY_HTTP_PORT=                                             # EDirectory HTTP port
EDIRECTORY_HTTPS_PORT=                                            # EDirectory HTTPS port
EDIRECTORY_INSECURE_LDAP_PORT=                                    # EDirectory Insecure LDAP port
EDIRECTORY_SECURE_LDAP_PORT=                                      # EDirectory Secure LDAP port
EDIRECTORY_NCP_PORT=                                              # EDirectory NCP port
ALL_INTERFACES_PORT=                                              # Interface to bind a port to be listen everywhere
HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY=             # Host local directory of the EDirectory Docker Container certificate used by the Docker Client
HOST_EDIRECTORY_CERTIFICATES_DIRECTORY=                           # Host local directory of the certificates used by EDirectory Docker Container
EDIRECTORY_CERTIFICATES_DIRECTORY=                                # EDirectory certificates directory inside the Docker Container
EDIRECTORY_PRIVATE_KEY_FILE=                                      # Decrypted private key to be used by EDirectory Docker Container
EDIRECTORY_CERTIFICATE_FILE=                                      # Self-signed SSL certificate to be used by EDirectory Docker Container
EDIRECTORY_PEM_FILE=                                              # PEM file to be used by EDirectory Docker Container
EDIRECTORY_CERTIFICATE_DAYS_VALID=                                # Days of validation of the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_KEY_SIZE=                                  # EDirectory SSL Key Size value
EDIRECTORY_CERTIFICATE_PASSWORD=                                  # Password from the EDirectory Docker Container key files
EDIRECTORY_CERTIFICATE_COUNTRY=                                   # Country value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_STATE=                                     # State value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_LOCALITY=                                  # Locality value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_ORGANIZATION=                              # Organization value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_ORGANIZATION_UNIT=                         # Organization Unit value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_COMMON_NAME=                               # Common Name value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_EMAIL=                                     # Email value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_SAN_VALUE=                                 # SAN value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_SUBJECT=                                   # Subject value from the EDirectory Docker Container Certificate
```

---

## 🔐 .env file used to use on the eDirectory LDAP and API Docker Containers Destroyer script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
EDIRECTORY_VERSION=                                               # EDirectory version to deployed on a container
EDIRECTORY_VERSION_FULL=                                          # EDirectory version number without dots
EDIRECTORY_API_VERSION=                                           # EDirectory API version to deployed on a container
EDIRECTORY_API_VERSION_FULL=                                      # EDirectory API version number without dots
EDIRECTORY_CONTAINER_NAME=                                        # EDirectory Docker Container name
EDIRECTORY_API_CONTAINER_NAME=                                    # EDirectory API Container Name
EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME=                          # EDirectory LDAP data Docker Volume name
EDIRECTORY_CONTAINER_IPADDRESS=                                   # EDirectory Container IP Address
EDIRECTORY_CERTIFICATE_FILE=                                      # Self-signed SSL certificate to be used by EDirectory Docker Container
HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY=             # Host local directory of the EDirectory Docker Container certificate used by the Docker Client
HOST_EDIRECTORY_CERTIFICATES_DIRECTORY=                           # Host local directory of the certificates used by EDirectory Docker Container
HOST_TRUSTED_CA_DIRECTORY=                                        # Host local directory of the Trusted CA store
HOST_CUSTOM_NETWORK_INTERFACE=                                    # Host custom network interface used to communicate with the Docker Containers
```
