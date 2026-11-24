# ☕ Java OpenJDK (17 & 21) Installers

A pair of Bash scripts that automate installing **Java OpenJDK 17** or **Java OpenJDK 21** (runtime + development kit) and 
configuring the system-wide `JAVA_HOME` environment variable on RHEL-based Linux systems.

---

## 📂 Scripts Included

| Script | Target Version | Packages Installed | Sets `alternatives` Default? | Sets `JAVA_HOME`? |
| :--- | :--- | :--- | :--- | :--- |
| `install_java17.sh` *(OpenJDK 17)* | **Java 17** | `java-17-openjdk`, `java-17-openjdk-devel` | ❌ No (uses system default) | ✅ Yes (`/etc/environment`) |
| `install_java21.sh` *(OpenJDK 21)* | **Java 21** | `java-21-openjdk`, `java-21-openjdk-devel` | ✅ Yes (`java` & `javac`) | ✅ Yes (`/etc/environment`) |

---

## ✨ Features

- 🔍 **Active Version Detection:** Checks the current Java major version via `java -version` before making changes.
- ⚡ **Idempotent Execution:** Exits cleanly (`exit 0`) if the target Java version (`17` or `21`) is already active.
- 🔄 **System Update & Package Install:** Runs `dnf update -y` and installs both the OpenJDK runtime and `-devel` packages.
- 🔀 **Default Java Switching (Java 21 script):** Locates the OpenJDK 21 installation under `/usr/lib/jvm` and sets both `java` and `javac` as the system default using `alternatives --set`.
- 🌐 **System-Wide `JAVA_HOME`:** Resolves the active Java installation path via `readlink -f`, removes stale `JAVA_HOME` entries from `/etc/environment`, and writes the updated `JAVA_HOME`.
- 🎨 **Color-Coded Terminal Output:** Uses ANSI colors (`CYAN`, `YELLOW`, `GREEN`, `RED`) for readable progress and status feedback.
- 🛡️ **Fail-Fast Safety:** Enabled with `set -e` to halt immediately on any command failure.

---

## 📋 Prerequisites

Before running either script, ensure the system meets these requirements:

- 🐧 **OS:** RHEL-based Linux distribution using `dnf` (e.g., RHEL 8/9, Rocky Linux, AlmaLinux, CentOS Stream)
- 🔐 **Privileges:** `root` or `sudo` permissions (required for `dnf`, writing to `/etc/environment`, and running `alternatives`)
- 🌐 **Network:** Internet access to reach configured DNF repositories
- 🧰 **Utilities:** Standard GNU/Linux tools (`awk`, `sed`, `readlink`, `dirname`, `tee`, plus `find` and `alternatives` for Java 21)

---

## 🚀 Usage

1. Grant execute permissions to the script you want to run:
   ```bash
   chmod +x java_17_installer.sh java_21_installer.sh
   ```
2. Run the desired installer with elevated privileges:
   ```bash
   # To install Java OpenJDK 17
   sudo ./java_17_installer.sh

   # OR to install Java OpenJDK 21
   sudo ./java_21_installer.sh
   ```
3. Reload `/etc/environment` in your current shell (or start a new login session) so `JAVA_HOME` is available:
   ```bash
   source /etc/environment
   ```
4. Verify the installation:
   ```bash
   java -version
   javac -version
   echo "$JAVA_HOME"
   ```
   
---

## 🔄 How They Work

1. **Check Current Java Version:** Extracts the installed Java major version from `java -version`.
2. **Skip if Already Active:** If the active version matches the script's target (`17` or `21`), prints a confirmation message and exits.
3. **Update & Install Packages:** Runs `dnf update -y` and installs the corresponding `java-<version>-openjdk` and `java-<version>-openjdk-devel` packages.
4. **Configure `alternatives` *(Java 21 only)*:** Finds `/usr/lib/jvm/java-21-openjdk*` and sets `java` and `javac` via `alternatives --set`.
5. **Verify Binary:** Runs `java -version` to display the active version.
6. **Configure `JAVA_HOME`:**
   - Resolves the real installation directory from `$(which java)`
   - Removes existing `JAVA_HOME=` and `PATH=...JAVA_HOME` lines from `/etc/environment`
   - Appends `JAVA_HOME=<resolved-path>` to `/etc/environment` and exports it

---

## 📌 Important Notes

- 🔀 **Switching Between Versions:** Because the **Java 17** script does not call `alternatives --set`, if another Java version (such as Java 11 or 21) is already installed as the system default, run `sudo alternatives --config java` and `sudo alternatives --config javac` after running it so `which java` and `JAVA_HOME` point to Java 17.
- 🖥️ **Shell Environment:** Updates to `/etc/environment` take effect automatically in new login sessions; run `source /etc/environment` in already-open terminals.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
