# 🔐 CreateLDAPServerConfig (Fortify SSC LDAP Server Configuration Creator)

This python script creates an **LDAP Server Configurations in Fortify Software Security Center (SSC)** using the **Fortify SSC REST API (v1)**.

---

## 📌 What This Script Does?

```makefile
flow:
	create-token -> create-ldap-server-config -> delete-token
```

The script performs the following operations:

✨ Automatic **Fortify SSC token creation**.
🔐 Secure **API authentication using UnifiedLoginToken**. 
📡 **LDAP Server configuration creation** via REST API.  
🧹 Automatic **token cleanup after execution**.  
📄 **JSON-based configuration input**. 
📝 **Structured logging**.  
🎨 **Colored terminal output** for better readability  
⚠️ **Error handling for API failures**.

---

## ⚙️ Requirements

- 🐍 Python 3.8+
- 📡 `requests`
- 📦 `python-dotenv`
- 🎨 `termcolor`
- 📚 `urllib3`
- 🔐 Access to Fortify SSC Admin user
- 🌐 Network connectivity to SSC API

### 📦 Python Dependencies:

```bash
pip install requests python-dotenv termcolor
```

---

## 📄 .env file used to run the CreateLDAPServerConfig script (generic example)

The values are at the discretion of each user.

```makefile
FORTIFY_SSC_DEFAULT_ADMIN_USER=               # Fortify SSC Default admin user
FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD=      # Fortify SSC Default admin user password
FORTIFY_SSC_API_URL=                          # Fortify SSC API URL
OUTPUT_LOG_FILE=                              # Output log file from this script
INPUT_JSON_BODY_FILE=                         # JSON body input file from this script 
```

---

---

## ▶️ Usage

```bash
 cd CreateLDAPServerConfig
 chmod +x CreateLDAPServerConfig.py
./CreateLDAPServerConfig.py
```

---

## 🚦 HTTP Status Handling

```makefile
201:
	✅ Token successfully created/LDAP server configuration created

401 / 403:
	⛔ Authentication or permission error

5xx:
	⚠️ SSC API unavailable
```

On critical failures, the script **exits immediately** to avoid partial or inconsistent states.
For more information regarding the http requests see Fortify SSC API Swagger Documentation for each API endpoint.

---

## 🧹 Token Lifecycle Management

To prevent token accumulation in Fortify SSC, the script automatically:

1️⃣ Creates a temporary UnifiedLoginToken
2️⃣ Uses the token to authenticate the API request
3️⃣ Deletes the token immediately after execution

This ensures a clean and secure SSC environment.

---

## 📝 Notes regarding the script functionality 

* 🔐 Token-based auth only.
* 🧹 Tokens are always deleted after usage.
* 📜 Full audit logs per action.
