#!/bin/bash

# Script that destroys the Docker Container for EDirectory 9.3.1 and it's respective volume and static ip routes in a linux system 

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
echo -e "${CYAN}Proceeding to remove the Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$EDIRECTORY_CONTAINER_NAME' at $(date)...${RESET}"

echo ""

# Checks if the EDirectory Docker Volume and the Docker Containers for EDirectory and EDirectory API exist
echo -e "${YELLOW}Checking if the Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$EDIRECTORY_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the EDirectory LDAP Data Docker Volume existance
docker volume ls | grep -q "$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME"
EDIR_DATA_VOLUME_EXISTS=$?

# Checks for the EDirectory Docker Container existance
docker container ps -a | grep -q "$EDIRECTORY_CONTAINER_NAME"
EDIR_CONTAINER_EXISTS=$?

if [ $EDIR_DATA_VOLUME_EXISTS -eq 0 ] && [ $EDIR_CONTAINER_EXISTS -eq 0 ]; then
    echo -e "${YELLOW}The Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$EDIRECTORY_CONTAINER_NAME' exist.${RESET}"

    echo ""

    # Step 1: Stops the EDirectory Application Docker Container
    echo -e "${YELLOW}Stopping the '$EDIRECTORY_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""
    
    docker stop "$EDIRECTORY_CONTAINER_NAME"
    stop_edir_container_status=$?             # Captures the exit code immediately
    check_success $stop_edir_container_status "Failed to stop the container '$EDIRECTORY_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$EDIRECTORY_CONTAINER_NAME' has been stopped!${RESET}"

    echo ""

    # Step 2: Removes the EDirectory Application Docker Containers
    echo -e "${YELLOW}Removing the '$EDIRECTORY_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""

    docker rm "$EDIRECTORY_CONTAINER_NAME"
    delete_edir_container_status=$?               # Captures the exit code immediately
    check_success $delete_edir_container_status "Failed to remove the container '$EDIRECTORY_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}Docker Container '$EDIRECTORY_CONTAINER_NAME' has been removed!${RESET}"

    echo ""

    # Step 3: Removes the EDirectory Docker Container self signed certificates and the static ip routes for it
    echo -e "${YELLOW}Removing EDirectory Docker Container self signed certificates and the static ip routes of the EDirectory Docker Container.${RESET}"

    echo ""

    # Removes the static routes for the EDirectory Docker Container
    echo -e "${YELLOW}Removing the static routes for the EDirectory Docker Container...${RESET}"
    
    echo ""
    
    # Removes the route to the EDirectory application container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} -ipv4.routes "${EDIRECTORY_CONTAINER_IPADDRESS}/32"
    nmcli connection reload

    echo ""

    # Removes the Certificates files from the Trusted CA Store and Certificates Directories 
    echo -e "${YELLOW}Removing the certificates files from the Trusted CA Store and the Certificates Directories.${RESET}"

    echo ""
    								
    rm -f $HOST_EDIRECTORY_CERTIFICATES_DIRECTORY/*
    rm -f $HOST_TRUSTED_CA_DIRECTORY/$EDIRECTORY_CERTIFICATE_FILE

    echo ""

    echo -e "${CYAN}Showing EDirectory Docker Container Certificates Directory:${RESET}"
    ls -l $HOST_EDIRECTORY_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${CYAN}Showing the Trusted CA Store:${RESET}"
    ls -l $HOST_TRUSTED_CA_DIRECTORY

    echo ""

    # Removes the LDAPDockerContainer Docker Client Directory
    echo -e "${YELLOW}Removes the LDAPDockerContainer Docker Client Directory.${RESET}"

    echo ""

    rm -rf $HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY
    systemctl restart docker

    echo ""

    # Step 4: Removes the EDirectory Docker Volume
    echo -e "${YELLOW}Removing the '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' Docker Volume.${RESET}"

    echo ""

    docker volume rm "$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME"  
    delete_edir_docker_volume_status=$?                   # Captures the exit code immediately
    check_success $delete_edir_docker_volume_status "Failed to remove the volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME'."

    echo ""
else
    echo -e "${YELLOW}The Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$EDIRECTORY_CONTAINER_NAME' don't exist or have been deleted.${RESET}"
    
    echo ""

    echo -e "${CYAN}Run the builder script if you want to create the Docker Components for EDirectory.${RESET}"

    exit 0
fi

# Prints a success message
echo -e "${GREEN}Execution completed successfully!${RESET}"


