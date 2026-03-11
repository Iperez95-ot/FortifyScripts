# 📚 AddLDAPEntities (Fortify SSC LDAP Entity Importer)

This Python automation script that **imports LDAP Users and Groups** from eDirectory into Fortify Software Security Center (SSC) using the **Fortify SSC REST API (v1)**.

---

## 📌 What This Script Does?

```makefile
flow:
	create-token -> add-ldap-entites -> delete-token
```

The script performs the following operations:

1. 🔐 Creates a temporary `UnifiedLoginToken`.
2. 📥 Parses LDAP users and groups from input files.
3. 🧑‍💻 Creates the corresponding LDAP entities in Fortify SSC.
4. 🧾 Logs all operations.
5. 🧹 Deletes the temporary token after execution.

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
pip install requests python-dotenv termcolor urllib3
```

---

## 📄 .env file used to run the AddLDAPEntities script (generic example)

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
 cd AddLDAPEntities
 chmod +x AddLDAPEntities.py
./AddLDAPEntities.py
```

---

## 🚦 HTTP Status Handling

```makefile
201:
	✅ Token successfully created/Addition of the LDAP Entity

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

- 1️⃣ Creates a temporary UnifiedLoginToken.
- 2️⃣ Uses the token to authenticate the API request.
- 3️⃣ Deletes the token immediately after execution.

This ensures a clean and secure SSC environment.

---

## 📝 Notes regarding the script functionality 

* 🔐 Token-based auth only.
* 🧹 Tokens are always deleted after usage.
* 📜 Full audit logs per action.
