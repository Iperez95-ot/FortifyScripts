#!/bin/bash

# Script that Configures the certificate from Fortify ScanCentral SAST Controller for Fortify Software Security Center (SSC).

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
echo -e "${CYAN}Proceeding to configure the certificate from Fortify ScanCentral SAST Controller for Fortify Software Security Center (SSC) at $(date)...${RESET}"

echo ""

# Checks if the Fortify ScanCentral SAST Controller Certificate directory and the certificate file exist
if [[ -d "$FORTIFY_SCC_CERTIFICATES_DIR" ]] && [[ -f "$FORTIFY_SCC_CERTIFICATE_FILE" ]]; then
    echo -e "${GREEN}The directory '$FORTIFY_SCC_CERTIFICATES_DIR' and the certificate '$FORTIFY_SCC_CERTIFICATE_FILE' already exist.${RESET}"

    exit 0
else
    echo -e "${YELLOW}The certificate or directory for Fortify ScanCentral SAST Controller does not exist. Proceeding to fetch and install it...${RESET}"

    echo ""

    # Step 1: Creates the directory for the Fortify ScanCentral SAST Controller certificate
    echo -e "${YELLOW}Creating the Fortify ScanCentral SAST Controller Certificate Directory '${FORTIFY_SCC_CERTIFICATES_DIR}'...${RESET}"

    echo ""

    mkdir -p "$FORTIFY_SCC_CERTIFICATES_DIR"

    echo ""

    # Step 2: Pulls the Fortify ScanCentral SAST Controllercertificate from the Fortify SCA remote server
    echo -e "${YELLOW}Pulling the Fortify ScanCentral SAST Controller certificate from '$FORTIFY_SCA_SERVER_HOSTNAME' server...${RESET}"

    echo ""
    
    scp "root@${FORTIFY_SCA_SERVER_HOSTNAME}:${FORTIFY_SCC_CERTIFICATE_FILE}" "$FORTIFY_SCC_CERTIFICATES_DIR"
   
    echo ""

    # Shows the pulled certificate file
    echo -e "${CYAN}Pulled certificate file:${RESET}"
    ls -l "$FORTIFY_SCC_CERTIFICATES_DIR"

    echo ""

    # Step 3: Adds the Certificate file to the Linux system trusted CA store and updates the CA trust database
    echo -e "${YELLOW}Adding the certificate file '$FORTIFY_SCC_CERTIFICATE_FILE' to the system trusted CA certificates...${RESET}"
    
    mkdir -p "${HOST_TRUSTED_CA_DIRECTORY:-/etc/pki/ca-trust/source/anchors/}"

    cp "$FORTIFY_SCC_CERTIFICATE_FILE" "${HOST_TRUSTED_CA_DIRECTORY:-/etc/pki/ca-trust/source/anchors/}"
    update-ca-trust extract
    
    echo ""

    echo -e "${GREEN}Fortify ScanCentral SAST Controller certificate has been added to the system CA trust store successfully!${RESET}"

    echo ""
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"