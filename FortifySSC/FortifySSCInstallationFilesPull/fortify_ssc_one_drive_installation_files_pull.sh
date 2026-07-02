#!/bin/bash

# Script to pull from OneDrive the installation files from Fortify SSC On Premise version xx.x standalone

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
echo -e "${CYAN}Proceeding to get Fortify SSC installation files from OT-Latam OneDrive on the system at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify SSC version
echo -ne "${CYAN}Enter the Fortify SSC version to pull from One Drive (e.g: 23.2, 24.2, 24.4, 25.2, 25.4 26.2, etc): ${RESET}"
    
read -r FORTIFY_SSC_VERSION    # Fortify SSC version to be installed and backed up												                                                                

# Checks if the Fortify SSC version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SSC_VERSION" ]]; then
    echo -e "${RED}Error: Fortify SSC version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Checks if the Fortify SSC version is 23.2 or 24.2 or 24.4,
# if it is, builds the Back Up and Installation directories for Fortify SSC version xx.x
if [[ "$FORTIFY_SSC_VERSION" =~ ^(23\.2|24\.2|24\.4)$ ]]; then
    # Builds the Back Up and Installation directories for Fortify SSC based on the version provided by the user (for versions 23.2, 24.2 and 24.4)
    FORTIFY_SSC_BACKUP_DIR="${FORTIFY_SSC_BACKUP_BASE_DIR}/${FORTIFY_SSC_VERSION}"               # Back Up directory where Fortify SSC files will be stored
    FORTIFY_SSC_INSTALLATION_DIR="${FORTIFY_SSC_INSTALLATION_BASE_DIR}/${FORTIFY_SSC_VERSION}"   # Installation directory where Fortify SSC files will be installed

# Checks if the Fortify SSC version is 25.2 or 25.4 or 26.2,
# if it is, builds the Back Up and Installation directories for Application Security version xx.x
elif [[ "$FORTIFY_SSC_VERSION" =~ ^(25\.2|25\.4|26\.2)$ ]]; then
    # Builds the Back Up and Installation directories for Fortify SSC based on the version provided by the user (for versions 25.2, 25.4, 26.2 and beyond)
    FORTIFY_SSC_BACKUP_DIR="${OT_APPLICATION_SECURITY_BACKUP_BASE_DIR}/${FORTIFY_SSC_VERSION}"               # Back Up directory where Application Security files will be stored
    FORTIFY_SSC_INSTALLATION_DIR="${OT_APPLICATION_SECURITY_INSTALLATION_BASE_DIR}/${FORTIFY_SSC_VERSION}"   # Installation directory where Application Security files will be installed
fi

# Verifies the Back Up and Installation directories for Fortify SSC version xx.x existance 
if [[ -d "$FORTIFY_SSC_BACKUP_DIR" && -d "$FORTIFY_SSC_INSTALLATION_DIR" ]]; then
    echo -e "${GREEN}Back Up and Installation directories for Fortify SSC $FORTIFY_SSC_VERSION already exist.${RESET}"

    echo ""
    
    exit 0
else
    echo -e "${RED}Both Back Up and Installation directories for Fortify SSC $FORTIFY_SSC_VERSION version don't exist.${RESET}"

    echo ""

    # Step 1: Creates the Back Up and Installation directories for Fortify SSC xx.x (where the installation and back up files will be stored)
    echo -e "${YELLOW}Creating the Back Up and Installation directories for Fortify SSC version $FORTIFY_SSC_VERSION...${RESET}"

    echo ""

    mkdir -p $FORTIFY_SSC_BACKUP_DIR
    mkdir -p $FORTIFY_SSC_INSTALLATION_DIR

    echo ""

    echo -e "${CYAN}Fortify SSC Application version $FORTIFY_SSC_VERSION back up directory is: '$FORTIFY_SSC_BACKUP_DIR'.${RESET}"
    echo -e "${CYAN}Fortify SSC Application version $FORTIFY_SSC_VERSION installation directory is: '$FORTIFY_SSC_INSTALLATION_DIR'.${RESET}"
    
    echo ""
    
    # Step 2: Pulls Fortify SSC version xx.x installation files and rulepacks into the Linux Server
    echo -e "${YELLOW}Pulling Fortify SSC version $FORTIFY_SSC_VERSION installation files from OneDrive to the Back Up and Installation directories...${RESET}"
   
    echo ""

    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/$FORTIFY_SSC_VERSION/SSC/Original Patch" $FORTIFY_SSC_BACKUP_DIR -P

    # Checks if the major version is 23,
    # if it is, pulls the rulepacks into the Back Up directory for Fortify SSC version xx.x
    if (( major_version == 23 )); then
        rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/$FORTIFY_SSC_VERSION/SSC/Rulepacks" $FORTIFY_SSC_BACKUP_DIR/rulepacks -P
    fi
    
    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/$FORTIFY_SSC_VERSION/SSC/Original Patch" $FORTIFY_SSC_INSTALLATION_DIR -P

    # Checks if the major version is 23,
    # if it is, pulls the rulepacks into the Installation directory for Fortify SSC version
    if (( major_version == 23 )); then
        rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/$FORTIFY_SSC_VERSION/SSC/Rulepacks" $FORTIFY_SSC_INSTALLATION_DIR/rulepacks -P
    fi
   
    echo ""

    # Step 3: Lists the files that were pulled from OneDrive into the Back Up directory for Fortify SSC version xx.x
    echo -e "${CYAN}Extracted files on the Fortify SSC version $FORTIFY_SSC_VERSION Back Up directory:${RESET}"
    ls -l $FORTIFY_SSC_BACKUP_DIR

    echo ""

    # Step 4: Lists the files that were pulled from OneDrive into the Installation directory for Fortify SSC version xx.x
    echo -e "${CYAN}Extracted files on Fortify SSC version $FORTIFY_SSC_VERSION Installation directory:${RESET}"
    ls -l $FORTIFY_SSC_INSTALLATION_DIR
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"