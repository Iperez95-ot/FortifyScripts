# 📦 Upload Fortify SSC Rulepacks API Script

This Python script uploads **Core Rulepacks (.zip)** to OpenText Application Security (Fortify Software Security Center (SSC)) using the **SSC REST API (v1)**.

---

## 📌 What This Script Does?

```makefile
flow:
	create-token -> upload-rulepacks -> delete-token
```

The script performs the following operations:

1. 🔐 Creates a temporary `UnifiedLoginToken`.
2. 📡 Uploads all `.zip` rulepacks found in the configured directory.
3. ⏳ Waits between uploads to avoid SSC background overload.
4. 🗑 Deletes the temporary token after execution.
5. 📝 Logs the script execution to a log file.

---

## ⚙️ Requirements

- 🐍 Python 3.8+
- 📡 `requests`
- 📦 `python-dotenv`
- 🎨 `termcolor`
- 🔐 Access to Fortify SSC Admin user
- 🌐 Network connectivity to SSC API

### 📦 Python Dependencies:

```bash
pip install requests python-dotenv termcolor
```

---

## 📄 .env file used to run the UploadFortifyRulepacks script (generic example)

The values are at the discretion of each user.

```makefile
CURRENT_FORTIFY_SSC_VERSION=                    # Current Fortify SSC version in use
FORTIFY_SSC_DEFAULT_ADMIN_USER=                 # Fortify SSC admin username
FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD=        # Fortify SSC admin password
FORTIFY_SSC_API_URL=                            # Base URL for Fortify SSC REST API
OUTPUT_LOG_FILE=                                # Full path to the log file where execution details will be written
FORTIFY_SSC_APPS_FILES_PATH=                    # Base directory containing Fortify SSC Application binary files 
```

---

## ▶️ Usage

```bash
 cd UploadFortifyRulepacks
 chmod +x UploadFortifyRulepacks.py
./UploadFortifyRulepacks.py
```

---

## 🚦 HTTP Status Handling

```makefile
201:
	✅ Token successfully created

200:
	✅ Rulepack successfully uploaded/Token successfully deleted

401 / 403:
	⛔ Authentication or permission error

5xx:
	⚠️ SSC API unavailable
```

On critical failures, the script **exits immediately** to avoid partial or inconsistent states.
For more information regarding the http requests see Fortify SSC API Swagger Documentation for each API endpoint.

---

## 📝 Notes regarding the script functionality 

* 🔐 Token-based auth only.
* 🧹 Tokens are always deleted after usage.
* 📜 Full audit logs per action.
