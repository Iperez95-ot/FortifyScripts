#!/bin/bash

# Script that destroys the Docker Container for IdentityConsole version 25.2 and it's respective static ip routes in a linux system 

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
echo -e "${CYAN}Proceeding to remove the Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' at $(date)...${RESET}"

echo ""

# Checks if the Docker Container for IdentityConsole exists
echo -e "${YELLOW}Checking if the Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' exists...${RESET}"

echo ""

# Checks for the IdentityConsole Docker Container existance
docker container ps -a | grep -q "$IDENTITYCONSOLE_CONTAINER_NAME"
IDC_CONTAINER_EXISTS=$?

# If the Docker Container exists, it proceeds to stop and remove it, and also removes the static ip routes for the IdentityConsole Docker Container. 
# If the Docker Container doesn't exist, it prints a message indicating that the container doesn't exist or have been deleted, 
# and suggests running the builder script to create the container.
if [ $IDC_CONTAINER_EXISTS -eq 0 ]; then
    echo -e "${YELLOW}The Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' exists.${RESET}"

    echo ""

    # Step 1: Stops the IdentityConsole Application Docker Container
    echo -e "${YELLOW}Stopping the '$IDENTITYCONSOLE_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""
    
    docker stop "$IDENTITYCONSOLE_CONTAINER_NAME"
    stop_idc_container_status=$?             # Captures the exit code immediately
    check_success $stop_idc_container_status "Failed to stop the container '$IDENTITYCONSOLE_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' has been stopped!${RESET}"

    echo ""

    # Step 2: Removes the IdentityConsole Application Docker Container
    echo -e "${YELLOW}Removing the '$IDENTITYCONSOLE_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""

    docker rm "$IDENTITYCONSOLE_CONTAINER_NAME"
    delete_idc_container_status=$?               # Captures the exit code immediately
    check_success $delete_idc_container_status "Failed to remove the container '$IDENTITYCONSOLE_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' has been removed!${RESET}"

    echo ""

    # Step 3: Removes the IdentityConsole Docker Container static ip route
    echo -e "${YELLOW}Removing IdentityConsole Docker Container static ip route.${RESET}"

    echo ""

    # Removes the static routes for the IdentityConsole Docker Container
    echo -e "${YELLOW}Removing the static routes for the IdentityConsole Docker Container...${RESET}"
    
    echo ""
    
    # Removes the route to the IdentityConsole container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} -ipv4.routes "${IDENTITYCONSOLE_CONTAINER_IPADDRESS}/32"
    nmcli connection reload

    echo ""

    # Removes the Certificates files from the IdentityConsole Certificates Directory
    echo -e "${YELLOW}Removing the certificates files from the IdentityConsole Certificates Directory.${RESET}"

    echo ""
    								
    rm -f $HOST_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY/*

    echo ""

    # Shows the contents of the IdentityConsole Certificates Directory after the files have been removed
    echo -e "${CYAN}Showing IdentityConsole Docker Container Certificates Directory:${RESET}"
    ls -l $HOST_IDENTITYCONSOLE_CERTIFICATES_DIRECTORY

    echo ""
else
    echo -e "${YELLOW}The Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' doesn't exist or have been deleted.${RESET}"
    
    echo ""

    echo -e "${CYAN}Run the builder script if you want to create the IdentityConsole Docker Container.${RESET}"

    exit 0
fi

# Prints a success message
echo -e "${GREEN}Execution completed successfully!${RESET}"