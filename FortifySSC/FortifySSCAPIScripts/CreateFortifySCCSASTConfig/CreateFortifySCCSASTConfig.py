#!/usr/bin/env python3

# Script that creates Fortify ScanCentral SAST Controller configuration in Fortify SSC using the SSC REST API.
# The script will create a UnifiedLoginToken, then it will use that token to authenticate the API request to create the ScanCentral SAST Controller Configuration 
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
from requests.auth import HTTPBasicAuth
import logging
import subprocess

# Suppress the InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Loads all the environment variables from the .env file
load_dotenv()

# Environment variables calls
fortify_ssc_user = os.getenv('FORTIFY_SSC_DEFAULT_ADMIN_USER')
fortify_ssc_password = os.getenv('FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD')
fortify_ssc_api_url = os.getenv('FORTIFY_SSC_API_URL')
fortify_ssc_created_sast_controller_config = os.getenv('OUTPUT_LOG_FILE')
fortify_ssc_sast_controller_config_json = os.getenv('INPUT_JSON_BODY_FILE')

# Defines the timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Defines the headers for the Fortify SSC API Requests
fortify_ssc_api_request_headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

# Ensures that the directory for the log file exists, if not it will create it
os.makedirs(os.path.dirname(fortify_ssc_created_sast_controller_config), exist_ok=True)

# Configure logging
logging.basicConfig(filename=fortify_ssc_created_sast_controller_config, level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

""" Functions """

# Function to check which Fortify SSC Tomcat service exists and restart it
def restart_ssc_tomcat_service():
    # Defines the candidate services to check for existence
    candidate_services = ["ot_application_security_tomcat", "fortify_ssc_tomcat"]
    
    # Intializes the detected service variable to None
    detected_service = None

    print(colored("Checking for Fortify SSC Tomcat systemd service...", "yellow"))
    
    print("")
    
    # Logs a message that indicates that the script is checking for Fortify SSC Tomcat systemd service
    logging.info("Checking for Fortify SSC Tomcat systemd service...")

    # Iterates through the candidate services to check which one exists on the system
    for service in candidate_services:
        # Uses subprocess to run the systemctl command to check if the service exists and captures the output
        check_cmd = subprocess.run(["systemctl", "list-unit-files", f"{service}.service"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        # Checks if the service exists in the output of the systemctl command
        if f"{service}.service" in check_cmd.stdout:
            # Assings the detected service to the variable and breaks the loop
            detected_service = service
            
            break
        
    # Checks if no service was detected and prints a warning message, logs the warning, and returns False
    if not detected_service:
        # Defines the warning message to be printed and logged
        warn_msg = "Neither 'ot_application_security_tomcat' nor 'fortify_ssc_tomcat' service was found on this system."
        
        print(colored(f"[WARN] {warn_msg}", "yellow"))
        
        print("")
        
        # Logs a warning message that indicates that neither 'ot_application_security_tomcat' nor 'fortify_ssc_tomcat' 
        # service was found on this system
        logging.warning(warn_msg)
        
        # Returns False to indicate that no service was detected
        return False

    print(colored(f"Detected service: '{detected_service}'. Proceeding to restart...", "yellow"))
    
    print("")
    
    # Logs a message that indicates which service was detected and that the script is proceeding to restart it
    logging.info(f"Restarting service '{detected_service}'...")

    # Attempts to restart the detected service using subprocess and handles any exceptions that may occur during the restart
    try:
        # Defines the command to restart the detected service using systemctl
        restart_cmd = subprocess.run(["systemctl", "restart", detected_service], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Checks the return code of the restart command to determine if the restart was successful 
        # or not and prints/logs the appropriate message
        if restart_cmd.returncode == 0:
            # Defines the success message to be printed and logged
            success_msg = f"Service '{detected_service}' has been restarted successfully!"
            
            print(colored(success_msg, "green"))
            
            print("")
            
            # Logs a message that indicates that the service was restarted successfully
            logging.info(success_msg)
            
            # Returns True to indicate that the service was restarted successfully
            return True
        else:
            # Defines the error message to be printed and logged
            error_msg = f"Failed to restart service '{detected_service}'. Error: {restart_cmd.stderr.strip()}"
            
            print(colored(f"Error: {error_msg}", "red"))
            
            print("")
            
            # Logs a message that indicates that the service failed to restart with the error details
            logging.error(error_msg)
            
            # Returns False to indicate that the service failed to restart
            return False

    # Handles any exceptions that may occur during the restart and prints/logs an error message with the exception details
    except Exception as e:
        # Defines the error message to be printed and logged with the exception details
        error_msg = f"An exception occurred while trying to restart '{detected_service}': {e}"
        
        print(colored(f"Error: {error_msg}", "red"))
        
        print("")
        
        # Logs a message that indicates that an exception occurred while trying to restart the service with the exception details
        logging.error(error_msg)
        
        # Returns False to indicate that an exception occurred while trying to restart the service
        return False

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
        
# Function to create the Fortify ScanCentral SAST Controller Configuration in Fortify SSC
def create_scancentral_sast_controller_config(fortify_ssc_api_url, fortify_ssc_api_request_headers, fortify_ssc_sast_controller_config_json):
    # Attempts to create the Fortify ScanCentral SAST Controller Configuration in Fortify SSC using the API 
    # and handles any exceptions that may occur during the request
    try:
        # Checks if the input JSON file exists
        if not os.path.isfile(fortify_ssc_sast_controller_config_json):
            error_msg = f"Configuration JSON file not found at path: '{fortify_ssc_sast_controller_config_json}'"
            
            print(colored(f"Error: {error_msg}", "red"))
            
            logging.error(error_msg)
            
            # Returns False to indicate that the configuration creation failed due to missing JSON file
            return False

        # Opens the JSON file and reads the payload
        with open(fortify_ssc_sast_controller_config_json, 'r', encoding='utf-8') as json_file:
            config_payload = json.load(json_file)

        # Sends the PUT API request to update the configuration in Fortify SSC
        fortify_scancentral_sast_controller_config_creation_response = requests.put(f"{fortify_ssc_api_url}/configuration", headers=fortify_ssc_api_request_headers, json=config_payload, verify=False)

        # Checks if the request was successful (200 OK)
        if fortify_scancentral_sast_controller_config_creation_response.status_code == 200:
            print(colored("API Request was successful!", "green"))
            
            print("")
            
            logging.info("API Request to update ScanCentral SAST Controller configuration was successful!")

            print("Showing the result from the query:")
            
            # Attempts to parse the response as JSON and print it in a formatted way, 
            # if it fails, it will print the raw text response
            try:
                response_json = fortify_scancentral_sast_controller_config_creation_response.json()
                
                print(json.dumps(response_json, indent=4))
                
                # Logs the response of the ScanCentral configuration query in a compact JSON format
                logging.info(f"Result from ScanCentral configuration query: {json.dumps(response_json, separators=(',', ':'))}")
            
            # Handles the case where the response is not valid JSON and prints the raw text response
            except Exception:
                print(fortify_scancentral_sast_controller_config_creation_response.text)
                
                # Logs the raw text response of the ScanCentral configuration query
                logging.info(f"Response text: {fortify_scancentral_sast_controller_config_creation_response.text}")

            print("")
            
            print(colored("ScanCentral SAST Controller Configuration was successfully applied in Fortify SSC!", "green"))
            
            # Logs a message that indicates that the ScanCentral SAST Controller Configuration was successfully applied in Fortify SSC
            logging.info("ScanCentral SAST Controller Configuration was successfully applied in Fortify SSC!")
            
            # Returns True to indicate that the configuration creation was successful
            return True
        else:
            print(colored("API Request has failed!", "red"))
            
            print("")
            
            # Logs a message that indicates that the API request to update the ScanCentral SAST Controller configuration has failed
            logging.error("API Request to update ScanCentral SAST Controller configuration has failed!")

            print(colored(f"The status code from the request is: {fortify_scancentral_sast_controller_config_creation_response.status_code}", "red"))
           
            print("")

            print("Showing the result from the query:")
            
            # Attempts to parse the response as JSON and print it in a formatted way, 
            # if it fails, it will print the raw text response
            try:
                print(json.dumps(fortify_scancentral_sast_controller_config_creation_response.json(), indent=4))
                
            # Handles the case where the response is not valid JSON and prints the raw text response
            except Exception:
                print(fortify_scancentral_sast_controller_config_creation_response.text)

            print("")
            
            print(colored(f"Failed to configure ScanCentral SAST Controller. Status code: {fortify_scancentral_sast_controller_config_creation_response.status_code} - {fortify_scancentral_sast_controller_config_creation_response.text}\n", "red"))
            
            # Logs a message that indicates that the ScanCentral SAST Controller Configuration creation has failed with the status code and the response from the API
            logging.error(f"Failed to configure ScanCentral SAST Controller. Status code: {fortify_scancentral_sast_controller_config_creation_response.status_code} - {fortify_scancentral_sast_controller_config_creation_response.text}")
            
            # Returns False to indicate that the configuration creation failed
            return False

    # Handles any unexpected exceptions that may occur during the request and prints an error message with the exception details
    except Exception as e:
        print(colored(f"An unexpected error occurred while configuring ScanCentral SAST Controller: {e}", "red"))
        
        # Logs a message that indicates that an unexpected error occurred while configuring the ScanCentral SAST Controller with the exception details
        logging.error(f"An unexpected error occurred while configuring ScanCentral SAST Controller: {e}")
        
        # Returns False to indicate that the configuration creation failed due to an unexpected error
        return False

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

""" Main Program """

print(colored(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Starting the Script...", 'cyan'))

print("")

# Logs a message that indicates that the script is starting
logging.info("Starting the Script")

print(colored(f"Creating a Token for the ScanCentral SAST Controller Configuration on Fortify SSC...", 'yellow'))

print("")

# Logs a message that indicates that the script is creating a token for the ScanCentral SAST Controller Configuration on Fortify SSC
logging.info(f"Creating a Token for the ScanCentral SAST Controller Configuration on Fortify SSC")

# Creates a UnifiedLoginToken for the creation of the ScanCentral SAST Controller Configuration on Fortify SSC and stores the token and the token id in variables
fortify_ssc_token, fortify_ssc_token_id = create_fortify_ssc_token("UnifiedLoginToken", fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

# Checks if the token was created if not it will exit the program
if fortify_ssc_token:
    # Adding the created token to the headers
    fortify_ssc_api_request_headers["Authorization"] = f"FortifyToken {fortify_ssc_token}"
else:
    sys.exit(1)  # Exits the program with an error status code

print("")

print(colored(f"Creating the LDAP Server Configuration on Fortify SSC...", 'yellow'))

print("")

# Logs a message that indicates that the script is creating the ScanCentral SAST Controller Configuration on Fortify SSC
logging.info(f"Creating the ScanCentral SAST Controller Configuration on Fortify SSC")

# Calls the function to create the ScanCentral SAST Controller Configuration on Fortify SSC with the API URL and the API headers as parameters
config_success = create_scancentral_sast_controller_config( fortify_ssc_api_url, fortify_ssc_api_request_headers, fortify_ssc_sast_controller_config_json)

# Checks if the configuration creation was successful and if so it will restart the Fortify SSC Tomcat service
if config_success:
    print("")
    
    # Calls the function to check which Fortify SSC Tomcat service exists and restart it
    restart_ssc_tomcat_service()

print("")

print(colored(f"Deleting the token created before...", 'yellow'))

print("")

# Logs a message that indicates that the script is deleting the token created before
logging.info(f"Deleting the token created before")

# Removes the token from the api headers before the delete request
fortify_ssc_api_request_headers.pop("Authorization", "")

# Deletes the token previously created because it is no longer needed and to keep the environment clean of unnecessary tokens
delete_fortify_ssc_token(fortify_ssc_token_id, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

print("")

print(colored('Execution Completed!', 'green'))