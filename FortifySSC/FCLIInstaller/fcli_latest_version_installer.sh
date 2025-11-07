#!/bin/bash

# Script that installs/updates Fortify Command Line Interface (FCLI) to the lastest version on a linux system.

# Exits immediately if a command exits with a non-zero status
set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the Variables
FCLI_WORKDIR=/opt/fcli
FCLI_LATEST_RELEASE_VERSION=$(curl -s https://api.github.com/repos/fortify/fcli/releases/latest | jq -r '.tag_name')
FCLI_LATEST_RELEASE_VERSION_NUMBER=$(curl -s https://api.github.com/repos/fortify/fcli/releases/latest | jq -r '.tag_name' | sed 's/^v//')
FCLI_LATEST_RELEASE_URL="https://github.com//fortify/fcli/releases/download/$FCLI_LATEST_RELEASE_VERSION/fcli-linux.tgz"
FCLI_CURRENT_VERSION_NUMBER=$(fcli --version | awk '{gsub(",", "", $3); print $3}')

# Prints the first message
echo -e "${CYAN}Proceeding to install FCLI latest version on the system at $(date)...${RESET}"

echo ""

# Checks if you have installed the latest version of FCLI
if [ "$FCLI_LATEST_RELEASE_VERSION_NUMBER" = "$FCLI_CURRENT_VERSION_NUMBER" ]; then
    echo -e "${GREEN}You have the latest version of FCLI installed!${RESET}"

    echo ""
else
    echo -e "${YELLOW}You have not the latest version of FCLI.${RESET}"
 
    echo ""

    # Step 1: Checks if FCLI working directory exists and creates it if not
    if [ ! -d "$FCLI_WORKDIR" ]; then
        echo -e "${RED}FCLI working directory doesn't exists.${RESET}"
 
        echo ""

	mkdir -p $FCLI_WORKDIR

        echo -e "${GREEN}'$FCLI_WORKDIR' directory has been created.${RESET}"

        echo ""
    fi
   
    # Step 2: Install/Updates FCLI installation
    echo -e "${YELLOW}Proceeding to install/update the FCLI installation...${RESET}"

    echo ""

    # Deletes the older files from the FCLI working directory
    find "$FCLI_WORKDIR" -mindepth 1 ! -name "$(basename "$0")" -exec rm -rf {} +

    echo ""

    # Downloads the latest release of Fortify Command Line Interface (FCLI) Utility dynamically
    wget $FCLI_LATEST_RELEASE_URL -P /tmp
    tar -xzvf /tmp/fcli-linux*.tgz -C $FCLI_WORKDIR 
    rm /tmp/fcli-linux*.tgz

    echo ""

    # Step 3: Add FCLI to PATH if not already present
    if ! grep -q "$FCLI_WORKDIR" /etc/profile; then
        echo -e "${YELLOW}Adding FCLI to system PATH...${RESET}"

        echo ""

        echo "export PATH=\$PATH:$FCLI_WORKDIR" >> /etc/profile
        
        export PATH=$PATH:$FCLI_WORKDIR
        
        echo -e "${GREEN}FCLI path added successfully!${RESET}"

        echo ""
    else
        echo -e "${YELLOW}FCLI is already present in the system PATH.${RESET}"

        echo ""
    fi

    # Step 4: Debugging: Verifies the directory where the latest FCLI release has been downloaded
    echo -e "${CYAN}Directory of the current FCLI installation:${RESET}"
    ls -l $FCLI_WORKDIR

    echo ""

    # Step 5: Debugging: Verifies the current FCLI installation
    FCLI_NEW_VERSION_NUMBER=$(fcli --version | awk '{gsub(",", "", $3); print $3}')
    echo -e "${CYAN}Current FCLI version is now: $FCLI_NEW_VERSION_NUMBER.${RESET}"

    echo ""

    echo -e "${GREEN}FCLI has been installed/updated succesfully!${RESET}"

    echo ""
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"