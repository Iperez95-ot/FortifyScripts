#!/bin/bash

# Script to pull from OneDrive the installation files for Fortify SSC On Premise version standalone

# Exits immediately if a command exits with a non-zero status
set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
FORTIFY_SSC_VERSION="23.2"													               # Fortify SSC version to be installed and backed up
FORTIFY_SSC_BACKUP_DIR="/home/nachossc/ssc_installation/Fortify_Software_Security_Center/$FORTIFY_SSC_VERSION"                                 # Back Up directory where Fortify SSC version 23.2 files will be stored
FORTIFY_SSC_INSTALLATION_DIR="/opt/Fortify_Software_Security_Center/Fortify_Software_Security_Center_Application_Files/$FORTIFY_SSC_VERSION"   # Installation directory where Fortify SSC version 23.2 files will be installed

# Prints the first message
echo -e "${CYAN}Proceeding to get Fortify SSC installation files from OT-Latam OneDrive on the system at $(date)...${RESET}"

echo ""

# Verifies the Back Up and Installation directories for Fortify SSC version 23.2 existance 
if [[ -d "$FORTIFY_SSC_BACKUP_DIR" && -d "$FORTIFY_SSC_INSTALLATION_DIR" ]]; then
    echo -e "${GREEN}Back Up and Installation directories for Fortify SSC $FORTIFY_SSC_VERSION already exist.${RESET}"

    echo ""
    
    exit 0
else
    echo -e "${RED}Both Back Up and Installation directories for Fortify SSC $FORTIFY_SSC_VERSION version don't exist.${RESET}"

    echo ""

    # Step 1: Creates the Back Up and Installation directories for Fortify SSC 23.2 (where the installation and back up files will be stored)
    echo -e "${YELLOW}Creating the Back Up and Installation directories for Fortify SSC version $FORTIFY_SSC_VERSION...${RESET}"

    echo ""

    mkdir -p $FORTIFY_SSC_BACKUP_DIR
    mkdir -p $FORTIFY_SSC_INSTALLATION_DIR
  
    echo ""
    
    # Step 2: Pulls Fortify SSC version 23.2 installation files into the Linux Server
    echo -e "${YELLOW}Pulling Fortify SSC version $FORTIFY_SSC_VERSION installation files from OneDrive to the Back Up and Installation directories...${RESET}"
   
    echo ""

    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/$FORTIFY_SSC_VERSION/SSC/Original Patch" $FORTIFY_SSC_BACKUP_DIR -P
    rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/$FORTIFY_SSC_VERSION/SSC/Original Patch" $FORTIFY_SSC_INSTALLATION_DIR -P

    echo ""

    echo -e "${CYAN}Extracted files on the Fortify SSC version $FORTIFY_SSC_VERSION Back Up directory:${RESET}"
    ls -l $FORTIFY_SSC_BACKUP_DIR

    echo ""

    echo -e "${CYAN}Extracted files on Fortify SSC version $FORTIFY_SSC_VERSION Installation directory:${RESET}"
    ls -l $FORTIFY_SSC_INSTALLATION_DIR
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"
