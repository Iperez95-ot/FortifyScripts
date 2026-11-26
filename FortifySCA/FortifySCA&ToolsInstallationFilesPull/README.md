# ☁️ Fortify SCA & OpenText SAST OneDrive Files Puller

A Bash script that downloads On-Premise standalone installation files for **Fortify Static Code Analyzer (SCA)** / **OpenText Application Security Testing (SAST)** 
and **Tools** from **OT-Latam OneDrive** using `rclone`, prepares local backup and installation directories, and sets executable permissions on `.run` installers.

---

## ✨ Features

- ☁️ **OneDrive Integration (`rclone`):** Pulls installer packages directly from the `ot-latam_onedrive` remote with real-time transfer progress (`-P`).
- 🧩 **Interactive Patch Selection:** Choose between downloading the **Original Patch (base installer)**, **all folders** (base + maintenance patches), or a **custom patch folder**.
- 🧭 **Version-Aware Path Mapping:** Automatically resolves directory structures for both legacy **Fortify SCA** (`23.2`, `24.2`, `24.4`) and **OpenText AST** (`25.2`, `25.4`, `26.2`).
- 📁 **Automated Directory Provisioning:** Creates both backup (installer storage) and target installation directories.
- ⚡ **Executable Setup:** Automatically finds all downloaded `*.run` files and sets `+x` permissions.
- 🔍 **File Verification:** Lists all downloaded files with human-readable sizes (`ls -lh`) upon completion.
- ⚙️ **Environment File Support:** Loads base directory paths from `.env` in the current working directory.
- 🛡️ **Fail-Fast Safety:** Runs with `set -e` so execution stops immediately if any step fails.

---

## 📂 Directory Structure

```
FortifySCA&ToolsInstallationFiles/
|   ├── .env                                                      # Defines environment variables for OneDrive integration, installation paths, and configuration settings
|   └── fortify_sca_and_tools_one_drive_installation_files.sh     # Main script for downloading and managing Fortify SCA and associated tools installation files from OneDrive
└────────────────────────────────────────────────────────────
```

---

## 📋 Prerequisites

Before running the script, ensure the following requirements are met:

- 🐧 **OS:** Linux system with `bash`
- ☁️ **Rclone:** `rclone` installed and pre-configured with an authenticated remote named `ot-latam_onedrive`
  ```bash
  rclone listremotes   # Should include: ot-latam_onedrive:
  ```
- 🌐 **Network:** Internet access to connect to Microsoft OneDrive
- 🔐 **Privileges:** Sufficient permissions (`root` / `sudo` if targeting system directories like `/opt`) to create directories and set file permissions
- 🧰 **Utilities:** Standard Linux tools (`mkdir`, `find`, `chmod`, `ls`)

---

## ⚙️ Configuration (`.env`)

Create a `.env` file in the **same directory** where you run the script and define the base directories for your target versions:

The values are at the discretion of each user.

```env
# Base directories for Fortify SCA versions 23.2, 24.2, and 24.4
FORTIFY_SCA_APP_BACKUP_BASE_DIR=
FORTIFY_SCA_APP_INSTALLATION_BASE_DIR=
FORTIFY_SCA_TOOLS_BACKUP_BASE_DIR=
FORTIFY_SCA_TOOLS_INSTALLATION_BASE_DIR=

# Base directories for OpenText Application Security Testing versions 25.2, 25.4, and 26.2
OT_APPLICATION_SECURITY_TESTING_BACKUP_BASE_DIR=
OT_APPLICATION_SECURITY_TESTING_INSTALLATION_BASE_DIR=
OT_APPLICATION_SECURITY_TOOLS_BACKUP_BASE_DIR=
OT_APPLICATION_SECURITY_TOOLS_INSTALLATION_BASE_DIR=
```

> 📁 The script automatically appends `/<VERSION>` to each base path above (for example: `<BASE_DIR>/25.4`).

---

## 🚀 Usage

1. Make sure `.env` is present in the current directory and `ot-latam_onedrive` is configured in `rclone`.
2. Grant execute permission to the script:
   ```bash
   chmod +x pull_fortify_onedrive.sh
   ```s/<VERSION>/SCA & Tools/` $\rightarrow$ Tools Backup directory
     3. Marks all downloaded `*.run` installers executable (`chmod +x`).
     4. Lists all files present in each backup and installation directory.

---

## 📌 Important Notes

- ⏭️ **Existing Version Directories:** If all 4 target directories for the entered version already exist, the script exits early and skips `rclone copy`. To re-pull files or download an additional patch for an existing version, remove/rename one of the target directories first or update the check.
- 🔑 **Rclone Config Context:** If you run with `sudo`, `rclone` will look for `/root/.config/rclone/rclone.conf` instead of your regular user's config unless `--config` or `RCLONE_CONFIG` is set.
- ⚠️ **Supported Versions:** Only `23.2`, `24.2`, `24.4`, `25.2`, `25.4`, and `26.2` are currently matched in the version conditional block. Add new versions to the `elif` regex if pulling newer releases (e.g., `26.3`).

---

## 🧾 License

This project is part of the **💻 FortifyScripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
