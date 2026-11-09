#!/bin/bash

# Script that installs .NET 10 SDK on a Linux System and creates the Fortify Static Code Analyzer (SCA) Directories
# Required to install OpenText Application Security Testing and OpenText Application Security Tools version 26.2, 26.3 and above

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
echo -e "${CYAN}Proceeding to install .NET 10 on the system at $(date)...${RESET}"

echo ""

# Verifies the current .NET version
CURRENT_DOTNET_SDK=$(dotnet --list-sdks 2>/dev/null | sort -V | tail -n 1 | awk '{print $1}')

echo -e "${YELLOW}Verifying the current .NET SDK version...${RESET}"

echo ""

# If the current .NET SDK version is 10 the script will print a message and terminates
if [[ "$CURRENT_DOTNET_SDK" == 10.* ]]; then
   echo -e "${YELLOW}.NET SDK 10 is already installed.${RESET}"

   exit 0
   
# If the current .NET SDK version is not installed the script will install .NET SDK and 
# creates the OpenText Application Security Testing installation directory and OpenText Application Security Tools directory
elif [ -z "$CURRENT_DOTNET_SDK" ]; then
   echo -e "${YELLOW}.NET SDK is not installed in any version${RESET}"
  
   echo ""

   # Step 1: Updates the system packages
   echo -e "${CYAN}Updating the system packages...${RESET}"

   dnf update -y
  
   echo ""

   # Step 2: Installs .NET SDK 10
   echo -e "${YELLOW}Installing .NET SDK 10...${RESET}"
  
   dnf install -y dotnet-sdk-10.0

   echo ""
   
   # Step 3: Confirms the .NET SDK and Runtime installation
   echo -e "${CYAN}Current .NET SDK version:${RESET}"
   dotnet --info

   echo ""

   echo -e "${GREEN}.NET SDK 10 installed successfully!${RESET}"

   echo ""

   # Verifies the current OpenText Application Security Testing installation directory and OpenText Application Security Tools installation directory existance
   if [[ -d "$HOME_DIR/sca_installation/OpenText_Application_Security_Testing_Application" && -d "$HOME_DIR/sca_installation/OpenText_Application_Security_Tools" && -d "$FORTIFY_SCA_DIR/OpenText_Application_Security_Testing/OpenText_Application_Security_Testing_Application" && -d "$FORTIFY_SCA_DIR/OpenText_Application_Security_Testing/OpenText_Application_Security_Tools" ]]; then
      echo -e "${GREEN}OpenText Application Security Testing and OpenText Application Security Tools installation directories exist.${RESET}"

      echo ""
    
      exit 0
   else
      # Step 4: Creates the OpenText Application Security Testing and OpenText Application Security Tools back up installation directories (where the installation files will be stored)
      echo -e "${YELLOW}Creating the directories of OpenText Application Security Testing and OpenText Application Security Tools Back Up installation files...${RESET}"

      echo ""
    
      mkdir -p $HOME_DIR/sca_installation/OpenText_Application_Security_Testing_Application
      mkdir -p $HOME_DIR/sca_installation/OpenText_Application_Security_Tools

      # Step 5: Creates the OpenText Application Security Testing and OpenText Application Security Tools installation directories
      echo -e "${YELLOW}Creating the directories of OpenText Application Security Testing and OpenText Application Security Tools installation files...${RESET}"
   
      echo ""
    
      mkdir -p $FORTIFY_SCA_DIR/OpenText_Application_Security_Testing/OpenText_Application_Security_Testing_Application
      mkdir -p $FORTIFY_SCA_DIR/OpenText_Application_Security_Testing/OpenText_Application_Security_Tools
    
      echo ""
   fi
# If the current .NET SDK version is not 10 it will print a message and exitst
else
   echo -e "${YELLOW}Your current .NET SDK version is: $CURRENT_DOTNET_SDK${RESET}"

   exit 0
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"