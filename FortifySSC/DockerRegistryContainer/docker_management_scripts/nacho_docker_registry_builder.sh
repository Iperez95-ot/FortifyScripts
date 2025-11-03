#!/bin/bash

# Script that builds a Docker Network, a Docker Volume, a Docker Registry and a Docker Registry UI for storing Docker Images in a linux system

# Exits immediately if a command exits with a non-zero status
#set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
HOST_IP_ADDRESS="192.168.1.14"                                                                  		   		# Linux Host IP Address 
CUSTOM_REGISTRY_CONTAINER_IPADDRESS="192.168.1.12"                                                                 		# Docker Registry Container IP Address
CUSTOM_REGISTRY_NETWORK_NAME="nacho-docker-registry-network"						           		# Docker Registry Network Name
CUSTOM_REGISTRY_NETWORK_SUBNET="192.168.1.0/24" 								   		# Docker Registry Network Subnet
HOST_IP_GATEWAY="192.168.1.1"										   	   		# Red Hat Linux Host Gateway IP Address 
CUSTOM_NETWORK_PARENT_INTERFACE="ens160"									   		# Parent Interface from the Red Hat Linux Host Server
CUSTOM_REGISTRY_PORT="5000"                                                                                       		# Port of the Docker Registry
CUSTOM_REGISTRY_HOSTNAME="docker.registry.nacho.com.ar"                                         		   		# Hostname of the Docker Registry
CUSTOM_REGISTRY_VOLUME_NAME="nacho-docker-volume-registry-data"                                		   	                # Docker Registry Volume name
CUSTOM_REGISTRY_CONTAINER_NAME="nacho-server-docker-registry"                                                      		# Docker Registry Container name
CUSTOM_REGISTRY_IMAGE_NAME="registry"                                                                              		# Docker Registry Image name
CUSTOM_REGISTRY_URL="https://$CUSTOM_REGISTRY_HOSTNAME:$CUSTOM_REGISTRY_PORT/v2/_catalog"                          		# Docker Registry Catalog URL
CUSTOM_REGISTRY_DATA_DIRECTORY="/var/lib/registry"                                                                 		# Docker Registry data directory inside the Docker Registry Container
CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS="192.168.1.11"                                                             		# Docker Registry UI Container IP Address
CUSTOM_REGISTRY_UI_CONTAINER_NAME="nacho-server-docker-registry-ui"  						   		# Docker Registry UI Container Name
CUSTOM_REGISTRY_UI_HOST_HTTP_PORT="8080"											# Docker Registry UI HTTP Port (Host side)
CUSTOM_REGISTRY_UI_CONTAINER_HTTP_PORT="80"                        							        # Docker Registry UI HTTP Port (Container side)
CUSTOM_REGISTRY_UI_HOST_HTTPS_PORT="8443"                                       				                # Docker Registry UI HTTPS Port (Host side)
CUSTOM_REGISTRY_UI_CONTAINER_HTTPS_PORT="443"                        							        # Docker Registry UI HTTPS Port (Container side)
CUSTOM_REGISTRY_UI_HOSTNAME="docker.registry.ui.nacho.com.ar"                                         		   		# Hostname of the Docker Registry UI
CUSTOM_UI_IMAGE_NAME="joxit/docker-registry-ui"								          		# Docker Registry UI Image name
CUSTOM_REGISTRY_UI_URL="https://$CUSTOM_REGISTRY_UI_HOSTNAME"                       				   		# Docker Registry UI URL
CUSTOM_REGISTRY_TITLE="OT Nacho Private Registry"                                                                  		# Docker Registry Title
CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY="/opt/Certificates"                                                         		# Docker Registry directory where the Docker Registry certificates will be located
CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY="/etc/nginx/certs"								        # Docker Registry UI directory where the Docker Registry UI certificates will be located
CUSTOM_REGISTRY_IMAGE_TAG="latest"                                                                                              # Docker Registry and Docker Registry UI Image Tag name
HOST_REGISTRY_CERTIFICATES_DIRECTORY="/opt/Scripts/DockerRegistryContainer/certificates/registry"                		# Host local directory of the certificates used by the Docker Registry
HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY="/opt/Scripts/DockerRegistryContainer/certificates/registryui"                          # Host local directory of the certificates used by the Docker Registry UI
HOST_REGISTRY_UI_NGINX_CONF_DIRECTORY="/opt/Scripts/DockerRegistryContainer/registry_ui_https_config"				# Host local directory of the nginx conf file with HTTPS support for the Docker Registry UI
HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY="/opt/Scripts/DockerRegistryContainer/auth"					        # Host local directory of the Basic Authentication file for the Docker Registry UI
HOST_NETWORK_MANAGER_DIRECTORY="/etc/sysconfig/network-scripts"								        # Host local directory of the Network Manager files
HOST_CUSTOM_NETWORK_INTERFACE="macvlan0"											# Host custom network interface used to communicate with the Docker Containers
HOST_IFCFG_FILE="ifcfg-${HOST_CUSTOM_NETWORK_INTERFACE}"									# IFCG file to be used to create a persistent macvlan interface config
HOST_TRUSTED_CA_DIRECTORY="/etc/pki/ca-trust/source/anchors/"									# Host local directory of the Trusted CA store
CUSTOM_REGISTRY_UI_NGINX_CONF_DIRECTORY="/etc/nginx/conf.d"									# Docker Registry UI directory where the nginx conf file is located
HOST_DOCKER_CLIENT_CUSTOM_REGISTRY_CERTIFICATES_DIRECTORY="/etc/docker/certs.d/NachoDockerRegistry"                             # Host local directory of the Docker Registry and Docker Registry UI certificates used by the Docker Client
CUSTOM_REGISTRY_PRIVATE_KEY_FILE="nacho-docker-registry.key"                                                       		# Decrypted private key to be used for the Docker Registry
CUSTOM_REGISTRY_CERTIFICATE_FILE="nacho-docker-registry.crt"                                                       		# Self-signed SSL certificate to be used for the Docker Registry
CUSTOM_REGISTRY_PEM_FILE="nacho-docker-registry.pem"                                                               		# PEM file to be used for the Docker Registry Certificate
CUSTOM_REGISTRY_UI_PEM_FILE="fullchain.pem"											# PEM file to be used for the Docker Registry UI
CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE="privkey.pem"										# Decrypted private key to be used for the Docker Registry UI
CUSTOM_REGISTRY_UI_HTTPS_NGINX_FILE="default.conf"										# Conf file to use HTTPS support for the Docker Registry UI
CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE=".htpasswd"											# Basic Authentication file for the Docker Registry UI
CUSTOM_REGISTRY_UI_AUTH_USER="registry_root"										        # Basic Authenticaction User for the Docker Registry UI
CUSTOM_REGISTRY_UI_AUTH_PASSWORD="N0v3ll95"											# Basic Authenticaction Password for the Docker Registry UI
CUSTOM_REGISTRY_CERTIFICATE_DAYS_VALID=4096                                                                        		# Days of validation of the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_PASSWORD="N0v3ll95"                                                                    		# Password from the Docker Registry and Docker Registry UI key files
CUSTOM_REGISTRY_CERTIFICATE_COUNTRY="AR"								           		# Country value from the Docker Registry and Docker Registry UI Certificates	
CUSTOM_REGISTRY_CERTIFICATE_STATE="Buenos Aires"                                                                   		# State value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_LOCALITY="Buenos Aires"                                                                		# Locality value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION="Optima"                                                                     		# Organization value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION_UNIT="Professional Services"                                                 		# Organization Unit value from the Docker Registry and Docker Registry UI Certificates
CUSTOM_REGISTRY_CERTIFICATE_COMMON_NAME="$CUSTOM_REGISTRY_HOSTNAME"                                                   		# Common Name value from the Docker Registry Certificate
CUSTOM_REGISTRY_UI_CERTIFICATE_COMMON_NAME="$CUSTOM_REGISTRY_UI_HOSTNAME"							# Common Name value from the Docker Registry UI Certificate
CUSTOM_REGISTRY_CERTIFICATE_EMAIL="iperez@ot-latam.com"                                                               		# Email value from the Docker Registry and Docker Registry UI Certificates 
CUSTOM_REGISTRY_CERTIFICATE_SAN_VALUE="DNS:${CUSTOM_REGISTRY_HOSTNAME},IP:${CUSTOM_REGISTRY_CONTAINER_IPADDRESS}"     		# SAN value from the Docker Registry Certificate
CUSTOM_REGISTRY_UI_CERTIFICATE_SAN_VALUE="DNS:${CUSTOM_REGISTRY_UI_HOSTNAME},IP:${CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS}"      # SAN value from the Docker Registry Certificate
CUSTOM_REGISTRY_UI_CERTIFICATE_SUBJECT="/C=$CUSTOM_REGISTRY_CERTIFICATE_COUNTRY/ST=$CUSTOM_REGISTRY_CERTIFICATE_STATE/L=$CUSTOM_REGISTRY_CERTIFICATE_LOCALITY/O=$CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION/OU=$CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION_UNIT/CN=$CUSTOM_REGISTRY_UI_HOSTNAME/emailAddress=$CUSTOM_REGISTRY_CERTIFICATE_EMAIL"				# Subject value from the Docker Registry UI Certificate
CUSTOM_REGISTRY_CERTIFICATE_SUBJECT="/C=$CUSTOM_REGISTRY_CERTIFICATE_COUNTRY/ST=$CUSTOM_REGISTRY_CERTIFICATE_STATE/L=$CUSTOM_REGISTRY_CERTIFICATE_LOCALITY/O=$CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION/OU=$CUSTOM_REGISTRY_CERTIFICATE_ORGANIZATION_UNIT/CN=$CUSTOM_REGISTRY_CERTIFICATE_COMMON_NAME/emailAddress=$CUSTOM_REGISTRY_CERTIFICATE_EMAIL"       	# Subject value from the Docker Registry Certificate
                                        
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

    docker run -d --name $CUSTOM_REGISTRY_UI_CONTAINER_NAME --restart unless-stopped --net $CUSTOM_REGISTRY_NETWORK_NAME --ip $CUSTOM_REGISTRY_UI_CONTAINER_IPADDRESS --hostname $CUSTOM_REGISTRY_UI_HOSTNAME -p $CUSTOM_REGISTRY_UI_HOST_HTTP_PORT:$CUSTOM_REGISTRY_UI_CONTAINER_HTTP_PORT -v $HOST_REGISTRY_UI_NGINX_CONF_DIRECTORY/$CUSTOM_REGISTRY_UI_HTTPS_NGINX_FILE:$CUSTOM_REGISTRY_UI_NGINX_CONF_DIRECTORY/$CUSTOM_REGISTRY_UI_HTTPS_NGINX_FILE -v $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE:$CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PRIVATE_KEY_FILE -v $HOST_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PEM_FILE:$CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_PEM_FILE -v $HOST_REGISTRY_UI_BASIC_AUTH_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE:$CUSTOM_REGISTRY_UI_CERTIFICATES_DIRECTORY/$CUSTOM_REGISTRY_UI_BASIC_AUTH_FILE:ro -e REGISTRY_TITLE="$CUSTOM_REGISTRY_TITLE" -e REGISTRY_URL="https://$CUSTOM_REGISTRY_HOSTNAME:$CUSTOM_REGISTRY_PORT" -e DELETE_IMAGES="true" $CUSTOM_UI_IMAGE_NAME:$CUSTOM_REGISTRY_IMAGE_TAG
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

# Prompt for reboot
read -p "$(echo -e "${CYAN}Installation complete. Do you want to reboot now? (y/N): ${RESET}")" REBOOT

if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    reboot
else
    # Prints the final message
    echo -e "${GREEN}Execution completed successfully!${RESET}"
fi