#!/bin/bash

# Script that Configures Tomcat 9.x on a Linux System for Fortify Software Security Center

# Exits immediately if a command exits with a non-zero status
set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
FORTIFY_SSC_VERSION="23.2"														 		     # Current Fortify SSC version in use
FORTIFY_SSC_DIR="/opt"															                     # Fortify SSC directory																	
FORTIFY_SSC_TOMCAT_DIR="$FORTIFY_SSC_DIR/Fortify_Software_Security_Center/Fortify_Software_Security_Center_Apache_Tomcat_9"		                     # Apache Tomcat 9 directory used by Fortify SSC current version
FORTIFY_SSC_FILES_DIR="$FORTIFY_SSC_DIR/Fortify_Software_Security_Center/Fortify_Software_Security_Center_Application_Files/$FORTIFY_SSC_VERSION"            # Directory where Fortify SSC current version files are installed        
SERVICES_DIR="/etc/systemd/system"                                                                                                       		     # Services directory
SETENV_BASH_FILE_DIR="$FORTIFY_SSC_TOMCAT_DIR/bin/setenv.sh"									         		     # Fortify SSC setenv bash file path
FORTIFY_SSC_TOMCAT_SERVICE_FILE_DIR="$SERVICES_DIR/fortify_ssc_tomcat.service"                                                                               # Fortify SSC Apache Tomcat service file path
ENVIRONMENT_FILE_DIR="/etc/environment"	 												 		     # Environment directory

# Prints the first message
echo -e "${CYAN}Proceeding to configure Fortify SSC Tomcat 9.x on the system at $(date)...${RESET}"

echo ""

# Checks if the Fortify SSC Tomcat Service and Setenv file exists
if [ -f "$FORTIFY_SSC_TOMCAT_SERVICE_FILE_DIR" ] && [ -f "$SETENV_BASH_FILE_DIR" ]; then
   echo -e "${YELLOW}Fortify SSC Tomcat configuration is already done.${RESET}"

   exit 0
else
   echo -e "${RED}Fortify SSC Tomcat configuration doesn't exist.${RESET}"
   
   echo ""

   # Step 1: Set CATALINA_HOME in /etc/environment
   echo -e "${YELLOW}Setting CATALINA_HOME in '$ENVIRONMENT_FILE_DIR' directory...${RESET}"
   
   echo ""

   grep -q "CATALINA_HOME" "$ENVIRONMENT_FILE_DIR" || echo "CATALINA_HOME=${FORTIFY_SSC_TOMCAT_DIR}" | tee -a "$ENVIRONMENT_FILE_DIR"

   echo ""

   # Step 2: Creates the setenv.sh file for Tomcat options
   echo -e "${YELLOW}Setting setenv.sh file in '$FORTIFY_SSC_TOMCAT_DIR/bin' directory...${RESET}"

   echo ""
   
   cat <<EOF > "$SETENV_BASH_FILE_DIR"
export CATALINA_OPTS="\$CATALINA_OPTS -Xms2048m"
export CATALINA_OPTS="\$CATALINA_OPTS -Xmx4096m"
EOF
   chmod +x "$SETENV_BASH_FILE_DIR"
   
   echo ""

   # Step 3: Creates the systemd service file
   echo -e "${YELLOW}Creating the Fortify SSC Tomcat 9.x service in '$SERVICES_DIR'...${RESET}"

   echo ""

   cat <<EOF > "$FORTIFY_SSC_TOMCAT_SERVICE_FILE_DIR"
[Unit]
Description=Fortify Software Security Center Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_PID=$FORTIFY_SSC_TOMCAT_DIR/temp/tomcat.pid"
Environment="CATALINA_HOME=$FORTIFY_SSC_TOMCAT_DIR"
Environment="CATALINA_BASE=$FORTIFY_SSC_TOMCAT_DIR"
ExecStart=$FORTIFY_SSC_TOMCAT_DIR/bin/startup.sh
ExecStop=$FORTIFY_SSC_TOMCAT_DIR/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

   # Makes executable the scripts to start and shutdown Tomcat
   chmod +x "$FORTIFY_SSC_TOMCAT_DIR/bin/startup.sh"
   chmod +x "$FORTIFY_SSC_TOMCAT_DIR/bin/shutdown.sh"

   echo ""

   echo -e "${CYAN}Service file:${RESET}"
   ls -l "$FORTIFY_SSC_TOMCAT_SERVICE_FILE_DIR"

   echo ""

   # Step 4: Copies the ssc.war into the Tomcat webapps directory
   echo -e "${YELLOW}Copying the ssc.war into the '$FORTIFY_SSC_TOMCAT_DIR/webapps' directory...${RESET}"

   echo ""

   cp $FORTIFY_SSC_FILES_DIR/ssc.war $FORTIFY_SSC_TOMCAT_DIR/webapps

   echo -e "${CYAN}ssc.war file is copied:${RESET}"
   ls -l "$FORTIFY_SSC_TOMCAT_DIR/webapps"

   echo ""

   # Step 5: Reloads systemd and starts the Fortify SSC Tomcat Service
   echo -e "${YELLOW}Reloading and starting the Fortify SSC Tomcat 9.x service...${RESET}"

   echo ""
   
   systemctl daemon-reexec
   systemctl daemon-reload
   systemctl enable fortify_ssc_tomcat
   systemctl start fortify_ssc_tomcat
   systemctl is-active fortify_ssc_tomcat || true

   # Step 6: Opens the ports 8080 and 8443 for Tomcat
   echo -e "${YELLOW}Opening and saving the Ports 8080 and 8443 for Tomcat 9.x...${RESET}"

   echo ""

   firewall-cmd --permanent --add-port=8080/tcp
   firewall-cmd --permanent --add-port=8443/tcp
   firewall-cmd --reload

   echo ""

   echo -e "${CYAN}List of opened Ports:${RESET}"
   firewall-cmd --list-ports
fi

echo ""

# Prompt for reboot
read -p "$(echo -e "${CYAN}Installation complete. Do you want to reboot now? (y/N): ${RESET}")" REBOOT

if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    reboot
else
    # Prints the final message
    echo -e "${GREEN}Execution completed successfully!${RESET}"
fi