#!/usr/bin/env python3

# Script that uploads Fortify Rulepacks from files to Fortify SSC using the SSC REST API.
# The script will create a UnifiedLoginToken, then it will use that token to authenticate the API requests to upload the rulepacks files to Fortify SSC,
# and at the end it will delete the token that was created before.

# Imports the necessary libraries for this script execution
from urllib import response
import requests
import os
import sys
import json
import os
from dotenv import load_dotenv
from termcolor import colored
import requests
import urllib3
from datetime import datetime
import time
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
fortify_ssc_version = os.getenv("CURRENT_FORTIFY_SSC_VERSION")
fortify_ssc_uploaded_rulepacks_log_file = os.getenv('OUTPUT_LOG_FILE')
fortify_ssc_apps_file_directory = os.getenv("FORTIFY_SSC_APPS_FILES_PATH")

# Defines Local Variables
fortify_ssc_rulepacks_directory = os.path.join(fortify_ssc_apps_file_directory, fortify_ssc_version, "rulepacks")

# Defines the timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Defines the headers for the Fortify SSC API Requests
fortify_ssc_api_request_headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

# Ensures that the directory for the log file exists, if not it will create it
os.makedirs(os.path.dirname(fortify_ssc_uploaded_rulepacks_log_file), exist_ok=True)

# Configure logging
logging.basicConfig(filename=fortify_ssc_uploaded_rulepacks_log_file, level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

""" Functions """

# Function to delete a Fortify SSC Token with the specified token id
def delete_fortify_ssc_token(fortify_ssc_token_id, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers):
    # Attempts to delete the Fortify SSC Token with the specified token id using the API and handles any exceptions that may occur during the request
    try:
        # Sends the API request to delete the Token created before
        fortify_ssc_token_deletion_response = requests.delete(f"{fortify_ssc_api_url}/tokens/{fortify_ssc_token_id}", auth=HTTPBasicAuth(fortify_ssc_user, fortify_ssc_password), headers=fortify_ssc_api_request_headers, verify=False)

        # Checks if the request was susccesful
        if fortify_ssc_token_deletion_response.status_code == 200:
            # Prints a message that indicates that the request was successfull
            print(colored(f"API Request was successfull!", "green"))

            print("")
            
            # Logs a message that indicates that the API request was successful
            logging.info(f"API Request was successfull!")

            print("Showing the result from the query:")
        
            # Prints the response of the deletion of fortify ssc token request (Passed Request)
            print(json.dumps(fortify_ssc_token_deletion_response.json(), indent=4))
        
            print("")
            
            # Logs the response of the deletion of fortify ssc token request (Passed Request)
            logging.info(("Result from the token deletion query: %s", json.dumps(fortify_ssc_token_deletion_response.json(), separators=(",", ":"))))
        
            # Prints the token that has been deleted
            print(colored(f"The token with ID '{fortify_ssc_token_id}' was successfully deleted!", 'green'))
            
            # Logs a message that indicates that the token with the specified ID was successfully deleted
            logging.info(f"The token with ID '{fortify_ssc_token_id}' was successfully deleted!")
    
        # If the deletion was not successful it will print an error message with the status code and the response from the API
        else:
            # Prints a message that indicates that the request was unsuccessfull
            print(colored("API Request has failed", "red"))
        
            print("")
            
            # Logs a message that indicates that the API request has failed
            logging.error(f"API Request has failed!")
        
            # Prints the status code of the deletion of fortify ssc token request (Failed Request)
            print(colored(f"The status code from the request of Fortify SSC token deletion is: {fortify_ssc_token_deletion_response.status_code}", "red"))
        
            print("")
        
            print("Showing the result from the query:")

            # Prints the response of the deletion of fortify ssc token request (Failed Request)
            print(json.dumps(fortify_ssc_token_deletion_response.json(), indent=4))

            print("")
        
            # Prints a message that indicates that the token deletion has failed
            print(colored(f"Failed to delete the token. Status code: {fortify_ssc_token_deletion_response.status_code} - {fortify_ssc_token_deletion_response.text}\n", 'red'))
            
            # Logs a message that indicates that the token deletion has failed with the status code and the response from the API
            logging.error(f"Failed to delete the token. Status code: {fortify_ssc_token_deletion_response.status_code} - {fortify_ssc_token_deletion_response.text}")
    
    # Handles any exceptions that may occur during the request and prints an error message with the exception details        
    except Exception as e:
        print(colored(f"Could not delete token (Server might be busy): {e}", "red"))
        
        # Logs a message that indicates that the token could not be deleted with the exception details (Server might be busy)
        logging.error(f"Could not delete token (Server might be busy): {e}")

# Function to upload Fortify Rulepacks from a directory to Fortify SSC
def upload_fortify_ssc_rulepacks(fortify_ssc_api_url, fortify_ssc_token, fortify_ssc_api_request_headers, rulepacks_directory):
    # Checks if the rulepacks directory exists if not it will exit the program
    if not os.path.isdir(rulepacks_directory):
        print(colored(f"[ERROR] Rulepacks Directory not found: '{rulepacks_directory}'", "red"))
        
        sys.exit(1)

    print(colored(f"Scanning the directory: '{rulepacks_directory}'", "cyan"))
    
    print("")
    
    # Logs a message indicating that the script is scanning the directory for rulepacks to be uploaded to Fortify SSC
    logging.info(f"Scanning the directory: '{rulepacks_directory}'")
    
    # Uses a SESSION to prevent 'Connection Refused' / 'Remote Disconnected'
    fortify_ssc_upload_rulepack_session = requests.Session()
    fortify_ssc_upload_rulepack_session.verify = False
    fortify_ssc_upload_rulepack_session.headers.update(fortify_ssc_api_request_headers)
    
    # Iterates over the files in the rulepacks directory and uploads the ones that end with .zip
    for file in os.listdir(rulepacks_directory):
        # Checks if the file ends with .zip to be uploaded as a rulepack
        if file.endswith(".zip"):
            # Constructs the full file path
            file_path = os.path.join(rulepacks_directory, file)
            
            # Prints a message indicating which rulepack is being uploaded
            print(colored(f"Uploading the rulepack file: '{file}'", "yellow"))
            
            print("")
            
            # Logs a message indicating which rulepack file is being uploaded to Fortify SSC
            logging.info(f"Uploading the rulepack file: '{file}'")
            
            # Opens the rulepack file in binary mode and uploads it to Fortify SSC using the API
            with open(file_path, "rb") as rulepack_file:
                # Defines the files to be uploaded in the request
                rulepack_file = {
                    "file": (file, rulepack_file, "application/zip")
                }
                
                # Attempts to upload the rulepack file to Fortify SSC using the API and handles any exceptions that may occur during the request
                try:
                    # Sends the API request to upload the rulepack file to Fortify SSC
                    fortify_ssc_upload_rulepack_response = fortify_ssc_upload_rulepack_session.post(f"{fortify_ssc_api_url}/coreRulepacks", files=rulepack_file, timeout=900)
                    
                    # Checks if the upload was successful
                    if fortify_ssc_upload_rulepack_response.status_code == 200:
                        # Prints a message that indicates that the request was successfull
                        print(colored(f"API Request was successfull!", "green"))

                        print("")
                        
                        # Logs a message that indicates that the API request was successful
                        logging.info(f"API Request was successfull!")

                        print("Showing the result from the query:")
        
                        # Prints the response of the upload of the rulepack file request (Passed Request)
                        print(json.dumps(fortify_ssc_upload_rulepack_response.json(), indent=4))
        
                        print("")
                        
                        # Logs the response of the upload of the rulepack file request (Passed Request)
                        logging.info(("Result from the rulepack upload query: %s", json.dumps(fortify_ssc_upload_rulepack_response.json(), separators=(",", ":"))))
                    
                        # Prints a message indicating that the rulepack file was successfully uploaded to Fortify SSC
                        print(colored(f"Successfully uploaded the rulepack file '{file}'", "green"))
                        
                        # Logs a message indicating that the rulepack file was successfully uploaded to Fortify SSC
                        logging.info(f"Successfully uploaded the rulepack file '{file}'")
                        
                    # If the upload was not successful it will print an error message with the status code and the response from the API
                    else:
                        # Prints a message that indicates that the request was unsuccessfull
                        print(colored("API Request has failed!", "red"))
        
                        print("")
                        
                        # Logs a message that indicates that the API request has failed
                        logging.error(f"API Request has failed!")
        
                        # Prints the status code of the upload of the rulepack file request (Failed Request)
                        print(colored(f"The status code from the request of Fortify SSC rulepack upload is: {fortify_ssc_upload_rulepack_response.status_code}", "red"))
        
                        print("")
                        
                        # Logs the status code of the upload of the rulepack file request (Failed Request)
                        logging.error(f"Status code: {fortify_ssc_upload_rulepack_response.status_code}")
        
                        print("Showing the result from the query:")

                        # Prints the response of the upload of the rulepack file request (Failed Request)
                        print(json.dumps(fortify_ssc_upload_rulepack_response.json(), indent=4))

                        print("")
                        
                        # Logs the response of the upload of the rulepack file request (Failed Request)
                        logging.error(("Result from the rulepack upload query: %s", json.dumps(fortify_ssc_upload_rulepack_response.json(), separators=(",", ":"))))
                        
                        # Prints a message that indicates that the upload of the rulepack file has failed
                        print(colored(f"Failed to upload the rulepack file '{file}'", "red"))
                        
                        # Logs a message that indicates that the upload of the rulepack file has failed
                        logging.error(f"Failed to upload the rulepack file '{file}'")
                
                    # Sleep to prevent overwhelming the SSC background processing
                    time.sleep(180)
                
                # Handles any exceptions that may occur during the request and prints an error message with the exception details
                except requests.exceptions.RequestException as e:
                    print(colored(f"[ERROR] Request failed: {e}", "red"))
                    
                    # Logs a message that indicates that the request to upload the rulepack file has failed with the exception details
                    logging.error(f"[ERROR] Request failed: {e}")

            print("")

# Function to create a Fortify SSC Token with the specified type and returns the token and the token id
def create_fortify_ssc_token(fortify_token_type, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers):
    # Creates the body in JSON format
    body = {
        "description": timestamp,
        "type": fortify_token_type
    }

    # Sends the API request to create the Token
    fortify_ssc_token_creation_response = requests.post(f"{fortify_ssc_api_url}/tokens", auth=HTTPBasicAuth(fortify_ssc_user, fortify_ssc_password), headers=fortify_ssc_api_request_headers, data=json.dumps(body), verify=False)

    # Checks if the request was successful
    if fortify_ssc_token_creation_response.status_code == 201:
        # Prints a message that indicates that the request was successfull
        print(colored(f"API Request was successfull!", "green"))

        print("")
        
        # Logs a message that indicates that the API request was successful
        logging.info(f"API Request was successfull!")

        print("Showing the result from the query:")
        
        # Prints the response of the creation of fortify ssc token request (Passed Request)
        print(json.dumps(fortify_ssc_token_creation_response.json(), indent=4))
        
        print("")
        
        # Logs the response of the creation of fortify ssc token request (Passed Request)
        logging.info(("Result from the token creation query: %s", json.dumps(fortify_ssc_token_creation_response.json(), separators=(",", ":"))))
        
        # Stores the token and the token id from the response in variables
        token = fortify_ssc_token_creation_response.json().get("data").get("token")
        token_id = fortify_ssc_token_creation_response.json().get("data").get("id")

        # Prints the token that has been recently created
        print(colored(f"{fortify_token_type} was successfully created: {token}", 'green'))
        
        # Logs a message that indicates that the token was successfully created with the token value
        logging.info(f"{fortify_token_type} was successfully created: {token}")

        return token, token_id
    else:
        # Prints a message that indicates that the request was unsuccessfull
        print(colored("API Request has failed!", "red"))
        
        print("")
        
        # Logs a message that indicates that the API request has failed
        logging.error(f"API Request has failed!")
        
        # Prints the status code of the creation of fortify ssc token request (Failed Request)
        print(colored(f"The status code from the request of Fortify SSC token creation is: {fortify_ssc_token_creation_response.status_code}", "red"))
        
        print("")
        
        print("Showing the result from the query:")

        # Prints the response of the creation of fortify ssc token request (Failed Request)
        print(json.dumps(fortify_ssc_token_creation_response.json(), indent=4))

        print("")
        
        # Prints a message that indicates that the token creation has failed with the status code and the response from the API 
        print(colored(f"Failed to create the token. Status code: {fortify_ssc_token_creation_response.status_code} - {fortify_ssc_token_creation_response.text}\n", 'red'))
        
        # Logs a message that indicates that the token creation has failed with the status code and the response from the API
        logging.error(f"Failed to create the token. Status code: {fortify_ssc_token_creation_response.status_code} - {fortify_ssc_token_creation_response.text}")

        return None

""" Main Program """

print(colored(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Starting the Script...", 'cyan'))

print("")

# Logs a message that indicates that the script is starting
logging.info("Starting the Script")

print(colored(f"Creating a Token for the upload of Fortify Rulepacks files to Fortify SSC...", 'yellow'))

print("")

# Logs a message that indicates that the script is creating a token for the upload of Fortify Rulepacks files to Fortify SSC
logging.info(f"Creating a Token for the upload of Fortify Rulepacks files to Fortify SSC")

# Creates a UnifiedLoginToken for the upload of Fortify Rulepacks files to Fortify SSC and stores the token and the token id in variables
fortify_ssc_token, fortify_ssc_token_id = create_fortify_ssc_token("UnifiedLoginToken", fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

# Checks if the token was created if not it will exit the program
if fortify_ssc_token:
    # Adding the created token to the headers
    fortify_ssc_api_request_headers["Authorization"] = f"FortifyToken {fortify_ssc_token}"
    
    # Removes the Content-Type from the headers because it is not needed in the upload of rulepacks request
    fortify_ssc_api_request_headers.pop("Content-Type", None) 
else:
    sys.exit(1)  # Exits the program with an error status code

print("")

print(colored(f"Uploading Fortify Rulepacks files to Fortify SSC...", 'yellow'))

print("")

# Logs a message that indicates that the script is uploading the Fortify Rulepacks files to Fortify SSC
logging.info(f"Uploading Fortify Rulepacks files to Fortify SSC")

# Calls the function to upload the Fortify Rulepacks files to Fortify SSC with the necessary parameters
upload_fortify_ssc_rulepacks(fortify_ssc_api_url, fortify_ssc_token, fortify_ssc_api_request_headers, fortify_ssc_rulepacks_directory)

print(colored(f"Deleting the token created before...", 'yellow'))

print("")

# Logs a message that indicates that the script is deleting the token created before
logging.info(f"Deleting the token created before")

# Removes the token from the api headers before the delete request
fortify_ssc_api_request_headers.pop("Authorization", "")

# Adds the Content-Type back to the headers for the delete token request
fortify_ssc_api_request_headers["Content-Type"] = f"application/json"

# Deletes the token previously created because it is no longer needed and to keep the environment clean of unnecessary tokens
delete_fortify_ssc_token(fortify_ssc_token_id, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

print("")

print(colored('Execution Completed!', 'green'))