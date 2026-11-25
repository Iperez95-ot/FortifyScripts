# 🟣 .NET & Fortify SCA / OpenText SAST Setup Scripts

A suite of Bash scripts that automate installing the required **.NET Runtime or SDK** and 
creating the **installer backup & working directory structures** for **Fortify Static Code Analyzer (SCA)** 
and **OpenText Application Security Testing (SAST)** on RHEL-based Linux systems.

---

## 📂 Scripts Included

| Script | .NET Package Installed | Target Fortify / OpenText SAST Versions | Interactive Prompt? |
| :--- | :--- | :--- | :--- |
| **Script 1** *(*.NET 6*)* | `dotnet-runtime-6.0` | **Fortify SCA 23.2** | ❌ No |
| **Script 2** *(*.NET 8*)* | `dotnet-sdk-8.0` | **Fortify SCA 24.2, 24.4** or **OpenText AST 25.2, 25.4** | ✅ Yes (asks for version) |
| **Script 3** *(*.NET 10*)* | `dotnet-sdk-10.0` | **OpenText SAST 26.2, 26.3+** | ❌ No |

---

## 📂 Directory Structure

```
DotNETInstaller/
├── 10.0
|     └── dot_net_10_installer.sh        # Main script that installs DotNET 10
├── 8.0
|    └── dot_net_8_installer.sh          # Main script that installs DotNET 8
└── 6.0
|    └── dot_net_6_installer.sh          # Main script that installs DotNET 6
└────────────────────────────────

```

---

## ✨ Features

- 🔍 **Pre-Install .NET Detection:** Checks `dotnet --list-runtimes` (Script 1) or `dotnet --list-sdks` (Scripts 2 & 3) before modifying the system.
- 🔄 **System Update & .NET Install:** Updates system packages with `dnf update -y` and installs the required .NET version when no .NET installation is present.
- 📁 **Automated Directory Provisioning:** Creates both the **backup/installer storage directories** (`$HOME_DIR/sca_installation/...`) and **application/tools working directories** (`$FORTIFY_SCA_DIR/...`).
- 🧭 **Version-Aware Paths (.NET 8 Script):** Prompts for `24.2`, `24.4`, `25.2`, or `25.4` and adjusts directory naming between *Fortify Static Code Analyzer* and *OpenText Application Security Testing*.
- ⚙️ **Environment File Support:** Automatically loads paths from a `.env` file in the current directory.
- 🎨 **Color-Coded Terminal Output:** Uses ANSI colors (`CYAN`, `YELLOW`, `GREEN`, `RED`) for clear status reporting.
- 🛡️ **Fail-Fast Execution:** Enabled with `set -e` to stop immediately on any error.

---

## 📋 Prerequisites

Before running any of these scripts, ensure the following requirements are met:

- 🐧 **OS:** RHEL-based Linux distribution using `dnf` (e.g., RHEL 8/9, Rocky Linux, AlmaLinux, CentOS Stream)
- 🔐 **Privileges:** `root` or `sudo` permissions (required for `dnf` and creating directories under system paths like `/opt`)
- 🌐 **Network:** Internet access to reach configured DNF repositories containing `.NET` packages
- 🧰 **Utilities:** Standard Linux tools (`awk`, `grep`, `sort`, `tail`, `mkdir`)

---

## ⚙️ Configuration (`.env`)

All three scripts automatically source a `.env` file located in the **current working directory**.

Before running the script, create a `.env` file in the same directory as the script with the following variables:

The values are at the discretion of each user.

```env
HOME_DIR=                      # Home directory of the user
FORTIFY_SCA_DIR=               # Base directory where Fortify SCA / OpenText SAST will be installed
```

> ⚠️ **Note:** Always ensure `HOME_DIR` and `FORTIFY_SCA_DIR` are defined in `.env` (or exported in your shell) before running the scripts, as paths are constructed directly from these variables.

---

## 📁 Directories Created by Script

### 1️⃣ .NET 6 Script (Fortify SCA `23.2`)
- **Backup / Installer Directories:**
  - `$HOME_DIR/sca_installation/Fortify_Static_Code_Analyzer_Application`
  - `$HOME_DIR/sca_installation/Fortify_Static_Code_Analyzer_Tools`
- **Working Directories:**
  - `$FORTIFY_SCA_DIR/Fortify_Static_Code_Analyzer/Fortify_Static_Code_Analyzer_Application`
  - `$FORTIFY_SCA_DIR/Fortify_Static_Code_Analyzer/Fortify_Static_Code_Analyzer_Tools`

### 2️⃣ .NET 8 Script (`24.2`, `24.4`, `25.2`, `25.4`)
- **If `24.2` or `24.4` is entered:**
  - **Backup:** `$HOME_DIR/sca_installation/Fortify_Static_Code_Analyzer_Application` & `.../Fortify_Static_Code_Analyzer_Tools`
  - **Working:** `$FORTIFY_SCA_DIR/Fortify_Static_Code_Analyzer/Fortify_Static_Code_Analyzer_Application` & `.../Fortify_Static_Code_Analyzer_Tools`
- **If `25.2` or `25.4` is entered:**
  - **Directories:** `$HOME_DIR/sca_installation/OpenText_Application_Security_Testing` & `$HOME_DIR/sca_installation/OpenText_Application_Security_Tools`

### 3️⃣ .NET 10 Script (OpenText AST `26.2`, `26.3+`)
- **Backup / Installer Directories:**
  - `$HOME_DIR/sca_installation/OpenText_Application_Security_Testing_Application`
  - `$HOME_DIR/sca_installation/OpenText_Application_Security_Tools`
- **Working Directories:**
  - `$FORTIFY_SCA_DIR/OpenText_Application_Security_Testing/OpenText_Application_Security_Testing_Application`
  - `$FORTIFY_SCA_DIR/OpenText_Application_Security_Testing/OpenText_Application_Security_Tools`

---

## 🚀 Usage

1. Create your `.env` file in the same directory as the scripts.
2. Make the scripts executable:
   ```bash
   chmod +x dot_net_6_installer.sh dot_net_8_installer.sh dot_net_10_installer.sh
   ```
3. Run the script corresponding to your Fortify / OpenText AST version:
   ```bash
   # For Fortify SCA 23.2 (.NET 6 Runtime)
   sudo ./dot_net_6_installer.sh

   # For Fortify SCA 24.2 / 24.4 or OpenText SAST 25.2 / 25.4 (.NET 8 SDK)
   sudo ./dot_net_8_installer.sh

   # For OpenText SAST 26.2 / 26.3+ (.NET 10 SDK)
   sudo ./dot_net_10_installer.sh
   ```
4. Verify the installed .NET version:
   ```bash
   dotnet --list-runtimes   # For .NET 6
   dotnet --info            # For .NET 8 and .NET 10
   ```

---

## 🔄 How They Work

1. **Load `.env`:** Exports variables from `.env` if present.
2. **Version Prompt *(Script 2 only)*:** Reads the Fortify/OpenText version (`24.2`, `24.4`, `25.2`, `25.4`) and sets directory paths accordingly (exits with status `1` if empty).
3. **Detect Existing .NET:**
   - If the target `.NET` version is detected, prints a notice and exits cleanly.
   - If a **different** `.NET` version is already installed, prints the detected version and exits (`exit 0`) without altering the system or creating directories.
   - If **no** `.NET` version is installed:
     1. Updates system packages (`dnf update -y`).
     2. Installs `dotnet-runtime-6.0`, `dotnet-sdk-8.0`, or `dotnet-sdk-10.0`.
     3. Displays installed `.NET` details (`dotnet --list-runtimes` or `dotnet --info`).
     4. Checks for existing Fortify / OpenText directories; creates any missing backup and working directories.

---

## 📌 Important Notes

- ⚠️ **Existing .NET Installations:** None of the three scripts install .NET or create directories if a different version of .NET is already installed on the machine.
- 📝 **Version Check Syntax (.NET 6 & 8 Scripts):** In the .NET 6 and .NET 8 scripts, `[ "$CURRENT_DOTNET_..." == 6.* ]` / `[ "$CURRENT_DOTNET_..." == 8.* ]` uses single brackets `[ ... ]` (literal match instead of wildcard globbing). If .NET 6 or 8 is already installed, it falls through to the `else` branch and exits cleanly after printing the detected version (whereas the .NET 10 script uses `[[ ... == 10.* ]]` wildcard matching).
- 📂 **`.NET 8` Script (`25.2` / `25.4`):** Both backup and working directory variables currently point under `${HOME_DIR}/sca_installation/` for versions `25.2` and `25.4`.

---

## 🧾 License

This project is part of the **💻 FortifyScripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
