#!/bin/bash

# Script that builds a Docker Network, a Docker Volume and a Docker Container 
# for Fortify ScanCentral SAST Controller in a linux system.

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
echo -e "${CYAN}Proceeding to create the Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME', the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' and the Fortify ScanCentral SAST Controller Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' at $(date)...${RESET}"

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

# Checks if the Docker Network, the Docker Volume and the Docker Container exist
echo -e "${YELLOW}Checking if the Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME', the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' and the Docker Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the Docker Network existence
docker network ls | grep -q "$SCANCENTRAL_CONTROLLER_NETWORK_NAME"
NETWORK_EXISTS=$?

# Checks for the Docker Volume existence
docker volume ls | grep -q "$SCANCENTRAL_CONTROLLER_VOLUME_NAME"
VOLUME_EXISTS=$?

# Checks for the Fortify ScanCentral Controller Docker Container existence
docker container ps -a | grep -q "$SCANCENTRAL_CONTROLLER_CONTAINER_NAME"
CONTROLLER_EXISTS=$?

# Checks if any of the Docker Network, Docker Volume, or Docker Container don't exist and creates them if necessary, 
# otherwise it prints a message and exits the script
if [ $NETWORK_EXISTS -ne 0 ] || [ $VOLUME_EXISTS -ne 0 ] || [ $CONTROLLER_EXISTS -ne 0 ]; then
    echo -e "${YELLOW}The Docker Network, the Docker Volume or the Fortify ScanCentral Controller Container don't exist.${RESET}"
    
    echo ""
    
    # Step 1: Creates the Docker Network for the Fortify ScanCentral Controller (macvlan)
    echo -e "${YELLOW}Creating the Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME'...${RESET}"
    
    echo ""
   
    docker network create -d macvlan  --subnet="$SCANCENTRAL_CONTROLLER_NETWORK_SUBNET"  --gateway="$HOST_IP_GATEWAY"  -o parent="$CUSTOM_NETWORK_PARENT_INTERFACE" "$SCANCENTRAL_CONTROLLER_NETWORK_NAME"
    check_success $? "Failed to create Docker network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME'."

    echo ""

    # Lists the settings of the new Docker Network 
    echo -e "${CYAN}Showing the settings of the Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME':${RESET}"
    docker network ls | grep "$SCANCENTRAL_CONTROLLER_NETWORK_NAME"

    echo ""

    echo -e "${GREEN}Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME' was created successfully.${RESET}"

    echo ""

    # Step 2: Creates a persistent macvlan interface config without assigning an IP address so it survives reboots 
    # to allow the host (and other servers on the same subnet) to communicate with the Container
    echo -e "${YELLOW}Creating a persistent macvlan interface config for '$HOST_CUSTOM_NETWORK_INTERFACE' with the '$HOST_IFCFG_FILE' file...${RESET}"

    echo ""

    # Checks if NetworkManager connection already exists before creating
    nmcli connection show "$HOST_CUSTOM_NETWORK_INTERFACE" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        nmcli connection add type macvlan con-name "$HOST_CUSTOM_NETWORK_INTERFACE" ifname "$HOST_CUSTOM_NETWORK_INTERFACE" dev "$CUSTOM_NETWORK_PARENT_INTERFACE" mode bridge ipv4.method disabled ipv6.method ignore
        nmcli connection up "$HOST_CUSTOM_NETWORK_INTERFACE"
    fi

    echo ""    

    # Writes the IFCFG file config
    mkdir -p "${HOST_NETWORK_MANAGER_DIRECTORY}"
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

    nmcli connection reload
    nmcli device set "${HOST_CUSTOM_NETWORK_INTERFACE}" managed yes
    nmcli device connect "${HOST_CUSTOM_NETWORK_INTERFACE}"

    echo ""

    # Adds the static route for the Fortify ScanCentral Controller container IP
    echo -e "${YELLOW}Adding static route for ScanCentral Controller container...${RESET}"
    
    echo ""
    
    nmcli connection modify "${HOST_CUSTOM_NETWORK_INTERFACE}" +ipv4.routes "${SCANCENTRAL_CONTROLLER_CONTAINER_IPADDRESS}/32"
    nmcli connection up "${HOST_CUSTOM_NETWORK_INTERFACE}"
    
    echo ""
 
    # Shows the new interface details
    echo -e "${CYAN}Interface details for ${HOST_CUSTOM_NETWORK_INTERFACE}:${RESET}"
    ip addr show "${HOST_CUSTOM_NETWORK_INTERFACE}"
    
    echo ""    

    # Step 3: Prepares host directories and stores secrets required by ScanCentral Controller entrypoint
    echo -e "${YELLOW}Preparing directories and authentication secrets in '${HOST_SCANCENTRAL_SECRETS_DIRECTORY}'...${RESET}"

    echo ""

    mkdir -p "${HOST_SCANCENTRAL_BASE_DIRECTORY}"
    mkdir -p "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}"
    mkdir -p "${HOST_SCANCENTRAL_CERTIFICATES_DIRECTORY}"

    # Populates the Worker Auth Token
    # Checks if the SCANCENTRAL_CONTROLLER_WORKER_AUTH_TOKEN_FILE variable is set, if it is,
    # it writes its value to the worker-auth-token file in the secrets directory.
    if [ -n "$SCANCENTRAL_CONTROLLER_WORKER_AUTH_TOKEN_FILE" ]; then
        echo -n "$SCANCENTRAL_CONTROLLER_WORKER_AUTH_TOKEN_FILE" > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/worker-auth-token"
    
    # If the SCANCENTRAL_CONTROLLER_WORKER_AUTH_TOKEN_FILE variable is not set, 
    # it checks if the worker-auth-token file already exists in the secrets directory.
    elif [ ! -f "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/worker-auth-token" ]; then
        # Generates a random Worker Auth Token if not provided and stores it in the secrets directory
        openssl rand -hex 16 > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/worker-auth-token"
    fi

    # Populates the Client Auth Token
    # Checks if the SCANCENTRAL_CONTROLLER_CLIENT_AUTH_TOKEN_FILE variable is set, if it is,
    # it writes its value to the client-auth-token file in the secrets directory.
    if [ -n "$SCANCENTRAL_CONTROLLER_CLIENT_AUTH_TOKEN_FILE" ]; then
        echo -n "$SCANCENTRAL_CONTROLLER_CLIENT_AUTH_TOKEN_FILE" > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/client-auth-token"
    
    # If the SCANCENTRAL_CONTROLLER_CLIENT_AUTH_TOKEN_FILE variable is not set, 
    # it checks if the client-auth-token file already exists in the secrets directory.
    elif [ ! -f "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/client-auth-token" ]; then
        # Generates a random Client Auth Token if not provided and stores it in the secrets directory
        openssl rand -hex 16 > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/client-auth-token"
    fi

    # Populates the Fortify SSC Secret
    # Checks if the SCANCENTRAL_CONTROLLER_SSC_SECRET_VALUE variable is set, if it is,
    # it writes its value to the ssc-secret file in the secrets directory.
    if [ -n "$SCANCENTRAL_CONTROLLER_SSC_SECRET_VALUE" ]; then
        echo -n "$SCANCENTRAL_CONTROLLER_SSC_SECRET_VALUE" > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/ssc-secret"

    # If the SCANCENTRAL_CONTROLLER_SSC_SECRET_VALUE variable is not set, 
    # it checks if the SCANCENTRAL_CONTROLLER_SSC_SECRET_FILE variable is set and not equal to "ssc-secret", if it is, 
    # it writes its value to the ssc-secret file in the secrets directory.
    elif [ -n "$SCANCENTRAL_CONTROLLER_SSC_SECRET_FILE" ] && [ "$SCANCENTRAL_CONTROLLER_SSC_SECRET_FILE" != "ssc-secret" ]; then
        echo -n "$SCANCENTRAL_CONTROLLER_SSC_SECRET_FILE" > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/ssc-secret"
    else
        # Generates a random SSC secret if not provided and stores it in the secrets directory
        openssl rand -hex 16 > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/ssc-secret"
    fi

    # Shows the generated secrets on the console for user reference
    echo -e "${CYAN}The Worker Auth Token is: '$(cat "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/worker-auth-token")'.${RESET}"
    echo -e "${CYAN}The Client Auth Token is: '$(cat "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/client-auth-token")'.${RESET}"
    echo -e "${CYAN}The SSC Shared Secret is: '$(cat "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/ssc-secret")'.${RESET}"

    echo ""

    # Password files required by Tomcat keystore verification in entrypoint.sh
    echo -n "${SCANCENTRAL_CONTROLLER_CERTIFICATE_PASSWORD}" > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/certificate-keystore-password"
    echo -n "${SCANCENTRAL_CONTROLLER_CERTIFICATE_PASSWORD}" > "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/certificate-key-password"

    echo -e "${GREEN}Authentication secrets generated and stored successfully!${RESET}"

    echo ""

    # Step 4: Generates Key, Certificate, PEM, and PKCS12 Keystore for ScanCentral Controller HTTPS
    echo -e "${YELLOW}Generating the private key '$SCANCENTRAL_CONTROLLER_KEY_FILE' in '$HOST_SCANCENTRAL_CERTIFICATES_DIRECTORY'...${RESET}"

    echo ""
    
    cd "$HOST_SCANCENTRAL_CERTIFICATES_DIRECTORY"
    openssl genrsa -out "$SCANCENTRAL_CONTROLLER_KEY_FILE" 2048
    check_success $? "Failed to generate private key."

    echo ""

    echo -e "${YELLOW}Generating the certificate '$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE'...${RESET}"

    echo ""

    openssl req -x509 -new -key "$SCANCENTRAL_CONTROLLER_KEY_FILE"  -sha256 -days "$SCANCENTRAL_CONTROLLER_CERTIFICATE_DAYS_VALID"  -out "$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE" -subj "$SCANCENTRAL_CONTROLLER_CERTIFICATE_SUBJECT"  -addext "subjectAltName = $SCANCENTRAL_CONTROLLER_CERTIFICATE_SAN_VALUE"
    check_success $? "Failed to generate certificate."

    echo ""

    echo -e "${YELLOW}Generating the PEM file '$SCANCENTRAL_CONTROLLER_CERTIFICATE_PEM_FILE'...${RESET}"

    echo ""

    cat "$SCANCENTRAL_CONTROLLER_KEY_FILE" "$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE" > "$SCANCENTRAL_CONTROLLER_CERTIFICATE_PEM_FILE"

    echo ""

    echo -e "${YELLOW}Generating the PKCS12 Keystore '$SCANCENTRAL_CONTROLLER_KEYSTORE_FILE' for Fortify ScanCentral Controller's Tomcat...${RESET}"

    echo ""

    # Builds PKCS12 keystore required by ScanCentral Controller entrypoint
    openssl pkcs12 -export  -in "$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE" -inkey "$SCANCENTRAL_CONTROLLER_KEY_FILE" -out "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}/${SCANCENTRAL_CONTROLLER_KEYSTORE_FILE}"  -name "$SCANCENTRAL_CONTROLLER_CERTIFICATE_ALIAS" -passout "pass:${SCANCENTRAL_CONTROLLER_CERTIFICATE_PASSWORD}"
    check_success $? "Failed to generate PKCS12 Keystore."

    # Adjusts permissions for container readability
    chmod 755 "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}"
    chmod 644 "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}"/*

    echo ""

    # Shows the generated certificates and keystore files
    echo -e "${CYAN}Certificates and Keystore generated successfully:${RESET}"
    ls -l "${HOST_SCANCENTRAL_CERTIFICATES_DIRECTORY}"
    ls -l "${HOST_SCANCENTRAL_SECRETS_DIRECTORY}"

    echo ""

    # Step 5: Adds Controller certificate to the linux server trusted anchors and Docker client certs
    echo -e "${YELLOW}Adding the certificate '$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE' to the system trusted CA store...${RESET}"

    echo ""

    mkdir -p "${HOST_TRUSTED_CA_DIRECTORY}"
    cp "$HOST_SCANCENTRAL_CERTIFICATES_DIRECTORY/$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE" "${HOST_TRUSTED_CA_DIRECTORY}"
    update-ca-trust extract
    check_success $? "Failed to update system CA trust store."

    echo ""

    echo -e "${GREEN}Certificate has been added to the system CA trust store successfully!${RESET}"

    echo ""

    echo -e "${YELLOW}Copying the certificate to the Docker client certificates directory...${RESET}"

    echo ""

    mkdir -p "$HOST_DOCKER_CLIENT_CUSTOM_CERTIFICATES_DIRECTORY"
    cp "$HOST_SCANCENTRAL_CERTIFICATES_DIRECTORY/$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE" "$HOST_DOCKER_CLIENT_CUSTOM_CERTIFICATES_DIRECTORY/$SCANCENTRAL_CONTROLLER_CERTIFICATE_FILE"
    systemctl restart docker

    echo ""

    echo -e "${CYAN}Certificates copied to:${RESET}"
    ls -l "$HOST_DOCKER_CLIENT_CUSTOM_CERTIFICATES_DIRECTORY"

    echo ""
    
    # Logs in to Docker Hub with the credentials that are provided in the .env
    if [ -n "$DOCKER_HUB_USER" ] && [ -n "$DOCKER_HUB_TOKEN" ]; then
        echo -e "${YELLOW}Authenticating with Docker Hub...${RESET}"

        echo "$DOCKER_HUB_TOKEN" | docker login -u "$DOCKER_HUB_USER" --password-stdin

        echo ""
    fi

    # Step 6: Creates the Docker Volume for persistence
    echo -e "${YELLOW}Creating the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME'...${RESET}"

    echo ""
   
    docker volume create "$SCANCENTRAL_CONTROLLER_VOLUME_NAME"
    volume_creation_status=$?
    check_success $volume_creation_status "Failed to create the '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' Docker Volume." 

    echo ""
    
    echo -e "${CYAN}Showing summary of the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME':${RESET}"
    docker volume ls | grep "$SCANCENTRAL_CONTROLLER_VOLUME_NAME"

    echo ""

    echo -e "${GREEN}Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' was created successfully.${RESET}"

    echo ""

    # Step 7: Pulls image and runs Fortify ScanCentral Controller Container
    echo -e "${YELLOW}Pulling the Docker Image '$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG'...${RESET}"

    echo ""

    docker pull "$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG"
    check_success $? "Failed to pull '$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG' Docker Image."

    echo ""

    echo -e "${YELLOW}Building and running Fortify ScanCentral SAST Controller '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' Docker Container...${RESET}"

    echo ""

    docker run -d --name "$SCANCENTRAL_CONTROLLER_CONTAINER_NAME" --restart unless-stopped --net "$SCANCENTRAL_CONTROLLER_NETWORK_NAME" --ip "$SCANCENTRAL_CONTROLLER_CONTAINER_IPADDRESS" --hostname "$SCANCENTRAL_CONTROLLER_HOSTNAME" --add-host "${FORTIFY_SSC_HOSTNAME}:${FORTIFY_SSC_IP_ADDRESS}" -p "$SCANCENTRAL_CONTROLLER_PORT:$SCANCENTRAL_CONTAINER_PORT" -v "$SCANCENTRAL_CONTROLLER_VOLUME_NAME:$SCANCENTRAL_CONTROLLER_DATA_DIRECTORY" -v "$HOST_SCANCENTRAL_SECRETS_DIRECTORY:$SCANCENTRAL_CONTROLLER_SECRETS_DIRECTORY:ro" -e SCANCENTRAL_CONFIG_CONTROLLER_URL="${SCANCENTRAL_CONTROLLER_URL}" -e SCANCENTRAL_CONFIG_SSC_URL="$FORTIFY_SSC_URL" -e SCANCENTRAL_WORKER_AUTH_TOKEN_FILE="$SCANCENTRAL_CONTROLLER_SECRETS_DIRECTORY/worker-auth-token" -e SCANCENTRAL_CLIENT_AUTH_TOKEN_FILE="$SCANCENTRAL_CONTROLLER_SECRETS_DIRECTORY/client-auth-token" -e SCANCENTRAL_SSC_SECRET_FILE="$SCANCENTRAL_CONTROLLER_SECRETS_DIRECTORY/ssc-secret" -e HTTP_SERVER_CERTIFICATE_KEYSTORE_FILE="$SCANCENTRAL_CONTROLLER_SECRETS_DIRECTORY/$SCANCENTRAL_CONTROLLER_KEYSTORE_FILE" -e HTTP_SERVER_CERTIFICATE_KEYSTORE_PASSWORD_FILE="$SCANCENTRAL_CONTROLLER_SECRETS_DIRECTORY/certificate-keystore-password" -e HTTP_SERVER_CERTIFICATE_KEY_PASSWORD_FILE="$SCANCENTRAL_CONTROLLER_SECRETS_DIRECTORY/certificate-key-password" --entrypoint /bin/bash "$SCANCENTRAL_CONTROLLER_IMAGE_NAME:$SCANCENTRAL_CONTROLLER_IMAGE_TAG" -c 'rm -f /app/etc/server.xml 2>/dev/null; exec /bin/bash /entrypoint.sh run'
    
    build_controller_status=$?
    check_success $build_controller_status "Failed to deploy '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' Docker Container."

    echo ""

    # Shows the new Docker Container information
    echo -e "${CYAN}New Docker Container created:${RESET}"
    docker ps -a --filter "name=$SCANCENTRAL_CONTROLLER_CONTAINER_NAME"

    echo ""
       
    echo -e "${GREEN}Fortify ScanCentral Controller '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' Docker Container was deployed successfully.${RESET}"

    echo ""
   
    echo -e "${CYAN}To view Fortify ScanCentral SAST Controller go to: '$SCANCENTRAL_CONTROLLER_URL' in any browser.${RESET}"

    echo ""

    # Step 8: Authenticates with the Private Docker Registry and pushes Fortify ScanCentral Controller Docker Image in the Private Docker Registry
    echo -e "${YELLOW}Authenticating with the Private Docker Registry '$CUSTOM_REGISTRY_URL'...${RESET}"

    echo ""

    # Logs in to the Private Docker Registry with basic auth credentials
    echo "$REGISTRY_PASSWORD" | docker login "$CUSTOM_REGISTRY_URL" -u "$REGISTRY_USER" --password-stdin
    check_success $? "Failed to log in to Private Docker Registry '$CUSTOM_REGISTRY_URL'."

    echo ""

    echo -e "${YELLOW}Checking if the Fortify ScanCentral SAST Controller Docker Image already exists in the Private Docker Registry...${RESET}"

    echo ""

    # Extracts the repository name from the full image name to use in the Docker Registry API call
    SCANCENTRAL_REPO_NAME=$(echo "$SCANCENTRAL_CONTROLLER_IMAGE_NAME" | awk -F'/' '{print $NF}')

    # Checks if the Fortify ScanCentral Controller Docker Image already exists in the Private Docker Registry, 
    # if not, sets the SCANCENTRAL_DOCKER_IMAGE_EXISTS variable to false, otherwise it sets it to true
    if curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/${SCANCENTRAL_REPO_NAME}/tags/list" | grep -q "${SCANCENTRAL_CONTROLLER_IMAGE_TAG}"; then
        SCANCENTRAL_DOCKER_IMAGE_EXISTS=true
    else
        SCANCENTRAL_DOCKER_IMAGE_EXISTS=false
    fi

    # Checks the value of SCANCENTRAL_DOCKER_IMAGE_EXISTS variable and proceeds to tag and push the Docker Image if missing
    if $SCANCENTRAL_DOCKER_IMAGE_EXISTS; then
        echo -e "${GREEN}Fortify ScanCentral SAST Controller Docker Image '${SCANCENTRAL_REPO_NAME}:${SCANCENTRAL_CONTROLLER_IMAGE_TAG}' already exists in the Private Docker Registry.${RESET}"

        echo ""
    else
        echo -e "${YELLOW}Fortify ScanCentral SAST Controller Docker Image is missing in the Private Docker Registry.${RESET}"

        echo ""

        echo -e "${YELLOW}Tagging and pushing Fortify ScanCentral Controller Docker Image to the Private Registry...${RESET}"

        echo ""

        # Tags the pulled Docker image with the Private Registry URL
        docker tag "${SCANCENTRAL_CONTROLLER_IMAGE_NAME}:${SCANCENTRAL_CONTROLLER_IMAGE_TAG}" "${CUSTOM_REGISTRY_URL}/${SCANCENTRAL_REPO_NAME}:${SCANCENTRAL_CONTROLLER_IMAGE_TAG}"
        check_success $? "Failed to tag Docker image for Private Registry."

        # Pushes the Docker image to the Private Docker Registry
        docker push "${CUSTOM_REGISTRY_URL}/${SCANCENTRAL_REPO_NAME}:${SCANCENTRAL_CONTROLLER_IMAGE_TAG}"
        check_success $? "Failed to push '${CUSTOM_REGISTRY_URL}/${SCANCENTRAL_REPO_NAME}:${SCANCENTRAL_CONTROLLER_IMAGE_TAG}' to Private Docker Registry."

        echo ""

        echo -e "${GREEN}Fortify ScanCentral SAST Controller Docker Image was successfully pushed to the Private Registry!${RESET}"

        echo ""

        # Shows all repositories and tags in the Private Docker Registry catalog
        echo -e "${CYAN}Fetching the Docker Registry repository catalog from '$CUSTOM_REGISTRY_URL'...${RESET}"
        curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/_catalog" | (jq . 2>/dev/null || cat)

        echo ""
    fi
else
    echo -e "${YELLOW}The Docker Network '$SCANCENTRAL_CONTROLLER_NETWORK_NAME', the Docker Volume '$SCANCENTRAL_CONTROLLER_VOLUME_NAME' and the Docker Container '$SCANCENTRAL_CONTROLLER_CONTAINER_NAME' already exist.${RESET}"

    exit 0
fi

# Prompts for reboot
read -p "$(echo -e "${CYAN}Installation complete. Do you want to reboot now? (y/N): ${RESET}")" REBOOT

# Checks the user's response and reboots if they answered yes, otherwise it prints a final message and exits
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    reboot
else
    echo ""

    # Prints the final message
    echo -e "${GREEN}Execution completed successfully!${RESET}"
fi