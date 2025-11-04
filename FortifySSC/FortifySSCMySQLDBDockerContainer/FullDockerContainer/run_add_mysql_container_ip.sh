#!/bin/bash

# Script to modify the /etc/hosts file to add custom entries for ip addresses and hostnames

# Backups the original /etc/hosts file
# This creates a copy of the current hosts file for recovery purposes in case of an issue.
cp /etc/hosts /etc/hosts.bak

# Defines the base structure of /etc/hosts
# This section writes the default loopback and IPv6-related entries into the hosts file.
cat <<EOF > /etc/hosts
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# Defines the static entries
# These are the predefined mappings for static IP addresses and their associated hostnames and aliases.
STATIC_ENTRIES=(
    "xxx.xxx.x.xx    sschostname             ssc"  # IP for SSC server
    "xxx.xxx.x.xx    scahostname             sca"  # IP for SCA server
    "xxx.xxx.x.xx    wihostname              wi"   # IP for WI server
    "xxx.xxx.x.xx    scchostname             scc"  # IP for SCC server
)

# Adds the static entries to /etc/hosts
# This loop ensures that each static entry is appended to the hosts file.
for ENTRY in "${STATIC_ENTRIES[@]}"; do
    echo "$ENTRY" >> /etc/hosts
done

# Adds a dynamic entry for the MySQL Docker Container
# These variables define the IP address, hostname (FQDN), alias, and container ID for the current container.
CONTAINER_IP="xxx.xxx.x.xx"                          # Static IP for the current container
CONTAINER_ID=$(cat /proc/self/cgroup | grep "docker" | sed 's/^.*\///' | tail -n1 | cut -c1-12)  # Retrieves the first 12 characters of the container ID
FQDN="mysqlhostname                                  # Fully qualified domain name for the container
ALIAS="scc"                                          # Alias for the container

# Constructs the dynamic entry
DYNAMIC_ENTRY="$CONTAINER_IP    	$FQDN 		$ALIAS $CONTAINER_ID"  

# Appends the dynamic entry to the hosts file
echo "$DYNAMIC_ENTRY" >> /etc/hosts

# Logs the updates to a log file
# This section writes the updated contents of the hosts file to a log file for auditing and troubleshooting.
#echo "Updated /etc/hosts with the following entries:" > "/var/log/add-container-ip.sh.log"
#cat /etc/hosts >> "/var/log/add-container-ip.sh.log"
