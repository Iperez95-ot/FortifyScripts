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

# Prompts for patch folder selection
echo -e "${CYAN}Select which folder to pull from 'SSC':${RESET}"
echo "  1) Original Patch only (Base installer)"
echo "  2) All folders (Original Patch + any maintenance patches like ${FORTIFY_SSC_VERSION}.1)"
echo "  3) Custom patch folder name (e.g. ${FORTIFY_SSC_VERSION}.1 Patch)"
echo -ne "${CYAN}Enter your choice [1-3] (Default: 1): ${RESET}"
read -r PATCH_CHOICE

case "$PATCH_CHOICE" in
    1)
        echo -e "${GREEN}Selected Option 1: Original Patch only${RESET}"
        SSC_SUBFOLDER="/Original Patch"
        ;;
    2)
        echo -e "${GREEN}Selected Option 2: All folders${RESET}"
        SSC_SUBFOLDER=""
        ;;
    3)
        echo -ne "${CYAN}Enter the exact folder name inside SSC (e.g., '${FORTIFY_SSC_VERSION}.1 Patch'): ${RESET}"
        read -r CUSTOM_PATCH_NAME
        echo -e "${GREEN}Selected Option 3: '${CUSTOM_PATCH_NAME}'${RESET}"
        SSC_SUBFOLDER="/${CUSTOM_PATCH_NAME}"
        ;;
    *)
        echo -e "${YELLOW}Defaulting to Option 1: Original Patch${RESET}"
        SSC_SUBFOLDER="/Original Patch"
        ;;
esac

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

    # 2.1 Pulls the selected folder of choice into the Back Up directory (Pulls based on user's selection: Original, All, or Specific Patch)
    echo -e "${CYAN}Pulling selected folder(s) to the Back Up directory...${RESET}"
    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/${FORTIFY_SSC_VERSION}/SSC${SSC_SUBFOLDER}/" "$FORTIFY_SSC_BACKUP_DIR" -P

    echo ""

    # 2.1.5 Pulls rulepacks to Back Up directory if Option 2 was not selected (Option 2 already pulled the entire SSC tree including Rulepacks)
    if [[ "$PATCH_CHOICE" != "2" ]]; then
        echo -e "\n${CYAN}Pulling Rulepacks to the Back Up directory...${RESET}"
        rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/${FORTIFY_SSC_VERSION}/SSC/Rulepacks/" "$FORTIFY_SSC_BACKUP_DIR/rulepacks" -P || true

        echo ""
    fi

    # 2.2 Pulls ONLY the contents inside "Original Patch" (first patch fresh installation) into the Installation directory
    echo -e "${CYAN}Pulling ONLY the 'Original Patch' files (fresh installation) to the Installation directory...${RESET}"
    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/${FORTIFY_SSC_VERSION}/SSC/Original Patch/" "$FORTIFY_SSC_INSTALLATION_DIR" -P
   
    echo ""

    # Step 3: Lists the files that were pulled from OneDrive into the Back Up directory for Fortify SSC version xx.x
    echo -e "${CYAN}Extracted files on Fortify SSC version $FORTIFY_SSC_VERSION Back Up directory:${RESET}"
    find "$FORTIFY_SSC_BACKUP_DIR" -type f -exec ls -lh {} + 2>/dev/null || ls -l "$FORTIFY_SSC_BACKUP_DIR"

    echo ""

    # Step 4: Lists the files that were pulled from OneDrive into the Installation directory for Fortify SSC version xx.x
    echo -e "${CYAN}Extracted files on Fortify SSC version $FORTIFY_SSC_VERSION Installation directory:${RESET}"
    find "$FORTIFY_SSC_INSTALLATION_DIR" -type f -exec ls -lh {} + 2>/dev/null || ls -l "$FORTIFY_SSC_INSTALLATION_DIR"
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"