#!/usr/bin/env python3

import csv
import json
import os
from dotenv import load_dotenv
from termcolor import colored
import requests
import urllib3
from datetime import datetime
from datetime import datetime, timedelta, UTC
from requests.auth import HTTPBasicAuth
import sys

# Suppress the InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Load all the environment variables from the .env file
load_dotenv()

# Environment variables calls
fortify_ssc_user = os.getenv('FORTIFY_SSC_USER')
fortify_ssc_password = os.getenv('FORTIFY_SSC_PASSWORD')
fortify_ssc_api_url = os.getenv('FORTIFY_SSC_API_URL')
fortify_tools_token_creation_log_file_env = os.getenv('OUTPUT_LOG_FILE_PATH')

# Checks if the environment variable for the log file path is set
if fortify_tools_token_creation_log_file_env is None:
    raise ValueError("OUTPUT_LOG_FILE_PATH environment variable is not set")

# Explicitly declare as str for Pylance
fortify_tools_token_creation_log_file: str = fortify_tools_token_creation_log_file_env

# Creates the log directory if it does not exist
os.makedirs(os.path.dirname(fortify_tools_token_creation_log_file), exist_ok=True)

# Defines the local variables
fortify_ssc_token_type = "ToolsConnectToken"

# Defines the timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Defines the headers for the Fortify SSC API Requests
fortify_ssc_api_request_headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

""" Functions """

# Function to check if a token is expired based on its terminal date
def is_token_expired(token):
    # Retrieves the terminal date from the token and converts it to a datetime object, 
    terminal_date = token.get("terminalDate")

    # Converts the terminal date string to a datetime object, handling the 'Z' suffix for UTC time
    terminal_datetime = datetime.fromisoformat(terminal_date.replace("Z", "+00:00"))

    # Returns True if the terminal date is in the past (i.e., the token is expired), otherwise returns False
    return terminal_datetime < datetime.now(UTC)

# Function to update the expiration date of an existing token to 90 days from now
def update_token_expiration(token_id, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password):
    # Calculates the new terminal date by adding 90 days to the current date and formatting it in ISO 8601 format
    new_terminal_date = (datetime.now(UTC) + timedelta(days=90)).strftime("%Y-%m-%dT%H:%M:%SZ")

    # Creates the body of the API request in JSON format with the new terminal date
    body = {
        "terminalDate": new_terminal_date
    }

    # Sends the API request to update the token's expiration date
    response = requests.put(f"{fortify_ssc_api_url}/tokens/{token_id}", auth=HTTPBasicAuth(fortify_ssc_user, fortify_ssc_password), headers=fortify_ssc_api_request_headers, data=json.dumps(body), verify=False)

    # Checks if the request was successful
    if response.status_code == 200:
        print(colored(f"Updated the expiration date to '{new_terminal_date}' for the token with the ID '{token_id}'", "green"))

        print("")

        # Prints the response as json
        print(json.dumps(response.json(), indent=4))

        print("")

        # Saves the log in the file with a timestamp
        with open(fortify_tools_token_creation_log_file, 'a') as log:
            log.write(f"[{timestamp}] Updated the expiration date to '{new_terminal_date}' for the token with the ID '{token_id}'\n")

        return True
    else:
        print(colored(f"Failed to update token expiration date: {response.status_code} - {response.text}", "red"))

        # Saves the log in the file with a timestamp
        with open(fortify_tools_token_creation_log_file, 'a') as log:
            log.write(f"[{timestamp}] Failed to update the token expiration date: {response.status_code} - {response.text}\n")

        return False

# Function to create a new Fortify SSC Tools Token for the user specified in the .env file
def create_fortify_ssc_tools_token(fortify_ssc_token_type, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers):
    terminal_date = (datetime.now(UTC) + timedelta(days=90)).strftime("%Y-%m-%dT%H:%M:%SZ")

    # Creates the body in JSON format
    body = {
        "description": f"Token created by script for the '{fortify_ssc_user}' user",
        "terminalDate": terminal_date,
        "type": fortify_ssc_token_type
    }

    # Sends the API request to create the Token
    response = requests.post(f"{fortify_ssc_api_url}/tokens", auth=HTTPBasicAuth(fortify_ssc_user, fortify_ssc_password), headers=fortify_ssc_api_request_headers, data=json.dumps(body), verify=False)

    # Checks if the request was successful
    if response.status_code == 201:
        # Stores the Token in variable token
        token = response.json().get("data").get("token")
        token_id = response.json().get("data").get("id")

        # Prints the token that has been created
        print(colored(f"{fortify_ssc_token_type} was successfully created: '{token}' for the user '{fortify_ssc_user}'", 'green'))

        print("")

        # Prints the response as json
        print(json.dumps(response.json(), indent=4))

        print("")

        # Saves the log in the file with a timestamp
        with open(fortify_tools_token_creation_log_file, 'a') as log:
            log.write(f"[{timestamp}] {fortify_ssc_token_type} was successfully created: '{token}' for the user '{fortify_ssc_user}'\n")

        return token, token_id
    else:
        # Prints the response and status
        print(colored(f"Failed to create the token. Status code: {response.status_code} - {response.text}\n", 'red'))

        print("")

        # Saves the log in the file with a timestamp
        with open(fortify_tools_token_creation_log_file, 'a') as log:
            log.write(f"[{timestamp}] Failed to create the token. Status code: {response.status_code} - {response.text}\n")

        return None, None

# Function to get the existing tokens of the user specified in the .env file
def get_existing_tokens(fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password):
    # Constructs the API URL to retrieve the token for the specified user, including pagination parameters
    get_token_by_username_api_url = f'{fortify_ssc_api_url}/tokens?q=type:"{fortify_ssc_token_type}"&start=0&limit=10000&withoutCount=false'

    # Sends the API request to retrieve the tokens for the specified user
    response = requests.get(get_token_by_username_api_url, auth=HTTPBasicAuth(fortify_ssc_user, fortify_ssc_password), headers=fortify_ssc_api_request_headers, verify=False)

    # Checks if the request was successful
    if response.status_code == 200:
        # Stores the list of tokens in the variable tokens
        tokens = response.json().get("data", [])

        # Filters the tokens to find those that belong to the specified user and are of the specified type
        user_tokens = [token for token in tokens if token.get("username").lower() == fortify_ssc_user.lower() and token.get("type") == fortify_ssc_token_type]

        # Checks if there are any tokens for the user, if not it returns None
        if not user_tokens:
            return None

        # Sorts the user tokens by creation date in descending order and retrieves the newest token
        newest_token = sorted(user_tokens, key=lambda x: x.get("creationDate"), reverse=True)[0]

        # Saves the log in the file with a timestamp
        with open(fortify_tools_token_creation_log_file, 'a') as log:
            log.write(f"[{timestamp}] a {fortify_ssc_token_type} token already exists for the user '{fortify_ssc_user}'\n")

        # Returns the newest token for the user
        return newest_token
    
    # If the request was not successful, it prints an error message with the status code and response text, and returns an empty list
    else:
        print(colored(f"Failed to retrieve the tools tokens: {response.status_code} - {response.text}", "red"))

        # Saves the log in the file with a timestamp
        with open(fortify_tools_token_creation_log_file, 'a') as log:
            log.write(f"[{timestamp}] Failed to retrieve the tools tokens: {response.status_code} - {response.text}\n")

        return None

""" Main Program """

print(colored(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Starting the Script...", 'cyan'))

print("")

# Prompts the user to enter their Fortify SSC username
fortify_ssc_user = input(colored("Enter your username (Employee ID/U user): ", "cyan"))

print("")

# Prompts the user to enter their Fortify SSC password
fortify_ssc_password = input(colored("Enter your user password: ", "cyan"))

print("")

print(colored(f"Proceeding to check if a '{fortify_ssc_token_type}' token type for the user '{fortify_ssc_user}' exists...", 'yellow'))

print("")

# Calls the function to get the existing tokens for the user and stores it in the variable existing_token
existing_token = get_existing_tokens(fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password)

# Checks if there is an existing token for the user specified in the .env file and stores it in the variable existing_token
if existing_token:
    print(colored(f"a token of the type '{fortify_ssc_token_type}' already exists for the user '{fortify_ssc_user}':", "cyan"))
    
    # Prints the existing token information as json
    print(json.dumps(existing_token, indent=4))
    
    print("")

    # Stores the token id in the variable token_id to be used in the function that updates the expiration date
    token_id = existing_token.get("id")

    # Checks if the existing token is expired
    if is_token_expired(existing_token):
        print(colored("Token is expired. Creating a new one...", "yellow"))

        # Calls the function to create a new token and stores the new token and token id in variables
        fortify_ssc_token, fortify_ssc_token_id = create_fortify_ssc_tools_token("ToolsConnectToken", fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)
    
    # If the token is not expired, it proceeds to update the expiration date to 90 days from now
    else:
        print(colored("Token is still valid. Extending expiration date...", "yellow"))

        print("")

        # Calls the function to update the token expiration date and checks if the update was successful
        update_token_expiration(token_id, fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password)

        print("")

# If there is no existing token for the user, it proceeds to create a new token and stores the token and token id in variables
else:
    print(colored(f"Proceeding to create a Fortify SSC Tools Token for the user '{fortify_ssc_user}'...", 'yellow'))

    print("")

    # Calls the function to create a new token and stores the new token and token id in variables
    fortify_ssc_token, fortify_ssc_token_id = create_fortify_ssc_tools_token("ToolsConnectToken", fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

    # Checks if the token is created if not it will exit the program
    if not fortify_ssc_token:
        print(colored(f"Failed to create the Fortify SSC Tools Token for the user '{fortify_ssc_user}'...", 'red'))

        print("")

        sys.exit(1)  # Exits the program with an error status code

    print(colored(f"the token '{fortify_ssc_token}' with the ID '{fortify_ssc_token_id}' was successfully created", 'cyan'))

    print("")
    
print(colored('Execution Completed!', 'green'))