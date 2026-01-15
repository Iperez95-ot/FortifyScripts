# 🐳 Docker Private Registry Environment Variables (build and destroy scripts)

The definition of the environment variables used to configure and deploy a **secure private Docker Registry** with a **web-based UI** using HTTPS, Basic Authentication, and custom networking.
The `.env` file centralizes all configuration values required by the build and destroy scripts that automate the registry’s deployment and teardown.

---

## ⚙️ Overview

The Docker Registry and its UI run on a **dedicated macvlan network** (to allow communication between the host and the Docker Containers) with the assigned static IPs, host-mounted certificate directories, and user authentication.

---

## 🚀 Usage Overview

1. **Ensure `.env` is configured correctly** with valid values.
2. **Run the scripts** with:

   ```bash
   # Build Script
   chmod +x nacho_docker_registry_builder.sh
   ./nacho_docker_registry_builder.sh
   ```

   ```bash
   # Destroy Script
   chmod +x nacho_docker_registry_destroyer.sh
   ./nacho_docker_registry_destroyer.sh
   ```
3. The scripts will:

   * Create 2 Docker Containers, one for the BackEnd and another one for the FrontEnd.

---

### 💠 Components

| Component                      | Description                                                            |
| ------------------------------ | ---------------------------------------------------------------------- |
| **Docker Registry**            | Stores Docker images securely in a private repository                  |
| **Docker Registry UI**         | Provides a web interface for browsing and managing images              |
| **Certificates**               | Enables HTTPS encryption for both the registry and its UI              |
| **Authentication (.htpasswd)** | Protects access to the UI and BackEnd using Basic Authentication       |

---

## 🌐 Network Configuration variables

| Variable                          | Description                        | Example                         |
| --------------------------------- | ---------------------------------- | ------------------------------- |
| `HOST_IP_ADDRESS`                 | Linux host IP address              | `xxx.xxx.x.xx`                  |
| `HOST_IP_GATEWAY`                 | Default host gateway               | `xxx.xxx.x.x`                   |
| `CUSTOM_NETWORK_PARENT_INTERFACE` | Host network interface for macvlan | `eth0`                          |
| `CUSTOM_REGISTRY_NETWORK_NAME`    | Docker network name                | `dockerregistrynetwork`         |
| `CUSTOM_REGISTRY_NETWORK_SUBNET`  | Docker network subnet              | `xxx.xxx.x.x/xx`                |
| `HOST_CUSTOM_NETWORK_INTERFACE`   | Custom macvlan interface name      | `macvlanx`                      |
| `HOST_IFCFG_FILE`                 | Persistent macvlan config file     | `ifcfg-macvlanx`                |

---

## 📦 Docker Registry Configuration

| Variable                              | Description                         | Example                                                 |
| ------------------------------------- | ----------------------------------- | ------------------------------------------------------- |
| `CUSTOM_REGISTRY_CONTAINER_NAME`      | Registry container name             | `dockerregistrycontainer`                               |
| `CUSTOM_REGISTRY_IMAGE_NAME`          | Docker image name                   | `registry` (default registry docker image name)         |
| `CUSTOM_REGISTRY_IMAGE_TAG`           | Image tag                           | `latest` (latest docker registry image tag)             |
| `CUSTOM_REGISTRY_CONTAINER_IPADDRESS` | Registry container IP               | `xxx.xxx.x.xx`                                          |
| `CUSTOM_REGISTRY_PORT`                | HTTPS port                          | `5000` (any non usable port)                            |
| `CUSTOM_REGISTRY_HOSTNAME`            | Registry hostname                   | `dockerregistryhostname`                                |
| `CUSTOM_REGISTRY_VOLUME_NAME`         | Volume for registry data            | `dockerregistryvolume`                                  |
| `CUSTOM_REGISTRY_DATA_DIRECTORY`      | Data directory inside the container | `/var/lib/registry`                                     |
| `CUSTOM_REGISTRY_URL`                 | Registry catalog endpoint           | `https://dockerregistryhostname:port/v2/_catalog`       |

---

## 🖥️ Docker Registry UI Configuration variables

| Variable                                  | Description             | Example                                                                               |
| ----------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------- |
| `CUSTOM_REGISTRY_UI_CONTAINER_NAME`       | UI container name       | `dockerregistryuicontainer`                                                           |
| `CUSTOM_UI_IMAGE_NAME`                    | UI image                | `joxit/docker-registry-ui` ([info here](https://github.com/Joxit/docker-registry-ui)) |
| `CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS`  | UI container IP         | `xxx.xxx.x.xx`                                                                        |
| `CUSTOM_REGISTRY_UI_HOST_HTTP_PORT`       | Host HTTP port          | `8080` (default http port)                                                            |
| `CUSTOM_REGISTRY_UI_HOST_HTTPS_PORT`      | Host HTTPS port         | `8443` (default https port)                                                           |
| `CUSTOM_REGISTRY_UI_CONTAINER_HTTP_PORT`  | Container HTTP port     | `80` (another default http port)                                                      |
| `CUSTOM_REGISTRY_UI_CONTAINER_HTTPS_PORT` | Container HTTPS port    | `443` (another default https port)                                                    |
| `CUSTOM_REGISTRY_UI_HOSTNAME`             | UI hostname             | `dockerregistryuihostname`                                                            |
| `CUSTOM_REGISTRY_UI_URL`                  | Full UI URL             | `https://dockerregistryuihostname`                                                    |
| `CUSTOM_REGISTRY_TITLE`                   | Display name for the UI | `any name of your choice`                                                             |

---

## 🔐 Authentication (`auth/.htpasswd`) variables

| Variable                                | Description                    | Example                                     |
| --------------------------------------- | ------------------------------ | ------------------------------------------- |
| `CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE`    | Auth file name                 | `.htpasswd`                                 |
| `CUSTOM_REGISTRY_UI_AUTH_USER`          | Username                       | `user`                                      |
| `CUSTOM_REGISTRY_UI_AUTH_PASSWORD`      | Password                       | `password`                                  |
| `HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY` | Host directory for `.htpasswd` | `/opt/Scripts/DockerRegistryContainer/auth` |

You can create or update the `.htpasswd` file manually (useless though since the script does it for you):

```bash
htpasswd -Bbn user password > /opt/Scripts/DockerRegistryContainer/auth/.htpasswd
```

---

## 🔏 Certificates variables

| Variable                                    | Description                         | Example                                                        |
| ------------------------------------------- | ----------------------------------- | -------------------------------------------------------------- |
| `CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY`    | Directory inside registry container | `/opt/Certificates`                                            |
| `CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY` | Directory inside UI container       | `/etc/nginx/certs`                                             |
| `HOST_REGISTRY_CERTIFICATES_DIRECTORY`      | Host cert directory (registry)      | `/opt/Scripts/DockerRegistryContainer/certificates/registry`   |
| `HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY`   | Host cert directory (UI)            | `/opt/Scripts/DockerRegistryContainer/certificates/registryui` |
| `CUSTOM_REGISTRY_CERTIFICATE_FILE`          | Registry certificate file           | `registrycert.crt`                                             |
| `CUSTOM_REGISTRY_PRIVATE_KEY_FILE`          | Registry private key                | `registrykey.key`                                              |
| `CUSTOM_REGISTRY_UI_PEM_FILE`               | UI fullchain cert                   | `fullchain.pem`                                                |
| `CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE`       | UI private key                      | `privkey.pem`                                                  |
| `CUSTOM_REGISTRY_CERTIFICATE_DAYS_VALID`    | Certificate validity (days)         | `4096` (or any of your choice)                                 |
| `CUSTOM_REGISTRY_CERTIFICATE_PASSWORD`      | Certificate key password            | `changeit`                                                     |

To generate a self-signed certificate this piece of code runs on the build script (for each container), example:

```bash
openssl req -x509 -nodes -days 4096 -newkey rsa:4096 \
  -keyout registrykey.key \
  -out registrycert.crt \
  -subj "/C=CountryCode/ST=City/L=Location/O=Organization/OU=Group/CN=hostname/emailAddress=exmple@company.com"
```

---

## 📜 Certificate Subject and SAN Configuration variables

| Variable                                   | Purpose                                   |
| ------------------------------------------ | ----------------------------------------- |
| `CUSTOM_REGISTRY_CERTIFICATE_SUBJECT`      | Full subject for the registry certificate |
| `CUSTOM_REGISTRY_UI_CERTIFICATE_SUBJECT`   | Full subject for the UI certificate       |
| `CUSTOM_REGISTRY_CERTIFICATE_SAN_VALUE`    | SAN entries (DNS/IP) for registry         |
| `CUSTOM_REGISTRY_UI_CERTIFICATE_SAN_VALUE` | SAN entries (DNS/IP) for UI               |

---

## 🧰 Host Directories variables

| Variable                                                    | Description                         |
| ----------------------------------------------------------- | ----------------------------------- |
| `HOST_NETWORK_MANAGER_DIRECTORY`                            | Network manager scripts directory   |
| `HOST_TRUSTED_CA_DIRECTORY`                                 | System CA trust anchors             |
| `HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY` | Docker client cert trust directory  |
| `HOST_REGISTRY_UI_NGINX_CONF_DIRECTORY`                     | Host path for UI HTTPS config       |
| `CUSTOM_REGISTRY_UI_NGINX_CONF_DIRECTORY`                   | Container path for UI NGINX configs |

---

## 🧾 Notes

* Always use secure passwords and properly signed certificates in production.
* Update `.htpasswd` and certificates before the expiration date.
* The `.env` file can be version-controlled (without sensitive credentials).

---

## 📄 .env file used to use on the Docker Registry Builder script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
HOST_IP_ADDRESS=                                                # Linux Host IP Address
CUSTOM_REGISTRY_CONTAINER_IPADDRESS=                            # Docker Registry Container IP Address
CUSTOM_REGISTRY_NETWORK_NAME=                                   # Docker Registry Network Name
CUSTOM_REGISTRY_NETWORK_SUBNET=                                 # Docker Registry Network Subnet
HOST_IP_GATEWAY=                                                # Red Hat Linux Host Gateway IP Address
CUSTOM_NETWORK_PARENT_INTERFACE=                                # Parent Interface from the Red Hat Linux Host Server
CUSTOM_REGISTRY_PORT=                                           # Port of the Docker Registry
CUSTOM_REGISTRY_HOSTNAME=                                       # Hostname of the Docker Registry
CUSTOM_REGISTRY_VOLUME_NAME=                                    # Docker Registry Volume name
CUSTOM_REGISTRY_CONTAINER_NAME=                                 # Docker Registry Container name
CUSTOM_REGISTRY_IMAGE_NAME=                                     # Docker Registry Image name
CUSTOM_REGISTRY_URL=                                            # Docker Registry Catalog URL
CUSTOM_REGISTRY_DATA_DIRECTORY=                                 # Docker Registry data directory inside the Docker Registry Container
CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS=                         # Docker Registry UI Container IP Address
CUSTOM_REGISTRY_UI_CONTAINER_NAME=                              # Docker Registry UI Container Name
CUSTOM_REGISTRY_UI_HOST_HTTP_PORT=                              # Docker Registry UI HTTP Port (Host side)
CUSTOM_REGISTRY_UI_CONTAINER_HTTP_PORT=                         # Docker Registry UI HTTP Port (Container side)
CUSTOM_REGISTRY_UI_HOST_HTTPS_PORT=                             # Docker Registry UI HTTPS Port (Host side)
CUSTOM_REGISTRY_UI_CONTAINER_HTTPS_PORT=                        # Docker Registry UI HTTPS Port (Container side)
CUSTOM_REGISTRY_UI_HOSTNAME=                                    # Hostname of the Docker Registry UI
CUSTOM_UI_IMAGE_NAME=                                           # Docker Registry UI Image name
CUSTOM_REGISTRY_UI_URL=                                         # Docker Registry UI URL
CUSTOM_REGISTRY_TITLE=                                          # Docker Registry Title
CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY=                         # Docker Registry directory where the Docker Registry certificates will be located
CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY=                      # Docker Registry UI directory where the Docker Registry UI certificates will be located
CUSTOM_REGISTRY_IMAGE_TAG=                                      # Docker Registry and Docker Registry UI Image Tag name
HOST_REGISTRY_CERTIFICATES_DIRECTORY=                           # Host local directory of the certificates used by the Docker Registry
HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY=                        # Host local directory of the certificates used by the Docker Registry UI
HOST_REGISTRY_UI_NGINX_CONF_DIRECTORY=                          # Host local directory of the nginx conf file with HTTPS support for the Docker Registry UI
HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY=                          # Host local directory of the Basic Authentication file for the Docker Registry UI
HOST_NETWORK_MANAGER_DIRECTORY=                                 # Host local directory of the Network Manager files
HOST_CUSTOM_NETWORK_INTERFACE=                                  # Host custom network interface used to communicate with the Docker Containers
HOST_IFCFG_FILE=                                                # IFCG file to be used to create a persistent macvlan interface config
HOST_TRUSTED_CA_DIRECTORY=                                      # Host local directory of the Trusted CA store
CUSTOM_REGISTRY_UI_NGINX_CONF_DIRECTORY=                        # Docker Registry UI directory where the nginx conf file is located
HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY=      # Host local directory of the Docker Registry and Docker Registry UI certificates used by the Docker Client
CUSTOM_REGISTRY_PRIVATE_KEY_FILE=                               # Decrypted private key to be used for the Docker Registry
CUSTOM_REGISTRY_CERTIFICATE_FILE=                               # Self-signed SSL certificate to be used for the Docker Registry
CUSTOM_REGISTRY_PEM_FILE=                                       # PEM file to be used for the Docker Registry Certificate
CUSTOM_REGISTRY_UI_PEM_FILE=                                    # PEM file to be used for the Docker Registry UI
CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE=                            # Decrypted private key to be used for the Docker Registry UI
CUSTOM_REGISTRY_UI_HTTPS_NGINX_FILE=                            # Conf file to use HTTPS support for the Docker Registry UI
CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE=                             # Basic Authentication file for the Docker Registry UI
CUSTOM_REGISTRY_UI_AUTH_USER=                                   # Basic Authentication User for the Docker Registry UI
CUSTOM_REGISTRY_UI_AUTH_PASSWORD=                               # Basic Authentication Password for the Docker Registry UI
CUSTOM_REGISTRY_CERTIFICATE_DAYS_VALID=                         # Days of validation of the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_PASSWORD=                           # Password from the Docker Registry and Docker Registry UI key files
CUSTOM_REGISTRY_CERTIFICATE_COUNTRY=                            # Country value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_STATE=                              # State value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_LOCALITY=                           # Locality value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION=                       # Organization value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION_UNIT=                  # Organization Unit value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_COMMON_NAME=                        # Common Name value from the Docker Registry Certificate
CUSTOM_REGISTRY_UI_CERTIFICATE_COMMON_NAME=                     # Common Name value from the Docker Registry UI Certificate
CUSTOM_REGISTRY_CERTIFICATE_EMAIL=                              # Email value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_SAN_VALUE=                          # SAN value from the Docker Registry Certificate
CUSTOM_REGISTRY_UI_CERTIFICATE_SAN_VALUE=                       # SAN value from the Docker Registry UI Certificate
CUSTOM_REGISTRY_UI_CERTIFICATE_SUBJECT=                         # Subject value from the Docker Registry UI Certificate
CUSTOM_REGISTRY_CERTIFICATE_SUBJECT=                            # Subject value from the Docker Registry Certificate
```

---

## 📄 .env file used to use on the Docker Registry Destroyer script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
CUSTOM_REGISTRY_NETWORK_NAME=                                                     # Docker Registry Network Name
CUSTOM_VOLUME_NAME=                                                               # Docker Registry Volume name
CUSTOM_REGISTRY_CONTAINER_NAME=                                                   # Docker Registry Container name
CUSTOM_REGISTRY_CONTAINER_IPADDRESS=                                              # Docker Registry Container IP Address
CUSTOM_REGISTRY_IMAGE_NAME=                                                       # Docker Registry Image name
CUSTOM_REGISTRY_UI_CONTAINER_NAME=                                                # Docker Registry UI Container Name
CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS=                                           # Docker Registry UI Container IP Address
CUSTOM_UI_IMAGE_NAME=                                                             # Docker Registry UI Image name
CUSTOM_REGISTRY_IMAGE_TAG=                                                        # Docker Registry and Docker Registry UI Image Tag name
CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE=                                               # Basic Authentication file for the Docker Registry UI
HOST_REGISTRY_CERTIFICATES_DIRECTORY=                                             # Host local directory of the certificates used by the Docker Registry
HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY=                                          # Host local directory of the certificates used by the Docker Registry UI
HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY=                        # Host local directory of the Docker Registry and Docker Registry UI certificates used by the Docker Client
HOST_DOCKER_CLIENT_DIRECTORY=                                                     # Host local directory for the Docker Client files
HOST_TRUSTED_CA_DIRECTORY=                                                        # Host local directory of the Trusted CA store
HOST_NETWORK_MANAGER_DIRECTORY=                                                   # Host local directory of the Network Manager files
HOST_CUSTOM_NETWORK_INTERFACE=                                                    # Host custom network interface used to communicate with the Docker Containers
HOST_IFCFG_FILE=                                                                  # IFCG file to be used to create a persistent macvlan interface config
HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY=                                            # Host local directory of the Basic Authentication file for the Docker Registry UI
CUSTOM_REGISTRY_CERTIFICATE_FILE=                                                 # Self-signed SSL certificate to be used for the Docker Registry
CUSTOM_REGISTRY_UI_CERTIFICATE_FILE=                                              # Self-signed SSL certificate to be used for the Docker Registry UI
```
