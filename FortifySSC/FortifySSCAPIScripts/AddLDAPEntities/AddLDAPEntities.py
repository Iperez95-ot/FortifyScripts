#!/usr/bin/env python3

# Script that adds LDAP Entities from the LDAP Server to Fortify SSC using the SSC REST API.
# The script reads the LDAP entries to add from the eDirectory users/groups input files in a specific format, 
# then it creates a token with the necessary permissions to add the LDAP entities on Fortify SSC.
# Finally, it deletes the token that was created before to keep the environment clean of unnecessary tokens.

# Imports the necessary libraries for this script execution
from urllib import response
from attr import attrs
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
fortify_ssc_added_ldap_entities = os.getenv('OUTPUT_LOG_FILE')
fortify_ssc_ldap_users_to_add_file = os.getenv('INPUT_EDIR_LDAP_USERS_FILE_PATH')
fortify_ssc_ldap_groups_to_add_file = os.getenv('INPUT_EDIR_LDAP_GROUPS_FILE_PATH')

# Defines the timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Defines the headers for the Fortify SSC API Requests
fortify_ssc_api_request_headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

# Ensures that the directory for the log file exists, if not it will create it
os.makedirs(os.path.dirname(fortify_ssc_added_ldap_entities), exist_ok=True)

# Configure logging
logging.basicConfig(filename=fortify_ssc_added_ldap_entities, level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

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
   
# Function that sends the API request to create an LDAP Object in Fortify SSC with the specified entry, API URL and headers     
def add_ldap_entry(entry, api_url, headers, group_map):
    # Calls the function to build the payload for adding an LDAP entity to Fortify SSC based on the type of the LDAP entry (User or Group) 
    # and stores the payload in a variable
    fortify_ssc_ldap_entry_body = build_ldap_entity_payload(entry, group_map)
    
    # Sends the API request to add the LDAP Entity in Fortify SSC with the specified entry, API URL and headers and stores the response in a variable
    fortify_ssc_ldap_entry_add_response = requests.post(f"{api_url}/ldapObjects", headers=headers, json=fortify_ssc_ldap_entry_body, verify=False)

    # Checks if the request was successful
    if fortify_ssc_ldap_entry_add_response.status_code == 201:
        # Prints a message that indicates that the request was successfull
        print(colored(f"API Request was successfull!", "green"))

        print("")
            
        # Logs a message that indicates that the API request was successful
        logging.info(f"API Request was successful!")

        print("Showing the result from the query:")
            
        print(json.dumps(fortify_ssc_ldap_entry_add_response.json(), indent=4))
            
        print("")
        
        # Logs the response of the aggregation of the ldap entity on fortify ssc request (Passed Request)
        logging.info(("Result from the Aggregation of the LDAP Entity query: %s", json.dumps(fortify_ssc_ldap_entry_add_response.json(), separators=(",", ":"))))
        
        # Prints a message that indicates that the LDAP Entity with the specified name and type was successfully created
        print(colored(f"Created the entity '{fortify_ssc_ldap_entry_body['name']}' with the type '{fortify_ssc_ldap_entry_body['ldapType']}'", "green"))
        
        print("")
        
    # If the request was not successful it will print an error message with the status code and the response from the API
    else:
        # Prints a message that indicates that the request was unsuccessfull
        print(colored("API Request has failed", "red"))
        
        print("")
            
        # Logs a message that indicates that the API request has failed
        logging.error(f"API Request has failed!")
        
        # Prints the status code of the ldap entity aggregation on fortify ssc request (Failed Request)
        print(colored(f"The status code from the request of LDAP Entity agreggation is: {fortify_ssc_ldap_entry_add_response.status_code}", "red"))
        
        print("")
        
        print("Showing the result from the query:")
            
        # Prints the response of the ldap entity aggregation on fortify ssc request (Failed Request)
        print(json.dumps(fortify_ssc_ldap_entry_add_response.json(), indent=4))
            
        print("")
        
        # Prints a message that indicates that the aggregation of the LDAP Entity with the specified name and type has failed
        print(colored(f"Failed to create the entity '{fortify_ssc_ldap_entry_body['name']}' with the type '{fortify_ssc_ldap_entry_body['ldapType']}'", "red"))
        
        print("")
        
        # Logs a message that indicates that the aggregation of the LDAP Entity with the specified name and type has failed
        logging.error(f"Failed to create the entity '{fortify_ssc_ldap_entry_body['name']}' with the type '{fortify_ssc_ldap_entry_body['ldapType']}'")
            
# Function that builds the payload for adding an LDAP entity to Fortify SSC based on the type of the LDAP entry (User or Group) 
# and returns the payload in a dictionary format   
def build_ldap_entity_payload(entry, group_map):
    # Calls the function to detect the LDAP entity type (User or Group) based on the objectClass attribute of the LDAP entry and stores the type in a variable
    ldap_type = detect_ldap_type(entry)
    
    # Calls the function to determine the role for the LDAP entity based on its group membership in the LDAP Server and stores the role in a variable,
    role = determine_role(entry, group_map)

    # Retrieves the attributes of the LDAP entry and stores them in a variable, then it retrieves the common name (cn) attribute 
    # to use it as the name of the LDAP entity in Fortify SSC and it also retrieves the distinguished name (dn) of the LDAP entry 
    # to use it in the payload for creating the LDAP entity in Fortify SSC1
    attrs = entry.get("attributes", {})
    name = attrs.get("cn", [None])[0]
    dn = entry.get("dn").split("/eDirAPI/v1/ot-tree/")[1]

    # Checks if the LDAP entity is a User or a Group based on the detected type and builds the payload accordingly, for Users it will include the first name, 
    # last name and email attributes while for Groups those attributes will be set to None
    if ldap_type == "USER":
        # Retrieves the first name, last name and email attributes for the User LDAP entity, if any of those attributes is missing it will set it to None
        first_name = attrs.get("givenName", [None])[0]
        last_name = attrs.get("sn", [None])[0]
        email = attrs.get("mail", [None])[0]
        
        # Returns the payload for creating a User LDAP entity in Fortify SSC with the specified attributes and role in a dictionary format
        return {
            "ldapType": "USER",
            "name": name,
            "distinguishedName": dn,
            "firstName": first_name,
            "lastName": last_name,
            "email": email,
            "roles": [role],
            "userPhoto": {
                "photo": None
            }
        }

    # If the LDAP entity is not a User it will be considered as a Group and it will return the payload for creating a Group LDAP entity in Fortify SSC 
    # with the specified attributes and role in a dictionary format,
    else:
        # Returns the payload for creating a Group LDAP entity in Fortify SSC with the specified attributes and role in a dictionary format, 
        # for Groups the first name, last name and email attributes will be set to None
        return {
            "ldapType": "GROUP",
            "name": name,
            "distinguishedName": dn,
            "firstName": None,
            "lastName": None,
            "email": None,
            "roles": [role],
            "userPhoto": None
        }

# Function that determines the role for the LDAP entity based on its group membership in the LDAP Server and returns the role in a dictionary format
def determine_role(entry, group_map):
    # Retrieves the attributes of the LDAP entry and stores them in a variable, then it retrieves the common name (cn) attribute
    attrs = entry.get("attributes", {})
    name = attrs.get("cn", [None])[0]
    dn = entry.get("dn")

    # Defines the default role for the LDAP entity as "Developer" with publishVersion 5, 
    # but it can be changed to "Administrator" with publishVersion 4 if the entity is a member 
    # of specific groups in the LDAP Server according to the group_map
    role = {
        "id": "developer",
        "name": "Developer",
        "publishVersion": 5
    }
    
    # If the entry itself is the support group → Administrator
    if name == "support":
        # Returns the role for the LDAP entity in a dictionary format with the id, name and publishVersion for the "Administrator" role
        return {
            "id": "admin",
            "name": "Administrator",
            "publishVersion": 4
        }

    # Iterates through the group_map to check if the distinguished name (dn) of the LDAP entry is a member of any group in the map,
    for group, members in group_map.items():
        # Checks if the distinguished name (dn) of the LDAP entry is in the list of members of the current group, 
        # if so it will determine the role based on the group name
        if dn in members:
            # Checks if the group name is "support" to set the role as "Administrator" with publishVersion 4 for those groups,
            if group == "support":
                # Returns the role for the LDAP entity in a dictionary format with the id, name and publishVersion for the "Administrator" role
                return {
                    "id": "admin",
                    "name": "Administrator",
                    "publishVersion": 4
                }

            # Checks if the group name is "service" to set the role as "Developer" with publishVersion 5 for those groups,
            if group == "service":
                # Returns the role for the LDAP entity in a dictionary format with the id, name and publishVersion for the "Developer" role
                return {
                    "id": "developer",
                    "name": "Developer",
                    "publishVersion": 5
                }

    # Returns the role for the LDAP entity in a dictionary format, 
    # if the entity is not a member of any group in the group_map it will return the default role defined before
    return role

# Function that builds a mapping of group names to their members based on the LDAP entries and returns the mapping in a dictionary format
def build_group_membership_map(entries):
    # Defines an empty dictionary to hold the mapping of group names to their members
    group_members = {}

    # Iterates through each LDAP entry and checks if it is a group based on the objectClass attribute, 
    # if it is a group it retrieves the group name and its members
    for entry in entries:
        # Retrieves the attributes of the LDAP entry and stores them in a variable, 
        # then it retrieves the objectClass attribute to check if it is a group
        attrs = entry.get("attributes", {})
        object_classes = attrs.get("objectClass", [])

        # Checks if the objectClass attribute contains "groupOfNames" to detect if the LDAP entry is a Group, 
        # if so it retrieves the group name from the cn attribute and its members from the member attribute,
        if "groupOfNames" in object_classes:
            # Retrieves the group name from the cn attribute, if the cn attribute is missing it will set the group name to None,
            group_name = attrs.get("cn", [None])[0]
            members = attrs.get("member", [])

            # Adds the group name and its members to the group_members dictionary, where the key is the group name 
            # and the value is the list of members
            group_members[group_name] = members

    # Returns the mapping of group names to their members in a dictionary format
    return group_members

# Function that detects the LDAP entity type (User or Group) based on the objectClass attribute of the LDAP entry
def detect_ldap_type(entry):
    # Retrieves the objectClass attribute from the LDAP entry
    object_classes = entry.get("attributes", {}).get("objectClass", [])
    
    # Checks if the objectClass attribute is a string and if so it converts it to a list to handle both cases where it can be a single value or multiple values
    if isinstance(object_classes, str):
        object_classes = [object_classes]
    
    # Checks if the objectClass attribute contains "groupOfNames" to detect if the LDAP entry is a Group, if so it returns "GROUP"
    if "groupOfNames" in object_classes:
        return "GROUP"
    
    # Returns "USER" by default if the objectClass attribute does not contain "groupOfNames" to detect if the LDAP entry is a User
    return "USER"
        
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

print(colored(f"Creating a Token for Adding the LDAP Entities on Fortify SSC...", 'yellow'))

print("")

# Logs a message that indicates that the script is creating a token for adding the LDAP entities on Fortify SSC
logging.info(f"Creating a Token for Adding the LDAP Entities on Fortify SSC")

# Creates a UnifiedLoginToken for adding the ldap entities on Fortify SSC and stores the token and the token id in variables
fortify_ssc_token, fortify_ssc_token_id = create_fortify_ssc_token("UnifiedLoginToken", fortify_ssc_api_url, fortify_ssc_user, fortify_ssc_password, fortify_ssc_api_request_headers)

# Checks if the token was created if not it will exit the program
if fortify_ssc_token:
    # Adding the created token to the headers
    fortify_ssc_api_request_headers["Authorization"] = f"FortifyToken {fortify_ssc_token}"
else:
    sys.exit(1)  # Exits the program with an error status code

print("")

print(colored(f"Adding the LDAP Entites on Fortify SSC...", 'yellow'))

print("")

# Logs a message that indicates that the script is adding the LDAP Entities on Fortify SSC
logging.info(f"Adding the LDAP Entites on Fortify SSC")

# Calls the function to parse the eDirectory LDAP entries to add from the input files and stores the list of user dictionaries (groups and users) in a variable
fortify_ldap_entries_to_add = parse_edirectory_entries_to_add((fortify_ssc_ldap_users_to_add_file))
fortify_ldap_entries_to_add += parse_edirectory_entries_to_add((fortify_ssc_ldap_groups_to_add_file))

# Calls the function to build a mapping of group names to their members based on the LDAP entries and stores the mapping in a variable, 
# this will be used to determine the role of the LDAP entities based on their group membership
group_map = build_group_membership_map(fortify_ldap_entries_to_add)

# Iterates through each LDAP entry to add and calls the function to add the LDAP entry to Fortify SSC with the specified entry, API URL and headers
for entry in fortify_ldap_entries_to_add:
    # Calls the function to add the LDAP entry to Fortify SSC with the specified entry, API URL and headers
    add_ldap_entry(entry, fortify_ssc_api_url, fortify_ssc_api_request_headers, group_map)

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