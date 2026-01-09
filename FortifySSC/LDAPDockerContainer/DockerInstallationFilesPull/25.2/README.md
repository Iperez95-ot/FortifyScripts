# 🚀 EDirectory & IdentityConsole OneDrive Sync + Docker Image Loader Environment Variables (LDAPDockerInstallationFilesPull script)

This project automates the workflow for preparing:

- **EDirectory Application 9.3.1**.
- **EDirectory API 25.2**.
- **IdentityConsole 25.2**.

It downloads installation files from OneDrive, creates versioned backup directories, copies configuration files, and loads Docker images.
All configuration comes from the `.env` file.

---

## 📄 `.env` File Variables

The `.env` file defines all versions, paths, and Docker image names. The values are at the discretion of each user.

### 📌 Environment Variables

| Variable | Description | Example |
|---------|-------------|---------|
| `EDIRECTORY_VERSION` | 🧱 EDirectory version to install | `9.3.1` |
| `EDIRECTORY_VERSION_FULL` | 🔢 Version number without dots | `931` |
| `IDENTITYCONSOLE_VERSION` | 🖥️ IdentityConsole version to install | `25.2` |
| `IDENTITYCONSOLE_VERSION_FULL` | 🔢 Version number without dots | `252` |
| `EDIRECTORY_LDAP_BACKUP_DIR` | 📁 Backup directory | `/home/backup/EDirectory_LDAP` |
| `EDIRECTORY_IMAGE_NAME` | 🐳 Docker image name for EDirectory | `edirectory` |
| `EDIRECTORY_API_IMAGE_NAME` | 🔌 Docker image name for eDir API | `edirapi` |
| `IDENTITYCONSOLE_IMAGE_NAME` | 🐳 Docker image name for IdentityConsole | `identityconsole` |

---

## ⚙️ Script Summary

The script performs these steps:

| Step | Description |
|------|-------------|
| **1. Load `.env`** | 📥 Loads environment variables |
| **2. Check directories** | 🧐 Exits early if they already exist |
| **3. Create directories** | 🏗️ Builds the backup folder structure |
| **4. Download from OneDrive** | ☁️ Pulls EDirectory & IdentityConsole install files |
| **5. Copy silent.properties** | 📄 Copies file from `Silent_Properties_Modified/` |
| **6. Load Docker images** | 🐳 Loads EDirectory, API, and IdentityConsole images |
| **7. List newly loaded images** | 👀 Displays available images |

---

## 🛠️ Requirements

You must have installed:

| Tool | Purpose |
|------|---------|
| **rclone** | ☁️ Copy files from OneDrive after setting up a remote config |
| **Docker Engine** | 🐳 Load and run images |
| **Bash Shell** | 💻 Linux script execution |

## ▶️ How to Run the Script

1. Ensure `.env` and the script are in the same folder
2. Test OneDrive access (before this ask for permission to the OneDrive account manager to give access to rclone):
   ```bash
   rclone config
   ```
3. Make the script executable
   ```bash
   chmod +x edirectory_931_identityconsole_252_files_pull.sh
   ```  
4. Run the script as:
   ```bash
   ./edirectory_931_identityconsole_252_files_pull.sh
   ```
   
---

## 🔐 .env file used to use on the LDAPDockerInstallationFilesPull script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
EDIRECTORY_VERSION=                    # EDirectory version to be installed and backed up
EDIRECTORY_VERSION_FULL=               # EDirectory version number without dots
IDENTITYCONSOLE_VERSION=               # IdentityConsole version to be installed and backed up
IDENTITYCONSOLE_VERSION_FULL=          # IdentityConsole version number without dots
EDIRECTORY_LDAP_BACKUP_DIR=            # Back Up directory where EDirectory and IdentityConsole files will be stored
EDIRECTORY_IMAGE_NAME=                 # EDirectory Image Name
EDIRECTORY_API_IMAGE_NAME=             # EDirectory Image API Name
IDENTITYCONSOLE_IMAGE_NAME=            # IdentityConsole Image Name
```
