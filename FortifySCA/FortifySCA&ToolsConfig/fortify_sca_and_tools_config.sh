#!/bin/bash

# Script that configures all the symlinks for Fortify Static Code Analyzer (SCA) Tools to be used globally

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

# Functions #

# Function that creates symlinks for all executables in the specified bin directory
create_symlinks() {
    local bin_dir="$1"

    # Checks if the bin directory exists
    if [[ ! -d "$bin_dir" ]]; then
        echo -e "${YELLOW}Skipping '$bin_dir' because it does not exist.${RESET}"

        echo ""

        return
    fi

    # Iterates over all files in the bin directory and creates symlinks for each executable
    for file in "$bin_dir"/*; do
        # Skips if no files exist
        [[ -e "$file" ]] || continue

        local base
        base=$(basename "$file")

        echo -e "${YELLOW}Adding the symlink to the '$base' tool...${RESET}"

        echo ""

        # Checks if the file already exists in /usr/local/bin
        # If it does, appends '-tools'suffix to the symlink name to avoid conflicts if the file already exists in /usr/local/bin
        if [[ -e "/usr/local/bin/$base" ]]; then
            ln -sf "$file" "/usr/local/bin/${base}-tools"
        else
            ln -sf "$file" "/usr/local/bin/$base"
        fi
    done
}

# Main Program #

# Prints the first message
echo -e "${CYAN}Proceeding to create the symlinks for Fortify Static Code Analyzer (SCA) Tools at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify SCA and Tools version
echo -ne "${CYAN}Enter the Fortify SCA and Tools version to configure the symlinks of the tools (e.g: 23.2, 24.2, 24.4, 25.2, 25.4 26.2, etc): ${RESET}"
    
read -r FORTIFY_SCA_APP_AND_TOOLS_VERSION  # Current Fortify SCA and Tools version in use											                                                                

# Checks if the Fortify SCA and Tools version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" ]]; then
    echo -e "${RED}Error: Fortify SCA and Tools version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Checks if the Fortify SCA version is 23.2 or 24.2 or 24.4,
# if it is, builds the bin directories for Fortify SCA Application and Tools version xx.x
if [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(23\.2|24\.2|24\.4)$ ]]; then
    # Builds the bin directories for Fortify SCA Application and Tools based on the version provided by the user (for versions 23.2, 24.2 and 24.4)
    FORTIFY_SCA_APP_BIN_DIR="${FORTIFY_SCA_APP_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/bin"      # Bin directory where Fortify SCA Application tools are located
    FORTIFY_SCA_TOOLS_BIN_DIR="${FORTIFY_SCA_TOOLS_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/bin"  # Bin directory where Fortify SCA Tools tools are located

    # Calls the create_symlinks function for both Fortify SCA Application and Tools bin directories
    create_symlinks "$FORTIFY_SCA_APP_BIN_DIR"
    create_symlinks "$FORTIFY_SCA_TOOLS_BIN_DIR"

# Checks if the Fortify SCA version is 25.2 or 25.4 or 26.2,
# if it is, builds the bin directories for Application Security Testing and Application Security Tools version xx.x
elif [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(25\.2|25\.4|26\.2)$ ]]; then
    # Builds the bin directories for Application Security Testing and Application Security Tools based on the version provided by the user (for versions 25.2, 25.4, 26.2 and beyond)
    OT_APPLICATION_SECURITY_TESTING_BIN_DIR="${OT_APPLICATION_SECURITY_TESTING_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/bin"     # Bin directory where Application Security Testing tools are located
    OT_APPLICATION_SECURITY_TOOLS_BIN_DIR="${OT_APPLICATION_SECURITY_TOOLS_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/bin"         # Bin directory where Application Security Tools tools are located

    # Calls the create_symlinks function for both Application Security Testing and Application Security Tools bin directories
    create_symlinks "$OT_APPLICATION_SECURITY_TESTING_BIN_DIR"
    create_symlinks "$OT_APPLICATION_SECURITY_TOOLS_BIN_DIR"
fi  

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"