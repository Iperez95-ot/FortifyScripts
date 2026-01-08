#!/bin/bash

# Script that builds a Docker Container for EDirectory API version 25.2 based on the EDirectory Docker Container with a network in a linux system

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
echo -e "${CYAN}Proceeding to create the Docker Container for EDirectory API version $EDIRECTORY_API_VERSION at $(date)...${RESET}"

echo ""

# Checks if the Docker Container for EDirectory API exists
echo -e "${YELLOW}Checking if the Docker Container '$EDIRECTORY_API_CONTAINER_NAME' exists...${RESET}"

echo ""

# Checks for EDirectory API Docker Container existance
docker container ps -a | grep -q "$EDIRECTORY_API_CONTAINER_NAME"
EDIR_API_CONTAINER_EXISTS=$?

if [ $EDIR_API_CONTAINER_EXISTS -ne 0 ]; then
    echo -e "${RED}The Docker Container '$EDIRECTORY_API_CONTAINER_NAME' don't exist.${RESET}"
    
    echo ""

    # Step 1: Adding a route to the EDirectory API Docker Container
    echo -e "${YELLOW}Adding a route to the Docker Container '$EDIRECTORY_API_CONTAINER_NAME' to the '$HOST_CUSTOM_NETWORK_INTERFACE'...${RESET}"

    echo ""

    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} +ipv4.routes "${EDIRECTORY_API_CONTAINER_IPADDRESS}/32"

    # Applies the changes
    nmcli connection up ${HOST_CUSTOM_NETWORK_INTERFACE}
    
    echo ""
    
    # Step 2: Builds the EDirectory API Docker Container
    echo -e "${YELLOW}Building the Docker Container '$EDIRECTORY_API_CONTAINER_NAME'...${RESET}"

    echo ""

    docker run -d --name $EDIRECTORY_API_CONTAINER_NAME --restart unless-stopped --hostname $EDIRECTORY_API_CONTAINER_HOSTNAME --network $DOCKER_NETWORK_NAME --ip $EDIRECTORY_API_CONTAINER_IPADDRESS -p $EDIRECTORY_API_PORT:$EDIRECTORY_API_PORT -v $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY:$EDIRECTORY_API_DATA_DIRECTORY -e ACCEPT_EULA=Y $EDIRECTORY_API_IMAGE_NAME:$EDIRECTORY_API_VERSION
    build_edir_api_container_status=$?                                                                         # Captures the exit code immediately
    check_success $build_edir_api_container_status "Failed to build the '$EDIRECTORY_API_CONTAINER_NAME' Docker Container."

    echo ""

    # Shows the new Docker Container information
    echo -e "${CYAN}New Docker Container created:${RESET}"
    docker ps -a --filter "name=$EDIRECTORY_API_CONTAINER_NAME"

    echo ""

    echo -e "${GREEN}The Docker Container '$EDIRECTORY_API_CONTAINER_NAME' was created successfully.${RESET}"

    echo ""

    echo -e "${Yellow}Proceeding to extract the Private Key and Certificate from EDirectory PFX File...${RESET}"

    echo ""

    # Step 3: Extracts the Private Key and Certificate from the EDirectory pfx File
    EXTRACTED_KEY="$HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/extracted.key"
    
    echo -e "${YELLOW}Extracting the Private Key...${RESET}"

    echo ""
    
    openssl pkcs12 -in "$EDIRECTORY_API_PFX_FILE" -nocerts -out "$EXTRACTED_KEY" -nodes -passin pass:"$EDIRECTORY_API_PFX_PASSWORD"
    
    # Checks if the last command was a success 
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to extract the Private Key from the PFX file. Check your password.${RESET}"

        exit 1
    fi

    echo -e "${CYAN}Extracted Private Key:${RESET}"
    find $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY -type f -name "extracted.key" -exec ls -l {} \;

    echo ""

    echo -e "${YELLOW}Extracting the Certificate...${RESET}"

    echo ""

    EXTRACTED_CRT="$HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/extracted.crt"
    openssl pkcs12 -in "$EDIRECTORY_API_PFX_FILE" -clcerts -nokeys -out "$EXTRACTED_CRT" -passin pass:"$EDIRECTORY_API_PFX_PASSWORD"
   
    # Checks if the last command was a success
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to extract Certificate from PFX.${RESET}"
        
        exit 1
    fi
  
    echo -e "${CYAN}extracted Cerificate:${RESET}"
    find $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY -type f -name "extracted.crt" -exec ls -l {} \;

    echo ""

    echo -e "${GREEN}Key and Certificate successfully extracted to '$HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY' directory.${RESET}"

    echo ""

    # Step 4: Creates an Authentication file for the Basic Authentication on the EDirectory API Swagger Documentation
    echo -e "${YELLOW}Creating the Basic Authentication file for the EDirectory API Swagger Documentation...${RESET}"

    echo ""

    htpasswd -Bbc $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/$HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE $EDIRECTORY_API_SWAGGER_AUTH_USER $EDIRECTORY_API_SWAGGER_AUTH_PASSWORD

    echo ""

    echo -e "${CYAN}New file created:${RESET}"
    cat $HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/$HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE

    echo ""

    # Step 5: Builds the Swagger UI Container for the EDirectory API Docker Container
    echo -e "${YELLOW}Building the Swagger Docker Container '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' for EDirectory API...${RESET}"
    
    echo ""
   
    docker run -d --name $EDIRECTORY_API_SWAGGER_CONTAINER_NAME --restart unless-stopped --network container:$EDIRECTORY_API_CONTAINER_NAME -v "$HOST_EDIRECTORY_API_SWAGGER_YAML_FILE_PATH:$EDIRECTORY_API_SWAGGER_YAML_FILE_PATH:z" -v "$HOST_EDIRECTORY_API_SWAGGER_NGINX_CONFIG_FILE_PATH:$EDIRECTORY_API_SWAGGER_NGINX_CONFIG_FILE_PATH:z" -v "$HOST_EDIRECTORY_API_REQUIRED_FILES_DIRECTORY/$HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE:$EDIRECTORY_API_SWAGGER_NGINX_CERTTIFCATES_DIRECTORY/$HOST_EDIRECTORY_API_SWAGGER_BASIC_AUTH_FILE:ro" -v "$EXTRACTED_CRT:$EDIRECTORY_API_SWAGGER_CERT_FILE_PATH:z" -v "$EXTRACTED_KEY:$EDIRECTORY_API_SWAGGER_KEY_FILE_PATH:z" -e FILTER=true -e SWAGGER_JSON=$EDIRECTORY_API_SWAGGER_YAML_FILE_PATH $EDIRECTORY_API_SWAGGER_IMAGE_NAME
    build_edir_api_container_status=$?
    check_success $build_edir_api_container_status "Failed to build the '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' Docker Container."
   
    echo ""

    echo -e "${GREEN}The Docker Container '$EDIRECTORY_API_SWAGGER_CONTAINER_NAME' was created successfully.${RESET}"

    echo ""

    echo -e "${CYAN}To access the Swagger UI EDirectory API documentation go to: '$EDIRECTORY_API_SWAGGER_URL'.${RESET}"

    echo ""
else
   echo -e "${YELLOW}The Docker Container '$EDIRECTORY_API_CONTAINER_NAME' already exist.${RESET}"

   exit 0
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"