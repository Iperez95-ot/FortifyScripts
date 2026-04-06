#!/bin/bash

# Script to pull from OneDrive the installation files for EDirectory version 9.3.1 (25.2) and IdentityConsole 25.2 to deploy Docker Containers
# It also creates the Docker Images for both applications and pushes them to a Private Docker Registry

# Exits immediately if a command exits with a non-zero status
set -e

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
		
# Prints the first message
echo -e "${CYAN}Proceeding to get EDirectory and IdentityConsole installation files from OT-Latam OneDrive on the system at $(date)...${RESET}"

echo ""

# Verifies the Back Up directory for EDirectory version 9.3.1 and IdentityConsole version 25.2 existance 
if [[ -d "$EDIRECTORY_LDAP_BACKUP_DIR" ]]; then
    echo -e "${GREEN}Back Up directories for EDirectory $EDIRECTORY_VERSION and IdentityConsole $IDENTITYCONSOLE_VERSION already exist.${RESET}"

    echo ""
    
    exit 0
else
    echo -e "${RED}Back Up directories for EDirectory $EDIRECTORY_VERSION and IdentityConsole $IDENTITYCONSOLE_VERSION version don't exist.${RESET}"

    echo ""

    # Step 1: Logs into the Private Docker Registry
    echo -e "${YELLOW}Logging into the private Docker Registry '$CUSTOM_REGISTRY_URL'...${RESET}"

    echo "$REGISTRY_PASSWORD" | docker login "$CUSTOM_REGISTRY_URL" -u "$REGISTRY_USER" --password-stdin

    echo ""

    # Step 2: Creates the Back Up directory for EDirectory version 9.3.1 and IdentityConsole version 25.2 (where the back up files will be stored)
    echo -e "${YELLOW}Creating the Back Up directory for EDirectory version $EDIRECTORY_VERSION and IdentityConsole version $IDENTITYCONSOLE_VERSION...${RESET}"

    echo ""

    mkdir -p $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    mkdir -p $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION
   
    echo ""
    
    # Step 3: Pulls EDirectory version 9.3.1 and IdentityConsole version 25.2 installation files into the Linux Server
    echo -e "${YELLOW}Pulling EDirectory version $EDIRECTORY_VERSION installation files from OneDrive to the Back Up directory...${RESET}"
   
    echo ""

    rclone copy "ot-latam_onedrive:Back Up/EDirectory/Product Versions/$EDIRECTORY_VERSION/EDirectory_Docker" $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION -P
    rclone copy "ot-latam_onedrive:Back Up/IdentityConsole/Product Versions/$IDENTITYCONSOLE_VERSION/IdentityConsole_Docker" $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION -P
    cd $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION
    cp -f Silent_Properties_Modified/silent.properties silent.properties
    cd $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    cp -f eDirAPI_Conf/edirapi.conf $EDIRECTORY_API_REQUIRED_FILES_DIRECTORY

    echo ""

    echo -e "${CYAN}Extracted files on the EDirectory version $EDIRECTORY_VERSION Back Up directory:${RESET}"
    ls -l $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION

    echo ""

    echo -e "${CYAN}Extracted files on the IdentityConsole version $IDENTITYCONSOLE_VERSION Back Up directory:${RESET}"
    ls -l $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION

    echo ""

    # Step 4: Creates the Docker Images for EDirectory 9.3.1 version and IdentityConsole 25.2 version
    echo -e "${YELLOW}Creating the Docker Images for EDirectory version $EDIRECTORY_VERSION and IdentityConsole version $IDENTITYCONSOLE_VERSION...${RESET}"

    echo ""
    
    # Loads the Docker Image for EDirectory version 9.3.1
    echo -e "${CYAN}Loading the Docker Image for EDirectory version $EDIRECTORY_VERSION:${RESET}"
    cd $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    docker load --input eDirectory_$EDIRECTORY_VERSION_FULL.tar.gz

    echo ""
    
    # Loads the Docker Image for EDirectory API version 9.3.1
    echo -e "${CYAN}Loading the Docker Image for EDirectory API version $IDENTITYCONSOLE_VERSION:${RESET}"
    docker load --input eDirAPI_$IDENTITYCONSOLE_VERSION_FULL.tar.gz

    echo ""
    
    # Loads the Docker Image for IdentityConsole version 25.2
    echo -e "${CYAN}Loading the Docker Image for IdentityConsole version $IDENTITYCONSOLE_VERSION:${RESET}" 
    cd $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION
    docker load --input identityconsole.tar.gz

    echo ""
    
    # Shows the new Docker Images recently created
    echo -e "${CYAN}New Docker Images created for EDirectory and IdentityConsole:${RESET}"
    docker images | grep -E "($EDIRECTORY_IMAGE_NAME|$EDIRECTORY_API_IMAGE_NAME|$IDENTITYCONSOLE_IMAGE_NAME)"

    echo ""

    # Step 5: Tags and Pushes the Docker Images into the Private Docker Registry
    echo -e "${YELLOW}Checks if the LDAP Docker Images already exist in the Private Docker Registry...${RESET}"

    echo ""

    # Step 6: Checks if the 3 Docker Images exists in the Private Docker Registry
    if curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/edirectory/tags/list" | grep -q "${EDIRECTORY_VERSION}" && curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/edirectory-api/tags/list" | grep -q "${IDENTITYCONSOLE_VERSION}" && curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/identityconsole/tags/list" | grep -q "${IDENTITYCONSOLE_VERSION}"; then
        # If the 3 Docker Images already exist in the Private Docker Registry, it sets ALL_LDAP_DOCKER_IMAGES_EXIST variable to true
        ALL_LDAP_DOCKER_IMAGES_EXIST=true
    else
        # If one or more of the 3 Docker Images are missing in the Private Docker Registry, it sets ALL_LDAP_DOCKER_IMAGES_EXIST variable to false
        ALL_LDAP_DOCKER_IMAGES_EXIST=false
    fi

    # Checks the value of ALL_LDAP_DOCKER_IMAGES_EXIST variable and proceeds to push the Docker Images to the Private Docker Registry 
    # if one or more of them are missing
    if $ALL_LDAP_DOCKER_IMAGES_EXIST; then
        echo -e "${GREEN}All LDAP Docker Images already exist in the Private Docker Registry.${RESET}"

        echo ""
    
    # If one or more of the LDAP Docker Images are missing in the Private Docker Registry, it tags and pushes the Docker Images to the Private Docker Registry
    else
        # Step 7: Tags and pushes the Docker Images to the Private Docker Registry if one or more of them are missing
        echo -e "${YELLOW}One or more of the LDAP Docker Images are missing in the Private Docker Registry.${RESET}"

        echo ""

        echo -e "${YELLOW}Tagging and pushing Docker Images to the Private Registry...${RESET}"

        echo ""

        # Tags and pushes EDirectory Docker Image
        docker tag $EDIRECTORY_IMAGE_NAME:$EDIRECTORY_VERSION $CUSTOM_REGISTRY_URL/$EDIRECTORY_IMAGE_NAME:$EDIRECTORY_VERSION
        docker push $CUSTOM_REGISTRY_URL/$EDIRECTORY_IMAGE_NAME:$EDIRECTORY_VERSION

        echo ""

        # Tags and pushes EDirectory API Docker Image
        docker tag $EDIRECTORY_API_IMAGE_NAME:$IDENTITYCONSOLE_VERSION $CUSTOM_REGISTRY_URL/$EDIRECTORY_API_IMAGE_NAME:$IDENTITYCONSOLE_VERSION
        docker push $CUSTOM_REGISTRY_URL/$EDIRECTORY_API_IMAGE_NAME:$IDENTITYCONSOLE_VERSION

        echo ""

        # Tags and pushes IdentityConsole Docker Image
        docker tag $IDENTITYCONSOLE_IMAGE_NAME:$IDENTITYCONSOLE_VERSION $CUSTOM_REGISTRY_URL/$IDENTITYCONSOLE_IMAGE_NAME:$IDENTITYCONSOLE_VERSION
        docker push $CUSTOM_REGISTRY_URL/$IDENTITYCONSOLE_IMAGE_NAME:$IDENTITYCONSOLE_VERSION

        echo ""

        echo -e "${GREEN}EDirectory Application, EDirectory API and Identity Console Docker Images successfully pushed into the Private Registry!${RESET}"

        echo ""

        # Step 8 : Shows all the repositories in the Docker Private Registry
        echo -e "${CYAN}Fetching the Docker Registry repository catalog from '$CUSTOM_REGISTRY_URL'...${RESET}"
        curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/_catalog" | jq .

        echo ""
    fi  
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"
 #!/bin/bash

# Script to pull from OneDrive the installation files for EDirectory version 9.3.1 (25.2) and IdentityConsole 25.2 to deploy Docker Containers
# It also creates the Docker Images for both applications and pushes them to a Private Docker Registry

# Exits immediately if a command exits with a non-zero status
set -e

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
		
# Prints the first message
echo -e "${CYAN}Proceeding to get EDirectory and IdentityConsole installation files from OT-Latam OneDrive on the system at $(date)...${RESET}"

echo ""

# Verifies the Back Up directory for EDirectory version 9.3.1 and IdentityConsole version 25.2 existance 
if [[ -d "$EDIRECTORY_LDAP_BACKUP_DIR" ]]; then
    echo -e "${GREEN}Back Up directories for EDirectory $EDIRECTORY_VERSION and IdentityConsole $IDENTITYCONSOLE_VERSION already exist.${RESET}"

    echo ""
    
    exit 0
else
    echo -e "${RED}Back Up directories for EDirectory $EDIRECTORY_VERSION and IdentityConsole $IDENTITYCONSOLE_VERSION version don't exist.${RESET}"

    echo ""

    # Step 1: Logs into the Private Docker Registry
    echo -e "${YELLOW}Logging into the private Docker Registry '$CUSTOM_REGISTRY_URL'...${RESET}"

    echo "$REGISTRY_PASSWORD" | docker login "$CUSTOM_REGISTRY_URL" -u "$REGISTRY_USER" --password-stdin

    echo ""

    # Step 2: Creates the Back Up directory for EDirectory version 9.3.1 and IdentityConsole version 25.2 (where the back up files will be stored)
    echo -e "${YELLOW}Creating the Back Up directory for EDirectory version $EDIRECTORY_VERSION and IdentityConsole version $IDENTITYCONSOLE_VERSION...${RESET}"

    echo ""

    mkdir -p $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    mkdir -p $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION
   
    echo ""
    
    # Step 3: Pulls EDirectory version 9.3.1 and IdentityConsole version 25.2 installation files into the Linux Server
    echo -e "${YELLOW}Pulling EDirectory version $EDIRECTORY_VERSION installation files from OneDrive to the Back Up directory...${RESET}"
   
    echo ""

    rclone copy "ot-latam_onedrive:Back Up/EDirectory/Product Versions/$EDIRECTORY_VERSION/EDirectory_Docker" $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION -P
    rclone copy "ot-latam_onedrive:Back Up/IdentityConsole/Product Versions/$IDENTITYCONSOLE_VERSION/IdentityConsole_Docker" $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION -P
    cd $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION
    cp -f Silent_Properties_Modified/silent.properties silent.properties
    cd $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    cp -f eDirAPI_Conf/edirapi.conf $EDIRECTORY_API_REQUIRED_FILES_DIRECTORY

    echo ""

    echo -e "${CYAN}Extracted files on the EDirectory version $EDIRECTORY_VERSION Back Up directory:${RESET}"
    ls -l $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION

    echo ""

    echo -e "${CYAN}Extracted files on the IdentityConsole version $IDENTITYCONSOLE_VERSION Back Up directory:${RESET}"
    ls -l $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION

    echo ""

    # Step 4: Creates the Docker Images for EDirectory 9.3.1 version and IdentityConsole 25.2 version
    echo -e "${YELLOW}Creating the Docker Images for EDirectory version $EDIRECTORY_VERSION and IdentityConsole version $IDENTITYCONSOLE_VERSION...${RESET}"

    echo ""
    
    # Loads the Docker Image for EDirectory version 9.3.1
    echo -e "${CYAN}Loading the Docker Image for EDirectory version $EDIRECTORY_VERSION:${RESET}"
    cd $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    docker load --input eDirectory_$EDIRECTORY_VERSION_FULL.tar.gz

    echo ""
    
    # Loads the Docker Image for EDirectory API version 9.3.1
    echo -e "${CYAN}Loading the Docker Image for EDirectory API version $IDENTITYCONSOLE_VERSION:${RESET}"
    docker load --input eDirAPI_$IDENTITYCONSOLE_VERSION_FULL.tar.gz

    echo ""
    
    # Loads the Docker Image for IdentityConsole version 25.2
    echo -e "${CYAN}Loading the Docker Image for IdentityConsole version $IDENTITYCONSOLE_VERSION:${RESET}" 
    cd $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION
    docker load --input identityconsole.tar.gz

    echo ""
    
    # Shows the new Docker Images recently created
    echo -e "${CYAN}New Docker Images created for EDirectory and IdentityConsole:${RESET}"
    docker images | grep -E "($EDIRECTORY_IMAGE_NAME|$EDIRECTORY_API_IMAGE_NAME|$IDENTITYCONSOLE_IMAGE_NAME)"

    echo ""

    # Step 5: Tags and Pushes the Docker Images into the Private Docker Registry
    echo -e "${YELLOW}Checks if the LDAP Docker Images already exist in the Private Docker Registry...${RESET}"

    echo ""

    # Step 6: Checks if the 3 Docker Images exists in the Private Docker Registry
    if curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/edirectory/tags/list" | grep -q "${EDIRECTORY_VERSION}" && curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/edirectory-api/tags/list" | grep -q "${IDENTITYCONSOLE_VERSION}" && curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/identityconsole/tags/list" | grep -q "${IDENTITYCONSOLE_VERSION}"; then
        # If the 3 Docker Images already exist in the Private Docker Registry, it sets ALL_LDAP_DOCKER_IMAGES_EXIST variable to true
        ALL_LDAP_DOCKER_IMAGES_EXIST=true
    else
        # If one or more of the 3 Docker Images are missing in the Private Docker Registry, it sets ALL_LDAP_DOCKER_IMAGES_EXIST variable to false
        ALL_LDAP_DOCKER_IMAGES_EXIST=false
    fi

    # Checks the value of ALL_LDAP_DOCKER_IMAGES_EXIST variable and proceeds to push the Docker Images to the Private Docker Registry 
    # if one or more of them are missing
    if $ALL_LDAP_DOCKER_IMAGES_EXIST; then
        echo -e "${GREEN}All LDAP Docker Images already exist in the Private Docker Registry.${RESET}"

        echo ""
    
    # If one or more of the LDAP Docker Images are missing in the Private Docker Registry, it tags and pushes the Docker Images to the Private Docker Registry
    else
        # Step 7: Tags and pushes the Docker Images to the Private Docker Registry if one or more of them are missing
        echo -e "${YELLOW}One or more of the LDAP Docker Images are missing in the Private Docker Registry.${RESET}"

        echo ""

        echo -e "${YELLOW}Tagging and pushing Docker Images to the Private Registry...${RESET}"

        echo ""

        # Tags and pushes EDirectory Docker Image
        docker tag $EDIRECTORY_IMAGE_NAME:$EDIRECTORY_VERSION_FULL $CUSTOM_REGISTRY_URL/$EDIRECTORY_IMAGE_NAME:$EDIRECTORY_VERSION
        docker push $CUSTOM_REGISTRY_URL/$EDIRECTORY_IMAGE_NAME:$EDIRECTORY_VERSION_FULL

        echo ""

        # Tags and pushes EDirectory API Docker Image
        docker tag $EDIRECTORY_API_IMAGE_NAME:$IDENTITYCONSOLE_VERSION_FULL $CUSTOM_REGISTRY_URL/$EDIRECTORY_API_IMAGE_NAME:$IDENTITYCONSOLE_VERSION
        docker push $CUSTOM_REGISTRY_URL/$EDIRECTORY_API_IMAGE_NAME:$IDENTITYCONSOLE_VERSION_FULL

        echo ""

        # Tags and pushes IdentityConsole Docker Image
        docker tag $IDENTITYCONSOLE_IMAGE_NAME:$IDENTITYCONSOLE_VERSION_FULL $CUSTOM_REGISTRY_URL/$IDENTITYCONSOLE_IMAGE_NAME:$IDENTITYCONSOLE_VERSION
        docker push $CUSTOM_REGISTRY_URL/$IDENTITYCONSOLE_IMAGE_NAME:$IDENTITYCONSOLE_VERSION_FULL

        echo ""

        echo -e "${GREEN}EDirectory Application, EDirectory API and Identity Console Docker Images successfully pushed into the Private Registry!${RESET}"

        echo ""

        # Step 8 : Shows all the repositories in the Docker Private Registry
        echo -e "${CYAN}Fetching the Docker Registry repository catalog from '$CUSTOM_REGISTRY_URL'...${RESET}"
        curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/_catalog" | jq .

        echo ""
    fi  
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"
 