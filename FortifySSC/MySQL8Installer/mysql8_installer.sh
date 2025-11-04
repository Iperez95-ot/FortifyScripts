#!/bin/bash

# Script that installs MySQL 8.0 Client on a Linux System

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
echo -e "${CYAN}Proceeding to install MySQL 8.0 on the system at $(date)...${RESET}"

echo ""

# Verifies the current MySQL Client version
echo -e "${YELLOW}Verifying the current MySQL version...${RESET}"

echo ""

# If MySQL 8.0 Client is already installed the script will print a message and terminates
if mysql --version >/dev/null 2>&1; then

   echo -e "${YELLOW}MySQL 8.0 Client is already installed.${RESET}"

   exit 0
# If MySQL 8.0 is not installed it will install it
else
   echo -e "${RED}MySQL 8.0 Client is not installed.${RESET}"
  
   echo ""

   # Step 1: Updates the system packages
   echo -e "${CYAN}Updating the system packages...${RESET}"
  
   dnf update -y
  
   echo ""

   # Step 2: Adds the MySQL 8.0 Community Repository
   echo -e "${YELLOW}Adding the MySQL 8.0 Community Repository...${RESET}"
  
   dnf install -y https://repo.mysql.com/mysql80-community-release-el9-1.noarch.rpm

   echo ""

   # Step 3: Imports the MySQL 2023 GPG Key (used by MySQL 8.0.42+ versions)
   echo -e "${YELLOW}Importing the MySQL 2023 GPG Key${RESET}"

   echo ""

   rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

   echo ""
   
   # Step 4: Installs MySQL 8.0 Client
   echo -e "${YELLOW}Installing MySQL 8.0 Client${RESET}"

   echo ""

   dnf install -y mysql-community-client

   echo ""
   
   # Step 5: Displays the installed MySQL Client version
   echo -e "${YELLOW}Verifying MySQL Client version...${RESET}"

   mysql --version
   
   echo ""

   # Step 6: Pulls from OT-Latam OneDrive the my.cnf (configuration file for mysql database) to the linux server
   echo -e "${YELLOW}Pulling Fortify SSC version $FORTIFY_SSC_VERSION installation files from OneDrive to the Back Up and Installation directories...${RESET}"
   
   echo ""

   rclone copy "ot-latam_onedrive:Back Up/Fortify/Product Versions/$FORTIFY_SSC_VERSION/SSC/mysql8" $MYSQL_CONFIG_HOST_DIRECTORY -P

   echo ""

   echo -e "${CYAN}Extracted files on the MYSQL config files directory:${RESET}"
   ls -l $MYSQL_CONFIG_HOST_DIRECTORY

   echo ""

   echo -e "${GREEN}MySQL 8.0 Client successfully!${RESET}"
fi

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"
