# 🧰 Linux Dev Tools Installer

An all-in-one Bash provisioning script that installs and configures **compilers, programming languages, databases, build tools, mobile SDKs, 
containerization, and frameworks** on `x86_64` RHEL-based Linux systems.

---

## ✨ What Gets Installed

### 🔧 System & Core Build Tools
- 🔄 **System Package Update** (`dnf update -y`)
- 🛠️ **Development Tools Group** (`gcc`, `g++`, `make`, etc.)

### 💻 Programming Languages & Runtimes
| Category | Tools / Versions |
| :--- | :--- |
| 🐍 **Python** | `python3`, `python3-pip`, `python3-devel` |
| 💎 **Ruby** | `ruby`, `ruby-devel` |
| 🐘 **PHP** | `php` |
| 🐹 **Go** | `golang` |
| 🐪 **Perl** | `perl` |
| 🦀 **Rust** | `rust`, `cargo` |
| 🌙 **Lua** | `lua` |
| 🟢 **Node.js & NPM** | Node.js `22.x` (NodeSource) & `npm@12.0.2` |
| 🔴 **Scala** | Coursier (`cs` in `/opt/scala`) |
| ⭐ **Groovy** | Latest Apache Groovy binary (`/opt/groovy`, added to `/etc/profile.d/groovy.sh`) |
| 🏛️ **COBOL** | Latest GnuCOBOL built from source (`/opt/cobol` $\rightarrow$ `/usr/local`) with `gmp-devel` & `libdb-devel` |
| 🟣 **C# / .NET** | `.NET SDK 8.0` (`dotnet-sdk-8.0`, MSBuild) & `mono-complete` |
| 🎯 **Dart** | *(Currently commented out in the script)* |

### 🗄️ Databases & Services
- 📦 **SQLite:** `sqlite`, `sqlite-devel`
- 🐘 **PostgreSQL:** `postgresql`, `postgresql-server` (auto-initialized via `postgresql-setup --initdb`, enabled & started)
- 🐬 **MySQL:** `mysql`, `mysql-server` (enabled & started via `mysqld`)
- 🍃 **MongoDB 7.0:** `mongodb-org` (repo configured, enabled & started via `mongod`)

### 📱 Mobile Development (Android)
- 🤖 **Android SDK Command-Line Tools:** Dynamically fetches the latest build ID (fallback: `11076708`), installed in `/opt/android-sdk`
- 🖥️ **Android CLI:** Installed via Google's `install_root.sh`
- 📦 **SDK Components:** `platform-tools`, `build-tools;34.0.0`, and `platforms;android-34`
- 🌐 **Environment Variables:** Configured system-wide in `/etc/profile.d/android.sh` (`ANDROID_HOME`, `ANDROID_SDK_ROOT`, `PATH`)

### 🐳 DevOps & Infrastructure
- 🏗️ **Terraform:** Installed via official HashiCorp RHEL repository
- 🐳 **Docker CE:** `docker-ce`, `docker-ce-cli`, `containerd.io` (enabled & started via `systemd`)

### 🏗️ Build Tools & Frameworks
- ☕ **JVM Build Tools:** Apache Maven (`maven`), Gradle (latest release in `/opt/gradle`), Apache Ant (`ant`)
- 🐍 **Python Tools:** `poetry`, `django`
- 🌐 **JavaScript Frameworks (Global NPM):** `@vue/cli`, `create-next-app` (React/Next.js), `@angular/cli`
- 💎 **Ruby Tools:** `bundler`, `rake`

---

## 📋 Prerequisites

Before running the script, ensure your environment meets these requirements:

- 🐧 **OS:** `x86_64` RHEL-based Linux distribution using `dnf` (e.g., RHEL 8/9, Rocky Linux, AlmaLinux, CentOS Stream)
- 🔐 **Privileges:** Run as `root` or with `sudo` (writes to `/etc/yum.repos.d/`, `/etc/profile.d/`, `/opt/`, `/usr/local/`, and manages `systemd` services)
- 🌐 **Network:** Active internet connection to reach DNF repos, GitHub, Google Android servers, Apache, GNU FTP, HashiCorp, Docker, and NPM/PyPI/RubyGems
- ⚙️ **Init System:** `systemd` running (required for `systemctl enable --now` on PostgreSQL, MySQL, MongoDB, and Docker)
- 🧰 **Helper Utilities:** Ensure `curl`, `wget`, `unzip`, `tar`, `gzip`, `jq`, and `dnf-plugins-core` (`dnf config-manager`) are available on the system

---

## 🚀 Usage

1. Make the script executable:
   ```bash
   chmod +x dev_tools_installer.sh
   ```
2. Run the script with root privileges:
   ```bash
   sudo ./dev_tools_installer.sh
   ```
3. Reload your shell environment so newly added `PATH` entries (Android SDK, Groovy, etc.) take effect:
   ```bash
   source /etc/profile
   ```

---

## 🔍 Verification Output

Throughout execution, the script automatically verifies and prints installed versions for:
- C/C++ (`gcc`, `g++`)
- Languages & Runtimes (`python3`, `pip3`, `ruby`, `php`, `go`, `perl`, `rustc`, `cargo`, `lua`, `node`, `npm`, `groovy`, `cobc`, `dotnet`, `mono`, `mcs`)
- Databases (`sqlite3`, `mysql`, `mongod`, `psql`)
- Mobile & DevOps (`sdkmanager`, `android`, `adb`, `terraform`, `docker`)
- Build Tools & Frameworks (`mvn`, `gradle`, `ant`, `poetry`, `django-admin`, `vue`, `create-next-app`, `ng`, `bundler`, `rake`, `dotnet msbuild`)

---

## 📌 Notes & Caveats

- 🛡️ **Fail-Fast Execution:** The script uses `set -e`, meaning it stops immediately if any package download, compilation, or service startup fails.
- ⏱️ **Execution Time:** Compiling **GnuCOBOL** from source and installing full language/framework toolchains can take several minutes depending on CPU and network speed.
- 🔐 **Database Security:** `postgresql`, `mysqld`, and `mongod` are installed and started with default configurations—remember to secure them (passwords, bind addresses, firewall rules) before exposing the machine to a network.
- 🔄 **Mono GPG Check:** `mono-complete` is installed with `--nogpgcheck` from the `centos8-stable` repository.
- 🎯 **Optional Dart Section:** A commented-out Dart SDK installation block is included in the script if you wish to enable it later.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
