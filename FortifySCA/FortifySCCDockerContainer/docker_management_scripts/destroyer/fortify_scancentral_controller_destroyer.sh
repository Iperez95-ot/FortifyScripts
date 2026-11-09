#!/bin/bash

# Script that Destroys a Docker Network, a Docker Volume, a Docker Image and a Docker Container for 
# Fortify ScanCentral SAST Controller in a Linux system

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
        echo -e "${RED}Error: $message${RESET}"                                                # Prints the error message in red
        exit $exit_code                                                                          # Exits the script with the captured failure status
    fi
}

# Prints the first message
echo -e "${CYAN}Proceeding to destroy the Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME', the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME', the Docker Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify ScanCentral Controller version
echo -ne "${CYAN}Enter the Fortify ScanCentral Controller version to pull from Docker Hub (e.g: 25.4.1, 26.2.0, 26.2.1, 26.2.0.0666.172, etc): ${RESET}"
    
read -r FORTIFY_SCANCENTRAL_CONTROLLER_VERSION    # Fortify ScanCentral Controller version to be installed and deployed										                                                                

# Checks if the Fortify ScanCentral Controller version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SCANCENTRAL_CONTROLLER_VERSION" ]]; then
    echo -e "${RED}Error: Fortify ScanCentral Controller version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Sets the Fortify ScanCentral Controller Docker Image Tag to the user-provided version
SCANCENTRAL_CONTROLLER_IMAGE_TAG=$FORTIFY_SCANCENTRAL_CONTROLLER_VERSION 

# Checks if the Docker Network, the Docker Volume and the Fortify ScanCentral Controller Container exist
echo -e "${YELLOW}Checking if the Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME', the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' and the Docker Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the Docker Network existence
docker network ls | grep -q "$SCANCENTRAL_CONTROLLER_NETWORK_NAME"
NETWORK_EXISTS=$?

# Checks for the Docker Volume existence
docker volume ls | grep -q "$SCANCENTRAL_CONTROLLER_VOLUME_NAME"
VOLUME_EXISTS=$?

# Checks for the Docker Controller Container existence
docker container ps -a | grep -q "$SCANCENTRAL_CONTROLLER_CONTAINER_NAME"
CONTROLLER_EXISTS=$?

# Checks if the Docker Network, the Docker Volume or the Fortify ScanCentral Controller Container exist
if [ $NETWORK_EXISTS -eq 0 ] || [ $VOLUME_EXISTS -eq 0 ] || [ $CONTROLLER_EXISTS -eq 0 ]; then
    echo -e "${YELLOW}The Docker Network, the Docker Volume or the Fortify ScanCentral Controller Container exist.${RESET}"

    echo ""

    # Step 1: Stops the Fortify ScanCentral Controller Docker Container
    echo -e "${YELLOW}Stopping the '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""
    
    # Checks if the Fortify ScanCentral Controller Docker Container is running before attempting to stop it
    if docker ps -q --filter "name=^${SCANCENTRAL_CONTROLLER_CONTAINER_NAME}$" | grep -q .; then
        # Stops Fortify ScanCentral Controller Docker Container
        docker stop "$SCANCENTRAL_CONTROLLER_CONTAINER_NAME"

        controller_docker_container_stop_status=$?             # Captures the exit code immediately
        check_success $controller_docker_container_stop_status "Failed to stop the container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME'."
    else
        echo -e "${CYAN}Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' is already stopped.${RESET}"
    fi

    echo ""

    echo -e "${GREEN}Docker Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' has been stopped!${RESET}"

    echo ""

    # Step 2: Removes the Fortify ScanCentral Controller Docker Container
    echo -e "${YELLOW}Removing the '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' Docker Container.${RESET}"

    echo ""

    # Checks if the Docker Container exists before attempting to remove it
    if docker ps -a -q --filter "name=^${SCANCENTRAL_CONTROLLER_CONTAINER_NAME}$" | grep -q .; then
        # Removes Fortify ScanCentral Controller Docker Container
        docker rm "$SCANCENTRAL_CONTROLLER_CONTAINER_NAME"
        
        controller_docker_container_rm_status=$?               # Captures the exit code immediately
        check_success $controller_docker_container_rm_status "Failed to remove the container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME'."
    fi

    echo ""

    echo -e "${GREEN}The Docker Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' has been removed!${RESET}"

    echo ""

    # Step 3: Removes Fortify ScanCentral Controller Docker Image
    echo -e "${YELLOW}Removing the '$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG' Docker Image.${RESET}"

    echo ""

    SCANCENTRAL_REPO_NAME=$(echo "$SCANCENTRAL_CONTROLLER_IMAGE_NAME" | awk -F'/' '{print $NF}')

    # Checks if the Fortify ScanCentral Controller Docker Image exists before attempting to remove it
    if docker images -q "$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG" | grep -q .; then

        # Removes Fortify ScanCentral Controller Docker Image
        docker rmi "$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG"  

        controller_docker_image_rm_status=$?                   # Captures the exit code immediately
        check_success $controller_docker_image_rm_status "Failed to remove the image '$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG'."
    fi

    echo ""

    echo -e "${GREEN}The Docker Image '$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG' has been removed!${RESET}"

    echo ""

    # Step 4: Removes the self signed certificates, the Custom Network Interface, the static ip routes, and the secrets
    echo -e "${YELLOW}Removing the self-signed certificates, the custom network interface, the static IP routes and the secrets...${RESET}"

    echo ""

    # Removes the route to the ScanCentral Controller container
    echo -e "${YELLOW}Removing the static route for the Controller container...${RESET}"
    nmcli connection show "${HOST_CUSTOM_NETWORK_INTERFACE}" >/dev/null 2>&1

    # Checks if the custom network interface exists before attempting to remove the static route
    if [ $? -eq 0 ]; then
        nmcli connection modify "${HOST_CUSTOM_NETWORK_INTERFACE}" -ipv4.routes "${SCANCENTRAL_CONTROLLER_CONTAINER_IPADDRESS}/32" 2>/dev/null || true
    fi

    echo ""

    # Removes the Custom Network Interface and the IFCFG file
    echo -e "${YELLOW}Removing the custom network interface and the IFCFG file related to the Docker Containers.${RESET}"

    echo ""

    nmcli connection delete "$HOST_CUSTOM_NETWORK_INTERFACE" 2>/dev/null || true
    nmcli connection reload
    rm -f "${HOST_NETWORK_MANAGER_DIRECTORY}/${HOST_IFCFG_FILE}"
    
    echo ""

    sleep 2

    # Shows the current Network Interfaces
    echo -e "${CYAN}Current Network Interfaces:${RESET}"
    ip addr show

    echo ""

    # Shows the Network Manager Directory
    echo -e "${CYAN}Network Manager Directory:${RESET}"
    ls -l "${HOST_NETWORK_MANAGER_DIRECTORY}"

    echo ""

    # Removes the Certificates files from the Trusted CA Store and local directories
    echo -e "${YELLOW}Removing the certificate files from the Trusted CA Store and local directories.${RESET}"

    echo ""
    								
    rm -rf "${HOST_SCANCENTRAL_CERTIFICATES_DIRECTORY}"
    rm -rf "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}"
    rm -f "${HOST_TRUSTED_CA_DIRECTORY}/${SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE}"

    # Updates the system CA trust database
    update-ca-trust extract

    echo ""

    # Shows the Trusted CA Store directory
    echo -e "${CYAN}Showing the Trusted CA Store:${RESET}"
    ls -l "${HOST_TRUSTED_CA_DIRECTORY}"

    echo ""

    # Removes the Docker Client Certificate Directory
    echo -e "${YELLOW}Removing the Docker Client Certificate Directory.${RESET}"

    echo ""

    rm -rf "${HOST_DOCKER_CLIENT_CUSTOM_CERTIFICATES_DIRECTORY}"
    systemctl restart docker

    echo ""

    # Shows the Docker Client Certificate Directory
    echo -e "${CYAN}Showing the Docker Client Directory:${RESET}"
    ls -l "${HOST_DOCKER_CLIENT_DIRECTORY}"

    echo ""
        
    # Step 5: Removes the Docker Volume
    echo -e "${YELLOW}Removing the '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' Docker Volume.${RESET}"

    echo ""

    # Checks if the Docker Volume exists before attempting to remove it
    if docker volume ls -q | grep -q "^${SCANCENTRAL_CONTROLLER_VOLUME_NAME}$"; then
        docker volume rm "$SCANCENTRAL_CONTROLLER_VOLUME_NAME"  

        docker_volume_rm_status=$?                   # Captures the exit code immediately
        check_success $docker_volume_rm_status "Failed to remove the volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME'."
    fi

    echo ""
    
    # Step 6: Removes the Docker Network
    echo -e "${YELLOW}Removing the '$SCANCENTRAL_CONTROLLER_NETWORK_NAME' Docker Network.${RESET}"

    echo ""

    # Checks if the Docker Network exists before attempting to remove it
    if docker network ls -q --filter "name=^${SCANCENTRAL_CONTROLLER_NETWORK_NAME}$" | grep -q .; then
        docker network rm "$SCANCENTRAL_CONTROLLER_NETWORK_NAME"  

        docker_network_rm_status=$?                   # Captures the exit code immediately
        check_success $docker_network_rm_status "Failed to remove the network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME'."
    fi
    
    echo ""
else
    echo -e "${YELLOW}The Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME', the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' and the Docker Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' don't exist or have already been deleted.${RESET}"
    
    echo ""

    echo -e "${CYAN}Run the builder script if you want to create the Fortify ScanCentral Controller Docker components.${RESET}"

    exit 0
fi

# Prints a success message
echo -e "${GREEN}Execution completed successfully!${RESET}"