#!/bin/bash

# Script that installs Java OpenJDK 17 on a Linux System

# Exits immediately if a command exits with a non-zero status
set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Prints the first message
echo -e "${CYAN}Proceeding to install Java OpenJDK 17 on the system at $(date)...${RESET}"

echo ""

# Verifies the current Java version
CURRENT_JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F. '{if ($1 =="1") print $2; else print $1}')

echo -e "${YELLOW}Verifying the current Java version...${RESET}"

echo ""

# If the current Java version is 17 the script will print a message and terminates
if [ "$CURRENT_JAVA_VERSION" == "17" ]; then

   echo -e "${YELLOW}Java 17 is already installed.${RESET}"

   exit 0
# If the current Java version is not 17 the script will install Java 17 and create the JAVA_HOME enviroment variable
else
   echo -e "${YELLOW}Your current Java version is: $CURRENT_JAVA_VERSION${RESET}"
  
   echo ""

   # Step 1: Updates the system packages
   echo -e "${CYAN}Updating the system packages...${RESET}"
  
   dnf update -y
  
   echo ""

   # Step 2: Installs Java 17 (OpenJDK)
   echo -e "${YELLOW}Installing Java 17 (OpenJDK)...${RESET}"
  
   dnf install -y java-17-openjdk java-17-openjdk-devel

   echo ""

   # Step 3: Confirms the Java installation
   echo -e "${GREEN}Java 17 installed successfully!${RESET}"

   echo ""
   
   # Step 4: Displays the installed Java version
   echo -e "${YELLOW}Verifying Java version...${RESET}"

   java -version
   
   echo ""

   # Step 5: Sets JAVA_HOME and updates PATH in /etc/environment
   echo -e "${YELLOW}Setting JAVA_HOME and PATH in /etc/environment...${RESET}"
   
   echo ""

   # Gets the actual JAVA_HOME path
   JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
   
   # Removes existing JAVA_HOME or PATH lines if present
   sed -i '/^JAVA_HOME=/d' /etc/environment
   sed -i '/^PATH=.*JAVA_HOME/d' /etc/environment

   # Adds JAVA_HOME and updated PATH
   echo "JAVA_HOME=${JAVA_HOME_PATH}" | tee -a /etc/environment

   # Re-read the JAVA_HOME from /etc/environment
   JAVA_HOME=$(grep '^JAVA_HOME=' /etc/environment | cut -d '=' -f2-)
   export JAVA_HOME

   echo ""
   
   echo -e "${GREEN}JAVA_HOME is set to $JAVA_HOME${RESET}"
fi

echo ""

# Prompts for reboot
read -p "$(echo -e "${CYAN}Installation complete. Do you want to reboot now? (y/N): ${RESET}")" REBOOT

# Checks the user's response and reboots if they answered yes, otherwise it prints a final message and exits
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    reboot
else
    # Prints the final message
    echo -e "${GREEN}Execution completed successfully!${RESET}"
fi
