#!/bin/bash

# Script that builds a Docker Container for MySQL to deploy Fortify Software Security Center (SSC) Database in a linux system

# Exits immediately if a command exits with a non-zero status
#set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Defines the variables
FORTIFY_SSC_VERSION="23.2"																				# Current Fortify SSC version in use
MYSQL_HOST="ssc.fortifynacho.com.ar"															        			# Hostname of the host machine running the MySQL Docker Container
MYSQL_PORT="3306"                                                                             		   	   									# Port of the MySQL Docker Container
MYSQL_IMAGE_NAME="mysql" 										           									# MySQL Docker Image name
MYSQL_IMAGE_TAG="8.0"                                         		   				  	   									# MySQL Docker Image tag
MYSQL_CONTAINER_NAME="mysql"                                                                   		   	  									# MySQL Docker Container name
MYSQL_USER="root"											           									# MySQL User to log in into the MySQL Docker Container
MYSQL_ROOT_PASSWORD="N0v3ll95"                                                                                     									# MySQL Root Password
FORTIFY_SSC_DATABASE_NAME="fortify_ssc_db"									   									# Fortify SSC Database Name
MYSQL_DATA_VOLUME_NAME="mysql-data"									           									# MYSQL data Docker Volume 		
MYSQL_DATA_DIRECTORY="/var/lib/mysql"                                                      		           									# MySQL data directory inside the MySQL Docker Container
MYSQL_CONFIG_HOST_DIRECTORY="/etc/docker/mysql8/db_config"								   							        # MySQL config file directory on the Host Machine
MYSQL_CONFIG_CONTAINER_DIRECTORY="/etc"                                                               							                                # MySQL config file directory on the MySQL Docker Container
MYSQL_CREATE_TABLES_SCRIPT="/opt/Fortify_Software_Security_Center/Fortify_Software_Security_Center_Application_Files/$FORTIFY_SSC_VERSION/sql/mysql/create-tables.sql"	        	# MySQL script to create the tables for the Fortify SSC Database
FORTIFY_SSC_DATABASE_JDBC_URL="jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$FORTIFY_SSC_DATABASE_NAME?sessionVariables=collation_connection=latin1_general_cs&rewriteBatchedStatements=true"   # JDBC URL for the Fortify SSC Setup when connecting to the MySQL Database running on the Docker Container
OUTPUT_JDBC_URL_FILE="fortify_ssc_db_jdbc_url.txt"                                                                                                                                      # Output file containing the Fortify SSC Database JDBC URL
