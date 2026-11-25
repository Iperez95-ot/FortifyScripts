# <img width="25" height="25" alt="image" src="https://avatars.githubusercontent.com/u/15859888?s=60&v=4" /> Helm Package Manager Installer & Updater 

A Bash script that automatically detects, installs, or updates **Helm** (the Kubernetes Package Manager) to the latest official release on a Linux `amd64` system. 

---

## ✨ Features

- 🔍 **Dynamic Latest Release Lookup:** Queries the official Helm GitHub Releases API to detect the latest version automatically.
- ⚡ **Idempotent Version Check:** Compares the installed `helm` version against the latest release and exits cleanly if already up to date.
- 🔄 **Seamless Install & Upgrade:** Handles both fresh installations and in-place upgrades using the exact same workflow.
- 🧹 **Automatic Cleanup:** Removes the extracted `linux-amd64/` folder and downloaded `.tar.gz` archive after installation.
- ⚙️ **Configurable Target Path:** Uses `.env` (`HELM_STANDARD_DIRECTORY`) to place the `helm` binary in your preferred `PATH` directory.
- 🎨 **Color-Coded Terminal Output:** Uses ANSI colors (`CYAN`, `YELLOW`, `GREEN`, `RED`) for clear status feedback.
- 🛡️ **Fail-Fast Safety:** Runs with `set -e` so execution stops immediately if any step fails.

---

## 🗂️ Directory Structure

```
HelmInstaller/                            
|   └── helm_latest_installer.sh       # Main Helm installation script
└───────────────────────────────
```

---

## 📋 Prerequisites

Before running the script, ensure your system meets these requirements:

- 🐧 **OS & Architecture:** Linux `x86_64` / `amd64` (`linux-amd64` release archive)
- 🔐 **Privileges:** `root` or `sudo` permissions if installing into a system directory such as `/usr/local/bin`
- 🌐 **Network:** Internet access to reach `api.github.com` and `get.helm.sh`
- 🧰 **Tools:** `curl`, `jq`, `tar`, `gzip`, `grep`, `sed`, `cut`, and `xargs`

---

## ⚙️ Configuration (`.env`)

Create a `.env` file in the **same directory** as the script to specify where the `helm` binary should be installed:

The values are at the discretion of each user.

```env
HELM_STANDARD_DIRECTORY=/usr/local/bin  # Standard PATH directory where the helm binary will be moved (must already exist)
```

> ⚠️ **Note:** Ensure `$HELM_STANDARD_DIRECTORY` already exists and is included in your system `PATH` (e.g., `/usr/local/bin`) so the final `helm version --short` verification succeeds. Avoid spaces or `#` characters in `.env` values since the script parses `.env` with `grep`, `sed`, and `xargs`.

---

## 🚀 Usage

1. Make sure your `.env` file is configured in the current directory.
2. Grant execute permission to the script:
   ```bash
   chmod +x install_helm.sh
   ```
3. Run the script with elevated privileges:
   ```bash
   sudo ./install_helm.sh
   ```
4. Verify Helm is available:
   ```bash
   helm version
   ```

---

## 🔄 How It Works

1. **Load `.env`:** Exports environment variables from `.env` if present in the working directory.
2. **Fetch Latest Version:** Queries `https://api.github.com/repos/helm/helm/releases/latest` using `curl` and `jq` to get the latest release tag and version number.
3. **Check Existing Installation:**
   - **If `helm` is installed:** Compares the local `helm version --short` output with the latest release:
     - ✅ **Up to date:** Prints `"You already have the latest Helm version."` and exits (`exit 0`).
     - 🔄 **Outdated:** Downloads the latest `tar.gz`, extracts it, moves `linux-amd64/helm` into `$HELM_STANDARD_DIRECTORY`, cleans up temporary files, and prints the updated version.
   - **If `helm` is not installed:** Downloads the latest `tar.gz`, extracts it, moves `linux-amd64/helm` into `$HELM_STANDARD_DIRECTORY`, cleans up temporary files, and prints the installed version.

---

## 📌 Important Notes

- 🖥️ **Architecture:** The download URL is configured for `linux-amd64`. If deploying on ARM (`arm64`), update `linux-amd64` in the script to `linux-arm64`.
- ⏱️ **GitHub API Rate Limits:** Unauthenticated calls to `api.github.com` are rate-limited by IP (60 requests/hour). If the API returns an empty response, `set -e` or `curl` will fail the script.
- 📁 **Working Directory Cleanup:** The script downloads and extracts `helm-*.tar.gz` and `linux-amd64/` inside the current working directory and removes them once the binary is moved.

---

## 🧾 License

This project is part of the **💻 FortifyScripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
