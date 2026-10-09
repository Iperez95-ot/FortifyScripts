#!/bin/bash

# Script that Configures Fortify ScanCentral SAST Controller for Fortify Software Security Center (SSC)

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
echo -e "${CYAN}Proceeding to configure Fortify ScanCentral SAST Controller for Fortify Software Security Center (SSC) at $(date)...${RESET}"

echo ""


# Checks if the Fortify SSC Certificate is present in the Java Keystore from Fortify SCA and Tools and checks the existance of the directory where the Fortify SSC Certificate is present
if echo "$CHECK_SCA_APPLICATION_ALIAS_OUTPUT" | grep -q "Alias name:" && echo "$CHECK_SCA_TOOLS_ALIAS_OUTPUT" | grep -q "Alias name:" | [[ -d "$FORTIFY_SSC_CERTIFICATES_DIR" ]]; then
    echo -e "${GREEN}The Alias '$FORTIFY_SSC_CERTIFICATE_ALIAS' already exists in both keystores from Fortify SCA Applications and Tools. Also the directory '$FORTIFY_SSC_CERTIFICATES_DIR' already exist.${RESET}"

    exit 0
else
    echo -e "${RED}The Alias '$FORTIFY_SSC_CERTIFICATE_ALIAS' is missing in both keystores from Fortify SCA Applications and Tools. Also the Fortify SSC Certificates directory doesn't exist.${RESET}"
    
    echo ""

    # Step 1: Creates the directory for the Fortify SSC certificates and pulls the certificate from Fortify SSC from 
    echo -e "${YELLOW}Creating the Fortify SSC Certificates Directory...${RESET}"

    echo ""

    mkdir -p $FORTIFY_SSC_CERTIFICATES_DIR

    echo ""

    echo -e "${YELLOW}Pulling the Fortify SSC certificate from $FORTIFY_SSC_SERVER_HOSTNAME server...${RESET}"

    echo ""

    scp root@$FORTIFY_SSC_SERVER_HOSTNAME:$FORTIFY_SSC_CERTIFICATE_FILE $FORTIFY_SSC_CERTIFICATES_DIR

    echo ""

    echo -e "${CYAN}Pulled files from $FORTIFY_SSC_SERVER_HOSTNAME server...${RESET}"
    ls -l $FORTIFY_SSC_CERTIFICATES_DIR

    echo ""

    # Step 2: Adds the Fortify SSC Certificate to the Java Keystores from Fortify SCA Application and Tools
    echo -e "${YELLOW}Adding the Fortify SSC certificate to the Fortify SCA and Tools Java Keystore...${RESET}"

    echo ""

    # Adds the Fortify SSC certificate to the Fortify SCA Application java keystore (cacerts)
    keytool -importcert -file $FORTIFY_SSC_CERTIFICATE_FILE -keystore $FORTIFY_SCA_APPLICATION_KEYSTORE_FILE -alias $FORTIFY_SSC_CERTIFICATE_ALIAS -storepass $CACERTS_PASSWORD -noprompt
    
    # Adds the Fortify SSC certificate to the Fortify SCA Tools java keystore (cacerts)
    keytool -importcert -file $FORTIFY_SSC_CERTIFICATE_FILE -keystore $FORTIFY_SCA_TOOLS_KEYSTORE_FILE -alias $FORTIFY_SSC_CERTIFICATE_ALIAS -storepass $CACERTS_PASSWORD -noprompt

    echo ""

    echo -e "${GREEN}Fortify SSC certificate has been added to the Fortify SCA Application and Tools java keystore successfully!${RESET}"

    echo ""

    # Step 3: Adds the Certificate file from Fortify SSC to the system's trusted CA store
    echo -e "${YELLOW}Adding the certificate file from Fortify SSC to the system's trusted CA certificates...${RESET}"

    echo ""

    # Copies the Certificate file to the trusted anchors directory
    cp "$FORTIFY_SSC_CERTIFICATE_FILE" "/etc/pki/ca-trust/source/anchors/"

    # Updates the CA trust database
    update-ca-trust extract

    echo -e "${GREEN}Fortify SSC certificate file has been added to the system CA trust store successfully!${RESET}"
    
    echo ""
fi