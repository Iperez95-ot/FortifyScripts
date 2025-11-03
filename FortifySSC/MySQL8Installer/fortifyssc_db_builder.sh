#!/bin/bash

# Script that build a MySQL Database for Fortify Software Security Center (SSC) on a Docker Container

# Exits immediately if a command exits with a non-zero status
set -e

# Defines the variables
FORTIFY_SSC_VERSION="23.2"																				# Current Fortify SSC version in use
MYSQL_HOST="ssc.fortifynacho.com.ar"															        			# Hostname of the host machine running the MySQL Docker Container
MYSQL_PORT="3306"                                                                             		   	   									# Port of the MySQL Docker Container
MYSQL_IMAGE_NAME="mysql" 										           									# MySQL Docker Image name
MYSQL_IMAGE_TAG="8.0"                                         		   				  	   									# MySQL Docker Image tag
MYSQL_CONTAINER_NAME="mysql"                                                                   		   	  									# MySQL Docker Container name
MYSQL_USER="root"											           									# MySQL User to log in into the MySQL Docker Container
MYSQL_ROOT_PASSWORD="N0v3ll95"                                                                                     									# MySQL Root Password
FORTIFY_SSC_DATABASE_NAME="fortify_ssc_db"									   									# Fortify SSC Database Name
MYSQL_DATA_VOLUME_NAME="mysql-data"									           									# MYSQL data Docker Volume 		
MYSQL_DATA_DIRECTORY="/var/lib/mysql"                                                      		           									# MySQL data directory inside the MySQL Docker Container
MYSQL_CONFIG_HOST_DIRECTORY="/etc/docker/mysql8/db_config"								   							        # MySQL config file directory on the Host Machine
MYSQL_CONFIG_CONTAINER_DIRECTORY="/etc"                                                               							                                # MySQL config file directory on the MySQL Docker Container
MYSQL_CREATE_TABLES_SCRIPT="/opt/Fortify_Software_Security_Center/Fortify_Software_Security_Center_Application_Files/$FORTIFY_SSC_VERSION/sql/mysql/create-tables.sql"	        	# MySQL script to create the tables for the Fortify SSC Database
FORTIFY_SSC_DATABASE_JDBC_URL="jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$FORTIFY_SSC_DATABASE_NAME?sessionVariables=collation_connection=latin1_general_cs&rewriteBatchedStatements=true"   # JDBC URL for the Fortify SSC Setup when connecting to the MySQL Database running on the Docker Container
OUTPUT_JDBC_URL_FILE="fortify_ssc_db_jdbc_url.txt"                                                                                                                                      # Output file containing the Fortify SSC Database JDBC URL

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Prints the first message
echo -e "${CYAN}Proceeding to create the MySQL Docker Container for Fortify Software Security Center (SSC) at $(date)...${RESET}"

echo ""

# Step 1: Builds a MySQL Docker Container based on a my.cnf config file with a root password, the default port, the default MySQL Image and a Docker Volume containing the data
docker run --name $MYSQL_CONTAINER_NAME --restart unless-stopped -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -p $MYSQL_PORT:$MYSQL_PORT -v $MYSQL_CONFIG_HOST_DIRECTORY/my.cnf:$MYSQL_CONFIG_CONTAINER_DIRECTORY/my.cnf:ro -v $MYSQL_DATA_VOLUME_NAME:$MYSQL_DATA_DIRECTORY -d $MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG

echo ""

# Step 2: Lists the Docker Containers and filter by the newly created Docker Container for MySQL
echo -e "${CYAN}New MySQL Docker Container:${RESET}"
docker ps -a | grep "$MYSQL_CONTAINER_NAME"

echo ""

# Waits for MySQL to be accepting connections
echo -e "${YELLOW}Waiting for MySQL to be ready for connections${RESET}"

echo ""
 
until mysqladmin ping -h"$MYSQL_HOST" -P"$MYSQL_PORT" --silent; do
  printf '.'
  sleep 2
done

echo ""

echo -e "\n${GREEN}MySQL is up and ready for connections!${RESET}"

echo ""

# Step 3: Logs into the MySQL Docker Container to Create a Database with a specific Collation, select that database to run a SQL script to create the Tables needed for Fortify Software Security Center (SSC) Database and run a query to it
echo -e "${YELLOW}Creating the Fortify SSC Database, inserts the tables and modifies the root user settings for MySQL authentication${RESET}"

echo ""

cat > temp_fortify_db_setup.sql <<EOF
CREATE DATABASE $FORTIFY_SSC_DATABASE_NAME CHARACTER SET latin1 COLLATE latin1_general_cs;
USE $FORTIFY_SSC_DATABASE_NAME;
SOURCE $MYSQL_CREATE_TABLES_SCRIPT;
ALTER USER '$MYSQL_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
SHOW TABLES;
EOF

mysql --host="$MYSQL_HOST" --port="$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" < temp_fortify_db_setup.sql

echo ""

# Cleans up the temp file
rm -f "temp_fortify_db_setup.sql"

echo ""

# Step 4: Creates the JDBC URL for the Database connection when setting up Fortify Software Security Center (SSC)
echo -e "${YELLOW}Creating the Fortify SSC JDBC URL${RESET}"

echo ""

# Writes the JDBC URL to a file text file
echo "$FORTIFY_SSC_DATABASE_JDBC_URL" > "$OUTPUT_JDBC_URL_FILE"

echo ""

echo -e "${CYAN}Fortify SSC JDBC URL is: '$FORTIFY_SSC_DATABASE_JDBC_URL'.${RESET}"

echo ""

echo -e "${GREEN}Fortify SSC Database JDBC URL written successfully to '$OUTPUT_JDBC_URL_FILE'.${RESET}"

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"