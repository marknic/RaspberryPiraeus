#!/bin/bash

. config_file

if [ -f $FILE_UPDATE_HOSTS ]; then
    printf "File $FILE_UPDATE_HOSTS exists locally.\n\n"

    while true; do
        printf "Has the $FILE_UPDATE_HOSTS file been updated with your network static IP addresses and hostnames? "
        read -p "(y/n)?" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done

else
    curl -O "https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/automation/$FILE_UPDATE_HOSTS"
    printf "\e[1;31mError: File $FILE_UPDATE_HOSTS did not exist locally.\e[0m\n"
    printf "It has been copied to this machine.  Please read the instructions and update the file\n"
    printf " with your static network IP addresses and hostnames (1 per machine/node).\n"
    printf "exiting...rerun this script when you have edited $FILE_UPDATE_HOSTS.\n"
    exit 1
fi


ip_addr_me="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"
printf "My IP Address:$ip_addr_me\n\n"


# Get the IP/hostname info from the update script
while read line; do

    cleanline=$(echo $line | sed 's/'"'"'/ /g')

    # Change first slash to space
    cleanline=$(echo $cleanline | sed 's/\// \//')

    # Split the line into an array delimited by spaces
    linearray=($cleanline)

    if [ "${linearray[5]}" == "hosts.local" ] ; then
        filearray+=($cleanline)
    fi
done < "$FILE_UPDATE_HOSTS"


let length="${#filearray[@]} / 6"

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target="${filearray[i*6+2]}"
    
    if [ $ip_addr_me != $ip_target ] ; then
        #ssh-copy-id $id@$ip_target
        sshpass -p $pword ssh $id@$ip_target "ssh-keyscan -H $ip_addr_me >> ~/.ssh/known_hosts"
    fi
done


