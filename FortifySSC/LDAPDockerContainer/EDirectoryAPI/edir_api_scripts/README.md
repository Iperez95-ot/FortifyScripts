# 🌐 eDirectory API Scripts

A collection of scripts that interacts with the **NetIQ eDirectory API** for automation, administration, and reporting.

These scripts are designed for DevOps / Security / Platform teams who want to **automate eDirectory operations** using API calls in a repeatable and configurable way.

---

## ⚙️ Purpose

This directory contains **only scripts that work directly with the eDirectory API**, including:

* 🔐 Authentication & token handling.
* 👥 User and group management.

❗ Scripts unrelated to the eDirectory API should live **outside** this directory.

---

## 🧰 Requirements

Before running any script, make sure you have:

* 🐍 **Python 3.8+** (unless otherwise stated).
* 📦 Required Python libraries (see each script or `requirements.txt` if it is present).
* 🌐 Network access to the eDirectory API Swagger and eDirectory API endpoint.

---

## 🔐 Environment Configuration

All of the scripts rely on environment variables loaded from a `.env` file. Just make sure those are properly configured before running any script.

---

## ▶️ Usage 

Each script can be executed directly or via a Makefile-style workflow.

```bash
cd script_directory
chmod +x script_name.py
./script_name.py
```

---

## 📜 Script Structure (Typical)

```makefile
imports:
	- requests
	- os
	- csv / json
	- dotenv
flow:
	load-env -> authenticate -> read input files -> api-call -> process-data -> create output files
```

Most scripts follow this pattern:

1. 📥 Load environment variables.
2. 🔑 Authenticate against eDirectory API.
3. 🔄 Perform API operations.
4. 🧠 Process responses.
5. 📤 Export results (CSV / JSON / TXT / logs).

---

## 📁 Output

Generated files are usually stored under:

```makefile
  output/
  | ├── csvfile
  | ├── txtfile
  | └── jsonfile
  |      
  logs/
    └── logfile

```

File formats may include:

* 📄 CSV
* 📦 JSON
* 🧾 TXT / LOG

---

## 🧪 Error Handling & Logging

Scripts typically include:

* 🚦 HTTP status code validation
* 🔁 Retry logic (when applicable)
* 🧾 Colored or structured logs

```makefile
logs:
	INFO  -> normal execution
	WARN  -> recoverable issues
	ERROR -> execution failure
```

---

👉 Always verify:

* API URL.
* Token validity.
* Network connectivity.
* API permissions.

---

## 🧹 Maintenance Tips

* ✅ Use `.env` for configuration.
* 🔄 Keep scripts idempotent.
* 🧹 Clean output directories regularly.
* 📝 Log everything that matters.

---

## 🧾 License

This project is part of the 💻 FortifyScripts Utilities suite. 
Use according to your organization’s internal deployment and licensing guidelines.
