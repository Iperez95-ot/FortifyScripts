# 🐳 FortifySSCMySQLDBDockerContainer (Fortify SSC MySQL Database Docker Container)

This directory contains the complete setup and configuration scripts for **Fortify SSC’s MySQL Database Docker Containers**, used to host and manage the **Fortify Software Security Center (SSC)** database in isolated and reproducible environments.

---

## 🧩 Components

* **`FullDockerContainer/`**
  Contains scripts and configuration files to build a **fully self-contained MySQL container**, including:

  * Custom network configuration.
  * Persistent storage setup.
  * SSL certificate management.
  * Automated MySQL initialization and destruction scripts.

* **`HostlessDockerContainer/`**
  Contains scripts for a **lightweight, host-independent MySQL container** configuration.
  Ideal for environments where the database runs without relying on the host’s networking interfaces or persistent mounts.
  With Automated MySQL initialization and destruction scripts.

---

## ⚙️ Configuration Overview

Each container configuration uses a dedicated `.env` file to define essential parameters, such as:

```bash
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
CUSTOM_NETWORK_NAME=
CUSTOM_CONTAINER_NAME=
CUSTOM_CONTAINER_IPADDRESS=
```

💡 **Tip:** Adjust these values according to your Fortify SSC setup and security policies.
Ensure the `.env` file is properly protected (recommended permissions: `chmod 600 .env`).

---

## 🚀 Usage Overview

### 🧱 Full Docker Container

Used when deploying the **complete MySQL instance** with custom networking, volumes, and SSL support.

Typical use case:

```bash
cd FullDockerContainer
./build_and_run_mysql_container.sh
```

### ☁️ Hostless Docker Container

Used in simpler setups or cloud-based deployments where minimal host dependency is required.

Typical use case:

```bash
# Build Script
chmod +x fortifyssc_db_builder.sh
./fortifyssc_db_builder.sh
```

---

## 🗂️ Directory Structure

```
FortifySSCMySQLDBDockerContainer/                        
├── FullDockerContainer/                                 # Complete container setup with host integration (volumes, SSL, network)
│   └── docker_management_scripts/                       # Contains scripts to build and destroy the full Docker container
│       ├── builder/                                     # Scripts to build, configure, and run the full MySQL container
│       └── destroyer/                                   # Scripts to stop and remove the full MySQL container and related resources
│
└── HostlessDockerContainer/                             # Lightweight, host-independent MySQL container setup
    └── docker_management_scripts/                       # Contains scripts to manage the hostless MySQL container
        ├── builder/                                     # Scripts to build and start the hostless MySQL container
        └── destroyer/                                   # Scripts to stop and remove the hostless MySQL container and cleanup artifacts
```

---

## 🧾 Notes

* ⚠️ Ensure **Docker** and **Docker Compose** are installed before executing the scripts.
* 🔐 The containers are intended for **internal Fortify SSC use only** and should be deployed in secure environments.
* 🧰 SSL certificates and credentials must be managed according to your organization’s security standards.
* 📦 Designed to integrate with the broader **Fortify SSC Docker Automation Suite**.

## 🧾 License

This project is part of the **Fortify SSC Automation Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
