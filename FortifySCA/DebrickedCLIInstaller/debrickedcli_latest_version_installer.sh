#!/bin/bash

# Script that installs/updates Debricked CLI to the latest version on a Linux system.

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
echo -e "${CYAN}Proceeding to install Debricked CLI latest version on the system at $(date)...${RESET}"

echo ""

# Checks if Debricked CLI is already installed and retrieves the current version number if it is installed
if command -v debricked &> /dev/null; then
    DEBRICKED_CURRENT_VERSION_NUMBER=$(debricked --version | awk '{print $NF}')
else
    DEBRICKED_CURRENT_VERSION_NUMBER="none"
fi

echo -e "${CYAN}Proceeding to install/update Debricked CLI on the system at $(date)...${RESET}"

echo ""

# Checks if the latest release version number is the same as the current version number
if [ "$DEBRICKED_LATEST_RELEASE_VERSION_NUMBER" = "$DEBRICKED_CURRENT_VERSION_NUMBER" ]; then
    echo -e "${GREEN}You already have the latest Debricked CLI installed!${RESET}"

    echo ""
else
    echo -e "${YELLOW}Debricked CLI is missing or outdated.${RESET}"

    echo ""

    # Step 1: Ensures the working directory exists
    if [ ! -d "$DEBRICKED_WORKDIR" ]; then
        echo -e "${YELLOW}Creating Debricked working directory...${RESET}"

        mkdir -p "$DEBRICKED_WORKDIR"

        echo -e "${GREEN}'$DEBRICKED_WORKDIR' created.${RESET}"

        echo ""
    fi

    # Step 2: Downloads the latest release of Debricked CLI
    echo -e "${YELLOW}Downloading latest Debricked CLI...${RESET}"

    echo ""

    wget -q "$DEBRICKED_LATEST_RELEASE_URL" -O "$DEBRICKED_WORKDIR/debricked"

    chmod +x "$DEBRICKED_WORKDIR/debricked"

    echo ""

    echo -e "${GREEN}Debricked CLI Download completed.${RESET}"

    echo ""

    # Step 3: Adds Debricked CLI to PATH
    if ! grep -q "$DEBRICKED_WORKDIR" /etc/profile; then
        echo -e "${YELLOW}Adding Debricked CLI to system PATH...${RESET}"

        echo ""

        # Adds the Debricked CLI working directory to the system PATH and refreshes the environment variables
        echo "export PATH=\$PATH:$DEBRICKED_WORKDIR" >> /etc/profile
        export PATH=$PATH:$DEBRICKED_WORKDIR
        hash -r

        echo -e "${GREEN}Debricked CLI added to PATH successfully.${RESET}"

        echo ""
    else
        echo -e "${YELLOW}Debricked CLI is already present in PATH.${RESET}"

        echo ""
    fi

    # Step 4: Debugging: Verifies the directory where the latest Debricked CLI release has been downloaded
    echo -e "${CYAN}Debricked installation directory:${RESET}"
    ls -l "$DEBRICKED_WORKDIR"

    echo ""

    # Gets the version number of the newly installed/updated Debricked CLI
    DEBRICKED_NEW_VERSION_NUMBER=$(debricked --version | awk '{print $NF}')

    echo -e "${CYAN}Current Debricked CLI version: $DEBRICKED_NEW_VERSION_NUMBER${RESET}"

    echo ""

    echo -e "${GREEN}Debricked CLI installed/updated successfully!${RESET}"

    echo ""
fi

echo -e "${GREEN}Execution completed successfully!${RESET}"