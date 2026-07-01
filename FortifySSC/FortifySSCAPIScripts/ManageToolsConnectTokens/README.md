# 🔐 ManageFortifyToolsToken (Fortify SSC User Tokens Manager)

## 📖 Overview

This Python script creates or updates a **Fortify Software Security Center (SSC)** token of the type **ToolsConnectToken** for the user entered 
using the **Fortify SSC REST API (v1)**.

---

## 📌 What This Script Does?

```makefile
flow:
	ask-user-name-passord -> check-token-existance -> create-token|update-token -> upload-rulepacks -> delete-token
```
---

The script performs the following actions:

- 👤 Prompts the user for their Fortify SSC username and password.
- 🔍 Checks whether a valid `ToolsConnectToken` already exists.
- ➕ Creates a new token if none exists.
- ♻️ Creates a new token if the existing one has expired.
- ⏳ Extends the expiration date by **90 days** if the existing token is still valid.
- 📝 Logs all operations to a configurable log file.
- 🌐 Uses the Fortify SSC REST API.
- ⚙️ Reads configuration from a `.env` file.

---

## ⚙️ Requirements

- 🐍 Python 3.8+
- 📡 `requests`
- 📦 `python-dotenv`
- 🎨 `termcolor`
- 🔐 Access to a Fortify SSC server
- 👤 A Fortify SSC user with permission to create personal tokens
- 🌐 Network connectivity to SSC API

---

## 📦 Python Packages

Install the required dependencies:

```bash
pip install requests python-dotenv termcolor
```

---

## 📄 .env file used to run the ManageToolsConnectTokens script (generic example)

The values are at the discretion of each user.

```makefile
FORTIFY_SSC_API_URL=""     # Base URL for Fortify SSC REST API 
OUTPUT_LOG_FILE_PATH=""    # Full path to the log file where execution details will be written
```

> 💡 **Note:** The username and password are **not** stored in the `.env` file. They are requested interactively when the script starts.

---

# ▶️ Usage

Run the script:

```bash
cd ManageFortifyToolsToken
chmod +x ManageFortifyToolsToken.py
python3 ManageFortifyToolsToken.py
```

The script will prompt for:

```text
Enter your username (Employee ID/U user):

Enter your user password:
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

# ⏳ Token Lifetime

- 🆕 New tokens are created with an expiration date of **90 days**.
- ♻️ Existing valid tokens automatically have their expiration date extended by another **90 days**.

---

# 📝 Notes

- ⚠️ SSL certificate verification is currently disabled (`verify=False`) to simplify connections to environments using self-signed certificates.
- 🔐 The script manages only **ToolsConnectToken** tokens.
- 👤 Existing tokens are identified by **username** and **token type**.
- 🆕 If multiple matching tokens exist, the **newest token** is selected.
