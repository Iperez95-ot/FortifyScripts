#!/bin/bash

# Script that destroys the Docker Container for Rancher, it's respective volume 
# and static ip routes in a linux system 

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
echo -e "${CYAN}Proceeding to remove the Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$RANCHER_CONTAINER_NAME' at $(date)...${RESET}"

echo ""

# Checks if the Docker Volume and the Docker Container for Rancher exist
echo -e "${YELLOW}Checking if the Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$RANCHER_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the Rancher Data Docker Volume existance
docker volume ls | grep -q "$RANCHER_DATA_DOCKER_VOLUME_NAME"
RANCHER_DATA_VOLUME_EXISTS=$?

# Checks for the Rancher Docker Container existance
docker container ps -a | grep -q "$RANCHER_CONTAINER_NAME"
RANCHER_CONTAINER_EXISTS=$?

# Checks if the Rancher Data Docker Volume and the Rancher Docker Container exist before trying to remove them, 
# otherwise it prints a message indicating that they don't exist or have been deleted and exits the script
if [ $RANCHER_DATA_VOLUME_EXISTS -eq 0 ] && [ $RANCHER_CONTAINER_EXISTS -eq 0 ]; then
    echo -e "${YELLOW}The Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$RANCHER_CONTAINER_NAME' exist.${RESET}"

    echo ""

    # Step 1: Stops the Rancher Docker Container
    echo -e "${YELLOW}Stopping the '$RANCHER_CONTAINER_NAME' Docker Container.${RESET}"

    docker container stop "$RANCHER_CONTAINER_NAME"
    stop_rancher_container_status=$?             # Captures the exit code immediately
    check_success $stop_rancher_container_status "Failed to stop the container '$RANCHER_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$RANCHER_CONTAINER_NAME' has been stopped!${RESET}"

    echo ""

    # Step 2: Removes the Rancher Docker Container
    echo -e "${YELLOW}Removing the '$RANCHER_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""

    docker rm "$RANCHER_CONTAINER_NAME"
    delete_rancher_container_status=$?               # Captures the exit code immediately
    check_success $delete_rancher_container_status "Failed to remove the container '$RANCHER_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}Docker Container '$RANCHER_CONTAINER_NAME' has been removed!${RESET}"

    echo ""

    # Step 3: Removes Rancher Docker Container self signed certificates and the static ip routes for it
    echo -e "${YELLOW}Removing Rancher Docker Container self signed certificates and the static ip routes of the Rancher Docker Container.${RESET}"

    echo ""

    # Removes the static routes for the Rancher Docker Container
    echo -e "${YELLOW}Removing the static routes for the Rancher Docker Container...${RESET}"
    
    echo ""
    
    # Removes the route to the Rancher application container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} -ipv4.routes "${RANCHER_CONTAINER_IPADDRESS}/32"
    nmcli connection reload

    echo ""

    # Removes the Certificate file from the Trusted CA Store and Certificates Directories 
    echo -e "${YELLOW}Removing the certificates files from the Trusted CA Store and the Certificates Directories.${RESET}"

    echo ""
    								
    rm -f $HOST_RANCHER_CERTIFICATES_DIRECTORY/*
    rm -f $HOST_TRUSTED_CA_DIRECTORY/$RANCHER_CERTIFICATE_FILE

    echo ""

    echo -e "${CYAN}Showing Rancher Docker Container Certificates Directory:${RESET}"
    ls -l $HOST_RANCHER_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${CYAN}Showing the Trusted CA Store:${RESET}"
    ls -l $HOST_TRUSTED_CA_DIRECTORY

    echo ""

    # Step 4: Removes the Rancher Docker Volume
    echo -e "${YELLOW}Removing the '$RANCHER_DATA_DOCKER_VOLUME_NAME' Docker Volume.${RESET}"

    echo ""

    docker volume rm "$RANCHER_DATA_DOCKER_VOLUME_NAME"  
    delete_rancher_docker_volume_status=$?                   # Captures the exit code immediately
    check_success $delete_rancher_docker_volume_status "Failed to remove the volume '$RANCHER_DATA_DOCKER_VOLUME_NAME'."

    echo ""
else
    echo -e "${RED}The Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' or the Docker Container '$RANCHER_CONTAINER_NAME' does not exist or have been deleted.${RESET}"
    
    echo ""

    echo -e "${CYAN}Run the builder script if you want to create the Docker Components for Rancher.${RESET}"

    exit 0
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"