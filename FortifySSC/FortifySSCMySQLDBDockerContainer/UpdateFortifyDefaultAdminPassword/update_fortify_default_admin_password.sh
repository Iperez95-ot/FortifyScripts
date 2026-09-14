#!/bin/bash

# Script that updates the default admin password for Fortify SSC stored in a MySQL Database Docker container.

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

