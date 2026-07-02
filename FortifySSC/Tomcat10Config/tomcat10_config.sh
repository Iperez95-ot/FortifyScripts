#!/bin/bash

# Script that Configures Tomcat 10.x on a Linux System for OpenText Application Security (Fortify Software Security Center)

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
echo -e "${CYAN}Proceeding to configure Application Security Tomcat 10.x on the system at $(date)...${RESET}"

echo ""

# Prompts the user for the Application Security version
echo -ne "${CYAN}Enter the Application Security version to configure Tomcat 10.x (e.g: 25.2, 25.4, 26.2, etc): ${RESET}"
    
read -r OT_APPLICATION_SECURITY_VERSION     # Current Application Security version to be in use												                                                                

# Checks if the Application Security version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$OT_APPLICATION_SECURITY_VERSION" ]]; then
    echo -e "${RED}Error: Application Security version cannot be empty.${RESET}"

    exit 1
fi

# Builds the Application Security current version installation directory based on the version provided by the user
OT_APPLICATION_SECURITY_CURRENT_VERSION_INSTALLATION_DIR="${OT_APPLICATION_SECURITY_FILES_DIR}/${OT_APPLICATION_SECURITY_VERSION}" # Directory where Application Security version xx.x files are installed

# Checks if the Application Security Tomcat Service and Setenv file exists
if [ -f "$OT_APPLICATION_SECURITY_TOMCAT_SERVICE_FILE_DIR" ] && [ -f "$SETENV_BASH_FILE_DIR" ]; then
   echo -e "${YELLOW}Application Security Tomcat configuration is already done.${RESET}"

   exit 0
else
   echo -e "${RED}Application Security Tomcat configuration doesn't exist.${RESET}"
   
   echo ""

   # Step 1: Sets CATALINA_HOME in /etc/environment
   echo -e "${YELLOW}Setting CATALINA_HOME in '$ENVIRONMENT_FILE_DIR' directory...${RESET}"
   
   echo ""

   grep -q "CATALINA_HOME" "$ENVIRONMENT_FILE_DIR" || echo "CATALINA_HOME=${OT_APPLICATION_SECURITY_TOMCAT_DIR}" | tee -a "$ENVIRONMENT_FILE_DIR"

   echo ""

   # Step 2: Creates the setenv.sh file for Tomcat options
   echo -e "${YELLOW}Setting setenv.sh file in '$OT_APPLICATION_SECURITY_TOMCAT_DIR/bin' directory...${RESET}"

   echo ""
   
   cat <<EOF > "$SETENV_BASH_FILE_DIR"
export CATALINA_OPTS="$CATALINA_OPTS -Xms8192m"
export CATALINA_OPTS="$CATALINA_OPTS -Xmx12288m"
EOF
   chmod +x "$SETENV_BASH_FILE_DIR"
   
   echo ""

   # Step 3: Creates the systemd service file
   echo -e "${YELLOW}Creating the Application Security Tomcat 10.x service in '$SERVICES_DIR'...${RESET}"

   echo ""

   cat <<EOF > "$OT_APPLICATION_SECURITY_TOMCAT_SERVICE_FILE_DIR"
[Unit]
Description=Application Security (Fortify Software Security Center) Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_PID=$OT_APPLICATION_SECURITY_TOMCAT_DIR/temp/tomcat.pid"
Environment="CATALINA_HOME=$OT_APPLICATION_SECURITY_TOMCAT_DIR"
Environment="CATALINA_BASE=$OT_APPLICATION_SECURITY_TOMCAT_DIR"
ExecStart=$OT_APPLICATION_SECURITY_TOMCAT_DIR/bin/startup.sh
ExecStop=$OT_APPLICATION_SECURITY_TOMCAT_DIR/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

   # Makes executable the scripts to start and shutdown Tomcat
   chmod +x "$OT_APPLICATION_SECURITY_TOMCAT_DIR/bin/startup.sh"
   chmod +x "$OT_APPLICATION_SECURITY_TOMCAT_DIR/bin/shutdown.sh"

   echo ""

   # shows the directory and permissions of the created service file
   echo -e "${CYAN}Service file:${RESET}"
   ls -l "$OT_APPLICATION_SECURITY_TOMCAT_SERVICE_FILE_DIR"

   echo ""

   # Step 4: Copies the ssc.war into the Tomcat webapps directory
   echo -e "${YELLOW}Copying the 'ssc.war' file into the '$OT_APPLICATION_SECURITY_TOMCAT_DIR/webapps' directory...${RESET}"

   echo ""

   cp $OT_APPLICATION_SECURITY_CURRENT_VERSION_INSTALLATION_DIR/ssc.war $OT_APPLICATION_SECURITY_TOMCAT_DIR/webapps

   # Shows the directory and permissions of the copied ssc.war file
   echo -e "${CYAN}ssc.war file is copied:${RESET}"
   ls -l "$OT_APPLICATION_SECURITY_TOMCAT_DIR/webapps/ssc.war"

   echo ""

   # Step 5: Reloads systemd and starts the Application Security Tomcat Service
   echo -e "${YELLOW}Reloading and starting the OpenText Application Security Tomcat 10.x service...${RESET}"

   echo ""
   
   systemctl daemon-reexec
   systemctl daemon-reload
   systemctl enable ot_application_security_tomcat
   systemctl start ot_application_security_tomcat
   systemctl is-active ot_application_security_tomcat || true

   echo ""

   # Step 6: Opens the ports 8080 and 8443 for Tomcat
   echo -e "${YELLOW}Opening and saving the Ports 8080 and 8443 for Tomcat 10.x...${RESET}"

   echo ""

   firewall-cmd --permanent --add-port=8080/tcp
   firewall-cmd --permanent --add-port=8443/tcp
   firewall-cmd --reload

   echo ""

   # Shows the list of opened ports
   echo -e "${CYAN}List of opened Ports:${RESET}"
   firewall-cmd --list-ports
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