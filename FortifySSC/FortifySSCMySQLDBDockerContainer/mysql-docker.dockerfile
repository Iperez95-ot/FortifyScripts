# Use the official MySQL 8.0 image as base
FROM ubuntu:22.04

# Sets the environment variable to suppress prompts
ENV DEBIAN_FRONTEND=noninteractive

# Installs the required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    net-tools \
    vim \
    openssl \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Sets the root password (can be overridden at runtime via environment variable)
ENV MYSQL_ROOT_PASSWORD=N0v3ll95

# Defines the MysQL Docker Container working directory variable
ENV MYSQL_WORKDIR=/var/lib/mysql

# Defines the MySQL host directory
ENV MYSQL_HOST_DIRECTORY=/opt/Scripts/MySQLDockerContainer

# Sets the root password (can be overridden at runtime via environment variable)
ENV MYSQL_ROOT_PASSWORD=N0v3ll95

# Copy the custom MySQL config
COPY /opt/Scripts/MySQLDockerContainer/config_file/my.cnf /etc/mysql/my.cnf

# Sets root password for SSH
RUN echo "root:N0v3ll95" | chpasswd

# Configures SSH to allow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Prepares SSH directory
RUN mkdir /var/run/sshd

# Adds a script to update /etc/hosts with container's IP, alias, and ID
COPY run_add_mariadb_container_ip.sh
$MYSQL_HOST_DIRECTORY/run_add_mysql_container_ip.sh
RUN chmod +x $MYSQL_HOST_DIRECTORY/run_add_mysql_container_ip.sh

# Exposes the port 3306 (default MySQL port) and port 22 (default SSH port)
EXPOSE 22 3306

