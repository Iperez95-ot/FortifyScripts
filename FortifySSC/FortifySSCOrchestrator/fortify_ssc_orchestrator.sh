#!/bin/bash

# Script that Orchestrates the Deployment Scripts for OpenText Application Security (Fortify Software Security Center) versions 25.2, 25.5, 26.2 and beyond

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

# Sets the pipefail option to ensure that the script fails if any command in a pipeline fails
set -o pipefail

# Prints the first message
echo -e "${CYAN}Proceeding to deploy Fortify SSC on the system at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify SSC version
echo -ne "${CYAN}Enter the Fortify SSC to Deploy on the Linux System (e.g: 23.2, 24.2, 24.4, 25.2, 25.4 26.2, etc): ${RESET}"
    
read -r FORTIFY_SSC_VERSION    # Fortify SSC version to be deployed

# Checks if the Fortify SSC version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SSC_VERSION" ]]; then
    echo -e "${RED}Error: Fortify SSC version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Prompts the user for the eDirectory version
echo -ne "${CYAN}Enter the eDirectory to Deploy on the Linux System (e.g: 9.3.1, 9.3.3, etc): ${RESET}"
    
read -r EDIRECTORY_VERSION    # eDirectory version to be deployed

# Checks if the eDirectory version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$EDIRECTORY_VERSION" ]]; then
    echo -e "${RED}Error: eDirectory version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Prompts the user for the IdentityConsole version
echo -ne "${CYAN}Enter the IdentityConsole to Deploy on the Linux System (e.g: 25.2, 26.1, etc): ${RESET}"
    
read -r IDENTITYCONSOLE_VERSION    # IdentityConsole version to be deployed

# Checks if the IdentityConsole version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$IDENTITYCONSOLE_VERSION" ]]; then
    echo -e "${RED}Error: IdentityConsole version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Step 0: Checks if the script is run as root
echo -e "${YELLOW}Checking if the script is run as root...${RESET}"

echo ""

# Checks if the script is run as root (EUID 0). If not, 
# it prints an error message and exits with a non-zero status
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script needs root privileges (sudo or root user).${NC}"

   exit 1
fi

# Creates the log file and redirects stdout and stderr to it
mkdir -p "$(dirname "$LOG_FILE")" # Creates the directory for the log file if it doesn't exist
touch "$LOG_FILE"  # Creates the log file if it doesn't exist
exec > >(tee -i "$LOG_FILE") 2>&1 # Redirects stdout and stderr to the log file while also displaying it in the terminal

# Functions # 

# Function to log messages with timestamps
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to execute a deployment step
execute_step() {
    # Defines the parameters for the function
    local step_num="$1"
    local step_name="$2"
    local folder="$3"
    local script_name="$4" # Optional: If not provided, the script will look for any .sh file in the folder

    echo -e "\n${CYAN}======================================================================${RESET}"
    log "${CYAN}[Step '$step_num'] '$step_name'${RESET}"
    echo -e "${CYAN}======================================================================${RESET}"

    # Defines the target directory based on the base directory and the folder name
    local target_dir="$BASE_DIR/$folder"

    # Checks if the target directory exists, if it doesn't, 
    # prints an error message and exits the function with a non-zero status
    if [[ ! -d "$target_dir" ]]; then
        log "${RED}[ERROR] The directory does not exist: $target_dir${RESET}"

        # Returns 1 to indicate an error and exit the function
        return 1
    fi

    # Defines the target script variable to hold the path of the script to be executed
    local target_script=""

    # Checks if a specific script name is provided, if it is, 
    # sets the target script to that script in the target directory
    if [[ -n "$script_name" ]]; then
        target_script="$target_dir/$script_name"
    
    # If no specific script name is provided, it looks for any .sh file in the target directory
    else
        # Finds the first .sh file in the target directory and sets it as the target script
        target_script=$(find "$target_dir" -maxdepth 1 -name "*.sh" | head -n 1)
    fi

    # Checks if the target script exists and is a file, if it doesn't,
    # prints an error message and exits the function with a non-zero status
    if [[ -z "$target_script" || ! -f "$target_script" ]]; then
        log "${RED}[ERROR] Couldn't found any executable (.sh) in: $target_dir${RESET}"

        # Returns 1 to indicate an error and exit the function
        return 1
    fi

    # Logs the script being executed and makes it executable, then executes it in a subshell to avoid issues with relative paths
    log "${YELLOW}Executing the script:${RESET} '$target_script'"

    echo ""

    #chmod +x "$target_script"

    # Executes the target script in a subshell to avoid issues with relative paths and captures the exit status
    (
        cd "$target_dir" || exit 1
        "./$(basename "$target_script")"
    )
    
    # Captures the exit status of the executed script and checks if it is non-zero, indicating an error.
    local status=$?

    # Checks if the executed script returned a non-zero status, indicating an error. 
    # If so, it logs the error and exits the main script with the same status code. 
    # If the script executed successfully, it logs a success message
    if [[ $status -ne 0 ]]; then
        log "${RED}[FAILED] The step '$step_num' ('$step_name') failed with error code: '$status'.${RESET}"

        echo ""

        exit $status
    fi

    log "${GREEN}[OK] The step '$step_num' ('$step_name') completed successfully.${RESET}"

    echo ""
}

# Execution of the deployment steps

# Logs the start of the automated deployment process for the specified Fortify SSC version
log "${CYAN}Starting the automated deployment of Fortify SSC '$FORTIFY_SSC_VERSION' version...${RESET}"

echo ""

# logs the location of the log file for the deployment process
log "Log saved to: '$LOG_FILE'"

echo ""

# Step 1: Java JDK Installation
# Checks if the Fortify SSC version is 26.2 or beyond, if it is, it logs a message indicating that Java JDK 21 will be installed 
# and calls the execute_step function to perform the installation
if [[ "$FORTIFY_SSC_VERSION" == "26.2" ]]; then
    log "${YELLOW}Fortifty SSC version is '$FORTIFY_SSC_VERSION', installing Java JDK 21...${RESET}"

    echo ""

    # Calls the execute_step function to perform the Java JDK 21 installation step, passing the step number, step name, folder name and script as arguments
    execute_step 1 "Java JDK 21 Installation" "JavaInstaller/21" "java_21_installer.sh"

# If the Fortify SSC version is not 26.2, it logs a message indicating that Java JDK 17 will be installed 
# and calls the execute_step function to perform the installation
else
    log "${YELLOW}Fortifty SSC version is '$FORTIFY_SSC_VERSION', installing Java JDK 17...${RESET}"

    echo ""

    # Calls the execute_step function to perform the Java JDK 17 installation step, passing the step number, step name, folder name and script as arguments
    execute_step 1 "Java JDK 17 Installation" "JavaInstaller/17" "java_17_installer.sh"
fi

# Step 2: Tomcat Installation
# Checks if Fortify SSC version is 25.2 or 25.4 or 26.2 or beyond, if it is, it logs a message indicating that Apache Tomcat 10 will be installed
# and calls the execute_step function to perform the installation
if [[ "$FORTIFY_SSC_VERSION" == "25.2" || "$FORTIFY_SSC_VERSION" == "25.4" || "$FORTIFY_SSC_VERSION" == "26.2" ]]; then
    log "${YELLOW}Fortifty SSC version is '$FORTIFY_SSC_VERSION', installing Apache Tomcat 10...${RESET}"

    echo ""
    
    # Calls the execute_step function to perform the Apache Tomcat 10 installation step, passing the step number, step name, folder name and script as arguments
    execute_step 2 "Tomcat 10 Installation" "Tomcat10Installer" "tomcat10_installer.sh"

# If the Fortify SSC version is not 25.2 or 25.4 or 26.2 or beyond, it logs a message indicating that Apache Tomcat 9 will be installed 
# and calls the execute_step function to perform the installation
else
    log "${YELLOW}Fortifty SSC version is '$FORTIFY_SSC_VERSION', installing Apache Tomcat 9...${RESET}"

    echo ""

    # Calls the execute_step function to perform the Apache Tomcat 9 installation step, passing the step number, step name, folder name and script as arguments
    execute_step 2 "Tomcat 9 Installation" "Tomcat9Installer" "tomcat9_installer.sh"
fi

# Step 3: Pulls from OneDrive the installation files from Fortify SSC 
execute_step 3 "OneDrive Files Pull (Download the installation files from Fortify SSC via rclone)" "FortifySSCInstallationFilesPull" "fortify_ssc_one_drive_installation_files_pull.sh"

# Step 4: Tomcat Configuration (ssc.war deploy and tomcat service creation)
# Checks if Fortify SSC version is 25.2 or 25.4 or 26.2 or beyond, if it is, it logs a message indicating that Apache Tomcat 10 will be configured
# and calls the execute_step function to perform the configuration
if [[ "$FORTIFY_SSC_VERSION" == "25.2" || "$FORTIFY_SSC_VERSION" == "25.4" || "$FORTIFY_SSC_VERSION" == "26.2" ]]; then
    log "${YELLOW}Fortifty SSC version is '$FORTIFY_SSC_VERSION', configuring Apache Tomcat 10...${RESET}"

    echo ""

    execute_step 4 "Tomcat 10 Configuration and Fortify SSC Deployment" "Tomcat10Config" "tomcat10_config.sh"

# If the Fortify SSC version is not 25.2 or 25.4 or 26.2 or beyond, it logs a message indicating that Apache Tomcat 9 will be configured 
# and calls the execute_step function to perform the configuration
else
    log "${YELLOW}Fortifty SSC version is '$FORTIFY_SSC_VERSION', configuring Apache Tomcat 9...${RESET}"

    echo ""

    execute_step 4 "Tomcat 9 Configuration and Fortify SSC Deployment" "Tomcat9Config" "tomcat9_config.sh"
fi

# Step 5: MySQL 8 Installation
execute_step 5 "MySQL 8 Database Deploy" "MySQL8Installer" "mysql8_installer.sh"

# Step 6: MySQL 8 Database Deploy
execute_step 6 "MySQL 8 Fortify SSC Database Deploy" "FortifySSCMySQLDBDockerContainer/HostlessDockerContainer/docker_management_scripts/builder" "fortifyssc_db_builder.sh"

# Step 6.5: Fortify SSC Initial Setup (wait for the user to finish)
log "${CYAN}Press any key to continue...${RESET}"

read -n 1 -s

echo ""

# Checks if Fortify SSC version is 25.2 or 25.4 or 26.2 or beyond, the service ot_application_security_tomcat will be restarted
if [[ "$FORTIFY_SSC_VERSION" == "25.2" || "$FORTIFY_SSC_VERSION" == "25.4" || "$FORTIFY_SSC_VERSION" == "26.2" ]]; then
    systemctl restart ot_application_security_tomcat

    log "${CYAN}Press any key to continue...${RESET}"

    read -n 1 -s

    echo ""

# If the Fortify SSC version is not 25.2 or 25.4 or 26.2 or beyond, the service fortify_ssc_tomcat will be restarted
else 
    systemctl restart fortify_ssc_tomcat

    log "${CYAN}Press any key to continue...${RESET}"
    
    read -n 1 -s

    echo ""
fi

# Step 7: Applies SSL to Fortify SSC
# Checks if Fortify SSC version is 25.2 or 25.4 or 26.2 or beyond, if it is, it logs a message indicating that Fortify SSC will be configured for SSL
# for Apache Tomcat 10 and calls the execute_step function to perform the configuration
if [[ "$FORTIFY_SSC_VERSION" == "25.2" || "$FORTIFY_SSC_VERSION" == "25.4" || "$FORTIFY_SSC_VERSION" == "26.2" ]]; then
    log "${YELLOW}Applying SSL to Fortifty SSC version '$FORTIFY_SSC_VERSION' on Apache Tomcat 10...${RESET}"

    echo ""

    execute_step 7 "Applies SSL / HTTPS to Fortify SSC" "Tomcat10SSLConfig" "tomcat10_ssl_config.sh"

# If the Fortify SSC version is not 25.2 or 25.4 or 26.2 or beyond, it logs a message indicating that Fortify SSC will be configured for SSL  
# for Apache Tomcat 9 and calls the execute_step function to perform the configuration
else
    log "${YELLOW}Applying SSL to Fortifty SSC version '$FORTIFY_SSC_VERSION' on Apache Tomcat 9...${RESET}"

    echo ""
    
    execute_step 7 "Applies SSL / HTTPS to Fortify SSC" "Tomcat9SSLConfig" "tomcat9_ssl_config.sh"
fi

# Step 8: Update Fortify SSC Default Admin Password
execute_step 8 "Updates Fortify SSC Default Admin Password" "FortifySSCMySQLDBDockerContainer/UpdateFortifyDefaultAdminPassword" "update_fortify_default_admin_user_password.sh"

# Step 9: Uploads Fortify Rulepacks to Fortify SSC
execute_step 9 "Uploads Fortify Rulepacks to Fortify SSC" "FortifySSCAPIScripts/UploadFortifyRulepacksToFortifySSC" "UpdateFortifySSCRulepacks.py"

# Step 10: Pulls from OneDrive the installation files from eDirectory Application, eDirectory API and IdentityConsole for LDAP services 
execute_step 10 "OneDrive Files Pull (Download the installation files from LDAP services via rclone)" "LDAPDockerContainer/DockerInstallationFilesPull" "edirectory_identityconsole_one_drive_installation_files_pull.sh"

# Step 11: eDirectory Application deployment
# Checks if eDirectory Application version variable is not empty, if it is, it logs a message indicating that eDirectory Application will be deployed
# and calls the execute_step function to perform the deployment
if [[ -n "$EDIRECTORY_VERSION" ]]; then
    log "${YELLOW}Deploying eDirectory Application version '$EDIRECTORY_VERSION'...${RESET}"

    echo ""

    execute_step 11 "eDirectory Application Deployment" "LDAPDockerContainer/eDirectory/${EDIRECTORY_VERSION}/docker_management_scripts/builder" "edirectory_docker_container_builder.sh"
fi

# Step 12: IdentityConsole Application deployment
# Checks if IdentityConsole Application version variable is not empty, if it is, it logs a message indicating that IdentityConsole Application will be deployed
# and calls the execute_step function to perform the deployment
if [[ -n "$IDENTITYCONSOLE_VERSION" ]]; then
    log "${YELLOW}Deploying IdentityConsole Application version '$IDENTITYCONSOLE_VERSION'...${RESET}"

    echo ""

    execute_step 12 "IdentityConsole Application Deployment" "LDAPDockerContainer/IdentityConsole/${IDENTITYCONSOLE_VERSION}/docker_management_scripts/builder" "identityconsole_docker_container_builder.sh"
fi

# Step 13: eDirectory API deployment
# Checks if eDirectory API version variable is not empty, if it is, it logs a message indicating that eDirectory API will be deployed
# and calls the execute_step function to perform the deployment
if [[ -n "$IDENTITYCONSOLE_VERSION" ]]; then
    log "${YELLOW}Deploying eDirectory API version '$IDENTITYCONSOLE_VERSION'...${RESET}"

    echo ""

    execute_step 13 "eDirectory API Deployment" "LDAPDockerContainer/EDirectoryAPI/${IDENTITYCONSOLE_VERSION}/docker_management_scripts/builder" "edirectory_api_docker_container_builder.sh"
fi

# Step 14: LDAP Configuration on Fortify SSC
execute_step 14 "Configures LDAP Server on Fortify SSC" "FortifySSCAPIScripts/CreateLDAPServerConfig" "CreateLDAPServerConfig.py"

# Step 15: LDAP Users and Groups Creation on eDirectory
execute_step 15 "LDAP Users and Groups Creation on eDirectory" "LDAPDockerContainer/EDirectoryAPI/edir_api_scripts/eDirectoryUsersGroupsCreation" "eDirectoryUsersGroupsCreation.py"

# Step 16: Add LDAP Entities on Fortify SSC
execute_step 16 "Configures LDAP Server on Fortify SSC" "FortifySSCAPIScripts/AddLDAPEntities" "AddLDAPEntities.py"

echo -e "\n${GREEN}======================================================================${RESET}"
log "${GREEN}[OK] Fortify SSC '$FORTIFY_SSC_VERSION' version deployed successfully!${RESET}"
echo -e "${GREEN}======================================================================${RESET}"

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"