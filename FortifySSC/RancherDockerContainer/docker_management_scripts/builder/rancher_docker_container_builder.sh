#!/bin/bash

# Script that builds a Docker Container and a Docker Volume for SUSE Rancher 
# based on the Rancher Docker Container with a network in a linux system

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
echo -e "${CYAN}Proceeding to create the Docker Container for Rancher at $(date)...${RESET}"

echo ""

# Checks if the Docker Volume and the Docker Container for Rancher exist
echo -e "${YELLOW}Checking if the Docker Container '$RANCHER_CONTAINER_NAME' and the Docker Volume '$RANCHER_VOLUME_NAME' exist...${RESET}"

echo ""

# Checks for the Rancher Docker Volume existance
docker volume ls | grep -q "$RANCHER_VOLUME_NAME"
RANCHER_VOLUME_EXISTS=$?

# Checks for Rancher Docker Container existance
docker container ps -a | grep -q "$RANCHER_CONTAINER_NAME"
RANCHER_CONTAINER_EXISTS=$?

# Checks if the Docker Volume and the Docker Container for Rancher exist and if not, 
# proceeds to create them and perform the necessary configurations
if [ $RANCHER_VOLUME_EXISTS -ne 0 ] || [ $RANCHER_CONTAINER_EXISTS -ne 0 ]; then
    echo -e "${RED}The Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$RANCHER_CONTAINER_NAME' don't exist.${RESET}"
    
    echo ""

    # Step 1: Creates a Key file, a Certificate file based on the Key file, 
    # a PEM file based on the Key and Certificate files from the Rancher Docker Container 
    # and adds the Certificate file from the Rancher Docker Container to the system's trusted CA store
    echo -e "${YELLOW}Generating the Key file '$RANCHER_PRIVATE_KEY_FILE'...${RESET}"

    # Generates the Key file for the Rancher Docker Container
    cd $HOST_RANCHER_CERTIFICATES_DIRECTORY
    openssl genrsa -out "$RANCHER_PRIVATE_KEY_FILE" $RANCHER_CERTIFICATE_KEY_SIZE
       
    echo ""

    echo -e "${YELLOW}Generating the certificate file '$RANCHER_CERTIFICATE_FILE' based on the '$RANCHER_PRIVATE_KEY_FILE' key file...${RESET}"

    echo ""

    # Generates the Certificate file based on the Key file for the Rancher Docker Container
    openssl req -x509 -new -key "$RANCHER_PRIVATE_KEY_FILE" \
     -sha256 -days "$RANCHER_CERTIFICATE_DAYS_VALID" -out "$RANCHER_CERTIFICATE_FILE" \
     -subj "$RANCHER_CERTIFICATE_SUBJECT" \
     -addext "subjectAltName = $RANCHER_CERTIFICATE_SAN_VALUE"

    echo ""

    echo -e "${CYAN}Certificates files generated:${RESET}"
    ls -l $HOST_RANCHER_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${YELLOW}Adding the certificate file '$RANCHER_CERTIFICATE_FILE' to the system's trusted CA certificates...${RESET}"

    echo ""

    # Copies the Certificate file to the trusted anchors directory
    cp "$HOST_RANCHER_CERTIFICATES_DIRECTORY/$RANCHER_CERTIFICATE_FILE" "/etc/pki/ca-trust/source/anchors/"
    
    # Updates the CA trust database
    update-ca-trust extract

    echo ""

    echo -e "${GREEN}Certificate '$RANCHER_CERTIFICATE_FILE' file has been added to the system CA trust store successfully!${RESET}"
    
    echo ""

    # Creates the PEM file based on the Key files and Certificate files for the Rancher Docker Container
    echo -e "${YELLOW}Creating the PEM file '$RANCHER_PEM_FILE' based on the '$RANCHER_PRIVATE_KEY_FILE' key file and '$RANCHER_CERTIFICATE_FILE' certificate file...${RESET}"

    echo "" 

    cat "$RANCHER_PRIVATE_KEY_FILE" "$RANCHER_CERTIFICATE_FILE" > "$RANCHER_PEM_FILE"
    
    echo ""

    echo -e "${CYAN}New files created:${RESET}"
    ls -l     

    echo ""

    # Step 2: Creates the Docker Volume to store the data of the Rancher Docker Container
    echo -e "${YELLOW}Creating the Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME'...${RESET}"

    echo ""
   
    docker volume create $RANCHER_DATA_DOCKER_VOLUME_NAME
    volume_rancher_data_creation_status=$?                                                                        # Captures the exit code immediately
    check_success $volume_rancher_data_creation_status "Failed to create the '$RANCHER_DATA_DOCKER_VOLUME_NAME' Docker Volume." 

    echo ""
    
    # Lists the settings of the new Docker Volume 
    echo -e "${CYAN}Showing the summary of the Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' ${RESET}"
    docker volume ls | grep "$RANCHER_DATA_DOCKER_VOLUME_NAME"

    echo ""

    # Inspects the new Docker Volume
    echo -e "${CYAN}The New Docker Volume settings are the following: ${RESET}"
    docker volume inspect $RANCHER_DATA_DOCKER_VOLUME_NAME

    echo ""
    
    echo -e "${GREEN}Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' was created successfully.${RESET}"

    echo ""

    # Step 3: Adding a route to the Rancher Docker Container
    echo -e "${YELLOW}Adding a route to the Docker Container '$RANCHER_CONTAINER_NAME' to the '$HOST_CUSTOM_NETWORK_INTERFACE'...${RESET}"

    echo ""

    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} +ipv4.routes "${RANCHER_CONTAINER_IPADDRESS}/32"

    # Applies the changes
    nmcli connection up ${HOST_CUSTOM_NETWORK_INTERFACE}
    
    echo ""

    # Step 4: Builds the Rancher Docker Container and attaches it to the recently created Docker Volumes
    echo -e "${YELLOW}Building the Docker Container '$RANCHER_CONTAINER_NAME' and attaching it to the Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME'...${RESET}"

    echo ""

    docker run --privileged -d --name $RANCHER_CONTAINER_NAME -p $RANCHER_HTTPS_HOST_PORT:$RANCHER_HTTPS_CONTAINER_PORT --restart=unless-stopped --hostname $RANCHER_CONTAINER_HOSTNAME --network $DOCKER_NETWORK_NAME --ip $RANCHER_CONTAINER_IPADDRESS -v $RANCHER_DATA_DOCKER_VOLUME_NAME:$RANCHER_DATA_DIRECTORY -v $HOST_RANCHER_CERTIFICATES_DIRECTORY:$RANCHER_CERTIFICATES_DIRECTORY $RANCHER_DOCKER_IMAGE_NAME     
    build_rancher_container_status=$?                                                                         # Captures the exit code immediately
    check_success $build_rancher_container_status "Failed to build the '$RANCHER_CONTAINER_NAME' Docker Container."

    echo ""

    # Shows the new Docker Container information
    echo -e "${CYAN}New Docker Container created:${RESET}"
    docker ps -a --filter "name=$RANCHER_CONTAINER_NAME"

    echo ""
       
    echo -e "${GREEN}The Docker Container '$RANCHER_CONTAINER_NAME' was created successfully.${RESET}"

    echo ""
else
    echo -e "${YELLOW}The Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$RANCHER_CONTAINER_NAME' already exist.${RESET}"

    exit 0 
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"

























