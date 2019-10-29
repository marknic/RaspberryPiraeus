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


# Get the IP/hostname info from the update script
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

printf "Array Length: $length\n"

# Clean up the hosts file before attempting to update with current information
hostfilename="hostfile.txt"
tmp_hostfilename="$hostfilename.bak"


for ((i=0; i<$length; i++));
do
    printf "i=$i\n"
    # Get the IP to search for
    ip_target="${filearray[i*6+2]}"
    new_host_name="${filearray[i*6+3]}"

    printf "\nCleaning the hosts file on $ip_target\n\n"

    # Delete the local host files (quietly - they may not exist)
    sshpass -p $pword ssh $id@$ip_target  "sudo rm -f $hostfilename > /dev/null 2>&1"
    sshpass -p $pword ssh $id@$ip_target  "sudo rm -f $tmp_hostfilename > /dev/null 2>&1"

    # Copy machine host file to local host file
    #sshpass -p $pword ssh $id@$ip_target  "sudo cp -f /etc/hosts ~/$hostfilename"

    host_name=$(sshpass -p $pword ssh $id@$ip_target hostname)
    
    sshpass -p $pword ssh $id@$ip_target  sudo sed "/127.0.1.1/d" $FILE_HOSTS

    # sshpass -p $pword ssh $id@$ip_target  "rm -f $hostfilename"
    # sshpass -p $pword ssh $id@$ip_target  "mv $tmp_hostfilename $hostfilename"

    sshpass -p $pword ssh $id@$ip_target sudo echo "127.0.1.1   $new_host_name" >> $FILE_HOSTS

    sshpass -p $pword ssh $id@$ip_target sudo sed -i -e "s/$host_name/$new_host_name/g" $FILE_HOSTNAME
    
    printf "\n"
 
    j=0
    while [ $j -lt $length ]
    do
        ip_to_remove="${filearray[j*6+2]}"
        
        printf "."
        
        # Delete the lines containing the IP address
        sshpass -p $pword ssh $id@$ip_target  sed "/$ip_to_remove/d" $FILE_HOSTS

        # Copy the updated file over the local host file
        # sshpass -p $pword ssh $id@$ip_target  "rm -f $hostfilename"
        # sshpass -p $pword ssh $id@$ip_target  "mv $tmp_hostfilename $hostfilename"

        ((j++))
    done

    printf "\n"

    # Replace the machine host file
    #sshpass -p $pword ssh $id@$ip_target  "sudo cp -f --backup=t $hostfilename /etc/hosts"

    printf "Copying $FILE_UPDATE_HOSTS to $ip_target...\n"
    sshpass -p $pword scp $FILE_UPDATE_HOSTS $id@$ip_target:
    
    sshpass -p $pword ssh $id@$ip_target "chmod +x $FILE_UPDATE_HOSTS"

    printf "Updating host names on $ip_target...\n"
    sshpass -p $pword ssh $id@$ip_target "sudo ./$FILE_UPDATE_HOSTS"
done


# for ((i=0; i<$length; i++));
# do
#     new_host_name=${filearray[i*6+3]}
#     ip_target="${filearray[i*6+2]}"
        
#     # if [ "${filearray[i*6+2]}" == "$ip_addr_me" ] ; then
        
#     #     host_name=hostname
#     #     # Working on the Master - Set the hostname
#     #     printf "Updating host names locally...\n\n"

#     #     chmod +x "$FILE_UPDATE_HOSTS"
#     #     sudo "./$FILE_UPDATE_HOSTS"
#     #     sudo sed -i -e "s/$host_name/$new_host_name/g" $FILE_HOSTNAME

#     # else         
#         host_name=$(sshpass -p $pword ssh $id@$ip_target hostname)

#         printf "Modifying $host_name to $new_host_name...\n"
#         sshpass -p $pword ssh $id@$ip_target sudo sed -i -e "s/$host_name/$new_host_name/g" $FILE_HOSTNAME

#         printf "Copying $FILE_UPDATE_HOSTS to $ip_target...\n"
#         sshpass -p $pword scp $FILE_UPDATE_HOSTS $id@$ip_target:
        
#         sshpass -p $pword ssh $id@$ip_target "chmod +x $FILE_UPDATE_HOSTS"

#         printf "Updating host names on $ip_target...\n"
#         sshpass -p $pword ssh $id@$ip_target "sudo ./$FILE_UPDATE_HOSTS"
#     #fi

#     # IP Address: ${filearray[i*6+2]}
#     # Host Name:  ${filearray[i*6+3]}
# done

#printf "Rebooting workers!"
#for ((i=0; i<$length; i++));
#do
#    if [ "${filearray[i*6+2]}" != "$ip_addr_me" ] ; then
#        ip_target="${filearray[i*6+2]}"
#        sshpass -p $pword ssh $id@$ip_target "sudo reboot"
#    fi
#done

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

# Write to ~/.bash_profile to script the next step in the process

# sudo echo "#/!bin/bash" >> ~/.bash_profile
# sudo echo "cd RaspberryPiraeus/src/automation/"
# sudo echo "chmod +x master_install_1.sh"
# sudo echo "./master_install_1.sh"


# sudo reboot