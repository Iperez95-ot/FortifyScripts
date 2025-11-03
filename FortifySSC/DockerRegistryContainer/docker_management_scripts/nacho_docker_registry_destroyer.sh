#!/bin/bash

# Script that destroys a Docker Network, a Docker Volume, a Docker Registry and a Docker Registry UI from a linux system 

# Exits immediately if a command exits with a non-zero status
#set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
CUSTOM_REGISTRY_NETWORK_NAME="nacho-docker-registry-network"						           		# Docker Registry Network Name
CUSTOM_VOLUME_NAME="nacho-docker-volume-registry-data"                                		   	           		# Docker Registry Volume name
CUSTOM_REGISTRY_CONTAINER_NAME="nacho-server-docker-registry"                                                      		# Docker Registry Container name
CUSTOM_REGISTRY_CONTAINER_IPADDRESS="192.168.1.12"                                                                 		# Docker Registry Container IP Address
CUSTOM_REGISTRY_IMAGE_NAME="registry"                                                                              		# Docker Registry Image name
CUSTOM_REGISTRY_UI_CONTAINER_NAME="nacho-server-docker-registry-ui"  						   		# Docker Registry UI Container Name
CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS="192.168.1.11"                                                             		# Docker Registry UI Container IP Address
CUSTOM_UI_IMAGE_NAME="joxit/docker-registry-ui"								          		# Docker Registry UI Image name
CUSTOM_REGISTRY_IMAGE_TAG="latest"                                                                                              # Docker Registry and Docker Registry UI Image Tag name
CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE=".htpasswd"											# Basic Authentication file for the Docker Registry UI
HOST_REGISTRY_CERTIFICATES_DIRECTORY="/opt/Scripts/DockerRegistryContainer/certificates/registry"                		# Host local directory of the certificates used by the Docker Registry
HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY="/opt/Scripts/DockerRegistryContainer/certificates/registryui"                          # Host local directory of the certificates used by the Docker Registry UI
HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY="/etc/docker/certs.d"                             			# Host local directory of the Docker Registry and Docker Registry UI certificates used by the Docker Client
HOST_DOCKER_CLIENT_DIRECTORY="/etc/docker"											# Host local directory for the Docker Client files
HOST_TRUSTED_CA_DIRECTORY="/etc/pki/ca-trust/source/anchors/"									# Host local directory of the Trusted CA store
HOST_NETWORK_MANAGER_DIRECTORY="/etc/sysconfig/network-scripts"								        # Host local directory of the Network Manager files
HOST_CUSTOM_NETWORK_INTERFACE="macvlan0"											# Host custom network interface used to communicate with the Docker Containers
HOST_IFCFG_FILE="ifcfg-${HOST_CUSTOM_NETWORK_INTERFACE}"									# IFCG file to be used to create a persistent macvlan interface config
HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY="/opt/Scripts/DockerRegistryContainer/auth"					        # Host local directory of the Basic Authentication file for the Docker Registry UI
CUSTOM_REGISTRY_CERTIFICATE_FILE="nacho-docker-registry.crt"                                                       		# Self-signed SSL certificate to be used for the Docker Registry
CUSTOM_REGISTRY_UI_CERTIFICATE_FILE="nacho-docker-registry-ui.crt"								# Self-signed SSL certificate to be used for the Docker Registry UI

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
echo -e "${CYAN}Proceeding to remove the Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME', the Docker Volume '$CUSTOM_VOLUME_NAME', the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' and the Docker Registry UI '$CUSTOM_REGISTRY_UI_CONTAINER_NAME at $(date)...${RESET}"

echo ""

# Checks if the Docker Network, the Docker Volume, the Docker Registry and the Docker Registry UI exist
echo -e "${YELLOW}Checking if the Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME', the Docker Volume '$CUSTOM_VOLUME_NAME', the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' and the Docker Registry UI '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the Docker Network existance
docker network ls | grep -q "$CUSTOM_REGISTRY_NETWORK_NAME"
NETWORK_EXISTS=$?

# Checks for the Docker Volume existance
docker volume ls | grep -q "$CUSTOM_VOLUME_NAME"
VOLUME_EXISTS=$?

# Checks for the Docker Registry Container existance
docker container ps -a | grep -q "$CUSTOM_REGISTRY_CONTAINER_NAME"
REGISTRY_EXISTS=$?

# Checks for Docker Registry UI Container existance
docker container ps -a | grep -q "$CUSTOM_REGISTRY_UI_CONTAINER_NAME"
REGISTRY_UI_EXISTS=$?

if [ $NETWORK_EXISTS -eq 0 ] && [ $VOLUME_EXISTS -eq 0 ] && [ $REGISTRY_EXISTS -eq 0 ] && [ $REGISTRY_UI_EXISTS -eq 0 ]; then
    echo -e "${YELLOW}the Docker Network, the Docker Volume, the Docker Registry and the Docker Registry UI exist.${RESET}"

    echo ""

    # Step 1: Stops the Docker Registry and the Docker Registry UI containers
    echo -e "${YELLOW}Stopping the '$CUSTOM_REGISTRY_CONTAINER_NAME' and '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' Docker Containers.${RESET}"

    echo ""
    
    docker stop "$CUSTOM_REGISTRY_CONTAINER_NAME"
    registry_docker_container_stop_status=$?             # Captures the exit code immediately
    check_success $registry_docker_container_stop_status "Failed to stop the container '$CUSTOM_REGISTRY_CONTAINER_NAME'."
    
    echo ""

    docker stop "$CUSTOM_REGISTRY_UI_CONTAINER_NAME"
    registry_ui_docker_container_stop_status=$?             # Captures the exit code immediately
    check_success $registry_ui_docker_container_stop_status "Failed to stop the container '$CUSTOM_REGISTRY_UI_CONTAINER_NAME'."

    echo ""

    echo -e "${GREEN}Docker Containers '$CUSTOM_REGISTRY_CONTAINER_NAME' and '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' have been stopped!${RESET}"

    echo ""

    # Step 2: Removes the Docker Registry and the Docker Registry UI containers
    echo -e "${YELLOW}Removing the '$CUSTOM_REGISTRY_CONTAINER_NAME' and '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' Docker Containers.${RESET}"

    echo ""

    docker rm "$CUSTOM_REGISTRY_CONTAINER_NAME"
    registry_docker_container_rm_status=$?               # Captures the exit code immediately
    check_success $registry_docker_container_rm_status "Failed to remove the container '$CUSTOM_REGISTRY_CONTAINER_NAME'."
    
    echo ""

    docker rm "$CUSTOM_REGISTRY_UI_CONTAINER_NAME"
    registry_ui_docker_container_rm_status=$?               # Captures the exit code immediately
    check_success $registry_ui_docker_container_rm_status "Failed to remove the container '$CUSTOM_REGISTRY_UI_CONTAINER_NAME'."
    
    echo ""

    echo -e "${GREEN}Docker Containers '$CUSTOM_REGISTRY_CONTAINER_NAME' and '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' have been removed!${RESET}"

    echo ""

    # Step 3: Removes the Docker Registry and the Docker Registry UI images
    echo -e "${YELLOW}Removing the '$CUSTOM_REGISTRY_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG' and '$CUSTOM_UI_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG' Docker Images.${RESET}"

    echo ""

    docker rmi "$CUSTOM_REGISTRY_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG"  
    registry_docker_image_rm_status=$?                   # Captures the exit code immediately
    check_success $registry_docker_image_rm_status "Failed to remove the image '$CUSTOM_REGISTRY_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG'."
    
    echo ""

    docker rmi "$CUSTOM_UI_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG"  
    registry_ui_docker_image_rm_status=$?                   # Captures the exit code immediately
    check_success $registry_ui_docker_image_rm_status "Failed to remove the image '$CUSTOM_UI_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG'."
    
    echo ""

    # Step 4: Removes the Docker Registry, the Docker Registry UI self signed certificates, the Custom Network Interface related to the Docker Containers, the static ip routes of the Docker Containers and the Basic Authentication file used by the UI
    echo -e "${YELLOW}Removing the Docker Registry and Docker Registry UI self signed certificates, the custom network interface related to the Docker Containers and the static ip routes of the Docker Containers.${RESET}"

    echo ""

    # Removes the static routes for the Docker Registry and Docker Registry UI containers
    echo -e "${YELLOW}Removing the static routes for the Registry and UI containers...${RESET}"
    
    echo ""
    
    # Removes the route to the Registry container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} -ipv4.routes "${CUSTOM_REGISTRY_CONTAINER_IPADDRESS}/32"

    # Removes the route to the Registry UI container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} -ipv4.routes "${CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS}/32"

    echo ""

    # Removes the Custom Network Interface related to the Docker Containers and the IFCG file related to it
    echo -e "${YELLOW}Removing the custom network interface, the ip routes and the IFCG file related tot the Docker Registry Containers.${RESET}"

    echo ""

    nmcli connection delete $HOST_CUSTOM_NETWORK_INTERFACE
    nmcli connection reload
    rm -f $HOST_NETWORK_MANAGER_DIRECTORY/$HOST_IFCFG_FILE
    
    echo ""

    sleep 5

    echo -e "${CYAN}Current Network Interfaces:${RESET}"
    ifconfig -a

    echo ""

    echo -e "${CYAN}Network Manager Directory:${RESET}"
    ls -l $HOST_NETWORK_MANAGER_DIRECTORY

    echo ""

    # Removes the Certificates files from the Trusted CA Store and Certificates Directories 
    echo -e "${YELLOW}Removing the certificates files from the Trusted CA Store and the Certificates Directories.${RESET}"

    echo ""
    								
    rm -f $HOST_REGISTRY_CERTIFICATES_DIRECTORY/*
    rm -f $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/*
    rm -f $HOST_TRUSTED_CA_DIRECTORY/$CUSTOM_REGISTRY_CERTIFICATE_FILE
    rm -f $HOST_TRUSTED_CA_DIRECTORY/$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE

    echo ""

    echo -e "${CYAN}Showing the Docker Registry Certificate Directory:${RESET}"
    ls -l $HOST_REGISTRY_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${CYAN}Showing the Docker Registry UI Certificate Directory:${RESET}"
    ls -l $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${CYAN}Showing the Trusted CA Store:${RESET}"
    ls -l $HOST_TRUSTED_CA_DIRECTORY

    echo ""

    # Removes the Docker Registry and Docker Registry UI Docker Client Directory
    echo -e "${YELLOW}Removes the Docker Registry and Docker Registry UI Docker Client Directory.${RESET}"

    echo ""

    rm -rf $HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${CYAN}Showing the Docker Client Directory:${RESET}"
    ls -l $HOST_DOCKER_CLIENT_DIRECTORY

    echo ""

    # Removes the Docker Registry UI Basic Authentication file
    echo -e "${YELLOW}Removes the Docker Registry UI Basic Authentication file.${RESET}"

    echo ""

    rm -f $HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE

    echo ""

    echo -e "${CYAN}Showing the Docker Registry Auth Directory:${RESET}"
    ls -l $HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY

    echo ""
        
    # Step 5: Removes the Docker Volume
    echo -e "${YELLOW}Removing the '$CUSTOM_VOLUME_NAME' Docker Volume.${RESET}"

    echo ""

    docker volume rm "$CUSTOM_VOLUME_NAME"  
    docker_volume_rm_status=$?                   # Captures the exit code immediately
    check_success $docker_volume_rm_status "Failed to remove the volume '$CUSTOM_VOLUME_NAME'."

    echo ""
    
    # Step 5: Removes the Docker Network
    echo -e "${YELLOW}Removing the '$CUSTOM_REGISTRY_NETWORK_NAME' Docker Network.${RESET}"

    echo ""

    echo ""

    docker network rm "$CUSTOM_REGISTRY_NETWORK_NAME"  
    docker_network_rm_status=$?                   # Captures the exit code immediately
    check_success $docker_network_rm_status "Failed to remove the image '$CUSTOM_REGISTRY_NETWORK_NAME'."
    
    echo ""
else
    echo -e "${YELLOW}The Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME', the Docker Volume '$CUSTOM_VOLUME_NAME', the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' and the Docker Registry UI '$$CUSTOM_REGISTRY_UI_CONTAINER_NAME' don't exist or have been deleted.${RESET}"
    
    echo ""

    echo -e "${CYAN}Run the builder script if you want to create the Docker Components.${RESET}"

    exit 0
fi

# Prints a success message
echo -e "${GREEN}Execution completed successfully!${RESET}"