#!/usr/bin/env python3

# Script that updates Fortify Rulepacks in Fortify SSC using the SSC REST API.
# The script will create a UnifiedLoginToken, use that token to authenticate
# the updateRulepacks API request, and at the end it will delete the token
# that was created before.

# Imports the necessary libraries for this script execution
import requests
import os
import sys
import json
from dotenv import load_dotenv
from termcolor import colored
import urllib3
from datetime import datetime
from requests.auth import HTTPBasicAuth
import logging

# Suppress the InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Loads all the environment variables from the .env file
load_dotenv()

# Environment variables calls
fortify_ssc_user = os.getenv('FORTIFY_SSC_DEFAULT_ADMIN_USER')
fortify_ssc_password = os.getenv('FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD')
fortify_ssc_api_url = os.getenv('FORTIFY_SSC_API_URL')
fortify_ssc_update_rulepacks_log_file = os.getenv('OUTPUT_LOG_FILE')

# Defines the timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Checks if the required environment variables are set
if not fortify_ssc_user:
    print(colored("Environment variable 'FORTIFY_SSC_DEFAULT_ADMIN_USER' is not set.", "red"))
    sys.exit(1)

if not fortify_ssc_password:
    print(colored("Environment variable 'FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD' is not set.", "red"))
    sys.exit(1)

if not fortify_ssc_api_url:
    print(colored("Environment variable 'FORTIFY_SSC_API_URL' is not set.", "red"))
    sys.exit(1)

if not fortify_ssc_update_rulepacks_log_file:
    print(colored("Environment variable 'OUTPUT_LOG_FILE' is not set.", "red"))
    sys.exit(1)

# Ensures that the directory for the log file exists, if not it will create it
log_directory = os.path.dirname(fortify_ssc_update_rulepacks_log_file)

if log_directory:
    os.makedirs(log_directory, exist_ok=True)

# Configure logging
logging.basicConfig(
    filename=fortify_ssc_update_rulepacks_log_file,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


""" Functions """


# Function to create a Fortify SSC Token with the specified type
# and returns the token and the token id
def create_fortify_ssc_token(
    fortify_token_type,
    fortify_ssc_api_url,
    fortify_ssc_user,
    fortify_ssc_password,
    fortify_ssc_api_request_headers
):

    # Creates the body in JSON format
    body = {
        "description": timestamp,
        "type": fortify_token_type
    }

    try:

        # Sends the API request to create the Token
        fortify_ssc_token_creation_response = requests.post(
            f"{fortify_ssc_api_url}/tokens",
            auth=HTTPBasicAuth(
                fortify_ssc_user,
                fortify_ssc_password
            ),
            headers=fortify_ssc_api_request_headers,
            data=json.dumps(body),
            verify=False,
            timeout=900
        )

        # Checks if the request was successful
        if fortify_ssc_token_creation_response.status_code == 201:

            # Prints a message that indicates that the request was successful
            print(colored("API Request was successful!", "green"))

            print("")

            # Logs a message that indicates that the API request was successful
            logging.info("API Request was successful!")

            print("Showing the result from the query:")

            # Prints the response of the token creation request
            print(
                json.dumps(
                    fortify_ssc_token_creation_response.json(),
                    indent=4
                )
            )

            print("")

            # Logs the response
            logging.info(
                "Result from the token creation query: %s",
                json.dumps(
                    fortify_ssc_token_creation_response.json(),
                    separators=(",", ":")
                )
            )

            # Stores the token and token id from the response
            token = (
                fortify_ssc_token_creation_response
                .json()
                .get("data")
                .get("token")
            )

            token_id = (
                fortify_ssc_token_creation_response
                .json()
                .get("data")
                .get("id")
            )

            # Prints the token type that was successfully created
            print(
                colored(
                    f"{fortify_token_type} was successfully created.",
                    "green"
                )
            )

            # Logs the token creation
            logging.info(
                f"{fortify_token_type} was successfully created."
            )

            return token, token_id

        else:

            # Prints a message that indicates that the request was unsuccessful
            print(colored("API Request has failed!", "red"))

            print("")

            # Logs the failure
            logging.error("API Request has failed!")

            # Prints the status code
            print(
                colored(
                    f"The status code from the request of Fortify SSC token creation is: "
                    f"{fortify_ssc_token_creation_response.status_code}",
                    "red"
                )
            )

            print("")

            print("Showing the result from the query:")

            # Prints the response
            try:
                print(
                    json.dumps(
                        fortify_ssc_token_creation_response.json(),
                        indent=4
                    )
                )
            except ValueError:
                print(fortify_ssc_token_creation_response.text)

            print("")

            # Prints the failure
            print(
                colored(
                    f"Failed to create the token. "
                    f"Status code: {fortify_ssc_token_creation_response.status_code} "
                    f"- {fortify_ssc_token_creation_response.text}\n",
                    "red"
                )
            )

            # Logs the failure
            logging.error(
                f"Failed to create the token. "
                f"Status code: {fortify_ssc_token_creation_response.status_code} "
                f"- {fortify_ssc_token_creation_response.text}"
            )

            return None, None

    except requests.exceptions.RequestException as e:

        print(
            colored(
                f"[ERROR] Could not create Fortify SSC token: {e}",
                "red"
            )
        )

        logging.error(
            f"[ERROR] Could not create Fortify SSC token: {e}"
        )

        return None, None


# Function to update Fortify SSC Rulepacks
def update_fortify_ssc_rulepacks(
    fortify_ssc_api_url,
    fortify_ssc_api_request_headers
):

    print(
        colored(
            "Updating Fortify SSC Rulepacks...",
            "yellow"
        )
    )

    print("")

    # Logs a message indicating that the script is updating
    # the Fortify SSC Rulepacks
    logging.info("Updating Fortify SSC Rulepacks")

    try:

        # Sends the GET request to the updateRulepacks endpoint
        fortify_ssc_update_rulepacks_response = requests.get(
            f"{fortify_ssc_api_url}/updateRulepacks",
            headers=fortify_ssc_api_request_headers,
            verify=False,
            timeout=900
        )

        # Checks if the request was successful
        if 200 <= fortify_ssc_update_rulepacks_response.status_code < 300:

            # Prints a message that indicates that the request was successful
            print(
                colored(
                    "API Request was successful!",
                    "green"
                )
            )

            print("")

            # Logs a successful request
            logging.info(
                "API Request was successful!"
            )

            print("Showing the result from the query:")

            # Attempts to print the API response as JSON
            try:

                response_json = fortify_ssc_update_rulepacks_response.json()

                print(
                    json.dumps(
                        response_json,
                        indent=4
                    )
                )

                # Logs the response
                logging.info(
                    "Result from the updateRulepacks query: %s",
                    json.dumps(
                        response_json,
                        separators=(",", ":")
                    )
                )

            except ValueError:

                # Handles responses that are not JSON
                print(
                    fortify_ssc_update_rulepacks_response.text
                )

                logging.info(
                    "Result from the updateRulepacks query: %s",
                    fortify_ssc_update_rulepacks_response.text
                )

            print("")

            print(
                colored(
                    "Fortify SSC Rulepacks update request completed successfully!",
                    "green"
                )
            )

            logging.info(
                "Fortify SSC Rulepacks update request completed successfully!"
            )

            return True

        else:

            # Prints a message that indicates that the request was unsuccessful
            print(
                colored(
                    "API Request has failed!",
                    "red"
                )
            )

            print("")

            # Logs the failure
            logging.error(
                "API Request has failed!"
            )

            # Prints the status code
            print(
                colored(
                    f"The status code from the Fortify SSC updateRulepacks request is: "
                    f"{fortify_ssc_update_rulepacks_response.status_code}",
                    "red"
                )
            )

            print("")

            print("Showing the result from the query:")

            try:

                print(
                    json.dumps(
                        fortify_ssc_update_rulepacks_response.json(),
                        indent=4
                    )
                )

            except ValueError:

                print(
                    fortify_ssc_update_rulepacks_response.text
                )

            print("")

            # Logs the failure
            logging.error(
                f"Failed to update Fortify SSC Rulepacks. "
                f"Status code: {fortify_ssc_update_rulepacks_response.status_code} "
                f"- {fortify_ssc_update_rulepacks_response.text}"
            )

            return False

    except requests.exceptions.RequestException as e:

        print(
            colored(
                f"[ERROR] Request failed: {e}",
                "red"
            )
        )

        logging.error(
            f"[ERROR] Request failed: {e}"
        )

        return False


# Function to delete a Fortify SSC Token with the specified token id
def delete_fortify_ssc_token(
    fortify_ssc_token_id,
    fortify_ssc_api_url,
    fortify_ssc_user,
    fortify_ssc_password,
    fortify_ssc_api_request_headers
):

    try:

        # Sends the API request to delete the Token created before
        fortify_ssc_token_deletion_response = requests.delete(
            f"{fortify_ssc_api_url}/tokens/{fortify_ssc_token_id}",
            auth=HTTPBasicAuth(
                fortify_ssc_user,
                fortify_ssc_password
            ),
            headers=fortify_ssc_api_request_headers,
            verify=False,
            timeout=900
        )

        # Checks if the request was successful
        if fortify_ssc_token_deletion_response.status_code == 200:

            print(
                colored(
                    "API Request was successful!",
                    "green"
                )
            )

            print("")

            logging.info(
                "API Request was successful!"
            )

            print("Showing the result from the query:")

            try:

                print(
                    json.dumps(
                        fortify_ssc_token_deletion_response.json(),
                        indent=4
                    )
                )

            except ValueError:

                print(
                    fortify_ssc_token_deletion_response.text
                )

            print("")

            print(
                colored(
                    f"The token with ID '{fortify_ssc_token_id}' "
                    f"was successfully deleted!",
                    "green"
                )
            )

            logging.info(
                f"The token with ID '{fortify_ssc_token_id}' "
                f"was successfully deleted!"
            )

        else:

            print(
                colored(
                    "API Request has failed!",
                    "red"
                )
            )

            print("")

            logging.error(
                "API Request has failed!"
            )

            print(
                colored(
                    f"The status code from the request of Fortify SSC token deletion is: "
                    f"{fortify_ssc_token_deletion_response.status_code}",
                    "red"
                )
            )

            print("")

            print("Showing the result from the query:")

            try:

                print(
                    json.dumps(
                        fortify_ssc_token_deletion_response.json(),
                        indent=4
                    )
                )

            except ValueError:

                print(
                    fortify_ssc_token_deletion_response.text
                )

            print("")

            print(
                colored(
                    f"Failed to delete the token. "
                    f"Status code: {fortify_ssc_token_deletion_response.status_code} "
                    f"- {fortify_ssc_token_deletion_response.text}\n",
                    "red"
                )
            )

            logging.error(
                f"Failed to delete the token. "
                f"Status code: {fortify_ssc_token_deletion_response.status_code} "
                f"- {fortify_ssc_token_deletion_response.text}"
            )

    except requests.exceptions.RequestException as e:

        print(
            colored(
                f"Could not delete token (Server might be busy): {e}",
                "red"
            )
        )

        logging.error(
            f"Could not delete token (Server might be busy): {e}"
        )


""" Main Program """

print(colored(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] " f"Starting the Script...", "cyan"))

print("")

# Logs a message that indicates that the script is starting
logging.info("Starting the Script")

# Defines the headers for the Fortify SSC API Requests
fortify_ssc_api_request_headers = {
    "accept": "application/json", 
    "Content-Type": "application/json"
}

print(colored("Creating a Token for the Fortify SSC Rulepacks update...", "yellow"))

print("")

# Logs a message that indicates that the script is creating
# a token for the updateRulepacks API request
logging.info("Creating a Token for the Fortify SSC Rulepacks update")

# Creates a UnifiedLoginToken
fortify_ssc_token, fortify_ssc_token_id = create_fortify_ssc_token("UnifiedLoginToken", fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

# Checks if the token was created
if fortify_ssc_token:
    # Adds the created token to the headers
    fortify_ssc_api_request_headers["Authorization"] = (f"FortifyToken {fortify_ssc_token}")

    # Removes Content-Type because it is not needed
    # for the updateRulepacks GET request
    fortify_ssc_api_request_headers.pop("Content-Type", None)

else:
    sys.exit(1)

print("")

# Calls the function to update the Fortify SSC Rulepacks
update_fortify_ssc_rulepacks(fortify_ssc_api_url, fortify_ssc_api_request_headers)

print("")

print(colored("Deleting the token created before...", "yellow"))

print("")

# Logs a message indicating that the script is deleting the token
logging.info("Deleting the token created before")

# Removes the token from the API headers before the delete request
fortify_ssc_api_request_headers.pop("Authorization", "")

# Adds Content-Type back to the headers for the delete token request
fortify_ssc_api_request_headers["Content-Type"] = ("application/json")

# Deletes the token previously created
delete_fortify_ssc_token(fortify_ssc_token_id, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

print("")

print(colored("Execution Completed!", "green"))