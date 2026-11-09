#!/bin/bash

# Script to pull from OneDrive the installation files for Fortify SCA Application and Tools On Premise version xx.x standalone

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
echo -e "${CYAN}Proceeding to get Fortify SCA and Tools installation files from OT-Latam OneDrive on the system at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify SCA and Tools version
echo -ne "${CYAN}Enter the Fortify SCA and Tools version to pull the installation files from OT-Latam OneDrive (e.g: 23.2, 24.2, 24.4, 25.2, 25.4 26.2, etc): ${RESET}"
    
read -r FORTIFY_SCA_APP_AND_TOOLS_VERSION    # Fortify SCA and Tools version to be installed and backed up												                                                                

# Checks if the Fortify SCA and Tools version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" ]]; then
    echo -e "${RED}Error: Fortify SCA and Tools version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Prompts for patch folder selection
echo -e "${CYAN}Select which folder to pull from 'SCA':${RESET}"
echo "  1) Original Patch only (Base installer)"
echo "  2) All folders (Original Patch + any maintenance patches like ${FORTIFY_SCA_APP_AND_TOOLS_VERSION}.1)"
echo "  3) Custom patch folder name (e.g. ${FORTIFY_SCA_APP_AND_TOOLS_VERSION}.1 Patch)"
echo -ne "${CYAN}Enter your choice [1-3] (Default: 1): ${RESET}"
read -r PATCH_CHOICE

case "$PATCH_CHOICE" in
    2)
        SCA_SUBFOLDER="" # Pulls entire SCA directory (both Original Patch and Patches)
        ;;
    3)
        echo -ne "${CYAN}Enter the exact folder name inside SCA (e.g., '${FORTIFY_SCA_APP_AND_TOOLS_VERSION}.1 Patch'): ${RESET}"
        read -r CUSTOM_PATCH_NAME
        SCA_SUBFOLDER="/${CUSTOM_PATCH_NAME}"
        ;;
    *)
        SCA_SUBFOLDER="/Original Patch" # Default: pulls base installer only
        ;;
esac

echo ""

# Checks if the Fortify SCA version is 23.2 or 24.2 or 24.4,
# if it is, builds the Back Up and Installation directories for Fortify SCA Application and Tools version xx.x
if [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(23\.2|24\.2|24\.4)$ ]]; then
    # Builds the Back Up and Installation directories for Fortify SCA Application and Tools based on the version provided by the user (for versions 23.2, 24.2 and 24.4)
    FORTIFY_SCA_APP_BACKUP_DIR="${FORTIFY_SCA_APP_BACKUP_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"                  # Back Up directory where Fortify SCA Application files will be stored
    FORTIFY_SCA_APP_INSTALLATION_DIR="${FORTIFY_SCA_APP_INSTALLATION_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"      # Installation directory where Fortify SCA Application files will be installed
    FORTIFY_SCA_TOOLS_BACKUP_DIR="${FORTIFY_SCA_TOOLS_BACKUP_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"              # Back Up directory where Fortify SCA Tools files will be stored
    FORTIFY_SCA_TOOLS_INSTALLATION_DIR="${FORTIFY_SCA_TOOLS_INSTALLATION_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"  # Installation directory where Fortify SCA Tools files will be installed

# Checks if the Fortify SCA version is 25.2 or 25.4 or 26.2,
# if it is, builds the Back Up and Installation directories for Application Security Testing and Application Security Tools version xx.x
elif [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(25\.2|25\.4|26\.2)$ ]]; then
    # Builds the Back Up and Installation directories for Application Security Testing and Application Security Tools based on the version provided by the user (for versions 25.2, 25.4, 26.2 and beyond)
    FORTIFY_SCA_APP_BACKUP_DIR="${OT_APPLICATION_SECURITY_TESTING_BACKUP_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"               # Back Up directory where Application Security Testing files will be stored
    FORTIFY_SCA_APP_INSTALLATION_DIR="${OT_APPLICATION_SECURITY_TESTING_INSTALLATION_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"   # Installation directory where Application Security Testing files will be installed
    FORTIFY_SCA_TOOLS_BACKUP_DIR="${OT_APPLICATION_SECURITY_TOOLS_BACKUP_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"               # Back Up directory where Application Security Tools files will be stored
    FORTIFY_SCA_TOOLS_INSTALLATION_DIR="${OT_APPLICATION_SECURITY_TOOLS_INSTALLATION_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}"   # Installation directory where Application Security Tools files will be installed
fi

# Verifies the Back Up and Installation directories for Fortify SCA and Tools version xx.x existance 
if [[ -d "$FORTIFY_SCA_APP_BACKUP_DIR" && -d "$FORTIFY_SCA_APP_INSTALLATION_DIR" && -d "$FORTIFY_SCA_TOOLS_BACKUP_DIR" && -d "$FORTIFY_SCA_TOOLS_INSTALLATION_DIR" ]]; then
    echo -e "${GREEN}Back Up and Installation directories for Fortify SCA and Tools $FORTIFY_SCA_APP_AND_TOOLS_VERSION already exist.${RESET}"

    echo ""
    
    exit 0
else
    echo -e "${RED}Both Back Up and Installation directories for Fortify SCA and Tools $FORTIFY_SCA_APP_AND_TOOLS_VERSION version don't exist.${RESET}"

    echo ""

    # Step 1: Creates the Back Up and Installation directories for Fortify SCA and Tools xx.x (where the installation and back up files will be stored)
    echo -e "${YELLOW}Creating the Back Up and Installation directories for Fortify SCA and Tools version $FORTIFY_SCA_APP_AND_TOOLS_VERSION...${RESET}"

    echo ""

    mkdir -p $FORTIFY_SCA_APP_BACKUP_DIR
    mkdir -p $FORTIFY_SCA_APP_INSTALLATION_DIR
    mkdir -p $FORTIFY_SCA_TOOLS_BACKUP_DIR
    mkdir -p $FORTIFY_SCA_TOOLS_INSTALLATION_DIR
  
    echo ""

    echo -e "${CYAN}Fortify SCA Application version $FORTIFY_SCA_APP_AND_TOOLS_VERSION back up directory is: '$FORTIFY_SCA_APP_BACKUP_DIR'.${RESET}"
    echo -e "${CYAN}Fortify SCA Application version $FORTIFY_SCA_APP_AND_TOOLS_VERSION installation directory is: '$FORTIFY_SCA_APP_INSTALLATION_DIR'.${RESET}"
    echo -e "${CYAN}Fortify SCA Tools version $FORTIFY_SCA_APP_AND_TOOLS_VERSION back up directory is: '$FORTIFY_SCA_TOOLS_BACKUP_DIR'.${RESET}"
    echo -e "${CYAN}Fortify SCA Tools version $FORTIFY_SCA_APP_AND_TOOLS_VERSION installation directory is: '$FORTIFY_SCA_TOOLS_INSTALLATION_DIR'.${RESET}"
    
    echo ""
    
    # Step 2: Pulls Fortify SCA and Tools version xx.xx installation files into the Linux Server
    echo -e "${YELLOW}Pulling Fortify SCA and Tools version $FORTIFY_SCA_APP_AND_TOOLS_VERSION installation files from OneDrive to the Back Up and Installation directories...${RESET}"
   
    echo ""

    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/SCA${SCA_SUBFOLDER}/" "$FORTIFY_SCA_APP_BACKUP_DIR" -P
    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/SCA & Tools/" "$FORTIFY_SCA_TOOLS_BACKUP_DIR" -P

    echo ""

    echo -e "${YELLOW}Setting executable permissions on all .run files...${RESET}"
    find "$FORTIFY_SCA_APP_BACKUP_DIR" -type f -name "*.run" -exec chmod +x {} +
    find "$FORTIFY_SCA_TOOLS_BACKUP_DIR" -type f -name "*.run" -exec chmod +x {} +

    echo ""

    echo -e "${CYAN}Extracted files on the Fortify SCA Application version $FORTIFY_SCA_APP_AND_TOOLS_VERSION Back Up directory:${RESET}"
    find "$FORTIFY_SCA_APP_BACKUP_DIR" -type f -exec ls -lh {} +

    echo ""

    echo -e "${CYAN}Extracted files on Fortify SCA Application version $FORTIFY_SCA_APP_AND_TOOLS_VERSION Installation directory:${RESET}"
    find "$FORTIFY_SCA_APP_INSTALLATION_DIR" -type f -exec ls -lh {} +

    echo ""

    echo -e "${CYAN}Extracted files on the Fortify SCA Tools version $FORTIFY_SCA_APP_AND_TOOLS_VERSION Back Up directory:${RESET}"
    find "$FORTIFY_SCA_TOOLS_BACKUP_DIR" -type f -exec ls -lh {} +

    echo ""

    echo -e "${CYAN}Extracted files on Fortify SCA Tools version $FORTIFY_SCA_APP_AND_TOOLS_VERSION Installation directory:${RESET}"
    find "$FORTIFY_SCA_TOOLS_INSTALLATION_DIR" -type f -exec ls -lh {} +
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"