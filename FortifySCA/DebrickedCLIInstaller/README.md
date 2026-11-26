# <img width="25" height="25" alt="image" src="https://github.com/debricked/cli/blob/main/assets/CLI_logo_1024.png" /> Debricked CLI Installer (Debricked Command Line Interface (DCLI) Installer Script)

## 📄 Overview

A lightweight Bash script that automates installing or updating the **Debricked CLI** to the latest configured release on a Linux system.

---

## ⚙️ Features

- 🔍 **Version Detection:** Checks if `debricked` is already installed and compares its current version against the target release.
- ⚡ **Idempotent Execution:** Skips installation if the latest version is already installed.
- 📁 **Automatic Directory Setup:** Creates the target working directory if it does not exist.
- ⬇️ **Direct Binary Download:** Downloads the CLI binary using `wget` and applies executable permissions (`chmod +x`).
- 🌐 **System-Wide `PATH` Configuration:** Automatically registers the installation directory in `/etc/profile` if not already present.
- 🎨 **Color-Coded Terminal Output:** Uses ANSI colors (`GREEN`, `YELLOW`, `CYAN`, `RED`) for clear status feedback.
- 🛡️ **Fail-Fast Safety:** Runs with `set -e` so execution stops immediately if any command fails.

---

## 📂 Directory Structure

```
DebrickedCLIInstaller/
|   ├── .env                                           # Defines environment variables for installation paths and configuration settings
|   └── debrickedcli_latest_version_installer.sh       # Main script for downloading and installing the latest Debricked CLI version
└───────────────────────────────────────────────
```

---

## 📋 Prerequisites

Make sure the following requirements are met before running the script:

- 🐧 **OS:** Linux system with `bash`
- 🌐 **Network:** Internet/network access to reach the Debricked CLI download URL
- 🧰 **Tools:** `wget`, `awk`, `grep`, `chmod`, and `mkdir` (standard Linux utilities)
- 🔐 **Privileges:** `root` or `sudo` permissions (required to write to `/etc/profile` and system directories such as `/opt/...`)

---

## 💻 Variables

The values are at the discretion of each user.

| Variable                                  | Description                                                   |
| ----------------------------------------- | ------------------------------------------------------------- |
| `DEBRICKED_WORKDIR`                       | Directory where DCLI will be installed (`/opt/debricked`).    |
| `DEBRICKED_LATEST_RELEASE_VERSION`        | The latest DCLI tag name fetched from GitHub.                 |
| `DEBRICKED_LATEST_RELEASE_VERSION_NUMBER` | Numeric representation of the release version (e.g. `2.4.0`). |
| `DEBRICKED_LATEST_RELEASE_URL`            | Download URL for the latest FCLI `.tgz` package.              |

> ⚠️ **Note:** Because the script downloads the file directly to `$DEBRICKED_WORKDIR/debricked` and runs `chmod +x` on it, `DEBRICKED_LATEST_RELEASE_URL` must point directly to the **executable binary** (not a `.tar.gz` or `.zip` archive).

---

## 🚀 Usage

1. Make sure your `.env` file is in the current directory.
2. Grant execute permission to the script:
   ```bash
   chmod +x debrickedcli_latest_version_installer.sh
   ```
3. Run the script with elevated privileges:
   ```bash
   sudo ./debrickedcli_latest_version_installer.sh
   ```
4. If this is a first-time installation, reload your shell environment so the updated `PATH` takes effect in your current terminal session:
   ```bash
   source /etc/profile
   ```
5. Verify the installation:
   ```bash
   debricked --version
   ```
   
---

## 🔄 How It Works

1. **Load Environment:** Reads variables from `.env` if the file exists in the current directory.
2. **Check Installed Version:** Runs `command -v debricked` and extracts the installed version via `debricked --version` (defaults to `none` if not found).
3. **Compare Versions:**
   - ✅ **Up to date:** Prints `"You already have the latest Debricked CLI installed!"` and exits cleanly.
   - 🔄 **Missing or outdated:**
     1. **Step 1:** Creates `$DEBRICKED_WORKDIR` if missing.
     2. **Step 2:** Downloads the binary from `$DEBRICKED_LATEST_RELEASE_URL` into `$DEBRICKED_WORKDIR/debricked` and marks it executable.
     3. **Step 3:** Appends `export PATH=$PATH:$DEBRICKED_WORKDIR` to `/etc/profile` (if not already present) and refreshes the shell command cache (`hash -r`).
     4. **Step 4:** Lists the installation directory and outputs the newly installed `debricked --version`.

---

## 📌 Important Notes

- 🔄 **Version String Format:** `DEBRICKED_LATEST_RELEASE_VERSION_NUMBER` must match the last whitespace-separated field returned by `debricked --version` (`awk '{print $NF}'`).
- 🖥️ **Non-Login Shells:** Changes appended to `/etc/profile` apply automatically to new login shells. Run `source /etc/profile` in existing sessions to use `debricked` immediately without opening a new session.
- 🛡️ **Error Handling:** Because `set -e` is enabled, any failure (such as a missing `.env` variable, invalid URL, or permission denied on `/etc/profile`) will immediately halt the script.

---

## 🧾 License

This project is part of the **💻 FortifyScripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
