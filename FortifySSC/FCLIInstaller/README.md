# # <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/d10482ad-8bff-452f-a65f-9882c5bceed3" /> FCLIInstaller (Fortify Command Line Interface (FCLI) Installer Script)

## 📄 Overview

This Bash script automatically **installs or updates** the latest version of the **Fortify Command Line Interface (FCLI)** on a Linux system.
It dynamically checks the most recent release from the official **Fortify GitHub repository**, downloads it, installs or updates the binary, and ensures the executable is added to the system’s `PATH`.

---

## ⚙️ Features

* Fetches the **latest FCLI version** from GitHub using the GitHub API.
* Detects if an older version is installed and updates it automatically.
* Creates the working directory `/opt/fcli` if it doesn’t exist.
* Adds `/opt/fcli` permanently to the system `PATH`.
* Cleans up temporary installation files.
* Displays detailed, color-coded logs for easy readability.

---

## 🗂️ Directory Structure

```
FCLIInstaller/                            
|   └── fcli_latest_version_installer.sh       # Main installation script
└───────────────────────────────────────
```

---

## 🧩 Requirements

Make sure your system has the following packages installed:

| Package | Purpose                                                   |
| ------- | --------------------------------------------------------- |
| `curl`  | Retrieves the latest release information from GitHub.     |
| `jq`    | Parses JSON output from the GitHub API.                   |
| `wget`  | Downloads the FCLI package.                               |
| `tar`   | Extracts the `.tgz` archive.                              |
| `bash`  | Script interpreter (default in most Linux distributions). |

You can install them on RHEL/CentOS or similar systems with:

```bash
sudo dnf install -y curl jq wget tar
```

---

## 💻 Variables

| Variable                             | Description                                                   |
| ------------------------------------ | ------------------------------------------------------------- |
| `FCLI_WORKDIR`                       | Directory where FCLI will be installed (`/opt/fcli`).         |
| `FCLI_LATEST_RELEASE_VERSION`        | The latest FCLI tag name fetched from GitHub.                 |
| `FCLI_LATEST_RELEASE_VERSION_NUMBER` | Numeric representation of the release version (e.g. `2.4.0`). |
| `FCLI_LATEST_RELEASE_URL`            | Download URL for the latest FCLI `.tgz` package.              |
| `FCLI_CURRENT_VERSION_NUMBER`        | Current installed version detected on the system.             |

---

## 🚀 Usage

1. Save the script as `fcli_latest_version_installer.sh`.
2. Give it execute permissions:

   ```bash
   chmod +x fcli_latest_version_installer.sh
   ```
3. Run it as **root** or with **sudo**:

   ```bash
   sudo ./fcli_latest_version_installer.sh
   ```

The script will:

1. Check if the latest FCLI version is already installed.
2. If not, download and install it in `/opt/fcli`.
3. Add `/opt/fcli` to the system `PATH` (via `/etc/profile`).
4. Confirm the version after installation.

---

## 🧩 Post-Installation

To apply the new `PATH` immediately, run:

```bash
source /etc/profile
```

Then verify the installation:

```bash
fcli --version
```

You should see something like:

```
Fortify Command Line Interface (fcli) 2.4.0
```

---

## 🛠️ Notes

* The script requires **root privileges** to modify `/etc/profile` and `/opt`.
* Safe to re-run — it will simply update to the latest release if needed.
* Designed for **Linux environments** (tested on RHEL, CentOS, and Ubuntu).

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
