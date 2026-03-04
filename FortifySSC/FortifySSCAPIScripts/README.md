# 🔌 Fortify SSC API scripts

A centralized collection of automation scripts for interacting with Fortify Software Security Center (SSC) via the REST API. This repository contains operational, administrative, and DevSecOps automation utilities designed for enterprise environments.

---

## 📦 Purpose

The goal of this project is to:

* 🔑 Automate SSC authentication workflows.
* 📦 Upload and manage rulepacks with the API.
* 📊 Interact with applications and versions.
* 📁 Handle FPR uploads.
* 🔄 Integrate SSC into CI/CD pipelines.
* 🛠 Provide reusable API utilities for DevOps and CyberSecurity teams.

---

## 📂 Directory Structure

```
FortifySSCAPIScripts/
├── UploadFortifyRulepacks/                                          # Directory of the script of Upload Fortify Rulepacks.
│   ├── upload_fortify_rulepacks.py                                  # Script to upload fortify rulepacks to Fortify SSC.
│   ├── .env                                                         # Environment variables file used by the upload fortify rulepacks script.                         
│   └── logs/                                                        # Logs directory.
│        └── uploaded_ssc_rulepacks.log                              # Logs file of the upload fortify rulepacks script.
│
└──────────────────────────────────────────────────────────────────
```

📂 Each subdirectory contains:

* 🐍 Python or 💻 Bash Script(s).
* ⚙️ Local .env configuration.
* 📝 Logging (if applicable).
* 📤 Output csv (if applicable).

---

## 🛠 Requirements

* 🐍 Python 3.8+.
* 📨 Requests.
* 🐍 python-dotenv library.
* 🌐 Network access to SSC.
* 🔑 Valid SSC credentials.

Install common dependencies:

```bash
pip install requests python-dotenv
```

---

## 🚀 Usage Overview

Most scripts follow this flow:

1. 🔑 Create authentication token (if applicable).
2. 🌐 Perform API requests (GET, POST, PUT, DELETE, etc).
3. 📝 Log results.
4. 📄 Output csv file.
4. 🗑 Delete authentication token (if applicable).

---

## 🧠 Design Principles

* Minimal external dependencies.
* Clear logging.
* Explicit error handling.
* Output files if needed.
* Clean token lifecycle management.
* Environment-based configuration.

---

## 📝 Notes

* ❌ Do not commit .env files.
* 🔐 Use a service user instead of the default admin user (except for the upload rulepacks script).
* 🔄 Use UnifiedLoginToken tokens regularly.
* 🧾 Restrict filesystem permissions on log files.
* 🔑 Limit token lifetime when possible (possible with UnifiedLoginToken token type).

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
