#!/bin/bash
# Script to install Helm Package Manager for Kubernetes latest version in a Linux System

# Exits immediately if a command exits with a non-zero status
set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
HELM_LATEST_RELEASE_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f 4)			# Helm latest release version
HELM_LATEST_RELEASE_VERSION_NUMBER=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name' | sed 's/^v//')         # Helm latest release version number    
HELM__LATEST_RELEASE_URL="curl -LO https://get.helm.sh/helm-${HELM_LATEST_RELEASE_VERSION}-linux-amd64.tar.gz"                                  # Helm latest release version url
HELM_STANDARD_DIRECTORY="/usr/local/bin/helm"													# Helm installation directory

# Prints the first message
echo -e "${CYAN}Proceeding to install Helm latest version on the system at $(date)...${RESET}"

echo ""

# Checks if Helm is installed. If it is already installed it will update Helm version to the latest version
if command -v helm &>/dev/null; then
    HELM_CURRENT_VERSION_NUMBER=$(helm version --short | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

    echo -e "${YELLOW}Helm is already installed on the version $HELM_CURRENT_VERSION_NUMBER.${RESET}"

    echo ""

    # Compares each Helm version (Current vs Latest one)
    if [ "$HELM_CURRENT_VERSION_NUMBER" = "$HELM_LATEST_RELEASE_VERSION_NUMBER" ]; then
        # If the latest version is already installed exits the script
        echo -e "${GREEN}You already have the latest Helm version.${RESET}"
        
        exit 0
    else
        # If the current version installed is older than the latest version, updates Helm installation to the latest one
        echo -e "${YELLOW}You have an older version from Helm.${RESET}"
        
        echo ""

	echo -e "${YELLOW}Updating Helm version...${RESET}"

        echo ""

	# Downloads Helm latest release
    	echo -e "${YELLOW}Downloading Helm $HELM_LATEST_RELEASE_VERSION_NUMBER version...${RESET}"

    	echo ""

    	curl -LO https://get.helm.sh/helm-${HELM_LATEST_RELEASE_VERSION}-linux-amd64.tar.gz

    	echo ""

	# Extracts and updates Helm (replaces old files with the new ones)
    	echo -e "${YELLOW}Extracting and installing Helm...${RESET}"

    	echo ""    

    	tar -zxvf helm-${HELM_LATEST_RELEASE_VERSION}-linux-amd64.tar.gz

    	echo ""

    	# Moves Helm installation to a standard folder
   	mv linux-amd64/helm $HELM_STANDARD_DIRECTORY

    	echo ""

    	echo -e "${CYAN}Shows new Helm installation files:${RESET}"
    	ls -l $HELM_STANDARD_DIRECTORY

    	echo ""

    	# Deletes the zip file downloaded
    	echo -e "${YELLOW}Deleting the downloaded zip file...${RESET}"

    	echo ""
    
    	rm -rf linux-amd64 helm-${HELM_LATEST_RELEASE_VERSION}-linux-amd64.tar.gz

    	echo ""

    	echo -e "${CYAN}Shows the script directory:${RESET}"
    	ls -l

    	echo ""

    	# Verifies the updated Helm version
    	echo -e "${GREEN}Updated Helm to version: $(helm version --short | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')${RESET}"

	echo ""
    fi
else
    HELM_CURRENT_VERSION_NUMBER="none"

    echo -e "${YELLOW}Helm is not installed.${RESET}"

    echo ""

    # Downloads Helm latest release
    echo -e "${YELLOW}Downloading Helm $HELM_LATEST_RELEASE_VERSION_NUMBER version...${RESET}"

    echo ""

    curl -LO https://get.helm.sh/helm-${HELM_LATEST_RELEASE_VERSION}-linux-amd64.tar.gz

    echo ""

    # Extracts and installs Helm
    echo -e "${YELLOW}Extracting and installing Helm...${RESET}"

    echo ""    

    tar -zxvf helm-${HELM_LATEST_RELEASE_VERSION}-linux-amd64.tar.gz

    echo ""

    # Moves Helm installation to a standard folder
    mv linux-amd64/helm $HELM_STANDARD_DIRECTORY

    echo ""

    echo -e "${CYAN}Shows Helm installation files:${RESET}"
    ls -l $HELM_STANDARD_DIRECTORY

    echo ""

    # Deletes the zip file downloaded
    echo -e "${YELLOW}Deleting the downloaded zip file...${RESET}"

    echo ""
    
    rm -rf linux-amd64 helm-${HELM_LATEST_RELEASE_VERSION}-linux-amd64.tar.gz

    echo ""

    echo -e "${CYAN}Shows the script directory:${RESET}"
    ls -l

    echo ""

    # Verifies the installed Helm version
    echo -e "${GREEN}Helm successfully installed on version: $(helm version --short | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')${RESET}"

    echo ""
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"