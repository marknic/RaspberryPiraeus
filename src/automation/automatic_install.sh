#!/bin/bash


. config_file


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


let length="${#filearray[@]} / 6"

for ((i=0; i<$length; i++));
do
    new_host_name=${filearray[i*6+3]}
    ip_target="${filearray[i*6+2]}"
        
    if [ "${filearray[i*6+2]}" == "$ip_addr_me" ] ; then
        
        host_name=hostname
        # Working on the Master - Set the hostname
        printf "Updating host names locally...\n\n"

        chmod +x "$FILE_UPDATE_HOSTS"
        sudo "./$FILE_UPDATE_HOSTS"
        sudo sed -i -e "s/$host_name/$new_host_name/g" $FILE_HOSTNAME

    else         
        host_name=$(sshpass -p $pword ssh pi@192.168.8.101 hostname)

        printf "Modifying $host_name to $new_host_name...\n"
        sshpass -p $pword ssh $id@$ip_target sudo sed -i -e "s/$host_name/$new_host_name/g" $FILE_HOSTNAME

        printf "Copying $FILE_UPDATE_HOSTS to $ip_target...\n"
        sshpass -p $pword scp $FILE_UPDATE_HOSTS $id@$ip_target:
        
        sshpass -p $pword ssh $id@$ip_target "chmod +x $FILE_UPDATE_HOSTS"

        printf "Updating host names on $ip_target...\n"
        sshpass -p $pword ssh $id@$ip_target "sudo ./$FILE_UPDATE_HOSTS"
    fi

    # IP Address: ${filearray[i*6+2]}
    # Host Name:  ${filearray[i*6+3]}
done

printf "Rebooting all workers!"
for ((i=0; i<$length; i++));
do
    if [ "${filearray[i*6+2]}" != "$ip_addr_me" ] ; then
        ip_target="${filearray[i*6+2]}"
        sshpass -p $pword ssh $id@$ip_target "sudo reboot"
    fi
done

sudo reboot

# printf "Verifying Reboot Complete\n"

# printf "Waiting 20 seconds"
# sleep 20

# for ((i=0; i<$length; i++));
# do
#     ip_target="${filearray[i*6+2]}"

#     if [ "$ip_target" != "$ip_addr_me" ] ; then

#         output='down'

#         while [ "$output" != "up" ]
#         do
#             output=$(sshpass -p $pword ssh $id@$ip_target uptime | awk '{print $2}')

#             if [ "$output" != "up" ]
#             then
#                 sleep 8
#             else
#                 echo "$ip_target is back up."
#             fi
#         done
#     fi
# done


