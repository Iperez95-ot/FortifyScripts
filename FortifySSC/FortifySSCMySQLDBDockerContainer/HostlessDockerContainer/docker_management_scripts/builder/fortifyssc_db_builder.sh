#!/bin/bash

# Script that build a MySQL Database for Fortify Software Security Center (SSC) on a Docker Container
# It also pushes the Docker Image to a Private Docker Registry and shows the repositories on it

# Exits immediately if a command exits with a non-zero status
#set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Loads the environment variables from the .env file
# Checks if the file named .env exists in the current directory
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi 

# Defines the variables
FORTIFY_SSC_DATABASE_JDBC_URL="jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$FORTIFY_SSC_DATABASE_NAME?sessionVariables=collation_connection=latin1_general_cs&rewriteBatchedStatements=true"    # JDBC URL for the Fortify SSC Setup when connecting to the MySQL Database running on the Docker Container

# Function to check the success of the last executed command
# Takes an error message as an argument and exits the script if the command failed
check_success() {
    local exit_code=$1
    local message=$2
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Error: $message\e${RESET}"                                                # Prints the error message in red
        exit $exit_code                                                                          # Exits the script with the captured failure status
    fi
}

# Prints the first message
echo -e "${CYAN}Proceeding to create the MySQL Docker Container for Fortify Software Security Center (SSC) database at $(date)...${RESET}"

echo ""

# Checks if the Docker Volume and the Docker Container for Fortify SSC MySQL Database exist
echo -e "${YELLOW}Checking if the Docker Container '$MYSQL_CONTAINER_NAME' and the Docker Volume '$MYSQL_DATA_VOLUME_NAME' exist...${RESET}"

echo ""

# Checks for the Fortify SSC Database MySQL Docker Container existance
docker container ps -a | grep -q "$MYSQL_CONTAINER_NAME"
MYSQL_SSC_DB_CONTAINER_EXISTS=$?

# Checks for the Fortify SSC Database MySQL Data Docker Volume existance
docker volume ls | grep -q "$MYSQL_DATA_VOLUME_NAME"
MYSQL_SSC_DB_DATA_VOLUME_EXISTS=$?

if [ $MYSQL_SSC_DB_CONTAINER_EXISTS -ne 0 ] || [ $MYSQL_SSC_DB_DATA_VOLUME_EXISTS -ne 0 ]; then
    echo -e "${RED}The Docker Volume '$MYSQL_DATA_VOLUME_NAME' and the Docker Container '$MYSQL_CONTAINER_NAME' don't exist.${RESET}"
    
    echo ""

    # Step 1: Logs into the Private Docker Registry
    echo -e "${YELLOW}Logging into the private Docker Registry '$CUSTOM_REGISTRY_URL'...${RESET}"

    echo "$REGISTRY_PASSWORD" | docker login "$CUSTOM_REGISTRY_URL" -u "$REGISTRY_USER" --password-stdin
    check_success $? "Docker registry login failed."

    echo ""

    # Step 2: Builds a MySQL Docker Container based on a my.cnf config file with a root password, 
    # the default port, the default MySQL Image and a Docker Volume containing the data
    echo -e "${YELLOW}Proceeding to build the MySQL Docker Container...${RESET}"

    echo ""

    docker run --name $MYSQL_CONTAINER_NAME --restart unless-stopped -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -p $MYSQL_PORT:$MYSQL_PORT -v $MYSQL_CONFIG_HOST_DIRECTORY/my.cnf:$MYSQL_CONFIG_CONTAINER_DIRECTORY/my.cnf:ro -v $MYSQL_DATA_VOLUME_NAME:$MYSQL_DATA_DIRECTORY -d $MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG
    build_mysql_ssc_container_status=$?                                                                         # Captures the exit code immediately
    check_success $build_mysql_ssc_container_status "Failed to build the '$MYSQL_CONTAINER_NAME' Docker Container and '$MYSQL_DATA_VOLUME_NAME' Docker Volume."

    echo ""

    # Step 3: Lists the Docker Containers and filter by the newly created Docker Container for MySQL
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

    # Step 4: Tags and Pushes the MySQL Docker Image into the Private Docker Registry
    echo -e "${YELLOW}Tagging MySQL image for private registry...${RESET}"

    docker tag "$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG" "$CUSTOM_REGISTRY_URL/$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG    "
    check_success $? "Failed to tag MySQL image."

    echo ""

    echo -e "${YELLOW}Pushing MySQL image to private registry...${RESET}"

    docker push "$CUSTOM_REGISTRY_URL/$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG"
    check_success $? "Failed to push MySQL image to registry."

    echo ""

    echo -e "${GREEN}MySQL image successfully pushed to '$CUSTOM_REGISTRY_URL/$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG'${RESET}"

    echo ""

    # Step 5: Logs into the MySQL Docker Container to Create a Database with a specific Collation, 
    # selects that database to run a SQL script to create the Tables needed for Fortify Software Security Center (SSC) Database and runs a query to it
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

    # Step 5: Creates the JDBC URL for the Database connection when setting up Fortify Software Security Center (SSC)
    echo -e "${YELLOW}Creating the Fortify SSC JDBC URL${RESET}"

    echo ""

    # Writes the JDBC URL to a file text file
    mkdir -p "$MYSQL_OUTPUT_DIRECTORY"
    cd $MYSQL_OUTPUT_DIRECTORY
    echo "$FORTIFY_SSC_DATABASE_JDBC_URL" > "$OUTPUT_JDBC_URL_FILE"

    echo ""

    echo -e "${CYAN}Fortify SSC JDBC URL is: '$FORTIFY_SSC_DATABASE_JDBC_URL'.${RESET}"

    echo ""

    echo -e "${GREEN}Fortify SSC Database JDBC URL written successfully to '$MYSQL_OUTPUT_DIRECTORY/$OUTPUT_JDBC_URL_FILE'.${RESET}"

    echo ""

    # Step 6: Logouts from Docker Private Registry, Docker Hub, and Helm
    echo -e "${YELLOW}Logging out from the '$CUSTOM_REGISTRY_URL' Docker Private Registry...${RESET}"
  
    echo ""
  
    docker logout "$CUSTOM_REGISTRY_URL"
  
    echo ""

    # Step 7: Shows all the repositories in the Docker Private Registry
    echo -e "${CYAN}Fetching the Docker Registry repository catalog from '$CUSTOM_REGISTRY_URL'...${RESET}"
    curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/_catalog" | jq .

    echo ""
else
    echo -e "${YELLOW}The Docker Volume '$MYSQL_DATA_VOLUME_NAME' and the Docker Container '$MYSQL_CONTAINER_NAME' already exist.${RESET}"

    exit 0
fi

# Prints a success message
echo -e "${GREEN}Execution completed successfully!${RESET}"