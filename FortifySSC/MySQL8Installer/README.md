# 🐬 MySQL8Installer (MySQL 8.0 Client Installer Script)

This Bash script automates the installation of the **MySQL 8.0 Client** on a Linux system. It ensures your environment is properly configured with the latest client version, sets up repositories, imports necessary GPG keys, and optionally downloads configuration files from OneDrive.

---

## ⚙️ Features

* Automatically detects if MySQL 8.0 Client is already installed.
* Installs the **official MySQL 8.0 Community Repository** and GPG keys.
* Downloads configuration files (`my.cnf`) directly from **OneDrive**.
* Provides clear and color-coded output for better readability.
* Ensures consistent and repeatable installation for Fortify SSC installation on a linux server.

---

## 🧾 Requirements

* 🐧 Linux OS (RHEL / CentOS / Rocky / Alma 9.x compatible).
* 📦 `dnf` package manager.
* 🌐 Internet connectivity.
* ☁️ [`rclone`](https://rclone.org/) installed and configured with OneDrive remote named `ot-latam_onedrive`.
* 💠 A valid `.env` file in the same directory as the script.

---

## 📁 Directory Structure

```
MySQLClientInstaller/
|    ├── .env                              # Environment variables file used by MySQL8 Installer script. 
|    └── mysql8_installer.sh               # Script to install and configure MySQL 8.0 Client.
└─────────────────────────────── 
```

---

## 🧩 .env Variables

| Variable                      | Description                                                            |
| ----------------------------- | ---------------------------------------------------------------------- |
| `FORTIFY_SSC_VERSION`         | Fortify SSC version used to fetch the corresponding MySQL config files |
| `MYSQL_CONFIG_HOST_DIRECTORY` | Path where the `my.cnf` configuration file will be stored              |

---

## 🚀 Usage Overview

1. Ensure you have your `.env` file properly configured in the same directory.
2. Make the script executable:

   ```bash
   chmod +x mysql8_installer.sh
   ```
3. Run the script with root privileges:

   ```bash
   sudo ./mysql8_installer.sh
   ```
4. The script will:

   * Check for existing MySQL 8.0 installation.
   * Install required repositories and packages.
   * Pull configuration files from OneDrive.

---

## 📝 Notes

* The script imports the **MySQL 2023 GPG Key**, required for versions 8.0.42 and above.
* It safely exits if MySQL 8.0 Client is already installed to avoid redundant setup.
* Configuration file pulling is handled via `rclone` for authenticated OneDrive access.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
