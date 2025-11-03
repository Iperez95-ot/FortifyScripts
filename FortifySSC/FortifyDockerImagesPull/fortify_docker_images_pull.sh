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
  export $(grep -v '^#' .env | xargs)
fi 

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

      # Gets the Fortify Docker Images Tags from Docker Hub API
      TAGS=$(curl -s -u "$DOCKER_HUB_USER:$DOCKER_HUB_TOKEN" "https://hub.docker.com/v2/repositories/${FORTIFY_DOCKER_HUB_ORG}/${IMAGE}/tags/?page_size=10000" | jq -r '.results | select(. != null)[]?.name')

      # Checks if the Tags list from Fortify Docker Hub is empty or not. Skips everything if no Docker Image found
      if [ -z "$TAGS" ]; then
          echo -e "${RED}No tags found for the Docker Image '${IMAGE}'. Skipping...${RESET}"

          echo ""

          continue
      fi

      # Iterates through the Foritfy Docker Images Tags from Docker Hub
      for TAG in $TAGS; do
	  # Checks if the Docker Repository name contains helm in the name
          if [[ "$IMAGE" == *helm* ]]; then
	      # If the Docker Repository is a Helm Chart as an OCI artifact pulls it and push it with helm
              echo "--------------------------------------------------------------------------------------------------------------------------------"
              echo -e "${YELLOW}Pulling the HELM chart '${IMAGE}:${TAG}'...${RESET}"

              echo ""

              # Pulls from Docker Hub the OCI registry artifact
              helm pull "oci://registry-1.docker.io/${FORTIFY_DOCKER_HUB_ORG}/${IMAGE}" --version "$TAG" --destination ./charts

              echo ""

              # Uses the expected filename directly
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
 
              # Skips known Windows-only images directly by name
	      if [[ "$IMAGE" == *"windows"* ]]; then
                 echo -e "${RED}Skipping '${DOCKER_HUB_IMAGE}' because it is a Windows-only image (not supported on Linux).${RESET}"
                 
                 echo ""
    
                 continue
              fi
      
              # Checks if the Docker Image is Windows-only before pulling
    	      IMAGE_PLATFORMS=$(docker manifest inspect "${DOCKER_HUB_IMAGE}" 2>/dev/null | jq -r '.manifests[].platform.os' || echo "unknown")

	      if echo "$IMAGE_PLATFORMS" | grep -q "windows"; then
                  if ! echo "$IMAGE_PLATFORMS" | grep -q "linux"; then
                    echo -e "${RED}Skipping '${DOCKER_HUB_IMAGE}' because it is Windows-only Docker Image (not supported on linux).${RESET}"
        	    
                    echo ""
                    
                    continue
                  fi
              fi	      
              
              # Pulls from Docker Hub the Docker Image
              docker pull "${DOCKER_HUB_IMAGE}"

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
  curl -s "https://${CUSTOM_REGISTRY_URL}/v2/_catalog" | jq .

  echo ""
fi

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}"