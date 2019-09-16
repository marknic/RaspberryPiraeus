#!/bin/bash

# This file will remotely copy the update hosts script file to each of the nodes in the cluster.  You just
# need to run it.  You will likely be asked if you are sure you would like to continue.  Answer "yes".  
# You will then be prompted to enter the password for the machine it is copying to.  
# This is where having all of the passwords the same comes in handy.

# Set the names of the required files
FILE_UPDATE_HOSTS="4_update_hosts.sh"

# Get the IP address of this machine
ip_addr="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"

while read line; do

  # Change single quotes to spaces
  cleanline=$(echo $line | sed 's/'"'"'/ /g')

  # Change first slash to space
  cleanline=$(echo $cleanline | sed 's/\// \//')

  # Split the line into an array delimited by spaces
  linearray=($cleanline)

  # When we find the same IP address in the file, that is the new host name
  if [ "${linearray[4]}" == "/etc/hosts" ] && [ "${linearray[1]}" != "$ip_addr" ]
  then
    echo "Copying $FILE_UPDATE_HOSTS to ${linearray[1]}..."
    scp 4_update_hosts.sh pi@${linearray[1]}:
  fi

done < $FILE_UPDATE_HOSTS

