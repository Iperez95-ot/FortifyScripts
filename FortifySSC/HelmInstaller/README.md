# ⚓ Helm Installation Script

This repository contains a **Bash script** to automatically install or update the **Helm Package Manager** (for Kubernetes) to its **latest available version** on a **Linux system**.
The script dynamically fetches the latest Helm release from GitHub and ensures your system is up to date with minimal manual effort.

---

## 📂 Directory Structure

```
HelmInstaller/
 ├── .env                            # Optional configuration file to define environment variables (e.g., installation paths)
 └── helm_latest_installer.sh        # Main script that installs or updates Helm
```

---

## 🧰 Requirements

* Linux system with `bash`, `curl`, `jq`, and `tar`
* Internet access to fetch Helm releases from GitHub
* Sudo privileges (if installing to system directories)

---

## ⚙️ Environment Variables

You can define optional variables in the `.env` file to customize the installation:

```makefile
# .env example
HELM_STANDARD_DIRECTORY=/usr/local/bin/helm        # Helm installation directory
```

If `.env` exists in the same directory, it will be automatically loaded.

---

## 🚀 Usage Overview

1. Loads environment variables from `.env` (if available).
2. Fetches the latest Helm release version from GitHub using the GitHub API.
3. Checks if Helm is already installed:

   * If installed → compares the current version with the latest and updates if needed.
   * If not installed → downloads and installs the latest version.
4. Verifies the installation and cleans up downloaded files.
5. Typical use case:

   ```bash
    chmod +x helm_latest_installer.sh
    ./helm_latest_installer.sh
   ```
   
If you wish to install Helm in a custom directory, define it in `.env` before running the script.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
