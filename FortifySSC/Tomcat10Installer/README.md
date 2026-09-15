# 🐱 Tomcat9Installer (Apache Tomcat 10.x Installation Script)

This script automates the installation of **Apache Tomcat 10.x** on a Linux system and prepares directories for **OpenText Application Security (Fortify SSC)** integration.
It handles directory creation, environment variable loading, Tomcat download, and extraction automatically.

---

## ⚙️ Features

* 📦 Installs the latest available **Tomcat 10.x** version dynamically.
* 🧩 Integrates with **Fortify Software Security Center** directory structure.
* 📁 Automatically creates installation and application directories.
* 🌱 Reads environment variables from `.env` file.
* 🧹 Clean and color-coded output for easy readability.
* ⏱️ Exits early if directories already exist.

---

## 🧾 Requirements

* 🐧 Linux-based OS (RHEL, CentOS, Ubuntu, etc.).
* 📥 `curl` and `wget` installed.
* 📦 `tar` utility available.
* 🌍 Internet access to download Apache Tomcat.
* ✅ `.env` file configured with the following variables:

The values are at the discretion of each user.

  ```makefile
  HOME_DIR=/path/to/home               # Home Back Up files directory of the Fortify SSC server
  FORTIFY_SSC_DIR=/path/to/fortify     # Binary files directory of the Fortify SSC server 
  ```

---

## 🗂️ Directory Structure

```
Tomcat10Installer/
|   ├── tomcat10_installer.sh     # Script that installs Apache Tomcat 10 on a linux system and prepares the directories.
|   └── .env                     # Environment variables file used by the Apache Tomcat 10 Installer script.
└────────────────────────────    
```

---

## 🧰 Usage

1. **Clone or download** this script to your Linux system.
2. Ensure a `.env` file exists in the same directory as the script.
3. Make the script executable:

   ```bash
   chmod +x tomcat10_installer.sh
   ```
4. Run the script:

   ```bash
   ./tomcat10_installer.sh
   ```

---

## 🧱 Components Used

* 🐚 **Bash** – Script execution environment
* 🐱 **Apache Tomcat 10.x** – Java application server
* 🛡️ **OpenText Application Security (Fortify SSC)** – Integration target for secure code analysis

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.

