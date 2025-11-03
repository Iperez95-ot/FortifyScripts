#!/bin/bash

# Script that builds Docker Containers for EDirectory and EDirectory API version 9.3.1 with a volume and a network in a linux system

# Exits immediately if a command exits with a non-zero status
#set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
EDIRECTORY_VERSION="9.3.1"                                                                              # EDirectory version to deploy on a container
EDIRECTORY_VERSION_FULL="931"									        # EDirectory version number without dots
EDIRECTORY_API_VERSION="25.2"                                                                           # EDirectory API version to deploy on a container     
EDIRECTORY_API_VERSION_FULL="252"                                                                       # EDirectory API version number without dots      
EDIRECTORY_IMAGE_NAME="edirectory"                                                                      # EDirectory Docker Image name
EDIRECTORY_IMAGE_TAG="$EDIRECTORY_VERSION"							        # EDirectory Docker Tag name	
EDIRECTORY_API_IMAGE_NAME="edirapi"								        # EDirectory Image API name
EDIRECTORY_CONTAINER_IPADDRESS="192.168.1.10"                                                           # EDirectory Container IP Address
DOCKER_NETWORK_NAME="nacho-docker-registry-network"						        # Docker Containers Network name
HOST_CUSTOM_NETWORK_INTERFACE="macvlan0"							        # Host custom network interface used to communicate with the Docker Containers
EDIRECTORY_CONTAINER_NAME="edirectory_$EDIRECTORY_VERSION_FULL"				                # EDirectory Docker Container name									
EDIRECTORY_API_CONTAINER_NAME="edirapi_$EDIRECTORY_API_VERSION_FULL"			                # EDirectory API Container Name
EDIRECTORY_CONTAINER_HOSTNAME="fortify.ldap.nacho.com.ar"                                               # Hostname of the Edirectory Docker Container
EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME="fortify-edirectory-docker-volume-ldap-data"                    # EDirectory LDAP data Docker Volume name
EDIRECTORY_DATA_DIRECTORY="/config/eDirectory"                                                          # EDirectory data directory inside the Docker Container
EDIRECTORY_TREE_NAME="OT-TREE"									        # EDirectory Tree name
EDIRECTORY_ORGANIZATION_NAME="optima"								        # EDirectory Organization name
EDIRECTORY_SERVER_NAME="FortifyEDIRLDAPServer"							        # EDirectory Server name
EDIRECTORY_COMMON_NAME="admin"									        # EDirectory Common name
EDIRECTORY_ADMIN_PASSWORD="N0v3ll95"                                                                    # EDirectory Admin password
EDIRECTORY_HTTP_PORT="8028"									        # EDirectory HTTP port
EDIRECTORY_HTTPS_PORT="8030"									        # EDirectory HTTPS port
EDIRECTORY_INSECURE_LDAP_PORT="389"								        # EDirectory Insecure LDAP port
EDIRECTORY_SECURE_LDAP_PORT="636"								        # EDirectory Secure LDAP port				
EDIRECTORY_NCP_PORT="524"									        # EDirectory NCP port
ALL_INTERFACES_PORT="0.0.0.0"									        # Interface to bind a port to be listen everywhere
HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY="/etc/docker/certs.d/LDAPDockerContainer"          # Host local directory of the EDirectory Docker Container certificate used by the Docker Client
HOST_EDIRECTORY_CERTIFICATES_DIRECTORY="/opt/Scripts/LDAPDockerContainer/EDirectory/9.3.1/certificates" # Host local directory of the certificates used by EDirectory Docker Container
EDIRECTORY_CERTIFICATES_DIRECTORY="/config/eDirectory/Certificates"					# EDirectory certificates directory inside the Docker Container
EDIRECTORY_PRIVATE_KEY_FILE="nacho-ldap-edirectory.key"                                                 # Decrypted private key to be used by EDirectory Docker Container
EDIRECTORY_CERTIFICATE_FILE="nacho-ldap-edirectory.crt"                                                 # Self-signed SSL certificate to be used by EDirectory Docker Container
EDIRECTORY_PEM_FILE="nacho-ldap-edirectory.pem"                                                         # PEM file to be used by EDirectory Docker Container
EDIRECTORY_CERTIFICATE_DAYS_VALID=4096                                                                  # Days of validation of the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_PASSWORD="N0v3ll95"                                                              # Password from the EDirectory Docker Container key files
EDIRECTORY_CERTIFICATE_COUNTRY="AR"						                        # Country value from the EDirectory Docker Container Certificate	
EDIRECTORY_CERTIFICATE_STATE="Buenos Aires"                                                             # State value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_LOCALITY="Buenos Aires"                                                          # Locality value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_ORGANIZATION="Optima"                                                            # Organization value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_ORGANIZATION_UNIT="Professional Services"                                        # Organization Unit value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_COMMON_NAME="$EDIRECTORY_CONTAINER_HOSTNAME"                                     # Common Name value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_EMAIL="iperez@ot-latam.com"                                                              # Email value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_SAN_VALUE="DNS:${EDIRECTORY_CONTAINER_HOSTNAME},IP:${EDIRECTORY_CONTAINER_IPADDRESS}"    # SAN value from the EDirectory Docker Container Certificate
EDIRECTORY_CERTIFICATE_SUBJECT="/C=$EDIRECTORY_CERTIFICATE_COUNTRY/ST=$EDIRECTORY_CERTIFICATE_STATE/L=$EDIRECTORY_CERTIFICATE_LOCALITY/O=$EDIRECTORY_CERTIFICATE_ORGANIZATION/OU=$EDIRECTORY_CERTIFICATE_ORGANIZATION_UNIT/CN=$EDIRECTORY_CONTAINER_HOSTNAME/emailAddress=$EDIRECTORY_CERTIFICATE_EMAIL"      # Subject value from the EDirectory Docker Container Certificate

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
echo -e "${CYAN}Proceeding to create the Docker Containers for EDirectory version $EDIRECTORY_VERSION and EDirectory API version $EDIRECTORY_API_VERSION at $(date)...${RESET}"

echo ""

# Checks if the Docker Volume, the Docker Container for EDirectory and the Docker Container for EDirectory API exist
echo -e "${YELLOW}Checking if the Docker Container '$EDIRECTORY_CONTAINER_NAME', the Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' and the Docker Container '$EDIRECTORY_API_CONTAINER_NAME' exist...${RESET}"

echo ""

# Checks for the EDirectory LDAP Data Docker Volume existance
docker volume ls | grep -q "$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME"
EDIR_DATA_VOLUME_EXISTS=$?

# Checks for the EDirectory Docker Container existance
docker container ps -a | grep -q "$EDIRECTORY_CONTAINER_NAME"
EDIR_CONTAINER_EXISTS=$?

# Checks for EDirectory API Docker Container existance
docker container ps -a | grep -q "$EDIRECTORY_API_CONTAINER_NAME"
EDIR_API_CONTAINER_EXISTS=$?

if [ $EDIR_DATA_VOLUME_EXISTS -ne 0 ] || [ $EDIR_CONTAINER_EXISTS -ne 0 ] || [ $EDIR_API_CONTAINER_EXISTS -ne 0 ]; then
    echo -e "${RED}The Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME', the Docker Container '$EDIRECTORY_CONTAINER_NAME' and the Docker Container '$EDIRECTORY_API_CONTAINER_NAME' don't exist.${RESET}"
    
    echo ""

    # Step 1: Creates a Key file, a Certificate file based on the Key file, a PEM file based on the Key and Certificate files from the EDirectory Docker Container and adds the Certificate file from the EDirectory Docker Container to the system's trusted CA store
    echo -e "${YELLOW}Generating the Key file '$EDIRECTORY_PRIVATE_KEY_FILE'...${RESET}"

    echo ""
    
    cd $HOST_EDIRECTORY_CERTIFICATES_DIRECTORY
    openssl genrsa -out "$EDIRECTORY_PRIVATE_KEY_FILE" $EDIRECTORY_CERTIFICATE_DAYS_VALID
       
    echo ""

    echo -e "${YELLOW}Generating the certificate file '$EDIRECTORY_CERTIFICATE_FILE' based on the '$EDIRECTORY_PRIVATE_KEY_FILE' key file...${RESET}"

    echo ""

    openssl req -x509 -new -key "$EDIRECTORY_PRIVATE_KEY_FILE" \
     -sha256 -days "$EDIRECTORY_CERTIFICATE_DAYS_VALID" -out "$EDIRECTORY_CERTIFICATE_FILE" \
     -subj "$EDIRECTORY_CERTIFICATE_SUBJECT" \
     -addext "subjectAltName = $EDIRECTORY_CERTIFICATE_SAN_VALUE"

    echo ""

    echo -e "${CYAN}Certificates files generated:${RESET}"
    ls -l $HOST_EDIRECTORY_CERTIFICATES_DIRECTORY

    echo ""

    echo -e "${YELLOW}Adding the certificate file '$EDIRECTORY_CERTIFICATE_FILE' to the system's trusted CA certificates...${RESET}"

    echo ""

    # Copies the Certificate file to the trusted anchors directory
    cp "$HOST_EDIRECTORY_CERTIFICATES_DIRECTORY/$EDIRECTORY_CERTIFICATE_FILE" "/etc/pki/ca-trust/source/anchors/"
    
    # Updates the CA trust database
    update-ca-trust extract

    echo ""

    echo -e "${GREEN}Certificate '$EDIRECTORY_CERTIFICATE_FILE' file has been added to the system CA trust store successfully!${RESET}"
    
    echo ""

    echo -e "${YELLOW}Copies the certificate file '$EDIRECTORY_CERTIFICATE_FILE' to the Docker CLient certificates directory...${RESET}"

    echo ""

    # Copies the Certificate files to the Docker client certificates directory
    mkdir -p $HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY
    cp $HOST_EDIRECTORY_CERTIFICATES_DIRECTORY/$EDIRECTORY_CERTIFICATE_FILE $HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY/$EDIRECTORY_CERTIFICATE_FILE
    systemctl restart docker

    echo ""

    echo -e "${CYAN}Certificates copied to:${RESET}"
    ls -l $HOST_DOCKER_CLIENT_EDIRECTORY_CERTIFICATES_DIRECTORY     

    echo ""

    # Creates the PEM file based on the Key files and Certificate files
    echo -e "${YELLOW}Creating the PEM file '$EDIRECTORY_PEM_FILE' based on the '$EDIRECTORY_PRIVATE_KEY_FILE' key file and '$EDIRECTORY_CERTIFICATE_FILE' certificate file...${RESET}"

    echo "" 

    cat "$EDIRECTORY_PRIVATE_KEY_FILE" "$EDIRECTORY_CERTIFICATE_FILE" > "$EDIRECTORY_PEM_FILE"
    
    echo ""

    echo -e "${CYAN}New files created:${RESET}"
    ls -l     

    echo ""

    # Step 2: Creates the Docker Volume to store the ldap data of the EDirectory Docker Container
    echo -e "${YELLOW}Creating the Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME'...${RESET}"

    echo ""
   
    docker volume create $EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME
    volume_ldap_data_creation_status=$?                                                                        # Captures the exit code immediately
    check_success $volume_ldap_data_creation_status "Failed to create the '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' Docker Volume." 

    echo ""
    
    # Lists the settings of the new Docker Volume 
    echo -e "${CYAN}Showing the summary of the Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' ${RESET}"
    docker volume ls | grep "$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME"

    echo ""

    # Inspects the new Docker Volume
    echo -e "${CYAN}The New Docker Volume settings are the following: ${RESET}"
    docker volume inspect $EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME

    echo ""
    
    echo -e "${GREEN}Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME' was created successfully.${RESET}"

    echo ""

    # Step 3: Adding a route to the EDirectory Docker Container
    echo -e "${YELLOW}Adding a route to the Docker Container '$EDIRECTORY_CONTAINER_NAME' to the '$HOST_CUSTOM_NETWORK_INTERFACE'...${RESET}"

    echo ""

    nmcli connection modify ${HOST_CUSTOM_NETWORK_INTERFACE} +ipv4.routes "${EDIRECTORY_CONTAINER_IPADDRESS}/32"

    # Applies the changes
    nmcli connection up ${HOST_CUSTOM_NETWORK_INTERFACE}
    
    echo ""

    # Step 4: Builds the EDirectory Docker Container and attachs it to the recently created Docker Volumes
    echo -e "${YELLOW}Building the Docker Container '$EDIRECTORY_CONTAINER_NAME' and attaching it to the Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME'...${RESET}"

    echo ""

    docker run -d --name $EDIRECTORY_CONTAINER_NAME -p $EDIRECTORY_INSECURE_LDAP_PORT:$EDIRECTORY_INSECURE_LDAP_PORT -p $EDIRECTORY_SECURE_LDAP_PORT:$EDIRECTORY_SECURE_LDAP_PORT -p $EDIRECTORY_NCP_PORT:$EDIRECTORY_NCP_PORT -p $EDIRECTORY_HTTP_PORT:$EDIRECTORY_HTTP_PORT -p $EDIRECTORY_HTTPS_PORT:$EDIRECTORY_HTTPS_PORT --user root --restart unless-stopped --hostname $EDIRECTORY_CONTAINER_HOSTNAME --network $DOCKER_NETWORK_NAME --ip $EDIRECTORY_CONTAINER_IPADDRESS -v $EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME:$EDIRECTORY_DATA_DIRECTORY -v $HOST_EDIRECTORY_CERTIFICATES_DIRECTORY:$EDIRECTORY_CERTIFICATES_DIRECTORY -e NDS_INSTANCE_LIST=$EDIRECTORY_DATA_DIRECTORY/inst/data $EDIRECTORY_IMAGE_NAME:$EDIRECTORY_IMAGE_TAG new -t $EDIRECTORY_TREE_NAME -n o=$EDIRECTORY_ORGANIZATION_NAME -S $EDIRECTORY_SERVER_NAME -a cn=$EDIRECTORY_COMMON_NAME.o=$EDIRECTORY_ORGANIZATION_NAME -w "$EDIRECTORY_ADMIN_PASSWORD" -B $ALL_INTERFACES_PORT@$EDIRECTORY_NCP_PORT -L $EDIRECTORY_INSECURE_LDAP_PORT -l $EDIRECTORY_SECURE_LDAP_PORT    
    build_edir_container_status=$?                                                                         # Captures the exit code immediately
    check_success $build_edir_container_status "Failed to build the '$EDIRECTORY_CONTAINER_NAME' Docker Container."

    echo ""

    # Shows the new Docker Container information
    echo -e "${CYAN}New Docker Container created:${RESET}"
    docker ps -a --filter "name=$EDIRECTORY_CONTAINER_NAME"

    echo ""
       
    echo -e "${GREEN}The Docker Container '$EDIRECTORY_CONTAINER_NAME' was created successfully.${RESET}"

    echo ""
else
    echo -e "${YELLOW}The Docker Volume '$EDIRECTORY_LDAP_DATA_DOCKER_VOLUME_NAME', the Docker Container '$EDIRECTORY_CONTAINER_NAME' and the Docker Container '$EDIRECTORY_API_CONTAINER_NAME' already exist.${RESET}"

    exit 0
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"
