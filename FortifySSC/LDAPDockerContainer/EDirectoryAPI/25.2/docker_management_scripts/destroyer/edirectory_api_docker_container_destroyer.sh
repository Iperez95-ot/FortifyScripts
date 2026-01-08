#!/bin/bash

# Script that destroys the Docker Container for EDirectory API version 25.2 and it's respective static ip routes in a linux system 

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
echo -e "${CYAN}Proceeding to remove the Docker Container '$EDIRECTORY_API_CONTAINER_NAME' at $(date)...${RESET}"

echo ""

# Checks if the Docker Container for EDirectory API exists
echo -e "${YELLOW}Checking if the Docker Container '$EDIRECTORY_API_CONTAINER_NAME' exists...${RESET}"

echo ""

# Checks for the EDirectory API Docker Container existance
docker container ps -a | grep -q "$EDIRECTORY_API_CONTAINER_NAME"
EDIR_API_CONTAINER_EXISTS=$?

# Checks for the EDirectory API Swagger Docker Container existance
docker container ps -a | grep -q "$EDIRECTORY_API_SWAGGER_CONTAINER_NAME"
EDIR_API_SWAGGER_CONTAINER_EXISTS=$?

if [ $EDIR_API_CONTAINER_EXISTS -eq 0 ] && [ $EDIR_API_SWAGGER_CONTAINER_EXISTS -eq 0 ]; then
    echo -e "${YELLOW}The Docker Containers '$EDIRECTORY_API_CONTAINER_NAME' and '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' exist.${RESET}"

    echo ""

    # Step 1: Stops the EDirectory API Docker Container
    echo -e "${YELLOW}Stopping the '$EDIRECTORY_API_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""
    
    docker stop "$EDIRECTORY_API_CONTAINER_NAME"
    stop_edir_api_container_status=$?             # Captures the exit code immediately
    check_success $stop_edir_api_container_status "Failed to stop the container '$EDIRECTORY_API_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$EDIRECTORY_API_CONTAINER_NAME' has been stopped!${RESET}"

    echo ""

    # Step 2: Removes the EDirectory API Docker Container
    echo -e "${YELLOW}Removing the '$EDIRECTORY_API_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""

    docker rm "$EDIRECTORY_API_CONTAINER_NAME"
    delete_edir_api_container_status=$?               # Captures the exit code immediately
    check_success $delete_edir_api_container_status "Failed to remove the container '$EDIRECTORY_API_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$EDIRECTORY_API_CONTAINER_NAME' has been removed!${RESET}"

    echo ""
   
    # Step 3: Removes the EDirectory API Docker Container static ip route
    echo -e "${YELLOW}Removing EDirectory API Docker Container static ip route.${RESET}"

    echo ""

    # Removes the static routes for the EDirectory API Docker Container
    echo -e "${YELLOW}Removing the static routes for the EDirectory API Docker Container...${RESET}"
    
    echo ""
    
    # Removes the route to the EDirectory API container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} -ipv4.routes "${EDIRECTORY_API_CONTAINER_IPADDRESS}/32"
    nmcli connection reload

    echo ""

    # Step 4: Stops the EDirectory API Swagger Docker Container
    echo -e "${YELLOW}Stopping the '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""
    
    docker stop "$EDIRECTORY_API_SWAGGER_CONTAINER_NAME"
    stop_edir_api_swagger_container_status=$?             # Captures the exit code immediately
    check_success $stop_edir_api_swagger_container_status "Failed to stop the container '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' has been stopped!${RESET}"

    echo ""

    # Step 5: Removes the EDirectory API Swagger Docker Container
    echo -e "${YELLOW}Removing the '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""

    docker rm "$EDIRECTORY_API_SWAGGER_CONTAINER_NAME"
    delete_edir_api_swagger_container_status=$?               # Captures the exit code immediately
    check_success $delete_edir_api_swagger_container_status "Failed to remove the container '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}The Docker Container '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' has been removed!${RESET}"

    echo ""

    # Step 6: Removes the self signed certificates and the basic authentication file used by the Swagger API Documentation
    echo -e "${YELLOW}Removing the Swagger API Documentation Basic Authentication file and self signed certificates files...${RESET}"

    echo ""

    rm -f $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/$HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE
    rm -f $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/$HOST_EDIRECTORY_API_SWAGGER_KEY_FILE
    rm -f $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/$HOST_EDIRECTORY_API_SWAGGER_CERTIFICATE_FILE

    echo ""

    echo -e "${CYAN}Showing the Required Files Directory:${RESET}"
    ls -l $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY

    echo ""
else
    echo -e "${YELLOW}The Docker Containers '$EDIRECTORY_API_CONTAINER_NAME' and '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' don't exist or have been deleted.${RESET}"
    
    echo ""

    echo -e "${CYAN}Run the builder script if you want to create the EDirectory API and EDirectory API Swagger Docker Containers.${RESET}"

    exit 0
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"