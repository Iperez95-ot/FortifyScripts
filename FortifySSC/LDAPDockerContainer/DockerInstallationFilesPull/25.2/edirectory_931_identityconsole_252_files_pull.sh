#!/bin/bash

# Script to pull from OneDrive the installation files for EDirectory version 9.3.1 (25.2) and IdentityConsole 25.2 to deploy Docker Containers

# Exits immediately if a command exits with a non-zero status
set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
EDIRECTORY_VERSION="9.3.1"                                                                            # EDirectory version to be installed and backed up
EDIRECTORY_VERSION_FULL="931"									      # EDirectory version number without dots
IDENTITYCONSOLE_VERSION="25.2"                                                                        # IdentityConsole version to be installed and backed up
IDENTITYCONSOLE_VERSION_FULL="252"							              # IdentityConsole version number without dots	               
EDIRECTORY_LDAP_BACKUP_DIR="/home/nachossc/ssc_installation/EDirectory_LDAP"                          # Back Up directory where EDirectory version 9.3.1 and IdentityConsole version 25.2 files will be stored
EDIRECTORY_IMAGE_NAME="edirectory"                                                                    # EDirectory Image Name
EDIRECTORY_API_IMAGE_NAME="edirapi"								      # EDirectory Image API Name
IDENTITYCONSOLE_IMAGE_NAME="identityconsole"							      # IdentityConsole Image Name
			
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

    # Step 1: Creates the Back Up directory for EDirectory version 9.3.1 and IdentityConsole version 25.2 (where the back up files will be stored)
    echo -e "${YELLOW}Creating the Back Up directory for EDirectory version $EDIRECTORY_VERSION and IdentityConsole version $IDENTITYCONSOLE_VERSION...${RESET}"

    echo ""

    mkdir -p $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    mkdir -p $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION

    echo ""
    
    # Step 2: Pulls EDirectory version 9.3.1 and IdentityConsole version 25.2 installation files into the Linux Server
    echo -e "${YELLOW}Pulling EDirectory version $EDIRECTORY_VERSION installation files from OneDrive to the Back Up directory...${RESET}"
   
    echo ""

    rclone copy "ot-latam_onedrive:Back Up/EDirectory/Product Versions/$EDIRECTORY_VERSION/EDirectory_Docker" $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION -P
    rclone copy "ot-latam_onedrive:Back Up/IdentityConsole/Product Versions/$IDENTITYCONSOLE_VERSION/IdentityConsole_Docker" $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION -P

    echo ""

    echo -e "${CYAN}Extracted files on the EDirectory version $EDIRECTORY_VERSION Back Up directory:${RESET}"
    ls -l $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION

    echo ""

    echo -e "${CYAN}Extracted files on the IdentityConsole version $IDENTITYCONSOLE_VERSION Back Up directory:${RESET}"
    ls -l $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION

    echo ""

    # Step 3: Creates the Docker Images for EDirectory 9.3.1 version and IdentityConsole 25.2 version
    echo -e "${YELLOW}Creating the Docker Images for EDirectory version $EDIRECTORY_VERSION and IdentityConsole version $IDENTITYCONSOLE_VERSION...${RESET}"

    echo ""
    
    echo -e "${CYAN}Loading the Docker Image for EDirectory version $EDIRECTORY_VERSION:${RESET}"
    cd $EDIRECTORY_LDAP_BACKUP_DIR/EDirectory/$EDIRECTORY_VERSION
    docker load --input eDirectory_$EDIRECTORY_VERSION_FULL.tar.gz

    echo ""
    
    echo -e "${CYAN}Loading the Docker Image for EDirectory API version $IDENTITYCONSOLE_VERSION:${RESET}"
    docker load --input eDirAPI_$IDENTITYCONSOLE_VERSION_FULL.tar.gz

    echo ""
    
    echo -e "${CYAN}Loading the Docker Image for IdentityConsole version $IDENTITYCONSOLE_VERSION:${RESET}" 
    cd $EDIRECTORY_LDAP_BACKUP_DIR/IdentityConsole/$IDENTITYCONSOLE_VERSION
    docker load --input identityconsole.tar.gz

    echo ""
    
    # Shows the new Docker Images recently created}
    echo -e "${CYAN}New Docker Images created for EDirectory and IdentityConsole:${RESET}"
    docker images | grep -E "($EDIRECTORY_IMAGE_NAME|$EDIRECTORY_API_IMAGE_NAME|$IDENTITYCONSOLE_IMAGE_NAME)"
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"
