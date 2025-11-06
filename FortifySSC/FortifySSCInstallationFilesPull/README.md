# 📦 FortifySSCInstallationFilesPull (Fortify SSC Installation/Binary Files Retrieval Script)

This Bash script automates the process of **pulling Fortify SSC On-Premise standalone installation files** from the **OT-Latam OneDrive** storage into a Linux system.
It ensures the **backup** and **installation directories** are properly created and synchronized for a specific Fortify SSC version.

---

## 🛰️ Components

* **rclone** – used to copy Fortify installation files from OneDrive.
* **.env file** – contains configurable environment variables such as version and directory paths.
* **Color-coded terminal output** – improves readability of process logs.
* **Automatic directory creation** – ensures the required folder structure exists before copying files.

---

## ⚙️ Configuration

Before running the script, create a `.env` file in the same directory as the script with the following variables:

```makefile
FORTIFY_SSC_VERSION=                     # Fortify SSC version to be installed and backed up
FORTIFY_SSC_BACKUP_DIR=                  # Back Up directory where Fortify SSC version 23.2 files will be stored
FORTIFY_SSC_INSTALLATION_DIR=            # Installation directory where Fortify SSC version 23.2 files will be installed    
```

Make sure that:

* `rclone` is installed and properly configured with your **OT-Latam OneDrive** remote.
* The `.env` file permissions are correctly set (`chmod 600 .env`) if it contains sensitive data.

---

## 🚀 Usage Overview

1. **Load environment variables**
   The script automatically reads the `.env` file if it exists in the current directory.
   💡 *This allows you to define version-specific paths and reuse them easily.*

      * Run the script with:

      ```bash
      chmod +x fortify_ssc_fortifyversion_files_pull.sh
      ./fortify_ssc_fortifyversion_files_pull.sh
      ```

3. **Directory validation and creation**
   The script checks if both backup and installation directories exist.
   If not, it creates them automatically under the paths specified in `.env`.

4. **Pulling files from OneDrive**
   Using `rclone`, the script retrieves the installation package from (example):

   ```
   ot-latam_onedrive:Back Up/Fortify/Product Versions/<FORTIFY_SSC_VERSION>/SSC/Original Patch
   ```

   and copies it into both the **backup** and **installation** directories.

5. **Verification and listing**
   Once completed, the script lists the extracted files in each directory and confirms successful execution.

---

## 📝 Notes

* ⚠️ Requires a working `rclone` configuration with the OneDrive remote named `ot-latam_onedrive` (you must ask for permission to technical support for this).
* 🧰 The script uses `set -e` to immediately stop on any command failure.
* 🗂️ Both backup and installation directories will mirror the retrieved installation files.
* 🧑‍💻 Ideal for automated setup or integration with larger Fortify SSC deployment scripts.

---

## 📁 Directory Structure

```
FortifySSCInstallationFilesPull/
├── 23.2/                                                  # Fortify SSC Installation files version to pull directory.                      
|     ├── .env                                             # Environment variables file containing the configuration values (e.g., directories, SSC version).
|     └── fortify_ssc_fortifyversion_files_pull.sh         # Bash script that automates downloading Fortify SSC installation files using rclone.
└─────────────────────────────────────────────────
```

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
