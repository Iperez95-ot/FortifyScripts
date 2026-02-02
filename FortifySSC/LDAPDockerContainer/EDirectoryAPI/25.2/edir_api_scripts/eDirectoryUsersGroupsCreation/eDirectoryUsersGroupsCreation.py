#!/usr/bin/env python3

# Imports the necessary libraries for this script execution
import sys
import json
import os
from dotenv import load_dotenv
from termcolor import colored
import requests
import urllib3
from datetime import datetime
import logging

# Suppress the InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Loads all the environment variables from the .env file
load_dotenv()

# Environment variables calls
edir_ldap_api_url = os.getenv('EDIR_LDAP_API_URL')
edir_ldap_origin = os.getenv('EDIR_LDAP_ORIGIN')
edir_ldap_admin_dn = os.getenv("EDIR_LDAP_ADMIN_DN")
edir_ldap_organization = os.getenv('EDIR_LDAP_ORG')
edir_ldap_admin_password = os.getenv("EDIR_LDAP_ADMIN_PASSWORD")
edir_ldap_tree = os.getenv('EDIR_LDAP_TREE')
edir_ldap_server = os.getenv("EDIR_LDAP_SERVER")
edir_ldap_logs_directory = os.getenv('OUTPUT_EDIR_LDAP_LOGS_DIRECTORY')
edir_ldap_users_to_add_file = os.getenv('INPUT_EDIR_LDAP_USERS_FILE_PATH')
edir_ldap_groups_to_add_file = os.getenv('INPUT_EDIR_LDAP_GROUPS_FILE_PATH')

# Defines the timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Ensures the log directory exists
os.makedirs(edir_ldap_logs_directory, exist_ok=True)

""" Functions """

# Function that sets up and returns a configured logger
def setup_logger(name, filename):
    # Creates (or retrieves) a logger instance with the given name
    logger = logging.getLogger(name)

    # Sets the logging level to INFO
    # This means INFO, WARNING, ERROR, and CRITICAL messages will be logged
    logger.setLevel(logging.INFO)

    # Prevents adding multiple handlers if the logger is initialized more than once
    if not logger.handlers:
        # Creates a file handler that writes logs to the specified file
        # The log file will be created inside the configured logs directory
        handler = logging.FileHandler(os.path.join(edir_ldap_logs_directory, filename), encoding="utf-8")

        # Defines the log message format
        # %(asctime)s   -> Timestamp of the log entry
        # %(levelname)s -> Log level (INFO, ERROR, etc.)
        # %(message)s   -> The actual log message
        formatter = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")

        # Applies the formatter to the handler
        handler.setFormatter(formatter)

        # Attaches the handler to the logger
        logger.addHandler(handler)
        
    # Returns the configured logger instance
    return logger

# Function that deletes a sessio against the eDirectory REST API and returns the JSON response
def delete_edir_ldap_api_session(rsessionid, anti_csrf_token):
    # Defines the eDirectory API Request URL to delete a session
    edir_api_ldap_delete_session_url = f"{edir_ldap_api_url}/session"

    # Defines the headers for the edir api session delete request
    edir_api_ldap_delete_session_headers = {
        "accept": "application/json",
        "Origin": edir_ldap_origin,
        "X-CSRF-Token": anti_csrf_token
    }

    # Defines the cookies for the session delete request
    edir_api_ldap_delete_session_cookies = {
        "RSESSIONID": rsessionid
    }
    
    session_delete_logger.info("Deleting eDirectory API session")

    # Performs the DELETE request to close the session
    edir_api_ldap_delete_session_response = requests.delete(edir_api_ldap_delete_session_url, headers=edir_api_ldap_delete_session_headers, cookies=edir_api_ldap_delete_session_cookies, verify=False)

    # Checks if the request was successful
    if edir_api_ldap_delete_session_response.status_code == 204:
        # Prints a message that indicates that the request was successfull
        print(colored(f"API Request was successfull!", "green"))

        print("")
        
        session_delete_logger.info("API Request was successfull!")
        
        return True
    else:
        # Prints a message that indicates that the request was unsuccessfull
        print(colored("API Request has failed. eDirectory API is down or your Token has expired.", "red"))
        
        print("")
        
        # Prints the status code of edir ldap entry creation request (Failed Request)
        print(colored(f"The status code from the request of eDirectory API ldap session deletion is: {edir_api_ldap_delete_session_response.status_code}", "red"))
        
        print("")
        
        session_delete_logger.info(f"The status code from the request of eDirectory API ldap session deletion is: {edir_api_ldap_delete_session_response.status_code}")
        
        # Exits the script with error code 1
        sys.exit(1) 

# Function that creates an eDirectory LDAP entry (groups and user) using the eDirectory REST API
def create_edir_entry(entry, rsessionid, anti_csrf_token):
    # Defines the eDirectory API Request URL to create an LDAP entry
    edir_api_ldap_create_entry_url = f"{edir_ldap_api_url}/{edir_ldap_tree}/{edir_ldap_organization}"

    # Defines the headers for the edirldap to create the entry request
    edir_api_ldap_create_entry_headers = {
        "accept": "application/json",
        "Origin": edir_ldap_origin,
        "Content-Type": "application/json",
        "X-CSRF-Token": anti_csrf_token
    }

    # Defines the cookies for the edir ldap to create the entry request (session-based auth)
    edir_api_ldap_create_entry_cookies = {
        "RSESSIONID": rsessionid
    }
    
    # Checks if the entry is a user or a group for logging purposes
    if entry == user:
        users_logger.info("Creating a user")
    else:
        groups_logger.info("Creating a group")

    # Performs the POST request to create the eDirectory LDAP entry
    edir_api_ldap_create_entry_response = requests.post(edir_api_ldap_create_entry_url, headers=edir_api_ldap_create_entry_headers, cookies=edir_api_ldap_create_entry_cookies, json=entry, verify=False)
    
    # Checks if the request was successful
    if edir_api_ldap_create_entry_response.status_code == 201:
        # Prints a message that indicates that the request was successfull
        print(colored(f"API Request was successfull!", "green"))

        print("")

        print("Showing the result from the query:")
        
        # Prints the response of edir ldap entry creation request as a parsed JSON (Passed Request)
        print(json.dumps(edir_api_ldap_create_entry_response.json(), indent=4))

        print("")
        
        # Checks if the entry is a user or a group for logging purposes
        if entry == user:
            # Adds info log for user creation
            users_logger.info("Result from the user query: %s", json.dumps(edir_api_ldap_create_entry_response.json(), separators=(",", ":")))
        else:
            # Adds info log for group creation
            groups_logger.info("Result from the group query: %s", json.dumps(edir_api_ldap_create_entry_response.json(), separators=(",", ":")))
        
        # Returns the edir ldap entry data created
        return edir_api_ldap_create_entry_response
    else:
        # Prints a message that indicates that the request was unsuccessfull
        print(colored("API Request has failed. eDirectory API is down or your Token has expired.", "red"))
        
        print("")
        
        # Prints the status code of edir ldap entry creation request (Failed Request)
        print(colored(f"The status code from the request of eDirectory API ldap entry creation is: {edir_api_ldap_create_entry_response.status_code}", "red"))
        
        print("")
        
        print("Showing the result from the query:")

        # Prints the response of edir ldap entry creation request as a parsed JSON (Failed Request)
        print(json.dumps(edir_api_ldap_create_entry_response.json(), indent=4))

        print("")
        
        # Checks if the entry is a user or a group for logging purposes
        if entry == user:
            # Adds error log for user creation
            users_logger.error(f"The status code from the request of eDirectory API ldap user creation is: {edir_api_ldap_create_entry_response.status_code}")
            users_logger.error("Result from the user query: %s", json.dumps(edir_api_ldap_create_entry_response.json(), separators=(",", ":")))
        else:
            # Adds error log for group creation
            groups_logger.error(f"The status code from the request of eDirectory API ldap group creation is: {edir_api_ldap_create_entry_response.status_code}")
            groups_logger.error("Result from the group query: %s", json.dumps(edir_api_ldap_create_entry_response.json(), separators=(",", ":")))
        
        # Exits the script with error code 1
        sys.exit(1) 

# Function that parses the eDirectory LDAP entries to add from the input files and returns a list of user dictionaries (groups and users)
def parse_edirectory_entries_to_add(file_path):
    # List to hold the parsed eDirectory LDAP entries
    edir_ldap_entries = []

    # Reads the input file content
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Splits the content into individual entries based on double newlines
    entries = [e.strip() for e in content.split("\n\n") if e.strip()]

    # Iterates through each entry and parses its attributes
    for entry in entries:
        # Initializes variables for dn and attributes
        dn = None
        attributes = {}

        # Iterates through each line in the entry
        for line in entry.splitlines():
            # Checks if the line contains a colon to separate key and value
            if ":" not in line:
                # Skips lines that do not contain a colon
                continue

            # Splits the line into key and value
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip()

            # Checks if the key is "dn" to set the dn variable, otherwise adds to attributes
            if key == "dn":
                dn = value
            else:
                # Adds the attribute to the attributes dictionary
                attributes.setdefault(key, []).append(value)
        
        # Checks if dn or objectClass attribute is missing
        if not dn or "objectClass" not in attributes:
            print(colored(f"Skipping invalid entry (missing dn or objectClass)", "yellow"))

            print("")

            # Skips invalid entries
            continue
        
        # Appends the parsed entry to the list
        edir_ldap_entries.append({
            "dn": dn,
            "attributes": attributes
        })
    
    # Returns the list of the parsed eDirectory LDAP entries from the input file
    return edir_ldap_entries

# Function that retrieves the anti-CSRF token using an existing RSESSIONID from the eDirectory REST API
def get_edir_ldap_anti_csrf_token(rsessionid):
    # Defines the eDirectory API Request URL to get the anti-CSRF token
    edir_api_ldap_create_anti_csrf_token_url = f"{edir_ldap_api_url}/{edir_ldap_tree}/getanticsrftoken"

    # Defines the headers for the edirldap CSRF token request
    edir_api_ldap_anti_csrf_token_headers = {
        "accept": "string"
    }

    # Defines the cookies for the edirldap  anti-CSRF token request (session-based auth)
    edir_api_ldap_anti_csrf_token_cookies = {
        "RSESSIONID": rsessionid
    }
    
    token_logger.info("Requesting Anti-CSRF token")

    # Performs the GET request to create the anti-CSRF token
    edir_api_ldap_anti_csrf_token_creation_response = requests.get(edir_api_ldap_create_anti_csrf_token_url, headers=edir_api_ldap_anti_csrf_token_headers, cookies=edir_api_ldap_anti_csrf_token_cookies, verify=False)

    # Checks if the request was successful
    if edir_api_ldap_anti_csrf_token_creation_response.status_code == 200:
        # Prints a message that indicates that the request was successfull
        print(colored(f"API Request was successfull!", "green"))

        print("")

        print("Showing the result from the query:")
        
        # Gets the anti-CSRF token data from the response
        anti_csrf_token = edir_api_ldap_anti_csrf_token_creation_response.text.strip().strip('"')
        
        # Prints the response of edir ldap anti-CSRF token creation request (Passed Request)
        print(colored(f"Anti CSRF Token generated: '{anti_csrf_token}'", "cyan"))
        
        print("")
        
        token_logger.info(f"Anti CSRF Token generated: '{anti_csrf_token}'")
        
        # Returns the edir ldap anti-CSRF tokenn data created
        return anti_csrf_token
    else:
        # Prints a message that indicates that the request was unsuccessfull
        print(colored("API Request has failed. eDirectory API is down or your Token has expired.", "red"))
        
        print("")
        
        # Prints the status code of edir ldap token creation request (Failed Request)
        print(colored(f"The status code from the request of eDirectory API ldap token creation is: {edir_api_ldap_anti_csrf_token_creation_response.status_code}", "red"))
        
        print("")
        
        print("Showing the result from the query:")
        
        # Prints the response of edir ldap anti-CSRF token creation request (Failed Request)
        print(edir_api_ldap_anti_csrf_token_creation_response.text)
        
        print("")
        
        token_logger.info("The status code from the request of eDirectory API ldap token creation is: {edir_api_ldap_anti_csrf_token_creation_response.status_code}")
        token_logger.info("Result from the query: %s, '{edir_api_ldap_anti_csrf_token_creation_response.text}'")
        
        sys.exit(1)

# Function that Creates a session and a token against the eDirectory REST API and returns the JSON response
def create_edir_ldap_api_session():
    # Defines the eDirectory API Request URL to create a session 
    edir_api_ldap_create_session_request_url = f"{edir_ldap_api_url}/session"
    
    # Defines the headers for the edir api session Requests
    edir_api_ldap_session_headers = {
        "accept": "application/json",
        "Origin": edir_ldap_origin,
        "Content-Type": "application/json"
    }

    # Defines the body for the edir api session creation request
    edir_api_ldap_session_body = {
        "dn": edir_ldap_admin_dn,
        "password": edir_ldap_admin_password,
        "ldapserver": edir_ldap_server
    }
    
    session_create_logger.info("Creating eDirectory API session")
    
    # Performs the POST request to create the eDirectory Session
    edir_api_ldap_create_session_response = requests.post(edir_api_ldap_create_session_request_url, headers=edir_api_ldap_session_headers, json=edir_api_ldap_session_body, verify=False)
    
    # Checks if the request was successful
    if edir_api_ldap_create_session_response.status_code == 201:
        # Prints a message that indicates that the request was successfull
        print(colored(f"API Request was successfull!", "green"))

        print("")

        print("Showing the result from the query:")
        
        # Gets edir ldap RSESSIONID (Session) data from the response
        rsessionid = edir_api_ldap_create_session_response.cookies.get("RSESSIONID")

        # Prints the response of edir ldap session creation request (Passed Request)
        print(colored(f"RSESSIONID generated: '{rsessionid}'", "cyan"))

        print("")
        
        session_create_logger.info(f"RSESSIONID generated: '{rsessionid}'")
        
        # Returns the edir ldap session data created
        return rsessionid
    else:
        # Prints a message that indicates that the request was unsuccessfull
        print(colored("API Request has failed. eDirectory API is down or your Token has expired.", "red"))
        
        print("")
        
        # Prints the status code of edir ldap session creation request (Failed Request)
        print(colored(f"The status code from the request of eDirectory API ldap session creation is: {edir_api_ldap_create_session_response.status_code}", "red"))
        
        print("")
        
        print("Showing the result from the query:")

        # Prints the response of edir ldap session creation request as a parsed JSON (Failed Request)
        print(json.dumps(edir_api_ldap_create_session_response.json(), indent=4))

        print("")
        
        session_create_logger.error(f"The status code from the request of eDirectory API ldap session creation is: {edir_api_ldap_create_session_response.status_code}")
        session_create_logger.error("Result from the query: %s", json.dumps(edir_api_ldap_create_session_response.json(), separators=(",", ":")))
        
        sys.exit(1)
           
""" Main Program """

print(colored(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Starting the Script...", 'cyan'))

print("")

# Sets up loggers for different operations
session_create_logger = setup_logger("session_create", "edir_ldap_session_creation.log") # Logger for session creation
token_logger = setup_logger("token", "edir_ldap_token_creation.log") # Logger for token creation
users_logger = setup_logger("users", "edir_ldap_users_creation.log") # Logger for users creation
groups_logger = setup_logger("groups", "edir_ldap_groups_creation.log") # Logger for groups creation
session_delete_logger = setup_logger("session_delete", "edir_ldap_session_deletion.log") # Logger for session deletion

print(colored(f"Proceeding to create a Session and a Token for eDirectory API", "yellow"))

print("")

# Attempts to create the eDirectory LDAP API session
try:
    # Calls the function to create the edir ldap session
    edir_ldap_session = create_edir_ldap_api_session()

    print(colored("eDirectory API Session created successfully!", "green"))
    
    print("")
    
    # Logs the successful creation of the eDirectory API session
    session_create_logger.info(f"eDirectory API Session created successfully!")
    
    # Calls the function to create the edir ldap token
    edir_ldap_token = get_edir_ldap_anti_csrf_token(edir_ldap_session)
        
    print(colored("eDirectory API Anti-CSRF token retrieved successfully!", "green"))
    
    # Logs the successful retrieval of the eDirectory API token
    token_logger.info(f"eDirectory API Anti-CSRF token retrieved successfully!")
        
# Exception handling for the eDirectory session creation
except requests.exceptions.RequestException as e:
    print(colored("Failed to create eDirectory session and token", "red"))
    
    print(colored(str(e), "red"))
    
    # Logs the failure to create the eDirectory API session and token
    session_create_logger.info(f"Failed to create eDirectory session and token")
    session_create_logger.info(str(e))

    # Raises the exception to propagate it up the call stack
    raise

print ("")

print(colored(f"Proceeding to create the Fortify SSC LDAP Users...", "yellow"))

print ("")

# Calls the function to parse the eDirectory LDAP users to add from the input file
fortify_ssc_ldap_users = parse_edirectory_entries_to_add(edir_ldap_users_to_add_file)

print(colored(f"Found {len(fortify_ssc_ldap_users)} users to create in the input file", "cyan"))

print("")

# Logs the number of users found to create
users_logger.info(f"Found: {len(fortify_ssc_ldap_users)} users to create in the input file")

# Iterates through each eDirectory LDAP user and creates them using the eDirectory REST API
for idx, user in enumerate(fortify_ssc_ldap_users, start=1):
    # Gets the common name (cn) of the user for logging purposes
    cn = user["attributes"].get("cn", ["<unknown>"])[0]

    print(colored(f"[{idx}/{len(fortify_ssc_ldap_users)}] Creating user: {cn}", "yellow"))
    
    print("")
    
    # Logs the user creation attempt
    users_logger.info(f"[{idx}/{len(fortify_ssc_ldap_users)}] Creating user: {cn}")

    # Attempts to create the eDirectory LDAP user
    try:
        # Calls the function to create the edir ldap user
        response_users = create_edir_entry(user, edir_ldap_session, edir_ldap_token)

        # Checks if the user was created successfully
        if response_users.status_code == 201:
            print(colored(f"User {cn} was created successfully!", "green"))
            
            # Logs the successful user creation
            users_logger.info(f"User {cn} was created successfully!")
               
        else:
            print(colored(f"Failed to create the user {cn}", "red"))
            
            # Logs the failed user creation
            users_logger.info(f"Failed to create the user {cn}")
            
    # Exception handling for the eDirectory user creation
    except requests.exceptions.RequestException as e:
        print(colored(f"Request error for user {cn}", "red"))
        
        print(colored(str(e), "red"))
        
        # Logs the request error for user creation
        users_logger.exception(f"Request error for user {cn}")
        users_logger.exception(str(e))

    print("")
    
print(colored(f"Proceeding to create the Fortify SSC LDAP Groups...", "yellow"))

print ("")

# Calls the function to parse the eDirectory LDAP group to add from the input file
groups = parse_edirectory_entries_to_add(edir_ldap_groups_to_add_file)

print(colored(f"Found {len(groups)} groups to create in the input file", "cyan"))

print("")

# Logs the number of groups found to create
groups_logger.info(f"Found {len(groups)} groups to create in the input file")

# Iterates through each eDirectory LDAP group and creates them using the eDirectory REST API
for idx, group in enumerate(groups, start=1):
    # Gets the common name (cn) of the group for logging purposes
    cn = group["attributes"].get("cn", ["<unknown>"])[0]

    print(colored(f"[{idx}/{len(groups)}] Creating group: {cn}", "yellow"))
    
    print("")
    
    # Logs the group creation attempt
    groups_logger.info(f"[{idx}/{len(groups)}] Creating group: {cn}")

    # Attempts to create the eDirectory LDAP group
    try:
        # Calls the function to create the edir ldap group
        response_groups = create_edir_entry(group, edir_ldap_session, edir_ldap_token)

        # Checks if the group was created successfully
        if response_groups.status_code == 201:
            print(colored(f"Group {cn} was created successfully!", "green"))
            
            # Logs the successful group creation
            groups_logger.info(f"Group {cn} was created successfully!")
               
        else:
            print(colored(f"Failed to create the group {cn}", "red"))
            
            # Logs the failed group creation
            groups_logger.error(f"Failed to create the group {cn}")
            
    # Exception handling for the eDirectory group creation
    except requests.exceptions.RequestException as e:
        print(colored(f"Request error for group {cn}", "red"))
        
        print(colored(str(e), "red"))
        
        # Logs the request error for group creation
        groups_logger.exception(f"Request error for group {cn}")
        groups_logger.exception(str(e))

    print("")

print(colored(f"Proceeding to delete the session from eDirectory API...", "yellow"))

print("")

# Attempts to delete the eDirectory LDAP API session
try:
    # Calls the function to delete the edir ldap session
    delete_edir_ldap_api_session(edir_ldap_session, edir_ldap_token) 

    print(colored("eDirectory API session deleted successfully!", "green"))
    
    # Logs the successful deletion of the eDirectory API session
    session_delete_logger.info("eDirectory API session deleted successfully!")
        
# Exception handling for the eDirectory session deletionn
except requests.exceptions.RequestException as e:
    print(colored("Failed to delete eDirectory API session", "red"))
    
    print(colored(str(e), "red"))
    
    # Logs the failure to delete the eDirectory API session
    session_delete_logger.exception("Failed to delete eDirectory API session")
    session_delete_logger.exception({str(e)})

    # Raises the exception to propagate it up the call stack
    raise

print ("")

print(colored('Execution Completed!', 'green'))