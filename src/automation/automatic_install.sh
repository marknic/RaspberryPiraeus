#!/bin/bash

FILE_UPDATE_HOSTS="4_update_hosts.sh"

pword="raspberry"
id="pi"




if [ -f $FILE_UPDATE_HOSTS ]; then
    printf "File $FILE_UPDATE_HOSTS exists locally.\n\n"

    while true; do
        printf "Has the $FILE_UPDATE_HOSTS file been updated with your network static IP addresses and hostnames?"
        read -p "(y/n)?" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done

else
    curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/automation/4_update_hosts.sh
    printf "\e[1;31mError: File $FILE_UPDATE_HOSTS did not exist locally.\e[0m\n"
    printf "It has been copied to this machine.  Please read the instructions and update the file\n"
    printf " with your static network IP addresses and hostnames (1 per machine/node).\n"
    printf "exiting...rerun this script when you have edited $FILE_UPDATE_HOSTS.\n"
    exit 1
fi


printf "Updating host names...\n"
# Get the IP address of this machine
ip_addr_me="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"
printf "My IP Address:$ip_addr_me\n\n"

while read line; do
    # Change single quotes to spaces
    cleanline=$(echo $line | sed 's/'"'"'/ /g')

    # Change first slash to space
    cleanline=$(echo $cleanline | sed 's/\// \//')

    # Split the line into an array delimited by spaces
    linearray=($cleanline)
    
    # When we find the same IP address in the file, that is the new host name
    if [ "${linearray[5]}" == "/etc/hosts" ] && [ "${linearray[2]}" != "$ip_addr_me" ] ; then

        ip_target=${linearray[2]}

        printf "Copying $FILE_UPDATE_HOSTS to $ip_target..."
        scp 4_update_hosts.sh pi@$ip_target:

        printf "Updating host names on $ip_target...\n\n"
        sshpass -p $pword ssh $id@$ip_target "sudo ./4_update_hosts.sh"
        printf "Result of sshpass: $?\n\n"

    elif [ "${linearray[5]}" == "/etc/hosts" ] && [ "${linearray[2]}" == "$ip_addr_me" ] ; then
        
        # Working on the Master - Set the hostname
        printf "Updating host names locally...\n\n"
        chmod +x 4_update_hosts.sh
        sudo ./4_update_hosts.sh
    fi

done < $FILE_UPDATE_HOSTS
