#!/usr/bin/env python3

# Script that creates LDAP Server Configurations in Fortify SSC using the SSC REST API.
# The script will create a UnifiedLoginToken, then it will use that token to authenticate the API request to create the LDAP Server Configuration 
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

# Suppress the InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Loads all the environment variables from the .env file
load_dotenv()

# Environment variables calls
fortify_ssc_user = os.getenv('FORTIFY_SSC_DEFAULT_ADMIN_USER')
fortify_ssc_password = os.getenv('FORTIFY_SSC_DEFAULT_ADMIN_USER_PASSWORD')
fortify_ssc_api_url = os.getenv('FORTIFY_SSC_API_URL')
fortify_ssc_created_ldap_server_config = os.getenv('OUTPUT_LOG_FILE')
fortify_ssc_ldap_server_config_json = os.getenv('INPUT_JSON_BODY_FILE')

# Defines the timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Defines the headers for the Fortify SSC API Requests
fortify_ssc_api_request_headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

# Ensures that the directory for the log file exists, if not it will create it
os.makedirs(os.path.dirname(fortify_ssc_created_ldap_server_config), exist_ok=True)

# Configure logging
logging.basicConfig(filename=fortify_ssc_created_ldap_server_config, level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

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

# Function to create a LDAP Server Configuration on Fortify SSC with the specified API URL and API headers
def create_ldap_server_config(fortify_ssc_api_url, fortify_ssc_api_request_headers, json_file):
    # Attempts to create the LDAP Server Configuration on Fortify SSC using the API and handles any exceptions that may occur during the request
    try:
        # Loads the JSON body from the input file
        with open(json_file, "r") as f:
            fortify_ssc_ldap_server_config_body = json.load(f)
            
        # Sends the API request to create the LDAP Server Configuration on Fortify SSC
        fortify_ssc_ldap_server_config_creation_response = requests.post(f"{fortify_ssc_api_url}/ldapServers", headers=fortify_ssc_api_request_headers, json=fortify_ssc_ldap_server_config_body, verify=False)
        
        # Checks if the request was successful
        if fortify_ssc_ldap_server_config_creation_response.status_code == 201:
            # Prints a message that indicates that the request was successfull
            print(colored(f"API Request was successfull!", "green"))

            print("")
            
            # Logs a message that indicates that the API request was successful
            logging.info(f"API Request was successful!")

            print("Showing the result from the query:")
            
            print(json.dumps( fortify_ssc_ldap_server_config_creation_response.json(), indent=4))
            
            print("")
            
            # Logs the response of thecreation of the ldap server configuration onfortify ssc request (Passed Request)
            logging.info(("Result from the Creation of the LDAP Server Configuration query: %s", json.dumps(fortify_ssc_ldap_server_config_creation_response.json(), separators=(",", ":"))))
            
            # Retrieves the id and serverName fields from the response and stores them in variables
            ldap_server_config_id = fortify_ssc_ldap_server_config_creation_response.json().get("data", {}).get("id")
            ldap_server_config_name = fortify_ssc_ldap_server_config_creation_response.json().get("data", {}).get("serverName")
            
            print(colored(f"LDAP Server Configuration with the id '{ldap_server_config_id}' for the '{ldap_server_config_name}' server was created successfully!", "green"))
            
            print("")
            
            # Logs a message that indicates that the LDAP Server Configuration was created successfully
            logging.info(f"LDAP Server Configuration with the id '{ldap_server_config_id}' for the '{ldap_server_config_name}' server was created successfully!")
        
        # If the creation was not successful it will print an error message with the status code and the response from the API
        else:
            # Prints a message that indicates that the request was unsuccessfull
            print(colored("API Request has failed", "red"))
        
            print("")
            
            # Logs a message that indicates that the API request has failed
            logging.error(f"API Request has failed!")
        
            # Prints the status code of the creation of the ldap server configuration on fortify ssc request (Failed Request)
            print(colored(f"The status code from the request of LDAP Server Configuration creation is: {fortify_ssc_ldap_server_config_creation_response.status_code}", "red"))
        
            print("")
        
            print("Showing the result from the query:")
            
            # Prints the response of the creation of the ldap server configuration on fortify ssc request (Failed Request)
            print(json.dumps(fortify_ssc_ldap_server_config_creation_response.json(), indent=4))
            
            print("")
            
            # Prints a message that indicates that the ldap server configuration creation has failed
            print(colored(f"Failed to create the LDAP Server Configuration. Status code: {fortify_ssc_ldap_server_config_creation_response.text}\n", 'red'))
            
            print("")
            
            # Logs a message that indicates that the ldap server configuration creation has failed with the status code and the response from the API
            logging.error(f"LDAP Server Configuration creation failed: {fortify_ssc_ldap_server_config_creation_response.text}")
    
    # Handles any exceptions that may occur during the request and prints an error message with the exception details      
    except Exception as e:
        # Prints a message that indicates that there was an error creating the LDAP Server Configuration with the exception details
        print(colored(f"Error creating LDAP Server Configuration: {e}", "red"))
        
        # Logs a message that indicates that the ldap server configuration creation has failed with the exception details
        logging.error(f"Error creating LDAP Server Configuration: {e}")

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

print(colored(f"Creating a Token for the LDAP Server Configuration on Fortify SSC...", 'yellow'))

print("")

# Logs a message that indicates that the script is creating a token for the LDAP Server Configuration on Fortify SSC
logging.info(f"Creating a Token for the LDAP Server Configuration on Fortify SSC")

# Creates a UnifiedLoginToken for the creation of the LDAP Server Configuration on Fortify SSC and stores the token and the token id in variables
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

# Logs a message that indicates that the script is creating the LDAP Server Configuration on Fortify SSC
logging.info(f"Creating the LDAP Server Configuration on Fortify SSC")

# Calls the function to create the LDAP Server Configuration on Fortify SSC with the API URL and the API headers as parameters
create_ldap_server_config( fortify_ssc_api_url, fortify_ssc_api_request_headers, fortify_ssc_ldap_server_config_json)

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