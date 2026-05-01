# 🖥 IdentityConsole Application Docker Container Environment Variables (build and destroy scripts)

This project provides 2 **Bash automation scripts** and 2 accompanying **`.env` configuration files** to build and destroy **NetIQ IdentityConsole 25.2** inside a Docker container using a **macvlan network**, static IP addressing, and automatic certificate extraction for integration with **EDirectory** and **EDirectory API** Docker Containers.

---

## ⚙️ Requirements

Before running the script, ensure the following are installed and configured:

* 🐧 **Linux system** properly configured.
* 🐳 **Docker Engine** installed and running.
* 📡 * **NetworkManager (`nmcli`)** is available on the system.
* 🔐 Proper **root** privileges/permissions to run Docker and modify network routes.
* 🔧 A `.env` file is present in the same directory as the scripts, defining the environment variables detailed below.
* 🗂️ **OpenText NetIQ eDirectory Application** docker container properly deployed and installed (PEM file from eDirectory is required for Identity Console Application deploytment).

---

## ⚙️ Environment Variables

### 🔧 General Configuration

| Variable                                      | Description                                         |
|---------------------------------------------- |---------------------------------------------------- |
| `IDENTITYCONSOLE_VERSION`                     | IdentityConsole version (e.g., `25.2`)              |
| `EDIRECTORY_VERSION`                          | EDirectory version in use                           |
| `IDENTITYCONSOLE_VERSION_FULL`                | IdentityConsole version number without dots         |
| `IDENTITYCONSOLE_IMAGE_NAME`                  | Docker image name for IdentityConsole               |    
| `IDENTITYCONSOLE_IMAGE_TAG`                   | Docker image tag (e.g.,`latest` or `25.2`)          |
| `IDENTITYCONSOLE_CONTAINER_NAME`              | Docker container name                               |
| `IDENTITYCONSOLE_CONTAINER_HOSTNAME`          | Hostname assigned to the container                  |   
| `IDENTITYCONSOLE_HTTPS_PORT`                  | HTTPS port exposed by IdentityConsole               |
| `IDENTITYCONSOLE_SILENT_PROPERTIES_FILE`      | Silent properties file path inside the container    |
| `HOST_IDENTITYCONSOLE_SILENT_PROPERTIES_FILE` | Silent properties file path on the host             |

---

### 🐳 Docker & Network Configuration

| Variable                              | Description                                       |  
|-------------------------------------- |-------------------------------------------------- |
| `DOCKER_NETWORK_NAME`                 | Docker network used by the container              |
| `IDENTITYCONSOLE_CONTAINER_IPADDRESS` | Static IP address assigned to the container       |
| `HOST_CUSTOM_NETWORK_INTERFACE`       | Host network interface used for routing (macvlan) |

---

### 🔐 SSL Certificate Configuration

| Variable                                                    | Description                                         |  
|------------------------------------------------------------ |---------------------------------------------------- |  
| `IDENTITYCONSOLE_EDIRECTORY_ETC_DEFAULT_PEM_FILE`           | EDirectory PEM file path inside `/etc`              |
| `IDENTITYCONSOLE_EDIRECTORY_CERT_DEFAULT_PEM_FILE`          | EDirectory PEM file path inside `/cert`             |
| `IDENTITYCONSOLE_EDIRECTORY_DEFAULT_PFX_FILE`               | Generated PFX certificate file inside the container |
| `HOST_EDIRECTORY_DEFAULT_PEM_FILE`                          | Default EDirectory PEM certificate on the host      |
| `HOST_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY`               | Host directory for IdentityConsole certificates     | 
| `HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY`              | Host directory for EDirectory API required files    |
| `HOST_DOCKER_CLIENT_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY` | Docker client certificate directory                 |

---

## 🏗️ `builder` Script

**Path:** `builder/identityconsole_docker_container_builder.sh`

### 📜 Purpose

Builds and configures:

* Self-signed certificates (extracted from eDirectory application container).
* Static routes and Docker network settings.
* Identity Console container based on the settings from the silent properties file.

### ▶️ Usage

```bash
cd builder
chmod +x identityconsole_docker_container_builder.sh
./identityconsole_docker_container_builder.sh
```

### 🪄 Steps Performed

1. Load variables from `.env`.
2. Install SSL certificates from eDirectory application.
3. Configure static routes.
4. Run containers with defined environment and network settings.
5. Display build summary and verification info.

---

## 💣 `destroyer` Script

**Path:** `destroyer/identityconsole_docker_container_destroyer.sh`

### 📜 Purpose

Cleans up:

* Identity Console Docker container.
* Certificates from trusted stores.
* Static routes.
* Docker client certificate directories.

### ▶️ Usage

```bash
cd destroyer
chmod +x identityconsole_docker_container_destroyer.sh
./identityconsole_docker_container_destroyer.sh
```

### 🪄 Steps Performed

1. Load variables from `.env`.
2. Stop and remove the container.
3. Delete certificate files.
4. Remove static IP routes.
5. Verify cleanup completion.

---

## 🧾 Notes

* Run the **builder** script before the **destroyer** script.
* All SSL certificates generated are **self-signed** and meant for internal or testing use.
* Modify `.env` before execution to match your environment.
* Each script provides a timestamped and color-coded output for traceability.

---

## 📄 .env file used to use on the Identity Console Appllication Docker Container Builder script (generic example)

```makefile
# Defines the variables
IDENTITYCONSOLE_VERSION=                                                     # IdentityConsole version to deploy on a container
EDIRECTORY_VERSION=                                                          # EDirectory version using
IDENTITYCONSOLE_VERSION_FULL=                                                # IdentityConsole version number without dots      
IDENTITYCONSOLE_IMAGE_NAME=                                                  # IdentityConsole Docker Image name
IDENTITYCONSOLE_IMAGE_TAG=                                                   # IdentityConsole Docker Tag name	
IDENTITYCONSOLE_CONTAINER_IPADDRESS=                                         # IdentityConsole Container IP Address
DOCKER_NETWORK_NAME=                                                         # Docker Containers Network name
HOST_CUSTOM_NETWORK_INTERFACE=                                               # Host custom network interface used to communicate with the Docker Containers
IDENTITYCONSOLE_CONTAINER_NAME=                                              # IdentityConsole Docker Container name									
IDENTITYCONSOLE_CONTAINER_HOSTNAME=                                          # Hostname of the IdentityConsole Container Docker Container
IDENTITYCONSOLE_HTTPS_PORT=                                                  # IdentityConsole HTTPS port
HOST_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY=                                 # Host local directory of the certificates used by IdentityConsole Docker Container
HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY=                                # Host local directory of the required files to build the EDirectory API Docker Container
IDENTITYCONSOLE_SILENT_PROPERTIES_FILE=                                      # IdentityConsole Silent Properties file directory inside the Docker Container	 
HOST_IDENTITYCONSOLE_SILENT_PROPERTIES_FILE=                                 # Host IdentityConsole Silent Properties file used to configure the Container
HOST_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY=                                 # Host local directory of the certificates used by IdentityConsole Docker Container
HOST_DOCKER_CLIENT_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY=                   # Host local directory of the IdentityConsole Docker Container certificate used by the Docker Client
HOST_EDIRECTORY_DEFAULT_PEM_FILE=                                            # Host local directory of the Default PEM File of EDirectory Docker Container
IDENTITYCONSOLE_EDIRECTORY_ETC_DEFAULT_PEM_FILE=                             # IdentityConsole Default PEM File of Edirectory Docker Container inside IdentityConsole eDirAPI etc directory
IDENTITYCONSOLE_EDIRECTORY_CERT_DEFAULT_PEM_FILE=                            # IdentityConsole Default PEM File of Edirectory Docker Container inside IdentityConsole eDirAPI cert directory
IDENTITYCONSOLE_EDIRECTORY_DEFAULT_PFX_FILE=                                 # IdentityConsole Default PFX file of Edirectory Docker Container inside IdentityConsole eDirAPI etc directory
```

---

## 📄 .env file used to use on the Identity Console Appllication Docker Container Destroyer script (generic example)

```makefile
# Defines the variables
IDENTITYCONSOLE_VERSION=                                                          # IdentityConsole version to deployed on a container    
IDENTITYCONSOLE_VERSION_FULL=                                                     # IdentityConsole version number without dots
IDENTITYCONSOLE_CONTAINER_NAME=                                                   # IdentityConsole Docker Container name									
IDENTITYCONSOLE_CONTAINER_IPADDRESS=                                              # IdentityConsole Container IP Address
HOST_CUSTOM_NETWORK_INTERFACE=                                                    # Host custom network interface used to communicate with the Docker Containers
HOST_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY=                                      # Host local directory of the certificates used by IdentityConsole Docker Container
```
