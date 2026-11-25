# 🧪 Fortify & Debricked Sample Projects Setup

A Bash script that provisions a centralized workspace of **intentionally vulnerable sample applications** 
for testing **Fortify Static Code Analyzer (SCA)**, **OpenText Application Security Testing (SAST)**, and **Debricked** across multiple languages and frameworks.

> ⚠️ **Security Notice:** The projects set up by this script are **intentionally insecure** and designed strictly for security scanning, demos, and testing in isolated environments. Do **not** deploy or expose them in production.

---

## ✨ Features

- 📁 **Structured Workspace Creation:** Builds `basic/`, `advanced/`, and `github/` subdirectories under `$SAMPLES_WORK_DIR`.
- 📦 **Official Fortify Samples Import:** Copies `basic` and `advanced` sample projects from your local Fortify SCA / OpenText AST `insecure_applications_samples` directory.
- 🧩 **Patch-Aware Source Path:** Lets you choose between `Original Patch`, a custom maintenance patch folder, or direct version directory layout.
- 🌐 **60+ GitHub Vulnerable Repositories:** Shallow-clones (`git clone --depth=1`) a curated collection of multi-language insecure apps (Java, .NET, Python, Go, Node.js, Angular, React, C++, Scala, Ruby, ABAP, Swift, Terraform/IaC, GraphQL, AI/MCP, and more).
- ⏭️ **Duplicate Clone Protection:** Checks for an existing `.git` directory before cloning each repository.
- ⚙️ **Environment File Support:** Automatically loads workspace and source base directories from `.env`.
- 🛡️ **Fail-Fast Execution:** Runs with `set -e` to halt immediately on errors.

---

## 📂 Directory Structure

```
FortifySCASamples/                            
|   └── fortify_sca_samples.sh      # Main Fortify SCA Samples installation script
└─────────────────────────────
```

---

## 📋 Prerequisites

- 🐧 **OS & Shell:** Linux with **Bash 4.0+** (required for associative arrays via `declare -A`)
- 🧰 **Tools:** `git` (for cloning GitHub repos) and standard coreutils (`cp`, `mkdir`, `ls`)
- 🌐 **Network:** Active internet access to reach `github.com`
- 📦 **Local Samples Source:** Extracted Fortify SCA / OpenText AST installer/backup files containing `insecure_applications_samples`
- 💾 **Disk Space & Permissions:** Sufficient disk space for 60+ repositories and write permissions for `$SAMPLES_WORK_DIR`

---

## ⚙️ Configuration (`.env`)

Create a `.env` file in the **current working directory** with the following variables:

The values are at the discretion of each user.

```env
SAMPLES_WORK_DIR=                                          # Destination directory where all sample projects will be stored
FORTIFY_SCA_SAMPLES_SOURCE_BASE_DIR=                       # Base source directory for Fortify SCA versions 23.2, 24.2, and 24.4
OT_APPLICATION_SECURITY_TESTING_SAMPLES_SOURCE_BASE_DIR=   # Base source directory for OpenText Application Security Testing versions 25.2, 25.4, and 26.2
```

> 📁 The script builds the source path as: `<SOURCE_BASE_DIR>/<VERSION>/<PATCH_SUBFOLDER>/insecure_applications_samples`.

---

## 🗂️ Resulting Directory Structure

```
$SAMPLES_WORK_DIR/
|   ├── basic/          # Official Fortify basic sample projects
|   ├── advanced/       # Official Fortify advanced sample projects
|   └── github/         # Shallow-cloned vulnerable & demo repositories (AltoroJ, DVWA, Juice-Shop, WebGoat, IWA-*, etc.)
└─────────────────
```

---

## 🚀 Usage

1. Configure your `.env` file in the same directory as the script.
2. Make the script executable:
   ```bash
   chmod +x setup_fortify_samples.sh
   ```
3. Run the script:
   ```bash
   ./setup_fortify_samples.sh
   ```
   *(Use `sudo -E ./setup_fortify_samples.sh` if `$SAMPLES_WORK_DIR` is inside a root-owned path such as `/opt`.)*
4. Answer the interactive prompts:
   - **Version:** Enter your Fortify SCA / OpenText AST version (e.g., `24.4`, `25.4`, `26.2`).
   - **Patch Subfolder (`1-3`):**
     - `1` *(Default)* — Uses `/Original Patch`
     - `2` — Prompts for a specific patch folder name (e.g., `25.4.1 Patch`)
     - `3` — Uses no subfolder (files directly under `<VERSION>`)

---

## 🔄 How It Works

1. **Load `.env`:** Exports environment variables from `.env` if present.
2. **Prompt Version & Patch Folder:** Captures the product version (exits `1` if empty) and resolves `PATCH_SUBFOLDER`.
3. **Resolve Source Path:** Selects the appropriate base directory (`23.2`, `24.2`, `24.4` vs. `25.2`, `25.4`, `26.2`) and builds `SAMPLES_SOURCE_DIR`.
4. **Check Existing Workspace:**
   - If `$SAMPLES_WORK_DIR` already exists, prints `"Fortify SCA samples are already set up to be used!"` and exits (`exit 0`).
   - Otherwise:
     1. Creates `$SAMPLES_WORK_DIR`, `basic/`, and `advanced/`.
     2. Copies `basic` and `advanced` folders from `$SAMPLES_SOURCE_DIR` (warns if either folder is missing).
     3. Creates `$SAMPLES_WORK_DIR/github` and clones each repository from `FORTIFY_SAMPLES_GITHUB_REPOS` with `--depth=1`, skipping any repo that already contains `.git`.
     4. Lists the contents of `basic/`, `advanced/`, and `github/`.

---

## 📌 Important Notes

- ⏭️ **Early Exit Check:** If `$SAMPLES_WORK_DIR` already exists—even if empty or partially populated from an interrupted run—the script exits immediately on start. Remove or rename `$SAMPLES_WORK_DIR` before re-running if a previous run was interrupted.
- 🌐 **Repository Availability:** Because `set -e` is enabled, if any GitHub repository URL becomes unavailable, private, or fails to clone due to network issues, the script will stop at that repository.
- ⚠️ **Supported Versions:** Only `23.2`, `24.2`, `24.4`, `25.2`, `25.4`, and `26.2` are currently matched in the version conditional block.
- 🔁 **Duplicate Key Note:** In `FORTIFY_SAMPLES_GITHUB_REPOS`, `["Debricked-Demo-Application"]` is defined twice, so the later entry (`https://github.com/debricked/demo`) takes precedence, and `["MediAssistAI "]` is currently commented out.

---

## 🧾 License

This project is part of the **💻 FortifyScripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
