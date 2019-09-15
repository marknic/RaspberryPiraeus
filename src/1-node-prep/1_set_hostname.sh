#!/bin/bash

# This script will update two files that dictate the name of the host.  "/etc/hostname" contains the name of the host and "/etc/hosts"
#  which contains the name of the host and associates it with IP addres 127.0.1.1 (a Debian convention).  Both are required changes 
#  to change the name of the host. 
#
# Note: you can do the same changes that this script will do with raspi-config.  This script is provided to automate changes
#  and to ensure the names are updated consistently across all RPi's by gettint the host names from the "update_hosts.sh" file.

# Set the names of the required files
FILE_UPDATE_HOSTS="4_update_hosts.sh"
FILE_HOSTNAME="/etc/hostname"
FILE_HOSTS="/etc/hosts"

# Get the current host name that will be replaced.  (Probably "raspberrypi")
host_name="$(hostname)"

# Get the IP address of this machine
ip_addr="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"

# Read the "update_hosts" script and extract the IP and host name info.
# When we find an IP address match, then we know that host name should be
# associated with this machine.  At that point, we change /etc/hostname and /etc/hosts

while read line; do

  # Change single quotes to spaces
  cleanline=$(echo $line | sed 's/'"'"'/ /g')

  # Change first slash to space
  cleanline=$(echo $cleanline | sed 's/\// \//')

  # Split the line into an array delimited by spaces
  linearray=($cleanline)

  # When we find the same IP address in the file, that is the new host name
  if [ "${linearray[4]}" == "/etc/hosts" ] && [ "${linearray[1]}" == "$ip_addr" ]
  then
    new_host_name="${linearray[2]}"

    sudo sed -i -e "s/$host_name/$new_host_name/g" $FILE_HOSTS

    result1=$?

    if [ $result1 ]
    then
      printf "Successfully changed the host name in $FILE_HOSTS.\n"

      sed -i -e "s/$host_name/$new_host_name/g" $FILE_HOSTNAME

      result2=$?

      if [ $result2 ]
      then
        printf "Successfully changed the host name in $FILE_HOSTNAME.\n"
        printf "Reboot to allow the machine to recognize the changes.\n\n"
      else
        printf "There was an error attempting to change the host name in $FILE_HOSTNAME.\n"
        printf "Note: $FILE_HOSTS was updated with the host name: $new_host_name.\n"
        printf "exiting the script...\n"
      fi
    else
      printf "There was an error attempting to change the host name in $FILE_HOSTS.\n"
      printf "exiting the script...\n"
    fi
  fi

done < $FILE_UPDATE_HOSTS

echo " "
echo "/etc/hostname contents:"
echo "====================="
cat /etc/hostname
echo "====================="
echo " "
echo " "
echo "/etc/hosts contents:"
echo "====================="
cat /etc/hosts
echo "====================="
echo "Done. "

