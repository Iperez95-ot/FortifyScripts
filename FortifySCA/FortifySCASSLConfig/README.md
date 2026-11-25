# 🔐 Fortify SCA SSL Certificate & Keystore Configurator

A Bash script that retrieves the **Fortify Software Security Center (SSC)** SSL/TLS certificate via `scp`, 
imports it into both the **Fortify SCA / OpenText AST Application** and **Tools** Java Keystores (`cacerts`), 
and registers it in the RHEL system-wide trusted CA store.

---

## ✨ Features

- 🔍 **Idempotent Keystore Check:** Verifies whether the SSC certificate alias already exists in both Application and Tools `cacerts` keystores before making changes.
- 🧭 **Version-Aware Keystore Mapping:** Supports both **Fortify SCA** (`23.2`, `24.2`, `24.4`) and **OpenText AST** (`25.2`, `25.4`, `26.2`) `jre/lib/security/cacerts` paths.
- 📡 **Remote Certificate Pull:** Automatically downloads the SSC certificate from the Fortify SSC server via `scp`.
- ☕ **Dual Java Keystore Import:** Imports the certificate non-interactively (`-noprompt`) into both Application and Tools `cacerts` files using `keytool`.
- 🛡️ **System-Wide CA Trust:** Copies the certificate to `/etc/pki/ca-trust/source/anchors/` and runs `update-ca-trust extract`.
- 🔄 **Optional Reboot Prompt:** Prompts whether to reboot the system after applying trust changes.
- ⚙️ **Environment File Support:** Loads paths, server hostname, alias, and keystore password from `.env`.

---

## 📂 Directory Structure

```
FortifySCASSLConfig/                            
|   └── fortify_sca_ssl_config.sh       # Main Fortify SCA SSL configuration script
└───────────────────────────────────────
```

---

## 📋 Prerequisites

- 🐧 **OS:** RHEL-based Linux distribution using `update-ca-trust` (e.g., RHEL 8/9, Rocky Linux, AlmaLinux, CentOS Stream)
- 🔐 **Privileges:** `root` or `sudo` permissions (required to modify `/etc/pki/ca-trust/source/anchors/`, update `cacerts`, and optionally `reboot`)
- 🔑 **SSH Access:** `scp` connectivity as `root` to the Fortify SSC server (`$FORTIFY_SSC_SERVER_HOSTNAME`)
- ☕ **Java & Fortify Installed:** `keytool` available in `PATH`, and Fortify SCA / OpenText AST Application & Tools already installed with their bundled JRE (`jre/lib/security/cacerts`)

---

## ⚙️ Configuration (`.env`)

Create a `.env` file in the **current working directory** with the following variables:

The values are at the discretion of each user.

```env
# Fortify SSC Server & Certificate Settings
FORTIFY_SSC_SERVER_HOSTNAME=
FORTIFY_SSC_CERTIFICATES_DIR=
FORTIFY_SSC_CERTIFICATE_FILE=
FORTIFY_SSC_CERTIFICATE_ALIAS=
CACERTS_PASSWORD=

# Base directories for Fortify SCA versions 23.2, 24.2, and 24.4
FORTIFY_SCA_APPLICATION_KEYSTORE_BASE_DIR=/
FORTIFY_SCA_TOOLS_KEYSTORE_BASE_DIR=

# Base directories for OpenText Application Security Testing versions 25.2, 25.4, and 26.2
OT_APPLICATION_SECURITY_TESTING_KEYSTORE_BASE_DIR=
OT_APPLICATION_SECURITY_TOOLS_KEYSTORE_BASE_DIR=
```

> ⚠️ **Important:** `FORTIFY_SSC_CERTIFICATE_FILE` is used both as the **remote path on the SSC server** in `scp` and as the **local path** in `keytool -importcert` and `cp`. Ensure the certificate exists at the exact same path inside `$FORTIFY_SSC_CERTIFICATES_DIR` (or that the local and remote paths match).

---

## 🗂️ Supported Versions & Resolved Keystore Paths

| Version Entered | Base Variables Used | Resolved Keystore Path |
| :--- | :--- | :--- |
| `23.2`, `24.2`, `24.4` | `FORTIFY_SCA_APPLICATION_KEYSTORE_BASE_DIR`<br>`FORTIFY_SCA_TOOLS_KEYSTORE_BASE_DIR` | `<BASE_DIR>/<version>/jre/lib/security/cacerts` |
| `25.2`, `25.4`, `26.2` | `OT_APPLICATION_SECURITY_TESTING_KEYSTORE_BASE_DIR`<br>`OT_APPLICATION_SECURITY_TOOLS_KEYSTORE_BASE_DIR` | `<BASE_DIR>/<version>/jre/lib/security/cacerts` |

---

## 🚀 Usage

1. Make sure `.env` is configured in the current directory.
2. Grant execute permission to the script:
   ```bash
   chmod +x apply_ssc_ssl.sh
   ```
3. Run the script with elevated privileges:
   ```bash
   sudo ./apply_ssc_ssl.sh
   ```
4. Enter the Fortify SCA / OpenText AST version when prompted (e.g., `24.4` or `25.4`).
5. Choose whether to reboot (`y/N`) once execution finishes.
6. Verify the certificate was imported:
   ```bash
   keytool -list -keystore <KEYSTORE_PATH> -alias "$FORTIFY_SSC_CERTIFICATE_ALIAS" -storepass "$CACERTS_PASSWORD"
   ```

---

## 🔄 How It Works

1. **Load `.env`:** Exports environment variables from `.env` if present.
2. **Prompt Version:** Requests the target Fortify SCA / OpenText AST version and exits (`exit 1`) if empty.
3. **Resolve Keystore Paths:** Builds the full `cacerts` paths for both Application and Tools based on the entered version.
4. **Check Existing Alias:** Temporarily disables `set -e`, runs `keytool -list` on both keystores, and re-enables `set -e`:
   - If the alias and `$FORTIFY_SSC_CERTIFICATES_DIR` are already detected, prints a confirmation message and exits (`exit 0`).
   - Otherwise:
     1. **Step 1:** Creates `$FORTIFY_SSC_CERTIFICATES_DIR` and pulls `$FORTIFY_SSC_CERTIFICATE_FILE` from `root@$FORTIFY_SSC_SERVER_HOSTNAME` via `scp`.
     2. **Step 2:** Imports the certificate into both Application and Tools `cacerts` keystores with `keytool -importcert`.
     3. **Step 3:** Copies the certificate to `/etc/pki/ca-trust/source/anchors/` and runs `update-ca-trust extract`.
5. **Reboot Prompt:** Prompts `(y/N)` to reboot the host or completes cleanly.

---

## 📌 Important Notes

- 🔍 **Conditional Check Detail:** In the `if` condition verifying existing aliases, `echo "$CHECK_SCA_TOOLS_ALIAS_OUTPUT" | grep -q "Alias name:" | [[ -d "$FORTIFY_SSC_CERTIFICATES_DIR" ]]` uses a pipe (`|`) instead of `&&` before `[[ -d ... ]]`. Because a pipe ignores the exit code of `grep` without `pipefail`, if the Application alias and local certificate directory already exist, the script may treat the check as satisfied even if the Tools keystore is missing the alias. Replacing that `|` with `&&` ensures all three conditions are strictly verified.
- ⚠️ **Supported Versions:** Only `23.2`, `24.2`, `24.4`, `25.2`, `25.4`, and `26.2` are currently matched in the version conditional block.
- 🔒 **Security Tip:** Keep `.env` protected (`chmod 600 .env`) and exclude it from version control (`.gitignore`) since it stores `CACERTS_PASSWORD`.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
