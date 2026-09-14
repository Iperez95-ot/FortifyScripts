#!/bin/bash

# Script that updates the default admin user password for Fortify SSC stored in a MySQL Database Docker container.

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
echo -e "${CYAN}Proceeding to Update the Default Admin User Password from the Fortify SSC database at $(date)...${RESET}"

echo ""

# Step 1: Logs into the MySQL Docker Container to update the default admin user password from the Fortify SSC Database
echo -e "${YELLOW}Updating Fortify SSC Default Admin User Password.${RESET}"

echo ""

cat > temp_fortify_ssc_default_admin_user_password.sql <<EOF
    USE $FORTIFY_SSC_DATABASE_NAME;

    UPDATE fortifyuser
    SET
       requirePasswordChange = 'N',
       failedLoginAttempts = 0,
       dateFrozen = NULL,
       suspended = 'N',
       password = '{bcrypt}\$2a\$10\$coOBlMqKxh52zGvIuHBUyuCXuGan77jehzMo3hQmYnCaRP5q9q6uS'
    WHERE userName = 'admin';

    SELECT
          userName AS User_Name,
          requirePasswordChange AS Password_Expired,
          failedLoginAttempts AS Failed_Login_Attempts,
          dateFrozen AS Frozen_Date,
          suspended AS Password_Suspended,
          password AS Password_String
    FROM fortifyuser
    WHERE userName = 'admin';
EOF

# Executes the SQL script to update the default admin password in the Fortify SSC Database
mysql --host="$MYSQL_HOST" --port="$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" < temp_fortify_ssc_default_admin_user_password.sql

echo ""

# Cleans up the temp file
rm -f "temp_fortify_ssc_default_admin_user_password.sql"

echo ""

# Step 2: Displays the Updated Fortify SSC admin user password
echo -e "${CYAN}The New Fortify SSC admin user password is: '$FORTIFY_SSC_ADMIN_PASSWORD'.${RESET}"

echo ""

echo -e "${GREEN}Fortify SSC admin user password updated successfully!${RESET}"

echo ""

# Prints a success message
echo -e "${GREEN}Execution completed successfully!${RESET}"