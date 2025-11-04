#!/bin/bash

# Script that build a MySQL Database for Fortify Software Security Center (SSC) on a Docker Container

# Exits immediately if a command exits with a non-zero status
set -e

 Loads the environment variables from the .env file
# Checks if the file named .env exists in the current directory
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi 

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