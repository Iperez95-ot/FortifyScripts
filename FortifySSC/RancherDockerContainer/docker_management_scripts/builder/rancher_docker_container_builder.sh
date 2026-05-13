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

# Checks for the Rancher Docker Container existance
docker container ps -a | grep -q "$RANCHER_CONTAINER_NAME"
RANCHER_CONTAINER_EXISTS=$?

# Checks if the Docker Volume and the Docker Container for Rancher exist and if not, proceeds to create them and perform the necessary configurations
if [ $RANCHER_VOLUME_EXISTS -ne 0 ] || [ $RANCHER_CONTAINER_EXISTS -ne 0 ]; then
    echo -e "${RED}The Docker Volume '$RANCHER_VOLUME_NAME' and the Docker Container '$RANCHER_CONTAINER_NAME' don't exist.${RESET}"
    
    echo ""

    # Step 1: Creates a Key file, a Certificate file based on the Key file, a PEM file based on the Key and Certificate files 
    # from the Rancher Docker Container and adds the Certificate file from the Rancher Docker Container to the system's trusted CA store
    echo -e "${YELLOW}Generating the Key file '$RANCHER_KEY_FILE'...${RESET}"

    # Generates the Key file for the EDirectory Docker Container
    cd $HOST_RANCHER_CERTIFICATES_DIRECTORY
    openssl genrsa -aes256 -passout pass:"$RANCHER_CERTIFICATE_PASSWORD" -out "$RANCHER_PRIVATE_KEY_FILE" $RANCHER_CERTIFICATE_KEY_SIZE
       
    echo ""

    echo -e "${YELLOW}Generating the certificate file '$RANCHER_CERTIFICATE_FILE' based on the '$RANCHER_PRIVATE_KEY_FILE' key file...${RESET}"

    echo ""

    # Generates the Certificate file based on the Key file for the EDirectory Docker Container
    openssl req -x509 -new -key "$RANCHER_PRIVATE_KEY_FILE" -passin pass:"$RANCHER_CERTIFICATE_PASSWORD" \
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

    # Creates the PEM file based on the Key files and Certificate files for the EDirectory Docker Container
    echo -e "${YELLOW}Creating the PEM file '$RANCHER_PEM_FILE' based on the '$RANCHER_PRIVATE_KEY_FILE' key file and '$RANCHER_CERTIFICATE_FILE' certificate file...${RESET}"

    echo "" 

    cat "$RANCHER_PRIVATE_KEY_FILE" "$RANCHER_CERTIFICATE_FILE" > "$RANCHER_PEM_FILE"
    
    echo ""

    echo -e "${CYAN}New files created:${RESET}"
    ls -l     

    echo ""

    # Step 2: Creates the Docker Volume to store the ldap data of the EDirectory Docker Container
    echo -e "${YELLOW}Creating the Docker Volume '$RANCHER_DATA_DOCKER_VOLUME_NAME'...${RESET}"

    echo ""
   
    docker volume create $RANCHER_DATA_DOCKER_VOLUME_NAME
    volume_ldap_data_creation_status=$?                                                                        # Captures the exit code immediately
    check_success $volume_ldap_data_creation_status "Failed to create the '$RANCHER_LDAP_DATA_DOCKER_VOLUME_NAME' Docker Volume." 

    echo ""
    
    # Lists the settings of the new Docker Volume 
    echo -e "${CYAN}Showing the summary of the Docker Volume '$RANCHER_LDAP_DATA_DOCKER_VOLUME_NAME' ${RESET}"
    docker volume ls | grep "$RANCHER_LDAP_DATA_DOCKER_VOLUME_NAME"

    echo ""

    # Inspects the new Docker Volume
    echo -e "${CYAN}The New Docker Volume settings are the following: ${RESET}"
    docker volume inspect $RANCHER_LDAP_DATA_DOCKER_VOLUME_NAME

    echo ""
    
    echo -e "${GREEN}Docker Volume '$RANCHER_LDAP_DATA_DOCKER_VOLUME_NAME' was created successfully.${RESET}"

    echo ""
else 
fi


























docker run --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher