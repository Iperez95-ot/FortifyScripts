# 🐬 Fortify SSC MySQL Docker Container (HostlessDockerContainer) Environment Variables (build and destroy scripts)

The definition of the environment variables used to configure and deploy a MySQL Docker Container for Fortify SSC database. 
The .env file centralizes all configuration values required by the build and destroy scripts that automate the MySQL database deployment and teardown.

---

## 📦 Overview
This project contains two Bash scripts to **create** and **destroy** the MySQL database used by **Fortify Software Security Center (SSC)** 
inside a Hostless Docker container. Both scripts read configuration from a `.env` file.

---

# 🏗 Builder Script  

**File:** `fortify_ssc_db_builder.sh`  
Creates the MySQL Docker environment for Fortify SSC database.

### 🚀 Actions
- Loads environment variables  
- Creates MySQL Docker container  
- Waits for MySQL service  
- Creates Fortify SSC database  
- Imports SQL schema  
- Generates JDBC URL  
- Stores JDBC URL in output directory  

---

# 🗑️ Destroy Script

File: `fortify_ssc_db_destroyer.sh` 
Removes all MySQL components created for Fortify SSC database.

### 🚀 Actions
- Stops the MySQL container
- Removes the container
- Deletes MySQL Docker image
- Removes JDBC URL output file
- Deletes Docker volume

---

## 🧾 .env file used to use on the Hostless MySQL Docker Container Builder script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
FORTIFY_SSC_VERSION=                                                    # Current Fortify SSC version in use
MYSQL_HOST=                                                             # Hostname of the host machine running the MySQL Docker Container
MYSQL_PORT=                                                             # Port of the MySQL Docker Container
MYSQL_IMAGE_NAME=                                                       # MySQL Docker Image name
MYSQL_IMAGE_TAG=                                                        # MySQL Docker Image tag
MYSQL_CONTAINER_NAME=                                                   # MySQL Docker Container name
MYSQL_USER=                                                             # MySQL User to log in into the MySQL Docker Container
MYSQL_ROOT_PASSWORD=                                                    # MySQL Root Password
FORTIFY_SSC_DATABASE_NAME=                                              # Fortify SSC Database Name
MYSQL_DATA_VOLUME_NAME=                                                 # MYSQL Fortify SSC Database data Docker Volume
MYSQL_DATA_DIRECTORY=                                                   # MySQL data directory inside the MySQL Docker Container
MYSQL_CONFIG_HOST_DIRECTORY=                                            # MySQL config file directory on the Host Machine
MYSQL_CONFIG_CONTAINER_DIRECTORY=                                       # MySQL config file directory on the MySQL Docker Container
MYSQL_CREATE_TABLES_SCRIPT=                                             # MySQL script to create the tables for the Fortify SSC Database
MYSQL_OUTPUT_DIRECTORY=                                                 # MySQL host output directory
OUTPUT_JDBC_URL_FILE=                                                   # Output file containing the Fortify SSC Database JDBC URL
```

---

## 🧾 .env file used to use on the Hostless MySQL Docker Container Destoryer script (generic example)

The values are at the discretion of each user.

```makefile
# Defines the variables
MYSQL_IMAGE_NAME=                 # MySQL Docker Image name
MYSQL_IMAGE_TAG=                  # MySQL Docker Image tag
MYSQL_CONTAINER_NAME=             # MySQL Docker Container name
MYSQL_DATA_VOLUME_NAME=           # MYSQL data Docker Volume
MYSQL_OUTPUT_DIRECTORY=           # MySQL host output directory
OUTPUT_JDBC_URL_FILE=             # Output file containing the Fortify SSC Database JDBC URL
```
