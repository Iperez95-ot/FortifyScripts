#!/bin/bash

# Script that applies the ssl certificate from Fortify Software Security Center to the Fortify Static Code Analyzer and Tools Java Keystore

# Exits immediately if a command exits with a non-zero status
set -e

# Temporarily disables the 'exit on error'
set +e

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
echo -e "${CYAN}Proceeding to add the Fortify SSC SSL Certificate to the Java Keystore from Fortify SCA and Tools on the system at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify SCA and Tools version
echo -ne "${CYAN}Enter the Fortify SCA and Tools version to apply SSL to the java keystore (e.g: 23.2, 24.2, 24.4, 25.2, 25.4 26.2, etc): ${RESET}"
    
read -r FORTIFY_SCA_APP_AND_TOOLS_VERSION  # Current Fortify SCA and Tools version in use											                                                                

# Checks if the Fortify SCA and Tools version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" ]]; then
    echo -e "${RED}Error: Fortify SCA and Tools version cannot be empty.${RESET}"

    exit 1
fi

# Checks if the Fortify SCA version is 23.2 or 24.2 or 24.4,
# if it is, builds the keystore file directory for Fortify SCA Application and Tools version xx.x
if [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(23\.2|24\.2|24\.4)$ ]]; then
    # Builds the keystore file directory for Fortify SCA Application and Tools based on the version provided by the user (for versions 23.2, 24.2 and 24.4)
    FORTIFY_SCA_APPLICATION_KEYSTORE_FILE="${FORTIFY_SCA_APPLICATION_KEYSTORE_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/jre/lib/security/cacerts"  # Fortify SCA Application Keystore file directory
    FORTIFY_SCA_TOOLS_KEYSTORE_FILE="${FORTIFY_SCA_TOOLS_KEYSTORE_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/jre/lib/security/cacerts"              # Fortify SCA Tools Keystore file directory

# Checks if the Fortify SCA version is 25.2 or 25.4 or 26.2,
# if it is, builds the keystore file directory for Application Security Testing and Application Security Tools version xx.x
elif [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(25\.2|25\.4|26\.2)$ ]]; then
    # Builds the keystore file directory for Application Security Testing and Application Security Tools based on the version provided by the user (for versions 25.2, 25.4, 26.2 and beyond)
    FORTIFY_SCA_APPLICATION_KEYSTORE_FILE="${OT_APPLICATION_SECURITY_TESTING_KEYSTORE_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/jre/lib/security/cacerts"  # OpenText Application Security Testing Keystore file directory
    FORTIFY_SCA_TOOLS_KEYSTORE_FILE="${OT_APPLICATION_SECURITY_TOOLS_KEYSTORE_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/jre/lib/security/cacerts"          # OpenText Application Security Tools Keystore file directory
fi

# Runs keytool and capture the output of both java keystores
CHECK_SCA_APPLICATION_ALIAS_OUTPUT=$(keytool -list -keystore "$FORTIFY_SCA_APPLICATION_KEYSTORE_FILE" -alias "$FORTIFY_SSC_CERTIFICATE_ALIAS" -storepass "$CACERTS_PASSWORD" 2>&1)
CHECK_SCA_TOOLS_ALIAS_OUTPUT=$(keytool -list -keystore "$FORTIFY_SCA_TOOLS_KEYSTORE_FILE" -alias "$FORTIFY_SSC_CERTIFICATE_ALIAS" -storepass "$CACERTS_PASSWORD" 2>&1)

# Re-enables the 'exit on error'
set -e

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

# Prompts for reboot
read -p "$(echo -e "${CYAN}Installation complete. Do you want to reboot now? (y/N): ${RESET}")" REBOOT

# Checks the user's response and reboots if they answered yes, otherwise it prints a final message and exits
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    reboot
else
    echo ""

    # Prints the final message
    echo -e "${GREEN}Execution completed successfully!${RESET}"
fi