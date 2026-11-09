#!/bin/bash

# Script that installs .NET 8 SDK on a Linux System and creates the Fortify Static Code Analyzer (SCA) or OpenText Application Security Testing Directories
# Required to install Fortify SCA Application and Fortify SCA Tools versions 24.2 and 24.4 
# or OpenText Application Security Testing and OpenText Application Security Tools versions 25.2 and 25.4

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
echo -e "${CYAN}Proceeding to install .NET 8 SDK on the system at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify SCA and Tools version
echo -ne "${CYAN}Enter the Fortify SCA and Tools version to create the corresponding directory (e.g: 24.2, 24.4, 25.2 and 25.4): ${RESET}"
    
read -r FORTIFY_SCA_APP_AND_TOOLS_VERSION  # Current Fortify SCA and Tools version in use											                                                                

# Checks if the Fortify SCA and Tools version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" ]]; then
    echo -e "${RED}Error: Fortify SCA and Tools version cannot be empty.${RESET}"

    exit 1
fi

# Checks if the Fortify SCA version is 24.2 or 24.4
# if it is, builds the back up installation files and working directories for Fortify SCA Application and Fortify SCA Tools version xx.x
if [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(24\.2|24\.4)$ ]]; then
    # Builds the back up installation files and working directories for Fortify SCA Application and Fortify SCA Tools based on the version provided by the user (for versions 24.2 and 24.4)
    FORTIFY_SCA_APPLICATION_BACKUP_DIR="${HOME_DIR}/sca_installation/Fortify_Static_Code_Analyzer_Application"                      # Fortify SCA Application installation files directory
    FORTIFY_SCA_TOOLS_BACKUP_DIR="${HOME_DIR}/sca_installation/Fortify_Static_Code_Analyzer_Tools"                                  # Fortify SCA Tools installation files directory
    FORTIFY_SCA_APPLICATION_WORKING_DIR="${FORTIFY_SCA_DIR}/Fortify_Static_Code_Analyzer/Fortify_Static_Code_Analyzer_Application"  # Fortify SCA Application working directory
    FORTIFY_SCA_TOOLS_WORKING_DIR="${FORTIFY_SCA_DIR}/Fortify_Static_Code_Analyzer/Fortify_Static_Code_Analyzer_Tools"              # Fortify SCA Tools working directory   

# Checks if the Fortify SCA version is 25.2 or 25.4
# if it is, builds the back up installation files and working directories for Application Security Testing and Application Security Tools version xx.x
elif [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(25\.2|25\.4)$ ]]; then
    # Builds the back up installation files and working directories for Application Security Testing and Application Security Tools based on the version provided by the user (for versions 25.2 and 25.4)
    FORTIFY_SCA_APPLICATION_BACKUP_DIR="${HOME_DIR}/sca_installation/OpenText_Application_Security_Testing"     # OpenText Application Security Testing installation files directory
    FORTIFY_SCA_TOOLS_BACKUP_DIR="${HOME_DIR}/sca_installation/OpenText_Application_Security_Tools"             # OpenText Application Security Tools installation files directory
    FORTIFY_SCA_APPLICATION_WORKING_DIR="${HOME_DIR}/sca_installation/OpenText_Application_Security_Testing"    # OpenText Application Security Testing working directory
    FORTIFY_SCA_TOOLS_WORKING_DIR="${HOME_DIR}/sca_installation/OpenText_Application_Security_Tools"            # OpenText Application Security Tools working directory
fi  

# Verifies the current .NET version
CURRENT_DOTNET_SDK=$(dotnet --list-sdks 2>/dev/null | sort -V | tail -n 1 | awk '{print $1}')

echo -e "${YELLOW}Verifying the current .NET SDK version...${RESET}"

echo ""

# If the current .NET SDK version is 8 the script will print a message and terminates
if [ "$CURRENT_DOTNET_SDK" == 8.* ]; then
   echo -e "${YELLOW}.NET SDK 8 is already installed.${RESET}"

   exit 0
   
# If the current .NET SDK version is not installed the script will install .NET SDK and
# creates the Fortify SCA Application installation directory and Fortify SCA Tools directory
elif [ -z "$CURRENT_DOTNET_SDK" ]; then
   echo -e "${YELLOW}.NET SDK is not installed in any version${RESET}"

   echo ""

   # Step 1: Updates the system packages
   echo -e "${CYAN}Updating the system packages...${RESET}"

   dnf update -y
  
   echo ""

   # Step 2: Installs .NET SDK 8
   echo -e "${YELLOW}Installing .NET SDK 8...${RESET}"
  
   dnf install -y dotnet-sdk-8.0

   echo ""
   
   # Step 3: Confirms the .NET SDK installation
   echo -e "${CYAN}Current .NET SDK version:${RESET}"
   dotnet --info

   echo ""

   echo -e "${GREEN}.NET SDK 8 installed successfully!${RESET}"

   echo ""

   # Verifies the current Fortify SCA Application installation directory and Fortify SCA Tools installation directory existance
   if [[ -d "$HOME_DIR/sca_installation" && -d "$FORTIFY_SCA_APPLICATION_WORKING_DIR" && -d "$FORTIFY_SCA_TOOLS_WORKING_DIR" ]]; then
      echo -e "${GREEN}Fortify SCA Application and Fortify SCA Tools installation directories exist.${RESET}"

      echo ""
    
      exit 0
   else
      # Step 4: Creates the Fortify SCA Application and Fortify SCA Tools back up installation directories (where the installation files will be stored)
      echo -e "${YELLOW}Creating the directories of Fortify SCA Application and Fortify SCA Tools Back Up installation files...${RESET}"

      echo ""
    
      mkdir -p $FORTIFY_SCA_APPLICATION_BACKUP_DIR
      mkdir -p $FORTIFY_SCA_TOOLS_BACKUP_DIR

      # Step 5: Creates the Fortify SCA Application and Fortify SCA Tools installation directories
      echo -e "${YELLOW}Creating the directories of Fortify SCA Application and Fortify SCA Tools installation files...${RESET}"
   
      echo ""
    
      mkdir -p $FORTIFY_SCA_APPLICATION_WORKING_DIR
      mkdir -p $FORTIFY_SCA_TOOLS_WORKING_DIR
    
      echo ""
   fi
# If the current .NET SDK version is not 8 it will print a message and exitst
else
   echo -e "${YELLOW}Your current .NET SDK version is: $CURRENT_DOTNET_SDK${RESET}"

   exit 0
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"