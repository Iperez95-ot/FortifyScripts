# 🗃️ LDAPDockerContainer (eDirectory, eDirectory API and IdentityConsole Docker Containers)

This project contains all the resources and automation scripts required to set up, manage, and configure **LDAP services** (including **eDirectory Application**, **eDirectory API** and **Identity Console**) within Docker containers for integration with **Fortify SSC** and related systems.

---

## ⚙️ Features

* Automated retrieval of Docker installation files from a remote repository.
* Containerized **eDirectory Application** and **eDirectory API** deployment for LDAP management.
* **Identity Console** setup for LDAP administration.
* Modular structure with separate management and installation components.

---

## 📂 Directory Structure

```
LDAPDockerContainer/
├── DockerInstallationFilesPull/                                                            # Directory of the eDirectory and IdentityConsole Docker installation binary files pull scripts.
|   └── 25.2/                                                                               # Version directory of the Binary files to be pulled.
|       ├── edirectory_931_identityconsole_252_files_pull.sh                                # Script to pull eDirectory and IdentityConsole version 25.2 Docker installation binary files from OT OneDrive.
|       └── .env                                                                            # Environment variables file used by the pull binary files script.       
└── EDirectory/                                                                             # Directory of the configuration and scripts for setting up the eDirectory application and API containers.
|       └── 9.3.1/                                                                          # Directory of the Version 9.3.1 of eDirectory application container to be deployed.
|             ├── docker_management_scripts/                                                # Shell scripts directory  to build and destroy the eDirectory application and API containers.
|             |               ├── builder/                                                  # Build script directory (eDirectory).
|             |               |     ├── edirectory_docker_container_builder.sh              # Script that builds the eDirectory application and API containers.
|             |               |     └── .env                                                # Environment variables file used by the build script (eDirectory).
|             |               └── destroyer/                                                # Destroy script directory (eDirectory).
|             |                     ├── edirectory_docker_container_destroyer.sh            # Script that destroys the eDirectory application and API containers.
|             |                     └── .env                                                # Environment variables file used by the destroy script (eDirectory).
!             └── certificates/                                                             # SSL/TLS self-signed certificates for secure HTTPS access to the eDirectory application and API containers.
└── IdentityConsole/                                                                        # Directory of the configuration and scripts for deploying the Identity Console container.
|             └── 25.2                                                                      # Directory of the Version 25.2 of IdentityConsole application container to be deployed.
|                 ├── docker_management_scripts/                                            # Shell scripts directory to build and destroy the IdentityConsole container.
|                 |               ├── builder/                                              # Build script directory (IdentityConsole).                                       
|                 |               |     ├── identityconsole_docker_container_builder.sh     # Script that builds the IdentityConsole container.
|                 |               |     └── .env                                            # Environment variables file used by the build script (IdentityConsole).
|                 |               └── destroyer/                                            # Destroy script directory (IdentityConsole).
|                 |                     ├── identityconsole_docker_container_destroyer.sh   # Script that destroys the IdentityConsole container.
|                 |                     └── .env                                            # Environment variables file used by the destroy script (IdentityConsole).
└── EDirectoryAPI/                                                                          # Directory of the configuration and scripts for deploying the eDirectory API container.
|             └── 25.2/                                                                     # Directory of the Version 25.2 of eDirectory API containers to be deployed.
|                 ├── docker_management_scripts/                                            # Shell scripts directory to build and destroy the eDirectory API containers.
|                 |               ├── builder/                                              # Build script directory (eDirectory API).                                       
|                 |               |     ├── edirectory_api_docker_container_builder.sh      # Script that builds the eDirectory API containers.
|                 |               |     └── .env                                            # Environment variables file used by the build script (eDirectory API).
|                 |               └── destroyer/                                            # Destroy script directory (eDirectory API).
|                 |                     ├── edirectory_api_docker_container_builder.sh      # Script that destroys the eDirectory API containers.
|                 |                     └── .env                                            # Environment variables file used by the destroy script (eDirectory API).
|                 └── required_files/                                                       # Directory of the configuration and SSL/TLS self-signed certificates files for deploying the eDirecotry API containers.
|                                 └── edirapi.yaml                                          # YAML file to generate the eDirecotry API Swagger UI Documentation.                
└────────────────────────────────────────────────────────────────────────────────────────
```

---

## 🚀 Usage Overview

1. Navigate to the desired component folder (e.g., `EDirectory`, `IdentityConsole` or `EDirectory API`) and choose the version you want to deploy on a container.
2. Review and adjust the `.env` file if present to fit your environment.
3. Run the corresponding setup or management script (e.g., `builder` or `destroyer` script) with:
   ```bash
   ./<script_name>.sh
   ```
4. Follow the terminal output for configuration and deployment progress.
5. Deploy the Docker Containers of the Identity and Access Management components in the following order:
   - **OpenText eDirectory (NetIQ) Application**.
   - **OpenText Identity Console (NetIQ) Application**.
   - **OpenText eDirectory (NetIQ) API (BackEnd & Swagger UI Documentation)**.

---

## 🧩 Components

* **DockerInstallationFilesPull** → Automates the retrieval of all required LDAP Docker images and resources.
* **EDirectory** → Manages the OpenText eDirectory LDAP instance configuration.
*  **EDirectoryAPI** → Manages the OpenText eDirectory API instance configuration.
* **IdentityConsole** → Provides a web-based LDAP administration interface.

---

## 📝 Notes

* Ensure Docker and Docker Compose are installed and properly configured on the host system before running any scripts.
* Certificates, credentials, and environment variables should be configured **at the discretion of each user** to match security policies.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
