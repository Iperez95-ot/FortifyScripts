#!/bin/bash

# Script that creates the Project Samples Directory and installs some insecure sample projects for Fortify testing functionality

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
echo -e "${CYAN}Proceeding to install Fortify SCA samples projects on the system at $(date)...${RESET}"

echo ""

# Prompts the user for the Fortify SCA and Tools version
echo -ne "${CYAN}Enter the Fortify SCA and Tools version to retrieve the Fortify SCA Insecure Sample Projects (e.g: 23.2, 24.2, 24.4, 25.2, 25.4, 26.2, etc): ${RESET}"
    
read -r FORTIFY_SCA_APP_AND_TOOLS_VERSION  # Current Fortify SCA and Tools version in use											                                                                

# Checks if the Fortify SCA and Tools version is empty, if it is, prints an error message and exits the script with a non-zero status
if [[ -z "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" ]]; then
    echo -e "${RED}Error: Fortify SCA and Tools version cannot be empty.${RESET}"

    exit 1
fi

echo ""

# Prompts for patch subfolder selection (handles "Original Patch" vs maintenance patches)
echo -e "${CYAN}Select which folder / patch to use for sample source files:${RESET}"
echo "  1) Original Patch (Base version)"
echo "  2) Specific patch folder (e.g. ${FORTIFY_SCA_APP_AND_TOOLS_VERSION}.1 Patch)"
echo "  3) Direct / None (files are directly under the version directory)"
echo -ne "${CYAN}Enter your choice [1-3] (Default: 1): ${RESET}"
read -r PATCH_CHOICE

case "$PATCH_CHOICE" in
    2)
        echo -ne "${CYAN}Enter the exact folder name (e.g., '${FORTIFY_SCA_APP_AND_TOOLS_VERSION}.1 Patch'): ${RESET}"
        read -r CUSTOM_PATCH_NAME
        PATCH_SUBFOLDER="/${CUSTOM_PATCH_NAME}"
        ;;
    3)
        PATCH_SUBFOLDER=""
        ;;
    *)
        PATCH_SUBFOLDER="/Original Patch"
        ;;
esac

echo ""

# Checks if the Fortify SCA version is 23.2 or 24.2 or 24.4,
# if it is, builds the samples source directory for Fortify SCA Application and Tools version xx.x
if [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(23\.2|24\.2|24\.4)$ ]]; then
    # Builds the samples source directory for Fortify SCA Application and Tools based on the version provided by the user (for versions 23.2, 24.2 and 24.4)
    SAMPLES_SOURCE_DIR="${FORTIFY_SCA_SAMPLES_SOURCE_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/${PATCH_SUBFOLDER}/insecure_applications_samples"  # Fortify SAST insecure project samples source directory
    
# Checks if the Fortify SCA version is 25.2 or 25.4 or 26.2,
# if it is, builds the samples source directory for Application Security Testing and Application Security Tools version xx.x
elif [[ "$FORTIFY_SCA_APP_AND_TOOLS_VERSION" =~ ^(25\.2|25\.4|26\.2)$ ]]; then
    # Builds the samples source directory for Application Security Testing and Application Security Tools based on the version provided by the user (for versions 25.2, 25.4, 26.2 and beyond)
    SAMPLES_SOURCE_DIR="${OT_APPLICATION_SECURITY_TESTING_SAMPLES_SOURCE_BASE_DIR}/${FORTIFY_SCA_APP_AND_TOOLS_VERSION}/${PATCH_SUBFOLDER}/insecure_applications_samples"  # Fortify SAST insecure project samples source directory
fi  

# Verifies the existence of the Fortify SCA sample projects directory
if [[ -d "$SAMPLES_WORK_DIR" ]]; then
    echo -e "${GREEN}Fortify SCA samples are already set up to be used!${RESET}"

    echo ""
    
    exit 0
else
    echo -e "${RED}Fortify SCA samples are not set up.${RESET}"

    echo ""
    
    # Step 1: Creates the Projects Samples Directory and adds the sample projects from Fortify SCA installation files on it
    echo -e "${YELLOW}Creating the Projects Samples Directory...${RESET}"
   
    echo ""

    mkdir -p $SAMPLES_WORK_DIR
    mkdir -p $SAMPLES_WORK_DIR/basic
    mkdir -p $SAMPLES_WORK_DIR/advanced

    echo ""

    # Step 2: Copies the sample projects from Fortify SCA installation files into the Projects Samples Directory, 
    # to be used for testing purposes, which includes both "basic" and "advanced" sample projects to provide a wide range of testing scenarios
    # for Fortify SCA and Debricked products
    echo -e "${YELLOW}Copying the projects samples from Fortify SCA installation files in the new project samples directory...${RESET}"
   
    echo ""

    # Copies both "basic" and "advanced" projects samples folders Projects Samples Directory, if they exist
    # Iterates over the "basic" and "advanced" folders to copy them, if they exist, from the source directory to the destination directory
    for level in basic advanced; do
        # Checks if the folder exists in the source directory before copying it to avoid errors
        if [[ -d "$SAMPLES_SOURCE_DIR/$level" ]]; then
            echo -e "${CYAN}Copying '$level' projects into the '$SAMPLES_WORK_DIR' directory...${RESET}"
            cp -r "$SAMPLES_SOURCE_DIR/$level" "$SAMPLES_WORK_DIR/"
        else
            echo -e "${RED}Warning: '$level' folder not found in '$SAMPLES_SOURCE_DIR'.${RESET}"
        fi
    done
 
    echo ""
   
    echo -e "${GREEN}Sample projects successfully copied to: '$SAMPLES_WORK_DIR' directory${RESET}"

    echo ""

    echo -e "${CYAN}Basic sample projects:${RESET}"
    ls -l $SAMPLES_WORK_DIR/basic

    echo ""

    echo -e "${CYAN}Advanced sample projects:${RESET}"
    ls -l $SAMPLES_WORK_DIR/advanced

    echo ""

    # Step 2: Cloning another insecure Fortify SCA samples projects from GitHub into the project samples directory
    echo -e "${YELLOW}Creating the directory for the extra Fortify SCA samples projects from GitHub...${RESET}"

    echo ""

    GITHUB_SAMPLES_DIR="$SAMPLES_WORK_DIR/github"
    mkdir -p $GITHUB_SAMPLES_DIR

    echo ""

    echo -e "${YELLOW}Cloning the insecure sample projects from GitHub...${RESET}"

    echo ""

    # Defines an associative array with the names and GitHub repository URLs of the extra Fortify SCA samples projects to be cloned, 
    # which includes a variety of sample projects in different programming languages and frameworks, such as Java, .NET, Python, JavaScript, and more, 
    # to provide a wide range of testing scenarios for Fortify SCA and Debricked users
    declare -A FORTIFY_SAMPLES_GITHUB_REPOS=(
        ["AltoroJ"]="https://github.com/HCL-TECH-SOFTWARE/AltoroJ"
        ["AWSGoat"]="https://github.com/ine-labs/AWSGoat"
        ["aviatordemo"]="https://github.com/fortify/aviatordemo"
        ["Damn-Vulnerable-AI-Application"]="https://github.com/airtasystems/DVAIA-Damn-Vulnerable-AI-Application"
        ["Damn-Vulnerable-GraphQL-Application"]="https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application"
        ["Damn-Vulnerable-MCP-Server"]="https://github.com/harishsg993010/damn-vulnerable-MCP-server"
        ["Damn-Vulnerable-NodeJS-Application"]="https://github.com/appsecco/dvna"
        ["Damn-Vulnerable-Serverless-Application"]="https://github.com/OWASP/DVSA"
        ["Damn-Vulnerable-Web-Application"]="https://github.com/digininja/DVWA"
        ["Debricked-Demo"]="https://github.com/fortify-presales/debricked-demo"
        ["Debricked-Demo-Application"]="https://github.com/fortify-presales/DebrickedDemoApp"
        ["Debricked-Demo-Application"]="https://github.com/debricked/demo"
        ["EightBallCPlus"]="https://github.com/fortify-presales/EightBallCpp"
        ["EmailEightBall"]="https://github.com/fortify-presales/EmailEightBall"
        ["Example-Source-Codeless-Scan-Gradle"]="https://github.com/debricked/example-source-codeless-scan-gradle"
        ["FoD-ADO-Demo"]="https://github.com/fortify-presales/FoD-ADO-Demo"
        ["fortify-abap-demo"]="https://github.com/fortify-presales/fortify-abap-demo"
        ["fortify-demo-app"]="https://github.com/fortify-presales/fortify-demo-app"
        ["fortify-fiori-demo"]="https://github.com/fortify-presales/fortify-fiori-demo"
        ["Go-Demo"]="https://github.com/fortify-presales/FortifyGoDemo"
        ["GoVWA"]="https://github.com/0c34/govwa"
        ["Hackazon"]="https://github.com/rapid7/hackazon"
        ["IAC-Samples"]="https://github.com/fortify-presales/IaC-Samples"
        ["IGoat-Swift"]="https://github.com/OWASP/iGoat-Swift"
        ["InsecureRestAPI"]="https://github.com/fortify-presales/InsecureRestAPI"
        ["InsecureWebApp"]="https://github.com/fortify-presales/InsecureWebApp"
        ["IWA-Angular-UI"]="https://github.com/fortify-presales/IWAAngularUI"
        ["IWA-API-Go"]="https://github.com/fortify-presales/IWA-API-Go"
        ["IWA-API-Java"]="https://github.com/fortify-presales/IWA-API-Java"
        ["IWA-DotNet"]="https://github.com/fortify/IWA-DotNet"
        ["IWA-DotNet-Demo"]="https://github.com/fortify/IWA-DotNet-demo"
        ["IWA-Java"]="https://github.com/fortify/IWA-Java"
        ["IWA-Java-Pharmacy-Direct"]="https://github.com/fortify-presales/IWA-Java"
        ["IWA-Mobile"]="https://github.com/fortify-presales/IWA-Mobile"
        ["IWA-Microservices"]="https://github.com/fortify-presales/IWA-Microservices"
        ["IWA-Microservices-old"]="https://github.com/fortify-presales/IWA-Microservices-old"
        ["IWA-NodeJS"]="https://github.com/fortify-presales/IWA-NodeJS"
        ["IWA-Python"]="https://github.com/kadraman/InsecureWebApp"
        ["IWA-SPA"]="https://github.com/fortify-presales/IWA-SPA"
        ["IWA-UI-Angular"]="https://github.com/fortify-presales/IWA-UI-Angular"
        ["insecure-maven-nexus-project"]="https://github.com/fortify-presales/insecure-maven-nexus-project"
        ["Javulna"]="https://github.com/fortify-presales/javulna"
        ["Juice-Shop"]="https://github.com/juice-shop/juice-shop"
        ["juice-shop"]="https://github.com/fortify-presales/juice-shop"
        ["Leaky-Angular"]="https://github.com/fortify-presales/leaky-angular"
       #["MediAssistAI "]="https://github.com/fortify-presales/MediAssistAI"
        ["MuleSoftDemo"]="https://github.com/fortify-presales/FortifyMuleSoftDemo"
        ["NodeGoat"]="https://github.com/OWASP/NodeGoat"
        ["Octane-Demo-Application"]="https://github.com/fortify-presales/OctaneDemoApp"
        ["PharmaBot"]="https://github.com/fortify-presales/PharmaBot"
        ["PyGoat"]="https://github.com/adeyosemanputra/pygoat"
        ["RailsGoat"]="https://github.com/OWASP/railsgoat"
        ["Reactvulna"]="https://github.com/fortify-presales/reactvulna"
        ["Riches"]="https://github.com/fortify/riches"
        ["ring2park-db"]="https://github.com/fortify-presales/ring2park-db"
        ["ring2park-online"]="https://github.com/fortify-presales/ring2park-online"
        ["Sample-CPlus"]="https://github.com/fortify-presales/sample-cpp"
        ["Sample-EightBall"]="https://github.com/fortify/sample-eightball"
        ["Sample-Scala"]="https://github.com/fortify/sample-scala"
        ["sandbox-application"]="https://github.com/fortify-presales/sandbox-application"
        ["terragoat"]="https://github.com/fortify-presales/terragoat"
        ["VulnerableApp"]="https://github.com/SasanLabs/VulnerableApp"
        ["Vulpy"]="https://github.com/fportantier/vulpy"
        ["WebGoat"]="https://github.com/fortify-presales/WebGoat"
        ["WebGoat-DotNet"]="https://github.com/jerryhoff/WebGoat.NET"
        ["WebGoat-Java"]="https://github.com/WebGoat/WebGoat"
    )

    # Iterates over the associative array of GitHub repositories to clone each repository into the target directory, 
    # if it is not already cloned, to avoid errors and save time
    for name in "${!FORTIFY_SAMPLES_GITHUB_REPOS[@]}"; do
        TARGET_DIR="$GITHUB_SAMPLES_DIR/$name"

        # Checks if the repository is already cloned by verifying the existence of the .git directory in the target directory, 
        # which indicates that the repository has already been cloned, to avoid errors and save time
        if [[ -d "$TARGET_DIR/.git" ]]; then
            echo -e "${YELLOW}Repository '$name' is already cloned. Skipping...${RESET}"

	    echo ""

        # If the repository is not cloned, it clones it into the target directory
        else
            echo -e "${CYAN}Cloning '$name' repository on '$TARGET_DIR' directory...${RESET}"

            git clone --depth=1 "${FORTIFY_SAMPLES_GITHUB_REPOS[$name]}" "$TARGET_DIR"
	    
	    echo ""
        fi
    done

    echo ""

    # Shows where the GitHub sample projects have been cloned into and confirms that they have been cloned successfully
    echo -e "${GREEN}GitHub sample projects for Fortify cloned into: '$GITHUB_SAMPLES_DIR' directory${RESET}"

    echo ""

    # Shows the list of the cloned GitHub sample projects in the terminal to confirm that they have been cloned successfully
    echo -e "${CYAN}GitHub sample projects:${RESET}"
    ls -l $GITHUB_SAMPLES_DIR

    echo ""
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"