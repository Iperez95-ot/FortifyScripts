# 🛡️ UpdateFortifySSCRulepacks (Fortify SSC Rulepacks Updater)

A Python automation script that updates **Fortify Rulepacks** on **Fortify Software Security Center (SSC)**  using the **Fortify SSC REST API (v1)**. 
It creates a temporary `UnifiedLoginToken`, triggers the Rulepacks update endpoint, logs all activity, and deletes the temporary token upon completion.

---

## 📌 What This Script Does?

```makefile
flow:
	create-token -> update-rulepacks-from-ssc -> delete-token
```

The script performs the following operations:

1. 🔑 **Temporary Token Lifecycle:** Creates a `UnifiedLoginToken` for the session and automatically deletes it (`DELETE /tokens/{id}`) when finished.
2. 🔄 **Automated Rulepack Update:** Calls the SSC `GET /updateRulepacks` endpoint with a 15-minute timeout (`900s`) to handle large downloads/updates.
3. 📝 **Dual Output (Console + Log File):** Prints color-coded terminal output (`termcolor`) while writing timestamped `INFO`/`ERROR` logs to `OUTPUT_LOG_FILE`.
4. 📁 **Auto Log Directory Creation:** Automatically creates the parent directory of `OUTPUT_LOG_FILE` if it does not exist.
5. 🔓 **Self-Signed SSL Support:** Disables SSL certificate verification (`verify=False`) and suppresses `InsecureRequestWarning` for internal SSC instances.
6. ⚙️ **Environment File Support:** Loads credentials, API URL, and log path securely from `.env` via `python-dotenv`.

---

## ⚙️ Requirements

- 🐍 **Python:** Python **3.x**
- 🌐 **Network & Access:** Connectivity to your Fortify SSC server and an SSC admin account permitted to create/delete tokens and update Rulepacks
- 📦 **Python Packages:**
  - `requests`
  - `python-dotenv`
  - `termcolor`
  - `urllib3` *(installed automatically as a dependency of `requests`)*

Install the required Python packages with:

```bash
pip install requests python-dotenv termcolor
```

---

## 📄 .env file used to run the UploadFortifyRulepacks script (generic example)

Creates a `.env` file in the **same directory** where you run the script:

The values are at the discretion of each user.

```makefile
FORTIFY_SSC_DEFAULT_ADMIN_USER=            # Fortify SSC local Admin user (used for HTTP Basic Auth on token creation/deletion)
FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD=   # Fortify SSC local Admin password (used for HTTP Basic Auth on token creation/deletion)
FORTIFY_SSC_API_URL=                       # Fortify SSC REST API v1 Base URL (no trailing slash)
OUTPUT_LOG_FILE=                           # Output log file path (required; parent directory will be created if missing)
```

> ⚠️ **Important:** `FORTIFY_SSC_API_URL` should point to `/ssc/api/v1` without a trailing slash (the script appends `/tokens` and `/updateRulepacks`), and `OUTPUT_LOG_FILE` must be defined.

---

## v Usage

1. Install dependencies and configure `.env`.
2. Make the script executable (optional):
   ```bash
   chmod +x UpdateFortifySSCRulepacks.py
   ```
3. Run the script:
   ```bash
   python3 UpdateFortifySSCRulepacks.py
   ```
   *(Or `./UpdateFortifySSCRulepacks.py` if executable. Use `sudo` if `OUTPUT_LOG_FILE` points to a root-owned path like `/var/log/`.)*

### 🕒 Optional: Automate with Cron

To schedule automatic Rulepack updates (e.g., weekly on Sunday at 02:00 AM):

```cron
0 2 * * 0 cd /path/to/script && /usr/bin/python3 update_ssc_rulepacks.py
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

## 🧹 Token Lifecycle Management

To prevent token accumulation in Fortify SSC, the script automatically:

- 1️⃣ Creates a temporary UnifiedLoginToken.
- 2️⃣ Uses the token to authenticate the API request.
- 3️⃣ Deletes the token immediately after execution.

This ensures a clean and secure SSC environment.

---

## 📝 Notes regarding the script functionality 

- 🔓 **SSL Verification Disabled:** All requests use `verify=False`. If your SSC server uses a trusted CA certificate in production, consider setting `verify=True` (or pointing `verify` to your CA bundle).
- 🔐 **Protect Credentials:** Because `.env` contains admin credentials and the token response is written to `OUTPUT_LOG_FILE`, restrict permissions on both files (`chmod 600 .env`) and exclude them from version control.
- ⏱️ **Request Timeout:** Each API call uses `timeout=900` (15 minutes) so long-running Rulepack updates do not time out prematurely.
