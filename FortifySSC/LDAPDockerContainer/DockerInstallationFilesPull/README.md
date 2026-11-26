# 🚀 EDirectory & IdentityConsole OneDrive Sync + Docker Image Loader (`LDAPDockerInstallationFilesPull`)

This project automates the workflow for preparing **EDirectory** and **IdentityConsole** environments across the following supported version sets:

| Script | EDirectory Application | EDirectory API | IdentityConsole |
| :--- | :--- | :--- | :--- |
| `edirectory_931_identityconsole_252_files_pull.sh` | **9.3.1** | **25.2** | **25.2** |
| `edirectory_933_identityconsole_261_files_pull.sh` | **9.3.3** | **26.1** | **26.1** |

It downloads installation files from OneDrive, creates versioned backup directories, copies configuration files, loads Docker images, and tags/pushes them to a private Docker registry. All configuration comes from the `.env` file.

---

## 📄 `.env` File Variables

The `.env` file defines all versions, paths, and Docker image names. The values are at the discretion of each user.

### 📌 Environment Variables

| Variable | Description | Example |
|---------|-------------|---------|
| `EDIRECTORY_VERSION` | 🧱 EDirectory version to install | `9.3.1` / `9.3.3` |
| `EDIRECTORY_VERSION_FULL` | 🔢 Version number without dots | `931` / `933` |
| `IDENTITYCONSOLE_VERSION` | 🖥️ IdentityConsole version to install | `25.2` / `26.1` |
| `IDENTITYCONSOLE_VERSION_FULL` | 🔢 Version number without dots | `252` / `261` |
| `EDIRECTORY_LDAP_BACKUP_DIR` | 📁 Backup directory | `/home/backup/EDirectory_LDAP` |
| `EDIRECTORY_IMAGE_NAME` | 🐳 Docker image name for EDirectory | `edirectory` |
| `EDIRECTORY_API_IMAGE_NAME` | 🔌 Docker image name for eDir API | `edirapi` |
| `IDENTITYCONSOLE_IMAGE_NAME` | 🐳 Docker image name for IdentityConsole | `identityconsole` |
| `CUSTOM_REGISTRY_URL` | 🌐 Docker Private Registry URL | `yourdockerregistryhostname:port` |
| `REGISTRY_USER` | 👤 Docker Private Registry User | `yourdockerregistryuser` |
| `REGISTRY_PASSWORD` | 🔐 Docker Private Registry Password | `yourdockerregistrypassword` |

---

## ⚙️ Script Summary

Both scripts perform the following steps:

| Step | Description |
|------|-------------|
| **1. Load `.env`** | 📥 Loads environment variables |
| **2. Check directories** | 🧐 Exits early if they already exist |
| **3. Create directories** | 🏗️ Builds the backup folder structure |
| **4. Download from OneDrive** | ☁️ Pulls EDirectory & IdentityConsole install files |
| **5. Copy `silent.properties`** | 📄 Copies file from `Silent_Properties_Modified/` |
| **6. Load Docker images** | 🐳 Loads EDirectory Application, EDirectory API, and IdentityConsole images |
| **7. Tag and push Docker images** | 🐳 Tags and pushes the EDirectory, API, and IdentityConsole images into a Docker private registry |
| **8. List newly loaded images** | 👀 Displays available images |

---

## 🛠️ Requirements

You must have installed:

| Tool | Purpose |
|------|---------|
| **rclone** | ☁️ Copy files from OneDrive after setting up a remote config |
| **Docker Engine** | 🐳 Load, tag, push, and run images |
| **Bash Shell** | 💻 Linux script execution |

---

## ▶️ How to Run the Script

1. Ensure `.env` and the desired script are in the same folder.
2. Test OneDrive access (before this, ask for permission from the OneDrive account manager to grant access to `rclone`):
   ```bash
   rclone config
   ```
3. Make the scripts executable:
   ```bash
   chmod +x edirectory_931_identityconsole_252_files_pull.sh edirectory_933_identityconsole_261_files_pull.sh
   ```
4. Run the script matching the version set defined in your `.env`:
   ```bash
   # For EDirectory 9.3.1 & IdentityConsole 25.2
   ./edirectory_931_identityconsole_252_files_pull.sh

   # OR for EDirectory 9.3.3 & IdentityConsole 26.1
   ./edirectory_933_identityconsole_261_files_pull.sh
   ```

---

## 🔐 `.env` File Used for the `LDAPDockerInstallationFilesPull` Scripts (Generic Example)

The values are at the discretion of each user.

```env
# Defines the variables
EDIRECTORY_VERSION=                    # EDirectory version to be installed and backed up
EDIRECTORY_VERSION_FULL=               # EDirectory version number without dots
IDENTITYCONSOLE_VERSION=               # IdentityConsole version to be installed and backed up
IDENTITYCONSOLE_VERSION_FULL=          # IdentityConsole version number without dots
EDIRECTORY_LDAP_BACKUP_DIR=            # Back Up directory where EDirectory and IdentityConsole files will be stored
EDIRECTORY_IMAGE_NAME=                 # EDirectory Image Name
EDIRECTORY_API_IMAGE_NAME=             # EDirectory Image API Name
IDENTITYCONSOLE_IMAGE_NAME=            # IdentityConsole Image Name
CUSTOM_REGISTRY_URL=                   # Docker Registry URL
REGISTRY_USER=                         # Private Docker Registry User
REGISTRY_PASSWORD=                     # Private Docker Registry Password
```

---

## 🧾 License

This project is part of the 💻 FortifyScripts Utilities suite. 
Use according to your organization’s internal deployment and licensing guidelines.
