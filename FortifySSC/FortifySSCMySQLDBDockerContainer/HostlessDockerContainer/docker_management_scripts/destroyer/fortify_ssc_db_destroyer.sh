#!/bin/bash

# Script that destroys the MySQL Database for Fortify Software Security Center (SSC) located in a Docker Container

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

# Function to check the success of the last executed command
# Takes an error message as an argument and exits the script if the command failed
check_success() {
    local exit_code=$1
    local message=$2
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Error: $message\e${RESET}"  # Prints the error message in red
        exit $exit_code                            # Exits the script with the captured failure status
    fi
}

# Prints the first message
echo -e "${CYAN}Proceeding to destroy the MySQL Docker Container for Fortify Software Security Center (SSC) database at $(date)...${RESET}"

echo ""

# Checks if the Docker Volume and the Docker Containers for Fortify SSC MySQL Database exist
echo -e "${YELLOW}Checking if the Docker Volume '$MYSQL_DATA_VOLUME_NAME' and the Docker Container '$MYSQL_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the Fortify SSC Database MySQL Docker Container existance
docker container ps -a | grep -q "$MYSQL_CONTAINER_NAME"
MYSQL_SSC_DB_CONTAINER_EXISTS=$?

# Checks for the Fortify SSC Database MySQL Data Docker Volume existance
docker volume ls | grep -q "$MYSQL_DATA_VOLUME_NAME"
MYSQL_SSC_DB_DATA_VOLUME_EXISTS=$?

if [ $MYSQL_SSC_DB_DATA_VOLUME_EXISTS -eq 0 ] && [ $MYSQL_SSC_DB_CONTAINER_EXISTS -eq 0 ]; then
    echo -e "${YELLOW}The Docker Volume '$MYSQL_DATA_VOLUME_NAME' and the Docker Container '$MYSQL_CONTAINER_NAME' exist.${RESET}"

    echo ""

    # Step 1: Stops the MySQL Fortify SSC database Docker Container
    echo -e "${YELLOW}Stopping the '$MYSQL_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""
    
    docker stop "$MYSQL_CONTAINER_NAME"
    stop_mysql_ssc_container_status=$?             # Captures the exit code immediately
    check_success $stop_mysql_ssc_container_status "Failed to stop the container '$EDIRECTORY_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$MYSQL_CONTAINER_NAME' has been stopped!${RESET}"

    echo ""

    # Step 2: Removes the MySQL Fortify SSC database Docker Container
    echo -e "${YELLOW}Removing the '$MYSQL_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""

    docker rm "$MYSQL_CONTAINER_NAME"
    delete_mysql_ssc_container_status=$?               # Captures the exit code immediately
    check_success $delete_mysql_ssc_container_status "Failed to remove the container '$MYSQL_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$MYSQL_CONTAINER_NAME' have been removed!${RESET}"

    echo ""

    # Step 3: Removes the MySQL 8 Docker Image
    echo -e "${YELLOW}Removing the '$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG' Docker Image.${RESET}"

    echo ""

    docker rmi "$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG"  
    delete_mysql_image_status=$?                   # Captures the exit code immediately
    check_success $delete_mysql_image_status "Failed to remove the image '$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG'."
    
    echo ""
    
    echo -e "${GREEN}The Docker Image '$MYSQL_IMAGE_NAME:$MYSQL_IMAGE_TAG' has been successfully deleted!.${RESET}"
    
    echo ""

    # Step 4: Removes the MySQL Fortify SSC database JDBC file
    echo -e "${YELLOW}Removing the MySQL Fortify SSC database JDBC file.${RESET}"

    echo ""
    
    rm -rf "$OUTPUT_JDBC_URL_FILE"

    echo ""

    echo -e "${GREEN}Fortify SSC Database JDBC URL file has been successfully deleted!.${RESET}"

    echo ""

    # Step 5: Removes the MySQL Fortify SSC database data Docker Volume
    echo -e "${YELLOW}Removing the '$MYSQL_DATA_VOLUME_NAME' Docker Volume.${RESET}"

    echo ""

    docker volume rm "$MYSQL_DATA_VOLUME_NAME"  
    delete_mysql_ssc_docker_volume_status=$?                   # Captures the exit code immediately
    check_success $delete_mysql_ssc_docker_volume_status "Failed to remove the volume '$MYSQL_DATA_VOLUME_NAME'."

    echo ""

    echo -e "${GREEN}The Docker Volume '$MYSQL_DATA_VOLUME_NAME' has been successfully deleted!.${RESET}"

    echo ""
else
    echo -e "${YELLOW}The Docker Volume '$MYSQL_DATA_VOLUME_NAME' and the Docker Container '$MYSQL_CONTAINER_NAME' don't exist or have been deleted.${RESET}"
    
    echo ""

    echo -e "${CYAN}Run the builder script if you want to create the Docker Components for MySQL Fortify SSC database.${RESET}"

    exit 0    
fi

# Prints a success message
echo -e "${GREEN}Execution completed successfully!${RESET}"