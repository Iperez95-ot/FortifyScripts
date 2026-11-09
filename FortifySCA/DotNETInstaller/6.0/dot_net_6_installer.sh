#!/bin/bash

# Script that installs .NET 6 Runtime on a Linux System and creates the Fortify Static Code Analyzer (SCA) Directories
# Required to install Fortify SCA Application and Fortify SCA Tools version 23.2

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
echo -e "${CYAN}Proceeding to install .NET 6 on the system at $(date)...${RESET}"

echo ""

# Verifies the current .NET version
CURRENT_DOTNET_RUNTIME=$(dotnet --list-runtimes 2>/dev/null | grep 'Microsoft.NETCore.App' | sort -V | tail -n 1 | awk '{print $2}')

echo -e "${YELLOW}Verifying the current .NET Runtime version...${RESET}"

echo ""

# If the current .NET Runtime version is 6 the script will print a message and terminates
if [ "$CURRENT_DOTNET_RUNTIME" == 6.* ]; then
   echo -e "${YELLOW}.NET Runtime 6 is already installed.${RESET}"

   exit 0
   
# If the current .NET Runtime version is not installed the script will install .NET Runtime 
elif [ -z "$CURRENT_DOTNET_RUNTIME" ]; then
   echo -e "${YELLOW}.NET Runtime is not installed in any version${RESET}"
  
   echo ""

   # Step 1: Updates the system packages
   echo -e "${CYAN}Updating the system packages...${RESET}"

   dnf update -y
  
   echo ""

   # Step 2: Installs .NET Runtime 6
   echo -e "${YELLOW}Installing .NET Runtime 6...${RESET}"
  
   dnf install -y dotnet-runtime-6.0

   echo ""
   
   # Step 3: Confirms the .NET Runtime installation
   dotnet --list-runtimes

   echo ""

   echo -e "${GREEN}.NET Runtime 6 installed successfully!${RESET}"

   echo ""

   # Verifies the current Fortify SCA Application installation directory and Fortify SCA Tools installation directory existance
   if [[ -d "$HOME_DIR/sca_installation" && -d "$FORTIFY_SCA_DIR/Fortify_Static_Code_Analyzer_Application" && -d "$FORTIFY_SCA_DIR/Fortify_Static_Code_Analyzer_Tools" ]]; then
      echo -e "${GREEN}Fortify SCA Application and Fortify SCA Tools installation directories exist.${RESET}"

      echo ""
    
      exit 0
   else
      # Step 4: Creates the Fortify SCA Application and Fortify SCA Tools back up installation directories (where the installation files will be stored)
      echo -e "${YELLOW}Creating the directories of Fortify SCA Application and Fortify SCA Tools back up installation files...${RESET}"

      echo ""
    
      mkdir -p $HOME_DIR/sca_installation/Fortify_Static_Code_Analyzer_Application
      mkdir -p $HOME_DIR/sca_installation/Fortify_Static_Code_Analyzer_Tools

      # Step 5: Creates the Fortify SCA Application and Fortify SCA Tools installation directories
      echo -e "${YELLOW}Creating the directories of Fortify SCA Application and Fortify SCA Tools installation files...${RESET}"
   
      echo ""
    
      mkdir -p $FORTIFY_SCA_DIR/Fortify_Static_Code_Analyzer/Fortify_Static_Code_Analyzer_Application
      mkdir -p $FORTIFY_SCA_DIR/Fortify_Static_Code_Analyzer/Fortify_Static_Code_Analyzer_Tools
    
      echo ""
   fi
# If the current .NET Runtime version is not 6 it will print a message and exitst
else
   echo -e "${YELLOW}Your current .NET Runtime version is: $CURRENT_DOTNET_RUNTIME${RESET}"

   exit 0
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"