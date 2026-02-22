#!/bin/bash

# Script that builds a Docker Network, a Docker Volume, a Docker Registry and a Docker Registry UI for storing Fortify Docker Images in a linux system

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
echo -e "${CYAN}Proceeding to create the Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME', the Docker Volume '$CUSTOM_REGISTRY_VOLUME_NAME', the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' and the Docker Registry UI '$CUSTOM_REGISTRY_UI_CONTAINER_NAME at $(date)...${RESET}"

echo ""

# Checks if the Docker Network, the Docker Volume, the Docker Registry and the Docker Registry UI exist
echo -e "${YELLOW}Checking if the Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME', the Docker Volume '$CUSTOM_REGISTRY_VOLUME_NAME', the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' and the Docker Registry UI '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the Docker Network existance
docker network ls | grep -q "$CUSTOM_REGISTRY_NETWORK_NAME"
NETWORK_EXISTS=$?

# Checks for the Docker Volume existance
docker volume ls | grep -q "$CUSTOM_REGISTRY_VOLUME_NAME"
VOLUME_EXISTS=$?

# Checks for the Docker Registry Container existance
docker container ps -a | grep -q "$CUSTOM_REGISTRY_CONTAINER_NAME"
REGISTRY_EXISTS=$?

# Checks for Docker Registry UI Container existance
docker container ps -a | grep -q "$CUSTOM_REGISTRY_UI_CONTAINER_NAME"
REGISTRY_UI_EXISTS=$?

# Checks if any of the Docker Network, Docker Volume, Docker Registry Container or Docker Registry UI Container don't exist and creates them if necessary, 
# otherwise it prints a message and exits the script
if [ $NETWORK_EXISTS -ne 0 ] || [ $VOLUME_EXISTS -ne 0 ] || [ $REGISTRY_EXISTS -ne 0 ] || [ $REGISTRY_UI_EXISTS -ne 0 ]; then
    echo -e "${YELLOW}the Docker Network, the Docker Volume, the Docker Registry and the Docker Registry UI don't exist.${RESET}"
    
    echo ""
    
    # Step 1: Creates the Docker Network of the Docker Registry
    echo -e "${YELLOW}Creating the Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME'...${RESET}"
    
    echo ""
   
    docker network create -d macvlan --subnet=$CUSTOM_REGISTRY_NETWORK_SUBNET --gateway=$HOST_IP_GATEWAY -o parent=$CUSTOM_NETWORK_PARENT_INTERFACE $CUSTOM_REGISTRY_NETWORK_NAME
    check_success $? "Failed to create Docker network '$CUSTOM_REGISTRY_NETWORK_NAME'."

    echo ""

    # Lists the settings of the new Docker Network 
    echo -e "${CYAN}Showing the settings of the Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME' ${RESET}"
    docker network ls | grep "$CUSTOM_REGISTRY_NETWORK_NAME"

    echo ""

    echo -e "${GREEN}Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME' was created successfully.${RESET}"

    echo ""

    # Step 2: Creates a persistent macvlan interface config without assigning an IP address so it survives reboots to allow the host (and another servers between the same subnet) to connect to the Registry Containers
    echo -e "${YELLOW}Creating a persistent macvlan interface config for '$HOST_CUSTOM_NETWORK_INTERFACE' with the '$HOST_IFCFG_FILE' file...${RESET}"

    echo ""

    # Creates the connection interface
    nmcli connection add type macvlan con-name $HOST_CUSTOM_NETWORK_INTERFACE ifname $HOST_CUSTOM_NETWORK_INTERFACE dev $CUSTOM_NETWORK_PARENT_INTERFACE mode bridge ipv4.method disabled ipv6.method ignore
    nmcli connection up $HOST_CUSTOM_NETWORK_INTERFACE

    echo ""    

    # Writes the IFCFG file config
    cat > "${HOST_NETWORK_MANAGER_DIRECTORY}/${HOST_IFCFG_FILE}" <<EOF
DEVICE=${HOST_CUSTOM_NETWORK_INTERFACE}
NAME=${HOST_CUSTOM_NETWORK_INTERFACE}
TYPE=Macvlan
PHYSDEV=${CUSTOM_NETWORK_PARENT_INTERFACE}
MODE=bridge
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED=yes
EOF

    echo ""

    # Reloads the NetworkManager and brings the new interface up
    echo -e "${YELLOW}Reloading NetworkManager and bringing up the new interface ${HOST_CUSTOM_NETWORK_INTERFACE}...${RESET}"

    echo ""

    # Reloads NetworkManager
    nmcli connection reload

    # Brings the interface up
    nmcli device set "${HOST_CUSTOM_NETWORK_INTERFACE}" managed yes
    nmcli device connect "${HOST_CUSTOM_NETWORK_INTERFACE}"

    echo ""

    # Adds the static routes for the Docker Registry and Docker Registry UI containers
    echo -e "${YELLOW}Adding static routes for Registry and UI containers...${RESET}"
    
    echo ""
    
    # Adds a route to the Registry container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} +ipv4.routes "${CUSTOM_REGISTRY_CONTAINER_IPADDRESS}/32"

    # Adds a route to the Registry UI container
    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} +ipv4.routes "${CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS}/32"

    # Applies the changes
    nmcli connection up ${HOST_CUSTOM_NETWORK_INTERFACE}
    
    echo ""
 
    # Shows the new interface details
    echo -e "${CYAN}Interface details for ${HOST_CUSTOM_NETWORK_INTERFACE}:${RESET}"
    ip addr show ${HOST_CUSTOM_NETWORK_INTERFACE}
    
    echo ""    

    # Step 3: Creates a Key file, a Certificate file based on the Key file, a PEM file based on the Key and Certificate files from the Docker Registry and adds the Certificate file from the Docker Registry to the system's trusted CA store
    echo -e "${YELLOW}Generating the Key files '$CUSTOM_REGISTRY_PRIVATE_KEY_FILE'...${RESET}"

    echo ""
    
    cd $HOST_REGISTRY_CERTIFICATES_DIRECTORY
    openssl genrsa -out "$CUSTOM_REGISTRY_PRIVATE_KEY_FILE" $CUSTOM_REGISTRY_CERTIFICATE_DAYS_VALID
       
    echo ""

    echo -e "${YELLOW}Generating the certificate file '$CUSTOM_REGISTRY_CERTIFICATE_FILE' based on the '$CUSTOM_REGISTRY_PRIVATE_KEY_FILE' key file...${RESET}"

    echo ""

    openssl req -x509 -new -key "$CUSTOM_REGISTRY_PRIVATE_KEY_FILE" \
     -sha256 -days "$CUSTOM_REGISTRY_CERTIFICATE_DAYS_VALID" -out "$CUSTOM_REGISTRY_CERTIFICATE_FILE" \
     -subj "$CUSTOM_REGISTRY_CERTIFICATE_SUBJECT" \
     -addext "subjectAltName = $CUSTOM_REGISTRY_CERTIFICATE_SAN_VALUE"

    echo ""

    echo -e "${CYAN}Certificates files generated:${RESET}"
    ls -l $HOST_REGISTRY_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${YELLOW}Adding the certificate file '$CUSTOM_REGISTRY_CERTIFICATE_FILE' to the system's trusted CA certificates...${RESET}"

    echo ""

    # Copies the Certificate file to the trusted anchors directory
    cp "$HOST_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_CERTIFICATE_FILE" "/etc/pki/ca-trust/source/anchors/"
    
    # Updates the CA trust database
    update-ca-trust extract

    echo ""

    echo -e "${GREEN}Certificate '$CUSTOM_REGISTRY_CERTIFICATE_FILE' file has been added to the system CA trust store successfully!${RESET}"
    
    echo ""

    echo -e "${YELLOW}Copies the certificate file '$CUSTOM_REGISTRY_CERTIFICATE_FILE' to the Docker CLient certificates directory...${RESET}"

    echo ""

    # Copies the Certificate files to the Docker client certificates directory
    mkdir -p $HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY
    cp $HOST_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_CERTIFICATE_FILE $HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_CERTIFICATE_FILE
    systemctl restart docker

    echo ""

    echo -e "${CYAN}Certificates copied to:${RESET}"
    ls -l $HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY     

    echo ""

    # Creates the PEM file based on the Key files and Certificate files
    echo -e "${YELLOW}Creating the PEM file '$CUSTOM_REGISTRY_PEM_FILE' based on the '$CUSTOM_REGISTRY_PRIVATE_KEY_FILE' key file and '$CUSTOM_REGISTRY_CERTIFICATE_FILE' certificate file...${RESET}"

    echo "" 

    cat "$CUSTOM_REGISTRY_PRIVATE_KEY_FILE" "$CUSTOM_REGISTRY_CERTIFICATE_FILE" > "$CUSTOM_REGISTRY_PEM_FILE"
    
    echo ""

    echo -e "${CYAN}New files created:${RESET}"
    ls -l     

    echo ""

    # Step 4: Creates a Key file and a PEM file for the Docker Registry UI and adds the Certificate file from the Docker Registry UI to the system's trusted CA store
    echo -e "${YELLOW}Generating the Key file '$CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE' and the PEM file '$CUSTOM_REGISTRY_UI_PEM_FILE'...${RESET}"

    echo ""

    openssl req -newkey rsa:2048 -nodes \
      -keyout "$HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE" \
      -x509 -days "$CUSTOM_REGISTRY_CERTIFICATE_DAYS_VALID" \
      -out "$HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PEM_FILE" \
      -subj "$CUSTOM_REGISTRY_UI_CERTIFICATE_SUBJECT" \
      -addext "subjectAltName = $CUSTOM_REGISTRY_UI_CERTIFICATE_SAN_VALUE"

    echo ""

    echo -e "${CYAN}Certificates files generated:${RESET}"
    ls -l $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY

    echo ""

    CUSTOM_REGISTRY_UI_CERTIFICATE_FILE="nacho-docker-registry-ui.crt" # Self-signed SSL certificate to be used for the Docker Registry UI

    # Extracts only the certificate part from the PEM file  
    openssl x509 -in $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PEM_FILE -out $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE

    echo ""

    echo -e "${YELLOW}Copies the certificate file '$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE' to the Trusted CA Store directory...${RESET}"

    echo ""
    
    # Copies the Certificate file to the trusted anchors directory
    cp "$HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE" "$HOST_TRUSTED_CA_DIRECTORY"
    
    # Updates the CA trust database
    update-ca-trust extract

    echo ""

    echo -e "${GREEN}Certificate '$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE' file has been added to the system CA trust store successfully!${RESET}"
    
    echo ""
    
    echo -e "${YELLOW}Copies the certificate file '$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE' to the Docker CLient certificates directory...${RESET}"

    echo ""

    # Copies the Certificate files to the Docker client certificates directory
    cp $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE $HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_CERTIFICATE_FILE
    systemctl restart docker

    echo ""

    echo -e "${CYAN}Certificates copied to:${RESET}"
    ls -l $HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY     

    echo ""

    # Step 5: Creates an Authentication file for the Basic Authentication on the Docker Registry UI
    echo -e "${YELLOW}Creating the Basic Authentication file for the Docker Registry UI...${RESET}"

    echo ""

    htpasswd -Bbc $HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE $CUSTOM_REGISTRY_UI_AUTH_USER $CUSTOM_REGISTRY_UI_AUTH_PASSWORD

    echo ""

    echo -e "${CYAN}New file created:${RESET}"
    cat $HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE

    echo ""

    # Step 6: Creates the Docker Volume to store the data of the Docker Registry
    echo -e "${YELLOW}Creating the Docker Volume '$CUSTOM_REGISTRY_VOLUME_NAME'...${RESET}"

    echo ""
   
    docker volume create $CUSTOM_REGISTRY_VOLUME_NAME
    volume_creation_status=$?                                                                        # Captures the exit code immediately
    check_success $volume_creation_status "Failed to create the '$CUSTOM_REGISTRY_VOLUME_NAME' Docker Volume." 

    echo ""
    
    # Lists the settings of the new Docker Volume 
    echo -e "${CYAN}Showing the summary of the Docker Volume '$CUSTOM_REGISTRY_VOLUME_NAME' ${RESET}"
    docker volume ls | grep "$CUSTOM_REGISTRY_VOLUME_NAME"

    echo ""

    # Inspects the new Docker Volume
    echo -e "${CYAN}The New Docker Volume settings are the following: ${RESET}"
    docker volume inspect $CUSTOM_REGISTRY_VOLUME_NAME

    echo ""
    
    echo -e "${GREEN}Docker Volume '$CUSTOM_REGISTRY_VOLUME_NAME' was created successfully.${RESET}"

    echo ""

    # Step 7: Builds the Docker Registry and attachs it to the recently created Docker Volume
    echo -e "${YELLOW}Building the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' and attaching it to the Docker Volume '$CUSTOM_REGISTRY_VOLUME_NAME'...${RESET}"

    echo ""

    docker run -d -p $CUSTOM_REGISTRY_PORT:$CUSTOM_REGISTRY_PORT --name $CUSTOM_REGISTRY_CONTAINER_NAME --restart unless-stopped --net $CUSTOM_REGISTRY_NETWORK_NAME --ip $CUSTOM_REGISTRY_CONTAINER_IPADDRESS --hostname $CUSTOM_REGISTRY_HOSTNAME -v $CUSTOM_REGISTRY_VOLUME_NAME:$CUSTOM_REGISTRY_DATA_DIRECTORY -v $HOST_REGISTRY_CERTIFICATES_DIRECTORY:$CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY -v $HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE:$CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE:ro -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM="basic-realm" -e REGISTRY_AUTH_HTPASSWD_PATH=$CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE -e REGISTRY_HTTP_ADDR=0.0.0.0:$CUSTOM_REGISTRY_PORT -e REGISTRY_HTTP_TLS_CERTIFICATE=$CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_CERTIFICATE_FILE -e REGISTRY_HTTP_TLS_KEY=$CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_PRIVATE_KEY_FILE -e "REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin=[\"$CUSTOM_REGISTRY_UI_URL\"]" -e REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods='["HEAD", "GET", "OPTIONS", "DELETE"]' -e REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers='["Authorization", "Accept", "Cache-Control"]' -e REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials='["true"]' $CUSTOM_REGISTRY_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG
    build_registry_status=$?                                                                         # Captures the exit code immediately
    check_success $build_registry_status "Failed to build the '$CUSTOM_REGISTRY_CONTAINER_NAME' Docker Registry." 

    echo ""

    # Shows the new Docker Registry information
    echo -e "${CYAN}New Docker Container created:${RESET}"
    docker ps -a --filter "name=$CUSTOM_REGISTRY_CONTAINER_NAME"

    echo ""
       
    echo -e "${GREEN}Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' was created successfully.${RESET}"

    echo ""
   
    echo -e "${CYAN}To view the Docker Registry (Back End) go to: '$CUSTOM_REGISTRY_URL' in any browser.${RESET}"

    echo ""

    # Step 8: Builds the Docker Registry UI Container and attachs it to the recenttly created Docker Registry
    echo -e "${YELLOW}Creating Docker Registry UI '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' and attaching it to the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME'...${RESET}"

    echo ""

    docker run -d --name $CUSTOM_REGISTRY_UI_CONTAINER_NAME --restart unless-stopped --pull always --net $CUSTOM_REGISTRY_NETWORK_NAME --ip $CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS --hostname $CUSTOM_REGISTRY_UI_HOSTNAME -p $CUSTOM_REGISTRY_UI_HOST_HTTP_PORT:$CUSTOM_REGISTRY_UI_CONTAINER_HTTP_PORT -v $HOST_REGISTRY_UI_NGINX_CONF_DIRECTORY/$CUSTOM_REGISTRY_UI_HTTPS_NGINX_FILE:$CUSTOM_REGISTRY_UI_NGINX_CONF_DIRECTORY/$CUSTOM_REGISTRY_UI_HTTPS_NGINX_FILE -v $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE:$CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE -v $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PEM_FILE:$CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PEM_FILE -v $HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE:$CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE:ro -e REGISTRY_TITLE="$CUSTOM_REGISTRY_TITLE" -e DOCKER_REGISTRY_UI_TITLE="$CUSTOM_REGISTRY_UI_HEADER_TITLE" -e REGISTRY_URL="https://$CUSTOM_REGISTRY_HOSTNAME:$CUSTOM_REGISTRY_PORT" -e SINGLE_REGISTRY="true" -e DELETE_IMAGES="true" $CUSTOM_UI_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG
    build_registry_ui_status=$?   
    check_success $build_registry_ui_status "Failed to create the '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' Docker Container."

    echo ""

    # Shows the new Docker Registry UI information
    echo -e "${CYAN}New Docker Container created:${RESET}"
    docker ps -a --filter "name=$CUSTOM_REGISTRY_UI_CONTAINER_NAME"

    echo ""
       
    echo -e "${GREEN}Docker Registry '$CUSTOM_REGISTRY_UI_CONTAINER_NAME' was created successfully.${RESET}"

    echo ""
    
    echo -e "${CYAN}To view the Docker Registry (UI) go to: '$CUSTOM_REGISTRY_UI_URL' in any browser.${RESET}"

    echo ""

else
    echo -e "${YELLOW}The Docker Network '$CUSTOM_REGISTRY_NETWORK_NAME', the Docker Volume '$CUSTOM_REGISTRY_VOLUME_NAME', the Docker Registry '$CUSTOM_REGISTRY_CONTAINER_NAME' and the Docker Registry UI '$$CUSTOM_REGISTRY_UI_CONTAINER_NAME' already exist.${RESET}"

    exit 0
fi

# Prompts for reboot
read -p "$(echo -e "${CYAN}Installation complete. Do you want to reboot now? (y/N): ${RESET}")" REBOOT

# Checks the user's response and reboots if they answered yes, otherwise it prints a final message and exits
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    reboot
else
    # Prints the final message
    echo -e "${GREEN}Execution completed successfully!${RESET}"
fi