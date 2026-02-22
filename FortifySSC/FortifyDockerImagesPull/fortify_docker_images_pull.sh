#!/bin/bash
# Script to pull Fortify Docker Images from Docker Hub, tag them and push them to a private Docker Registry

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

# Ensures the log directory exists
mkdir -p "$(dirname "$OUTPUT_FILE_PATH")"

# Redirects all output (stdout + stderr) to log file and console
exec > >(tee -a "$OUTPUT_FILE_PATH") 2>&1

# List of the Docker Images to push to the Docker Registry
FORTIFY_DOCKER_IMAGES=(
    "fcli"
    "helm-scancentral-sast"
    "scancentral-sast-sensor-windows"
    "scancentral-sast-sensor"
    "scancentral-sast-db-migration"
    "scancentral-sast-controller"
    "fortify-bitbucket-pipe"
    "fortify-ci-tools"
    "ssc-webapp"
    "helm-ssc"
    "helm-scancentral-dast-scanner"
    "helm-lim"
    "webinspect"
    "scancentral-dast-utilityservice"
    "scancentral-dast-scannerservice"
    "scancentral-dast-api"
    "scancentral-dast-globalservice"
    "scancentral-dast-config"
    "lim"
    "scancentral-dast-fortifyconnect"
    "fortify-connect"
    "fortify-oast"
    "fortify-fast"
    "dast-scanner"
    "fortify-2fa"
    "wise"
    "helm-scancentral-dast-core"
    "fortify-vulnerability-exporter"
    "iwa-dotnet"
    "iwa-java"
    "sync-fod-to-ssc"
    "riches"
)

# Prints the first message
echo -e "${CYAN}Proceeding to pull Fortify Docker Images from Docker Hub org '$FORTIFY_DOCKER_HUB_ORG', tag them and push to private registry '$CUSTOM_REGISTRY_URL' at $(date)...${RESET}"

echo ""

# Checks if the Docker Hub user, Docker Hub token, Docker Registry user and Docker Registry password exists
if [ -z "$DOCKER_HUB_USER" ] || [ -z "$DOCKER_HUB_TOKEN" ] || [ -z "$REGISTRY_USER" ] || [ -z "$REGISTRY_PASSWORD" ]; then
  # If the credentials are not present it will exit the program
  echo -e "${RED}The Docker Hub and Registry credentials are missing.${RESET}"
  
  exit 1
else
  # If the credentials are present proceeds with the program normally
  mkdir -p ./charts
   
  # Step 1: Logs in to Docker Hub (with Docker)
  echo -e "${YELLOW}Logging in to Docker Hub wtih Docker...${RESET}"

  echo ""

  echo "$DOCKER_HUB_TOKEN" | docker login -u "$DOCKER_HUB_USER" --password-stdin

  echo ""

  echo -e "${GREEN}Successfully logged into Docker Hub with Docker!${RESET}"

  echo ""

  # Step 2: Logs in to private Docker Registry (with Docker)
  echo -e "${YELLOW}Logging in to the '$CUSTOM_REGISTRY_URL' Private Docker Registry with Docker...${RESET}"

  echo ""

  echo "$REGISTRY_PASSWORD" | docker login "$CUSTOM_REGISTRY_URL" -u "$REGISTRY_USER" --password-stdin

  echo ""

  echo -e "${GREEN}Successfully logged into the private registry with Docker!${RESET}"

  echo ""

  # Step 3: Logs in to the private Docker Registry (with Helm)
  echo -e "${YELLOW}Logging in to the '$CUSTOM_REGISTRY_URL' Private Docker Registry with Helm...${RESET}"

  echo ""

  echo "$REGISTRY_PASSWORD" | helm registry login -u "$REGISTRY_USER" --password-stdin "$CUSTOM_REGISTRY_URL"

  echo ""

  echo -e "${GREEN}Successfully logged into the private registry with Helm!${RESET}"

  echo ""

  # Step 4: Logs in to Docker Hub (with Helm)
  echo -e "${YELLOW}Logging in to Docker Hub wtih Helm...${RESET}"

  echo ""

  echo "$DOCKER_HUB_TOKEN" | helm registry login -u "$DOCKER_HUB_USER" --password-stdin registry-1.docker.io

  echo ""

  echo -e "${GREEN}Successfully logged into Docker Hub with Docker with Helm!${RESET}"

  echo ""

  # Step 5: Pulls all tags of Docker Images from Docker Hub, tags them and pushes them into the Docker Registry
  # Iterates through the Fortify Docker Images list
  for IMAGE in "${FORTIFY_DOCKER_IMAGES[@]}"; do
      echo "===================================================================================================================================="
      echo -e "${YELLOW}Fetching all tags of '${FORTIFY_DOCKER_HUB_ORG}/${IMAGE}' from Docker Hub...${RESET}"

      echo ""

      # REFRESH TOKEN: Get a fresh JWT token for every repository to avoid expiration or scope issues
      echo -e "${YELLOW}Obtaining JWT token from Docker Hub for Private Repository access...${RESET}"
      HUB_TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d "{\"username\": \"$DOCKER_HUB_USER\", \"password\": \"$DOCKER_HUB_TOKEN\"}" https://hub.docker.com/v2/users/login/ | jq -r .token)

      echo ""

      # Checks if the token was obtained successfully
      if [ "$HUB_TOKEN" == "null" ] || [ -z "$HUB_TOKEN" ]; then
          echo -e "${RED}Failed to obtain JWT from Docker Hub. Listing private tags will fail.${RESET}"

          exit 1
      fi
  
      echo -e "${GREEN}JWT Token obtained successfully.${RESET}"

      echo ""

      # Gets the Fortify Docker Images Tags from Docker Hub API with PAGINATION
      CURRENT_PAGE_URL="https://hub.docker.com/v2/repositories/${FORTIFY_DOCKER_HUB_ORG}/${IMAGE}/tags/?page_size=100"

      # Defines a variable to hold all tags across pages
      ALL_TAGS=""

      # Loops through the paginated results until there are no more pages (i.e., until 'next' is null or empty)
      while [ "$CURRENT_PAGE_URL" != "null" ] && [ -n "$CURRENT_PAGE_URL" ]; do
        # AUTH CHANGE: Using JWT Bearer token instead of -u
        RESPONSE=$(curl -s -H "Authorization: JWT ${HUB_TOKEN}" "$CURRENT_PAGE_URL")
        
        # Extracts any API-level error message from the response, if present
        API_ERR=$(echo "$RESPONSE" | jq -r '.message // empty')

        # Checks for API-level error messages
        if [ -n "$API_ERR" ]; then
            echo -e "${RED}API Error for $IMAGE: $API_ERR${RESET}"
            break
        fi

        # Extracts the tag names from the current page of results and appends them to the ALL_TAGS variable
        TAGS_BATCH=$(echo "$RESPONSE" | jq -r '.results[]?.name // empty' 2>/dev/null)

        # Checks if any tags were extracted before appending to the ALL_TAGS variable to avoid adding empty lines
        if [ -n "$TAGS_BATCH" ]; then
            ALL_TAGS="$ALL_TAGS $TAGS_BATCH"
        fi
        
        # Gets the URL for the next page of results
        CURRENT_PAGE_URL=$(echo "$RESPONSE" | jq -r '.next' 2>/dev/null)
      done

      # Converts the ALL_TAGS string into an array for easier processing later, splitting by whitespace
      TAG_LIST=($ALL_TAGS)

      # Checks if the Tags list from Fortify Docker Hub is empty or not. Skips everything if no Docker Image found
      if [ -z "$ALL_TAGS" ] || [ "$ALL_TAGS" == " " ] || [ ${#TAG_LIST[@]} -eq 0 ]; then
          echo -e "${RED}No tags found for the Docker Image '${IMAGE}'. Skipping...${RESET}"

          echo ""

          continue
      fi

      echo ""

      echo -e "${CYAN}Found ${#TAG_LIST[@]} tags on '${FORTIFY_DOCKER_HUB_ORG}/${IMAGE}'. Starting processing...${RESET}"

      echo ""

      # Iterates through the Foritfy Docker Images Tags from Docker Hub
      for TAG in "${TAG_LIST[@]}"; do
        # Checks if the Docker Repository name contains helm in the name
        if [[ "$IMAGE" == *helm* ]]; then
            # If the Docker Repository is a Helm Chart as an OCI artifact pulls it and push it with helm
            echo "--------------------------------------------------------------------------------------------------------------------------------"
            echo -e "${YELLOW}Pulling the HELM chart '${IMAGE}:${TAG}'...${RESET}"

            echo ""

            # Pulls from Docker Hub the OCI registry artifact
            helm pull "oci://registry-1.docker.io/${FORTIFY_DOCKER_HUB_ORG}/${IMAGE}" --version "$TAG" --destination ./charts

            echo ""

            # Gets the path of the pulled Helm chart
            CHART_FILE=$(ls ./charts/${IMAGE}-${TAG}.tgz* | head -n 1)

            echo -e "${YELLOW}Pushing the Helm chart '${CHART_FILE}.tgz' to '${CUSTOM_REGISTRY_URL}/${IMAGE}:${TAG}'...${RESET}"

            echo ""

            # Pushes the OCI registry artifact to the Docker Private Registry
            helm push "$CHART_FILE" "oci://$CUSTOM_REGISTRY_URL/$IMAGE"              

	        echo ""

            echo -e "${YELLOW}Cleaning up the local OCI registry artifact '${CHART_FILE}.tgz'...${RESET}"

            echo ""

            # Cleanups the local OCI registry artifact
            rm -f "$CHART_FILE"

            echo "--------------------------------------------------------------------------------------------------------------------------------"
        else
	        # If the Docker Repository name is a Docker Image pulls it and push it with Docker
            DOCKER_HUB_IMAGE="${FORTIFY_DOCKER_HUB_ORG}/${IMAGE}:${TAG}"
            REGISTRY_IMAGE="${CUSTOM_REGISTRY_URL}/${IMAGE}:${TAG}"

            echo "--------------------------------------------------------------------------------------------------------------------------------"
            echo -e "${YELLOW}Pulling '${DOCKER_HUB_IMAGE}' Docker Image...${RESET}"

            echo ""

            # Inspects the Docker Image manifest to get the supported platforms
            MANIFEST_DATA=$(timeout 15s docker manifest inspect --verbose "${DOCKER_HUB_IMAGE}" 2>/dev/null || echo "FAILED")

            # Checks if the manifest inspection was successful before trying to parse it, 
            # and if it fails it will skip the image with a warning, 
            # but it will not exit the script because some images might not have a manifest or might fail to be inspected for various reasons (e.g. network issues, rate limiting, etc.) 
            # and we want to continue processing the rest of the images instead of exiting the entire script
            if [ "$MANIFEST_DATA" != "FAILED" ]; then
                # Extracts the platforms from the manifest data and checks if it contains windows but not linux, which means it is a Windows-only image, and skips it because it cannot be pulled on Linux hosts. This is an additional check to avoid trying to pull Windows-only images on Linux hosts, which will fail, and this way we can skip them with a warning instead of trying to pull them and failing with an error. This is needed because some images might not have the word "windows" in their name but are still Windows-only, and the only way to know for sure is by checking the manifest data for the supported platforms.
                IMAGE_PLATFORMS=$(echo "$MANIFEST_DATA" | jq -r '[.. | .os? | select(. != null)] | unique | join(" ")' 2>/dev/null || echo "unknown")
                                    
                # Checks if the platforms contains windows but not linux, which means it is a Windows-only image, 
                # and skips it because it cannot be pulled on Linux hosts
                if [[ "$IMAGE_PLATFORMS" == *"windows"* ]] && [[ "$IMAGE_PLATFORMS" != *"linux"* ]]; then
                    echo -e "${RED}Skipping '${DOCKER_HUB_IMAGE}' because metadata confirms Windows-only ($IMAGE_PLATFORMS).${RESET}"

                    echo ""

                    continue
                fi
            fi

            # Checks if the platforms contains windows but not linux, 
            # which means it is a Windows-only image, and skips it because it cannot be pulled on Linux hosts
            if [[ "$IMAGE_PLATFORMS" == *"windows"* ]] && [[ "$IMAGE_PLATFORMS" != *"linux"* ]]; then
                echo -e "${RED}Skipping '${DOCKER_HUB_IMAGE}' because it is Windows-only (Platforms: $IMAGE_PLATFORMS).${RESET}"

                echo ""

                continue
            fi      
            
            # Sets +e to handle the error of pulling unsupported images without exiting the script
            set +e

            # Pulls the Docker Image from Docker Hub
            docker pull "${DOCKER_HUB_IMAGE}"

            # Captures the exit code of the docker pull command to check if it was successful or not
            PULL_EXIT_CODE=$?
              
            # Re-enables immediate exit on error
            set -e 

            # Checks if the pull command was successful, if not it will skip the image with a warning, 
            # but it will not exit the script because some images might be unsupported on the current host (e.g. Windows-only images on Linux hosts) 
            # and we want to continue processing the rest of the images instead of exiting the entire script
            if [ $PULL_EXIT_CODE -ne 0 ]; then
                echo ""

                echo -e "${RED}Failed to pull '${DOCKER_HUB_IMAGE}'. This image is likely Windows-only and not supported on this host. Skipping...${RESET}"

                echo ""

                continue
            fi

            echo ""

            echo -e "${YELLOW}Tagging '${DOCKER_HUB_IMAGE}' as '${REGISTRY_IMAGE}'...${RESET}"

            echo ""
	      
            # Tags the Docker Image pulled from Docker Hub
            docker tag "${DOCKER_HUB_IMAGE}" "${REGISTRY_IMAGE}"

            echo ""

            echo -e "${YELLOW}Pushing '${REGISTRY_IMAGE}' to Private Registry...${RESET}"

            echo ""
		
	        # Pushes the Docker Image to the private Docker Registry
            docker push "${REGISTRY_IMAGE}"

            echo ""

            echo -e "${YELLOW}Cleaning up local images '${DOCKER_HUB_IMAGE}' and '${REGISTRY_IMAGE}'...${RESET}"

            echo ""
	      
	        # Cleanups the local Docker Images
            docker rmi "${DOCKER_HUB_IMAGE}" "${REGISTRY_IMAGE}" || true

            echo "--------------------------------------------------------------------------------------------------------------------------------"
        fi
      done

    echo "===================================================================================================================================="
  done
  
  echo ""

  # Step 6: Logouts from Docker Private Registry, Docker Hub, and Helm
  echo -e "${YELLOW}Logging out from the '$CUSTOM_REGISTRY_URL' Docker Private Registry...${RESET}"
  
  echo ""
  
  docker logout "$CUSTOM_REGISTRY_URL"
  
  echo ""

  echo -e "${YELLOW}Logging out from Docker Hub...${RESET}"
  
  echo ""
  
  docker logout
  
  echo ""

  # Logouts from the Docker Private Registry (Helm)
  echo -e "${YELLOW}Logging out Helm from '$CUSTOM_REGISTRY_URL'...${RESET}"
  
  echo ""
  
  helm registry logout "$CUSTOM_REGISTRY_URL"
  
  echo ""

  # Logouts Helm from Docker Hub (Helm)
  echo -e "${YELLOW}Logging out Helm from Docker Hub...${RESET}"
  
  echo ""
  
  helm registry logout registry-1.docker.io
  
  echo ""
  
  # Step 7: Shows all the repositories in the Docker Private Registry
  echo -e "${CYAN}Fetching the Docker Registry repository catalog from '$CUSTOM_REGISTRY_URL'...${RESET}"
  curl -s -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" "https://${CUSTOM_REGISTRY_URL}/v2/_catalog" | jq .

  echo ""

  rm -rf ./charts
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"