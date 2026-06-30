#!/bin/bash

# Script that Configures Secure Sockets Layer (SSL) on a Tomcat 10.x running OpenText Application Security (Fortify Software Security Center) Web Application on a Linux System

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
echo -e "${CYAN}Proceeding to create and add a SSL Certificate to the Apache Tomcat 10 running OpenText Application Security on the system at $(date)...${RESET}"

echo ""

# Checks if the SSL Connector is present (look for port="8443" or SSLEnabled="true") and not commented out in the server.xml file of Tomcat 10 used by OpenText Application Security
if awk '
    BEGIN { in_comment=0; ssl=0; port=0; }
    {
        # Start or end of a comment block
        if ($0 ~ /<!--/) in_comment=1
        if ($0 ~ /-->/)  { in_comment=0; next }

        # Skips if in comment block
        if (in_comment) next

        # Looks for active SSL markers
        if ($0 ~ /SSLEnabled="true"/) ssl=1
        if ($0 ~ /port="8443"/) port=1
    }
    END {
        # Returns success if either is found
        exit !(ssl || port)
    }
' "$OT_APPLICATION_SECURITY_TOMCAT_SERVER_FILE"; then   
    echo -e "${GREEN}SSL is already configured in the Apache Tomcat 10 used by OpenText Application Security.${RESET}"
    
    exit 0
else
    echo -e "${RED}SSL is not configured in the Apache Tomcat 10 used by OpenText Application Security.${RESET}"

    echo ""

    # Step 1: Generates a Key file 
    echo -e "${YELLOW}Generating the Key file '$OT_APPLICATION_SECURITY_KEY_FILE'...${RESET}"
    
    systemctl stop fortify_ssc_tomcat
    mkdir -p "$CERTIFICATES_DIR"  	
    cd "$CERTIFICATES_DIR"
    openssl genrsa -aes256 -passout pass:"$OT_APPLICATION_SECURITY_CERTIFICATE_PASSWORD" -out "$OT_APPLICATION_SECURITY_KEY_FILE" "$OT_APPLICATION_SECURITY_CERTIFICATE_KEY_SIZE"

    echo ""
    
    # Step 2: Generates the Certificate file based on the Key file
    echo -e "${YELLOW}Generating the certificate file '$OT_APPLICATION_SECURITY_CERTIFICATE_FILE' based on the '$OT_APPLICATION_SECURITY_KEY_FILE' key file...${RESET}"

    echo ""

    openssl req -x509 -new -key "$OT_APPLICATION_SECURITY_KEY_FILE" -passin pass:"$OT_APPLICATION_SECURITY_CERTIFICATE_PASSWORD" \
     -sha256 -days "$OT_APPLICATION_SECURITY_CERTIFICATE_DAYS_VALID" -out "$OT_APPLICATION_SECURITY_CERTIFICATE_FILE" \
     -subj "$OT_APPLICATION_SECURITY_CERTIFICATE_SUBJECT" \
     -addext "subjectAltName = $OT_APPLICATION_SECURITY_CERTIFICATE_SAN_VALUE"

    echo ""

    # Step 2.1: Adds the Certificate file from Application Security to the system's trusted CA store
    echo -e "${YELLOW}Adding the certificate file '$OT_APPLICATION_SECURITY_CERTIFICATE_FILE' to the system's trusted CA certificates...${RESET}"

    echo ""

    # Copies the Certificate file to the trusted anchors directory
    cp "$CERTIFICATES_DIR/$OT_APPLICATION_SECURITY_CERTIFICATE_FILE" "/etc/pki/ca-trust/source/anchors/"

    # Updates the CA trust database
    update-ca-trust extract

    echo ""

    echo -e "${GREEN}Certificate '$OT_APPLICATION_SECURITY_CERTIFICATE_FILE' file has been added to the system CA trust store successfully!${RESET}"
    
    echo ""

    # Step 3: Creating the PEM file based on the Key file and Certificate file
    echo -e "${YELLOW}Creating the PEM file '$OT_APPLICATION_SECURITY_PEM_FILE' based on the '$OT_APPLICATION_SECURITY_KEY_FILE' key file and '$OT_APPLICATION_SECURITY_CERTIFICATE_FILE' certificate file...${RESET}"

    echo "" 

    cat "$OT_APPLICATION_SECURITY_KEY_FILE" "$OT_APPLICATION_SECURITY_CERTIFICATE_FILE" > "$OT_APPLICATION_SECURITY_PEM_FILE"

    echo ""

    # Step 4: Creates the P12 file to be called in the Tomcat 10 server.xml file
    echo -e "${YELLOW}Creating the PKCS#12 (.p12) file '$OT_APPLICATION_SECURITY_P12_FILE'...${RESET}"
   
    openssl pkcs12 -export \
     -inkey "$OT_APPLICATION_SECURITY_KEY_FILE" -passin pass:"$OT_APPLICATION_SECURITY_CERTIFICATE_PASSWORD" \
     -in "$OT_APPLICATION_SECURITY_CERTIFICATE_FILE" \
     -out "$OT_APPLICATION_SECURITY_P12_FILE" -passout pass:"$OT_APPLICATION_SECURITY_CERTIFICATE_PASSWORD" \
     -name "$APP_ALIAS"
    
    echo ""
    
    # Shows the directory and permissions of the created .p12 file
    echo -e "${CYAN}New files created:${RESET}"
    ls -l     

    echo ""

    # Step 5: Applies SSL to the Tomcat 10 server.xml file using the .p12 file
    echo -e "${YELLOW}Appliying SSL to the Tomcat10 where OpenText Application Security is deployed...${RESET}"

    cd "$SCRIPT_DIR"

    # Creates a temporary file with the SSL connector block
    tmpfile=$(mktemp)

    cat <<EOF > "$tmpfile"
        <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               SSLEnabled="true" maxThreads="150" scheme="https" secure="true"
               keystoreFile="${CERTIFICATES_DIR}/${OT_APPLICATION_SECURITY_P12_FILE}"
               keystoreType="PKCS12" keystorePass="${OT_APPLICATION_SECURITY_CERTIFICATE_PASSWORD}"
               clientAuth="false" sslProtocol="TLS" />
EOF

    # Inserts the SSL connector before the closing </Service> tag
    sed -i.bak "/<\/Service>/e cat $tmpfile" "$OT_APPLICATION_SECURITY_TOMCAT_SERVER_FILE"

    # Cleans up the temp file
    rm -f "$tmpfile"
    
    echo ""

    echo -e "${GREEN}SSL Connector added to Tomcat's server.xml!${RESET}"
    
    echo ""

    # Step 6: Modifies the app.properties file of Fortify Software Security Center (SSC)
    echo -e "${YELLOW}Modifying the 'app.properties' file of Fortify SSC...${RESET}"
    
    echo ""

    # Checks if the app.properties file exists before trying to modify it
    if [ -f "$APP_PROPERTIES_FILE" ]; then
        echo -e "${YELLOW}Updating 'host.url value' in the app.properties file...${RESET}"
   
        echo ""
        
        # Updates the host.url value in the app.properties file using the value of OT_APPLICATION_SECURITY_NEW_HOST_URL variable, 
        # only if the current value matches the OT_APPLICATION_SECURITY_OLD_HOST_URL variable
        sed -i.bak "s|^host\.url=${OT_APPLICATION_SECURITY_OLD_HOST_URL}|host.url=${OT_APPLICATION_SECURITY_NEW_HOST_URL}|" "$APP_PROPERTIES_FILE"
        
        echo -e "${GREEN}Fortify SSC Host URL updated successfully!${RESET}"

        echo ""

        echo -e "${YELLOW}Enabling SOAP API in the app.properties file...${RESET}"

        # Enables the SOAP API in the app.properties file by changing soap.api.disabled from true to false
        sed -i "s|^soap\.api\.disabled=true|soap.api.disabled=false|" "$APP_PROPERTIES_FILE"

        echo -e "${GREEN}SOAP API enabled successfully!${RESET}"

        echo ""
    else
        echo -e "${RED}File ${APP_PROPERTIES_FILE} not found. Skipping Fortify SSC Host URL update and Enabling the SOAP API in the app.properties file.${RESET}"
       
        echo ""
    fi

    echo -e "${YELLOW}Restarting OpenText Application Security Tomcat service...${RESET}"
    
    # Restarts the OT Application Security Tomcat service to apply the changes
    systemctl restart ot_application_security_tomcat

    echo ""
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"