#!/bin/bash

# Script that installs Tomcat 10.x on a Linux System

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
  export $(grep -v '^#' .env | sed 's/#.*//g' | xargs)
fi 

# Prints the first message
echo -e "${CYAN}Proceeding to install Tomcat 10.x on the system at $(date)...${RESET}"

echo ""

# Verifies the current Tomcat installation directory and Fortify Software Security Center installation directory existance 
# and if they exist, it skips the installation steps, 
# otherwise it proceeds to install Tomcat 10.x and creates the necessary directories for the installation files
if [[ -d "$HOME_DIR/ssc_installation" && -d "$FORTIFY_SSC_DIR/OpenText_Application_Security" ]]; then
    echo -e "${GREEN}Home and Tomcat installation directories already exist.${RESET}"

    echo ""
    
    exit 0
else
    echo -e "${RED}Both Tomcat installation and Home directories don't exist.${RESET}"

    echo ""

    # Step 1: Creates the Tomcat installation directory (where the installation files will be stored)
    echo -e "${YELLOW}Creating the directory of Tomcat 10.x installation files...${RESET}"

    echo ""
    
    mkdir -p $HOME_DIR/ssc_installation/Apache_Tomcat_10.x
    mkdir -p $HOME_DIR/ssc_installation/OpenText_Application_Security
  
    echo ""

    # Step 2: Downloads Tomcat 10.x zip file inside the Tomcat installation directory
    echo -e "${YELLOW}Downloading the latest Tomcat 10.x installation files...${RESET}"

    echo ""

    cd $HOME_DIR/ssc_installation/Apache_Tomcat_10.x
    LATEST_TOMCAT10_VERSION=$(curl -s https://dlcdn.apache.org/tomcat/tomcat-10/ | grep -oE 'v10\.[0-9]+\.[0-9]+/' | sort -V | tail -n1 | tr -d '/')
    wget "https://dlcdn.apache.org/tomcat/tomcat-10/${LATEST_TOMCAT10_VERSION}/bin/apache-tomcat-${LATEST_TOMCAT10_VERSION#v}.tar.gz"

    echo ""

    # Shows the directory and permissions of the downloaded file
    echo -e "${CYAN}Downloaded file:${RESET}"
    ls -l $HOME_DIR/ssc_installation/Apache_Tomcat_10.x
    
    echo ""

    # Step 3: Creates the Fortify Software Security Center installation directory
    echo -e "${YELLOW}Creating the directory of Fortify Software Security Center installation files...${RESET}"
   
    echo ""
    
    mkdir -p $FORTIFY_SSC_DIR/OpenText_Application_Security/OpenText_Application_Security_Apache_Tomcat_10
    mkdir -p $FORTIFY_SSC_DIR/OpenText_Application_Security/OpenText_Application_Security_Application_Files
    
    echo ""
    
    # Step 4: Extracts Tomcat instalaltion zip file in the Fortify Software Security Center installation directory
    tar --strip-components=1 -xvf apache-tomcat-${LATEST_TOMCAT10_VERSION#v}.tar.gz -C "$FORTIFY_SSC_DIR/OpenText_Application_Security/OpenText_Application_Security_Apache_Tomcat_10"

    echo ""
    
    # Shows the directory and permissions of the extracted files
    echo -e "${CYAN}Extracted files:${RESET}"
    ls -l $FORTIFY_SSC_DIR/OpenText_Application_Security/OpenText_Application_Security_Apache_Tomcat_10
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"