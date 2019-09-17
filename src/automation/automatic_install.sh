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
    curl -O "https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/automation/$FILE_UPDATE_HOSTS"
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

    cleanline=$(echo $line | sed 's/'"'"'/ /g')

    # Change first slash to space
    cleanline=$(echo $cleanline | sed 's/\// \//')

    # Split the line into an array delimited by spaces
    linearray=($cleanline)

    if [ "${linearray[5]}" == "/etc/hosts" ] ; then
        filearray+=($cleanline)
    fi
done < "$FILE_UPDATE_HOSTS"

echo "${#filearray[@]}"
echo "${filearray[@]}"
echo "${filearray[2]}"
echo "${filearray[3]}"
echo "${filearray[5]}"

let length="${#filearray[@]} / 6"

echo "length: $length"

for ((i=0; i<$length; i++));
do
    if [ "${filearray[i*6+2]}" == "$ip_addr_me" ] ; then

        # Working on the Master - Set the hostname
        printf "Updating host names locally...\n\n"
        chmod +x "$FILE_UPDATE_HOSTS"
        sudo "./$FILE_UPDATE_HOSTS"

    else         
        ip_target="${filearray[i*6+2]}"

        printf "Copying $FILE_UPDATE_HOSTS to $ip_target...\n\n"
        sshpass -p $pword scp $FILE_UPDATE_HOSTS $id@$ip_target:
        
        sshpass -p $pword ssh $id@$ip_target "chmod +x $FILE_UPDATE_HOSTS"

        printf "Updating host names on $ip_target...\n\n"
        sshpass -p $pword ssh $id@$ip_target "sudo ./$FILE_UPDATE_HOSTS"
    fi


    # IP Address: echo ${filearray[i*6+2]}
    # Host Name:  echo ${filearray[i*6+3]}
done


printf "Exited loop.\n\n"
