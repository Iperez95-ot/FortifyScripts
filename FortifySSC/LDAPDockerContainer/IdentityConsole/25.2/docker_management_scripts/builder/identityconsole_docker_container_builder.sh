#!/bin/bash

# Script that builds a Docker Container for IdentityConsole version 25.2 with a network in a linux system

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
        echo -e "${RED}Error: $message\e${RESET}"                                                # Prints the error message in red
        exit $exit_code                                                                          # Exits the script with the captured failure status
    fi
}

# Prints the first message
echo -e "${CYAN}Proceeding to create the Docker Container for IdentityConsole version $IDENTITYCONSOLE_VERSION at $(date)...${RESET}"

echo ""

# Checks if the Docker Container for IdentityConsole exists
echo -e "${YELLOW}Checking if the Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' exists...${RESET}"

echo ""

# Checks for the IdentityConsole Docker Container existance
docker container ps -a | grep -q "$IDENTITYCONSOLE_CONTAINER_NAME"
IDC_CONTAINER_EXISTS=$?

if [ $IDC_CONTAINER_EXISTS -ne 0 ]; then
    echo -e "${RED}The Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' don't exist.${RESET}"
    
    echo ""

    # Step 1: Adding a route to the IdentityConsole Docker Container
    echo -e "${YELLOW}Adding a route to the Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' to the '$HOST_CUSTOM_NETWORK_INTERFACE'...${RESET}"

    echo ""

    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} +ipv4.routes "${IDENTITYCONSOLE_CONTAINER_IPADDRESS}/32"

    # Applies the changes
    nmcli connection up ${HOST_CUSTOM_NETWORK_INTERFACE}
    
    echo ""

    # Step 2: Builds the IdentityConsole Docker Container
    echo -e "${YELLOW}Building the Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME'...${RESET}"

    echo ""

    docker run -d --name $IDENTITYCONSOLE_CONTAINER_NAME --restart unless-stopped --hostname $IDENTITYCONSOLE_CONTAINER_HOSTNAME --network $DOCKER_NETWORK_NAME --ip $IDENTITYCONSOLE_CONTAINER_IPADDRESS -p $IDENTITYCONSOLE_HTTPS_PORT:$IDENTITYCONSOLE_HTTPS_PORT -v $HOST_IDENTITYCONSOLE_SILENT_PROPERTIES_FILE:$IDENTITYCONSOLE_SILENT_PROPERTIES_FILE:ro -v $HOST_EDIRECTORY_DEFAULT_PEM_FILE:$IDENTITYCONSOLE_EDIRECTORY_ETC_DEFAULT_PEM_FILE:ro -v $HOST_EDIRECTORY_DEFAULT_PEM_FILE:$IDENTITYCONSOLE_EDIRECTORY_CERT_DEFAULT_PEM_FILE:ro $IDENTITYCONSOLE_IMAGE_NAME:$IDENTITYCONSOLE_VERSION
    build_idc_container_status=$?                                                                         # Captures the exit code immediately
    check_success $build_idc_container_status "Failed to build the '$IDENTITYCONSOLE_CONTAINER_NAME' Docker Container."

    echo ""

    # Shows the new Docker Container information
    echo -e "${CYAN}New Docker Container created:${RESET}"
    docker ps -a --filter "name=$IDENTITYCONSOLE_CONTAINER_NAME"

    echo ""
       
    echo -e "${GREEN}The Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' was created successfully.${RESET}"

    echo ""
else
   echo -e "${YELLOW}The Docker Container '$IDENTITYCONSOLE_CONTAINER_NAME' already exist.${RESET}"

   exit 0
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"