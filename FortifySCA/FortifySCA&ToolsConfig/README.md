# 🔗 Fortify SCA & OpenText SAST Global Symlink Configurator

A Bash script that creates global symbolic links (`symlinks`) in `/usr/local/bin` for **Fortify Static Code Analyzer (SCA)** and **OpenText Application Security Testing (SAST)** executables and tools so they can be run from any directory without typing full paths.

---

## ✨ Features

- 🌐 **Global CLI Access:** Links all files inside the application and tools `bin` directories into `/usr/local/bin`.
- 🧭 **Version-Aware Path Resolution:** Supports both legacy **Fortify SCA** (`23.2`, `24.2`, `24.4`) and **OpenText AST** (`25.2`, `25.4`, `26.2`) directory structures.
- 🛡️ **Collision Protection:** If a command name already exists in `/usr/local/bin`, automatically appends `-tools` to the symlink name (e.g., `<tool>-tools`) instead of overwriting the existing binary/symlink.
- ⏭️ **Graceful Skipping:** Skips any `bin` directory that does not exist without crashing the script.
- ⚙️ **Environment File Support:** Automatically loads base directory paths from a `.env` file in the current directory.
- 🎨 **Color-Coded Terminal Output:** Uses ANSI colors (`CYAN`, `YELLOW`, `GREEN`, `RED`) for readable progress and error messages.
- 🛑 **Fail-Fast Safety:** Runs with `set -e` so execution stops immediately if an unexpected error occurs.

---

## 📋 Prerequisites

- 🐧 **OS:** Linux system with `bash`
- 🔐 **Privileges:** `root` or `sudo` permissions (required to write symlinks into `/usr/local/bin`)
- 📦 **Installed Software:** Fortify SCA / OpenText AST Application and Tools already installed on the system
- 🌐 **PATH:** `/usr/local/bin` should be present in your `PATH` (standard on most Linux distributions)
- 🧰 **Utilities:** Standard coreutils (`ln`, `basename`)

---

## ⚙️ Configuration (`.env`)

The script loads base installation paths from a `.env` file in the **current working directory**. 
Define the variables corresponding to the versions you manage:

The values are at the discretion of each user.

```env
# Base directories for Fortify SCA versions 23.2, 24.2, and 24.4
FORTIFY_SCA_APP_BASE_DIR=
FORTIFY_SCA_TOOLS_BASE_DIR=

# Base directories for OpenText Application Security Testing versions 25.2, 25.4, and 26.2
OT_APPLICATION_SECURITY_TESTING_BASE_DIR=
OT_APPLICATION_SECURITY_TOOLS_BASE_DIR=
```

> 📁 The script appends `/<VERSION>/bin` to each base directory above (for example: `/opt/.../25.4/bin`).

---

## 🗂️ Supported Versions & Target Paths

| Version Entered | Base Variables Used | Resolved `bin` Directories |
| :--- | :--- | :--- |
| `23.2`, `24.2`, `24.4` | `FORTIFY_SCA_APP_BASE_DIR`<br>`FORTIFY_SCA_TOOLS_BASE_DIR` | `<FORTIFY_SCA_APP_BASE_DIR>/<version>/bin`<br>`<FORTIFY_SCA_TOOLS_BASE_DIR>/<version>/bin` |
| `25.2`, `25.4`, `26.2` | `OT_APPLICATION_SECURITY_TESTING_BASE_DIR`<br>`OT_APPLICATION_SECURITY_TOOLS_BASE_DIR` | `<OT_APPLICATION_SECURITY_TESTING_BASE_DIR>/<version>/bin`<br>`<OT_APPLICATION_SECURITY_TOOLS_BASE_DIR>/<version>/bin` |

---

## 🚀 Usage

1. Make sure your `.env` file is configured in the current directory.
2. Grant execute permission to the script:
   ```bash
   chmod +x create_fortify_symlinks.sh
   ```
3. Run the script with elevated privileges:
   ```bash
   sudo ./create_fortify_symlinks.sh
   ```
4. When prompted, enter the installed version (e.g., `24.4` or `26.2`):
   ```text
   Enter the Fortify SCA and Tools version to configure the symlinks of the tools (e.g: 23.2, 24.2, 24.4, 25.2, 25.4 26.2, etc): 25.4
   ```
5. Verify that tools are globally accessible:
   ```bash
   ls -la /usr/local/bin
   sourceanalyzer -version
   ```

---

## 🔄 How It Works

1. **Load `.env`:** Exports environment variables from `.env` if present in the working directory.
2. **Prompt & Validate Version:** Asks the user for the version string and exits with status `1` if left empty.
3. **Resolve `bin` Paths:** Selects either the Fortify SCA (`23.2`, `24.2`, `24.4`) or OpenText AST (`25.2`, `25.4`, `26.2`) base directory variables and builds `<BASE_DIR>/<VERSION>/bin`.
4. **Create Symlinks (`create_symlinks`):**
   - Verifies that the target `bin` directory exists (skips with a warning if not found).
   - Iterates over every file in `<BASE_DIR>/<VERSION>/bin`.
   - Creates `/usr/local/bin/<tool>` if no file with that name exists yet.
   - Creates `/usr/local/bin/<tool>-tools` (`ln -sf`) if `/usr/local/bin/<tool>` already exists.

---

## 📌 Important Notes

- ⚠️ **Unsupported Version Strings:** Only versions matching `23.2`, `24.2`, `24.4`, `25.2`, `25.4`, or `26.2` are currently handled in the `if/elif` block. Entering another version (such as `26.3`) will complete without creating symlinks unless added to the regex pattern.
- 🔁 **Re-running or Upgrading Versions:** Because existing `/usr/local/bin/<tool>` entries are preserved and redirected to `<tool>-tools`, clean out old symlinks in `/usr/local/bin` first if you are upgrading from an older Fortify/OpenText SAST version.
- 📄 **All Files in `bin`:** The script links every entry inside `bin` (excluding empty globs), so ensure only intended executables/scripts reside in those `bin` directories.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
