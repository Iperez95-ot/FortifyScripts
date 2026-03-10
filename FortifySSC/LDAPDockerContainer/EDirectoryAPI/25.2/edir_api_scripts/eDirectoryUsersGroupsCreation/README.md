# 👥 eDirectoryUsersGroupsCreation (eDirectory API – Users & Groups Creation script)

Automation script to **create LDAP users 👤 and groups 👥 in NetIQ eDirectory** using the **eDirectory REST API**.

This script authenticates against eDirectory, generates a session and Anti-CSRF token, parses LDAP-style input files, creates the specified users and groups, logs every operation, and safely closes the API session.

---

## 📌 What This Script Does?

```makefile
flow:
	create-session -> get-csrf-token -> parse-input-files -> create-users -> add-default-password-to-users -> create-groups -> delete-session
```

* Creates LDAP **users** from an input file.
* Creates LDAP **groups** from an input file.
* Adds a default password for each **user**.
* Uses **session-based authentication** (RSESSIONID).
* Uses **Anti-CSRF tokens**.
* Writes detailed logs per operation.
* Clean and safe API session teardown.

---

## 📁 Directory Structure

```
EDirectoryAPI/
├── 25.2/
│   ├── docker_management_scripts/                               # Shell scripts directory to build and destroy the eDirectory API containers (BackEnd and Swagger FrontEnd).
│   │   └── (Docker-related scripts, helpers and utilities)     
│   │                                            
│   ├── edir_api_scripts/                                        # Python scripts directory to interact with the NetIQ eDirectory API.
│   │   └── eDirectoryUsersGroupsCreation/                       # eDirectoryUsersGroupsCreation script main directory.
│   │       ├── input/                                           # Input directory containing the data of the users and groups to be added to LDAP eDirectory.                                       
│   │       │   ├── eDirectoryUsersToAdd.txt                     # Users to be added input file.      
│   │       │   └── eDirectoryGroupsToAdd.txt                    # Groups to be added input file.
│   │       │
│   │       ├── logs/                                            # Logs directory containing the logs of the script execution.
│   │       │   ├── edir_ldap_session_creation.log               # Session creation log file.
│   │       │   ├── edir_ldap_token_creation.log                 # Token creation log file.
│   │       │   ├── edir_ldap_users_creation.log                 # Users creation log file.
│   │       │   ├── edir_ldap_groups_creation.log                # Groups creation log file.
│   │       │   └── edir_ldap_session_deletion.log               # Session deletion log file.
│   │       │
│   │       ├── .env                                             # Environment variables file used by the python script (eDirectoryUsersGroupsCreation).
│   │       └── eDirectoryUsersGroupsCreation.py                 # Python Script that creates users and groups with eDirectory API endpoints.
└────────────────────────────────────────────────────────────
```

---

## 🧾 Requirements

* 🐍 Python **3.8+**.
* 🔌 Network access to eDirectory API.
* 🌳 Valid eDirectory Tree properly configured.
* 🔑 Valid eDirectory **Admin DN & password** properly configured.

### 📦 Python Dependencies

Dependencies required to make the script work.

```bash
pip install requests python-dotenv termcolor urllib3
```

---

## 📄 .env file used to run the eDirectoryUsersGroupsCreation script (generic example)

The values are at the discretion of each user.

```makefile
EDIR_LDAP_API_URL=""                       # Base URL of the eDirectory REST API
EDIR_LDAP_ORIGIN=""                        # Origin header required by the eDirectory API
EDIR_LDAP_ADMIN_DN=""                      # Admin DN used to authenticate against eDirectory
EDIR_LDAP_ORG=""                           # eDirectory organization where entries will be created
EDIR_LDAP_ADMIN_PASSWORD=""                # Password for the admin DN (do NOT commit real values)
EDIR_LDAP_TREE=""                          # eDirectory tree name
EDIR_LDAP_SERVER=""                        # eDirectory LDAP server and port
OUTPUT_EDIR_LDAP_LOGS_DIRECTORY=""         # Directory where script log files will be written
INPUT_EDIR_LDAP_USERS_FILE_PATH=""         # Input file containing LDAP users to be created
INPUT_EDIR_LDAP_GROUPS_FILE_PATH=""        # Input file containing LDAP groups to be created
```

---

## 📥 Input File Format

The script expects **LDAP-style entries**, separated by a blank line.

### 👤 Users Example

```makefile
dn: /eDirAPI/v1/treename/cn=jdoe,o=company
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: jdoe
sn: Doe
givenName: John
fullName: John Doe
mail: jdoe@company.com
telephoneNumber: +123456789
title: UserRoleInCompany
ou: UserArea
l: UserCountryState

dn: /eDirAPI/v1/treename/cn=jandoe,o=company
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: jandoe
sn: Doe
givenName: Jane
fullName: Jane Doe
mail: jandoe@company.com
telephoneNumber: +987654321
title: UserRoleInCompany
ou: UserArea
l: UserCountryState

...
```

### 👥 Groups Example

```makefile
dn: /eDirAPI/v1/treename/developers,o=company
objectClass: top
objectClass: groupOfNames
cn: developers
description: Description of the group.
l: Region, country
member: /eDirAPI/v1/treename/cn=jdoe,o=company
owner: /eDirAPI/v1/treename/cn=jandoe,o=company
ou: UserArea
o: company

dn: /eDirAPI/v1/treename/projectmanagers,o=company
objectClass: top
objectClass: groupOfNames
cn: projectmanagers
description: Description of the group.
l: Region, country
member: /eDirAPI/v1/treename/cn=jdoe,o=company
owner: /eDirAPI/v1/treename/cn=jandoe,o=company
ou: UserArea
o: company

...
```

---

## ▶️ Usage

```bash
 cd eDirectoryUsersGroupsCreation
 chmod +x edir_users_groups_creation.py
./edir_users_groups_creation.py
```

---

## 📂 Logs Structure

Each operation has its own dedicated log file:

```makefile
logs/
	├── edir_ldap_session_creation.log
	├── edir_ldap_token_creation.log
	├── edir_ldap_users_creation.log
	├── edir_ldap_groups_creation.log
	└── edir_ldap_session_deletion.log
```

Logs include timestamps, levels, and API responses.

---

## 🚦 HTTP Status Handling

```makefile
201:
	✅ Resource created/updated successfully

204:
	🗑️ Session deleted successfully

401 / 403:
	⛔ Authentication or permission error

5xx:
	⚠️ eDirectory API unavailable
```

On critical failures, the script **exits immediately** to avoid partial or inconsistent states.
For more information regarding the https requests see the eDirectory API Swagger Documentation for each API endpoint.

---

## 📝 Notes regarding the script functionality 

* 🔐 Session-based auth only (no hardcoded tokens).
* 🧹 Sessions are always deleted.
* 📜 Full audit logs per action.
* 🚫 Skips invalid LDAP entries safely.
* ♻️ LDIF input design.
