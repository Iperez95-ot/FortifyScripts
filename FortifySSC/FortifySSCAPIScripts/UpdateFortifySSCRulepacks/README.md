# 🛡️ Fortify SSC Rulepacks Updater (REST API)

A Python automation script that updates **Fortify Rulepacks** on **Fortify Software Security Center (SSC)** via the SSC REST API. 
It creates a temporary `UnifiedLoginToken`, triggers the Rulepacks update endpoint, logs all activity, and deletes the temporary token upon completion.

---

## ✨ Features

- 🔑 **Temporary Token Lifecycle:** Creates a `UnifiedLoginToken` for the session and automatically deletes it (`DELETE /tokens/{id}`) when finished.
- 🔄 **Automated Rulepack Update:** Calls the SSC `GET /updateRulepacks` endpoint with a 15-minute timeout (`900s`) to handle large downloads/updates.
- 📝 **Dual Output (Console + Log File):** Prints color-coded terminal output (`termcolor`) while writing timestamped `INFO`/`ERROR` logs to `OUTPUT_LOG_FILE`.
- 📁 **Auto Log Directory Creation:** Automatically creates the parent directory of `OUTPUT_LOG_FILE` if it does not exist.
- 🔓 **Self-Signed SSL Support:** Disables SSL certificate verification (`verify=False`) and suppresses `InsecureRequestWarning` for internal SSC instances.
- ⚙️ **Environment File Support:** Loads credentials, API URL, and log path securely from `.env` via `python-dotenv`.

---

## 📋 Prerequisites

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

## ⚙️ Configuration (`.env`)

Create a `.env` file in the **same directory** where you run the script:

```env
# Fortify SSC Admin Credentials (used for HTTP Basic Auth on token creation/deletion)
FORTIFY_SSC_DEFAULT_ADMIN_USER=admin
FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD=your_admin_password

# Fortify SSC REST API v1 Base URL (no trailing slash)
FORTIFY_SSC_API_URL=https://ssc.example.com/ssc/api/v1

# Output log file path (required; parent directory will be created if missing)
OUTPUT_LOG_FILE=/var/log/fortify/ssc_update_rulepacks.log
```

> ⚠️ **Important:** `FORTIFY_SSC_API_URL` should point to `/ssc/api/v1` without a trailing slash (the script appends `/tokens` and `/updateRulepacks`), and `OUTPUT_LOG_FILE` must be defined.

---

## 🚀 Usage

1. Install dependencies and configure `.env`.
2. Make the script executable (optional):
   ```bash
   chmod +x update_ssc_rulepacks.py
   ```
3. Run the script:
   ```bash
   python3 update_ssc_rulepacks.py
   ```
   *(Or `./update_ssc_rulepacks.py` if executable. Use `sudo` if `OUTPUT_LOG_FILE` points to a root-owned path like `/var/log/`.)*

### 🕒 Optional: Automate with Cron

To schedule automatic Rulepack updates (e.g., weekly on Sunday at 02:00 AM):

```cron
0 2 * * 0 cd /path/to/script && /usr/bin/python3 update_ssc_rulepacks.py
```

---

## 🔄 How It Works

1. **Initialize & Load Config:** Suppresses `InsecureRequestWarning`, loads variables from `.env`, ensures the log directory exists, and configures file logging.
2. **Create Token (`POST /tokens`):** Authenticates via HTTP Basic Auth and requests a `UnifiedLoginToken` (expects HTTP `201`). Exits with status `1` if token creation fails.
3. **Update Rulepacks (`GET /updateRulepacks`):** Switches headers to `Authorization: FortifyToken <token>` and sends the update request (expects HTTP `200`).
4. **Delete Token (`DELETE /tokens/{id}`):** Removes the `Authorization` header, restores HTTP Basic Auth, and deletes the temporary token (expects HTTP `200`).

---

## 📌 Important Notes

- 🔓 **SSL Verification Disabled:** All requests use `verify=False`. If your SSC server uses a trusted CA certificate in production, consider setting `verify=True` (or pointing `verify` to your CA bundle).
- 🔐 **Protect Credentials:** Because `.env` contains admin credentials and the token response is written to `OUTPUT_LOG_FILE`, restrict permissions on both files (`chmod 600 .env`) and exclude them from version control.
- ⏱️ **Request Timeout:** Each API call uses `timeout=900` (15 minutes) so long-running Rulepack updates do not time out prematurely.
