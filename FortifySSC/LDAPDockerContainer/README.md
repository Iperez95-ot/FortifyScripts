# 🧱 LDAP Docker Container

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
├── DockerInstallationFilesPull/     # Scripts to pull LDAP Docker installation files (binary files from eDirectory and IdentityConsole) from OneDrive
├── EDirectory/                      # Configuration and scripts for setting up the eDirectory LDAP container
└── IdentityConsole/                 # Configuration and scripts for deploying the Identity Console container
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
