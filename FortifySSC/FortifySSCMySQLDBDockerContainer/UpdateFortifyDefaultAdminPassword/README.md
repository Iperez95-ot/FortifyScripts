# 📦 UpdateFortifyDefaultAdminPassword (Fortify SSC Default Admin Password Updater)

This bash script updates the default **admin** user password and restores account access for OpenText Application Security (**Fortify Software Security Center (SSC)**) directly inside the **MySQL Database** Docker container.

---

## 📌 What This Script Does?

```makefile
flow:
	load-env -> generate-sql -> execute-mysql-query -> verify-and-display -> cleanup-temp-file
```

The script performs the following operations:

1. ⚙️ Loads environment variables and database credentials from the `.env` file.
2. 📝 Generates a temporary SQL script (`temp_fortify_ssc_default_admin_user_password.sql`).
3. 🔐 Updates the `fortifyuser` table for the user `'admin'`:
   - Sets the bcrypt-hashed password string.
   - Clears failed login attempts (`failedLoginAttempts = 0`).
   - Unfreezes the account (`dateFrozen = NULL`).
   - Unsuspends the account (`suspended = 'N'`).
   - Bypasses forced password change on next login (`requirePasswordChange = 'N'`).
4. 🐬 Connects to MySQL via the CLI client and executes the SQL commands against `$FORTIFY_SSC_DATABASE_NAME`.
5. 📊 Queries and outputs the updated record from `fortifyuser` to confirm the changes.
6. 🧹 Deletes the temporary SQL script immediately after execution.
7. 🔑 Prints the updated plain-text password for the Fortify SSC admin user.

---

## ⚙️ Requirements

- 🐚 Bash shell (Linux / macOS / WSL)
- 🐬 MySQL client (`mysql` CLI) installed
- 🐳 Access to the MySQL instance or Docker container hosting the Fortify SSC database
- 🔐 MySQL root/admin user credentials with read/write permissions
- 🌐 Network connectivity to the MySQL host and port

---

## 📄 .env file used to run the UpdateFortifyDefaultAdminPassword script (generic example)

The values are at the discretion of each user.

```makefile
MYSQL_HOST=                                     # Hostname of the host machine running the MySQL Docker Container
MYSQL_PORT=                                     # Port of the MySQL Docker Container (e.g., 3306)
MYSQL_IMAGE_NAME=                               # MySQL Docker Image name (e.g., mysql)
MYSQL_IMAGE_TAG=                                # MySQL Docker Image tag (e.g., 8.0)
MYSQL_CONTAINER_NAME=                           # MySQL Docker Container name (e.g., fortify_ssc_mysql_database)
MYSQL_USER=                                     # MySQL User to log into the MySQL Docker Container (e.g., root)
MYSQL_ROOT_PASSWORD=                            # MySQL Root Password
FORTIFY_SSC_DATABASE_NAME=                      # Fortify SSC Database Name (e.g., fortify_ssc_db)
FORTIFY_SSC_ADMIN_PASSWORD=                     # Fortify SSC Default Admin Password (plain text)
```

---

## ▶️ Usage

```bash
cd UpdateFortifyDefaultAdminPassword
chmod +x UpdateFortifyDefaultAdminPassword.sh
./UpdateFortifyDefaultAdminPassword.sh
```

---

## 🚦 Execution & Error Handling

```makefile
exit 0:
	✅ Password and account state updated successfully

Non-zero exit (set -e):
	⛔ Execution halted immediately due to an error

MySQL Error 2003 / 2005:
	⚠️ Host unreachable or unknown MySQL server host

MySQL Error 1045:
	⛔ Access denied (invalid username or password)

MySQL Error 1049:
	⚠️ Unknown database name ($FORTIFY_SSC_DATABASE_NAME)
```

On any failure, the script **exits immediately** (`set -e`) to prevent partial or inconsistent states.

---

## 🛡️ Account State & Security Reset

To recover administrative access and resolve account lockouts in Fortify SSC, the script automatically applies:

- 1️⃣ **Password Hash**: Inserts the pre-computed bcrypt hash corresponding to `$FORTIFY_SSC_ADMIN_PASSWORD`.
- 2️⃣ **Failed Attempts Reset**: Resets `failedLoginAttempts` back to `0`.
- 3️⃣ **Freeze Removal**: Clears `dateFrozen` to `NULL`.
- 4️⃣ **Suspension Lift**: Changes `suspended` status to `'N'`.
- 5️⃣ **Password Expiry Bypass**: Sets `requirePasswordChange` to `'N'` to allow immediate login.

---

## 🧹 Temporary File Cleanup

To protect sensitive database queries and prevent credential clutter:

- 1️⃣ Generates the temporary file `temp_fortify_ssc_default_admin_user_password.sql` during runtime.
- 2️⃣ Executes the SQL commands through the MySQL client.
- 3️⃣ Removes `temp_fortify_ssc_default_admin_user_password.sql` immediately after execution.

---

## 📝 Notes regarding the script functionality

* 🔐 **Direct Database Update**: Directly modifies the `fortifyuser` table in the database, requiring no active SSC web session or API tokens.
* 🔓 **Administrative Recovery**: Ideal for break-glass scenarios when the admin account is locked, suspended, or password is forgotten.
* 🧹 **Clean Execution**: Temporary SQL files containing database commands are deleted upon completion.
* 💾 **Backup Recommendation**: Always take a snapshot or backup of the database before applying direct SQL modifications.
