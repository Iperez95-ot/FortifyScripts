# 🧱 LDAPDockerContainer (eDirectory and IdentityConsole Docker Containers)

This project contains all the resources and automation scripts required to set up, manage, and configure **LDAP services** (including **eDirectory** and **Identity Console**) within Docker containers for integration with **Fortify SSC** and related systems.

---

## ⚙️ Features

* Automated retrieval of Docker installation files from a remote repository.
* Containerized **eDirectory** deployment for LDAP management.
* **Identity Console** setup for LDAP administration.
* Modular structure with separate management and installation components.

---

## 📂 Directory Structure

```
LDAPDockerContainer/
├── DockerInstallationFilesPull/                                                    # Directory of the LDAP Docker installation files pull scripts.
|   ├── 25.2/                                                                       # Version of the Binary files to be pulled.
|        └── edirectory_931_identityconsole_252_files_pull.sh                       # Script to pull 25.2 LDAP Docker installation files (eDirectory and IdentityConsole) from OneDrive.
├── EDirectory/                                                                     # Directory of the configuration and scripts for setting up the eDirectory LDAP and API containers.
|       └── 9.3.1/                                                                  # Version of eDirectory LDAP and API containers to be deployed.
|             ├── docker_management_scripts/                                        # Shell scripts to build and destroy the eDirectory LDAP and API containers.
|                            ├── builder/                                           # Build script directory.
|                                  └── edirectory_docker_container_builder.sh       # BUilds the eDirectory containers.
|                            └── destroyer/                                         # Destroy script directory.
|                                   └── edirectory_docker_container_destroyer.sh    # Destroys the eDirectory containers.
!             └── certificates/                                                     # SSL/TLS self-signed certificates for secure HTTPS access to the eDirectory LDAP and API containers.
└── IdentityConsole/                                                                # Directory of the configuration and scripts for deploying the Identity Console container.
```

---

## 🚀 Usage Overview

1. Navigate to the desired component folder (e.g., `EDirectory` or `IdentityConsole`).
2. Review and adjust the `.env` file if present to fit your environment.
3. Run the corresponding setup or management script (e.g., `builder` or `destroyer` script) with:

   ```bash
   ./<script_name>.sh
   ```
4. Follow the terminal output for configuration and deployment progress.

---

## 🧩 Components

* **DockerInstallationFilesPull** → Automates the retrieval of all required LDAP Docker images and resources.
* **EDirectory** → Manages the OpenText eDirectory LDAP instance configuration.
* **IdentityConsole** → Provides a web-based LDAP administration interface.

---

## 📝 Notes

* Ensure Docker and Docker Compose are installed and properly configured on the host system before running any scripts.
* Certificates, credentials, and environment variables should be configured **at the discretion of each user** to match security policies.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
