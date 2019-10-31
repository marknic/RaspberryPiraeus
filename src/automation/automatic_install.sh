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

    if [ "${linearray[5]}" == "hosts.local" ] ; then
        filearray+=($cleanline)
    fi
done < "$FILE_UPDATE_HOSTS"


let length="${#filearray[@]} / 6"

printf "Array Length: $length\n"

# Clean up the hosts file before attempting to update with current information
hostfilename="hostfile.txt"
tmp_hostfilename="$hostfilename.bak"

localhostsfile="hosts.local"
localhostnamefile="hostname.local"

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target="${filearray[i*6+2]}"
    new_host_name="${filearray[i*6+3]}"

    printf "\nUpdating the hosts and hostname files on $ip_target\n\n"

    # Delete the local host files (quietly - they may not exist)
    sudo rm -f $localhostsfile > /dev/null 2>&1
    sudo rm -f $localhostnamefile > /dev/null 2>&1

    # Copy machine host file to local host file
    sshpass -p $pword sudo scp "$id@$ip_target:/etc/hosts" $localhostsfile

    # Get the host
    # host_name=$(sshpass -p $pword ssh $id@$ip_target hostname)

    sudo sed -i -e "/127.0.1.1/d" $localhostsfile

    sudo echo "127.0.1.1    $new_host_name" >> $localhostsfile

    # Create the hostname file (to be copied to the remote machine's /etc/ folder)
    sudo echo "$new_host_name" > $localhostnamefile

    j=0
    while [ $j -lt $length ]
    do
        ip_to_remove="${filearray[j*6+2]}"

        # Indicate that work is being done
        printf "."

        # Delete the lines containing the IP address
        sudo sed -i -e "/$ip_to_remove/d" $localhostsfile

        ((j++))
    done

    # Make the update script executable
    sudo chmod +x $FILE_UPDATE_HOSTS

    # Execute the script to add the host IP/Names
    sudo ./$FILE_UPDATE_HOSTS

    # Remove the redundant entry in the hosts file
    sudo sed -i -e "/$ip_target/d" $localhostsfile
    
    printf "."

    # Replace the machine hosts/hostname files
    sudo sshpass -p $pword sudo scp $localhostsfile  $id@$ip_target:
    sudo sshpass -p $pword sudo scp $localhostnamefile  $id@$ip_target:

    printf "."

    sshpass -p $pword ssh $id@$ip_target "sudo rm -f /etc/hosts"
    sshpass -p $pword ssh $id@$ip_target "sudo mv -f '$localhostsfile' '/etc/hosts'"

    printf "."

    sshpass -p $pword ssh $id@$ip_target "sudo rm -f /etc/hostname"
    sshpass -p $pword ssh $id@$ip_target "sudo mv -f '$localhostnamefile' '/etc/hostname'"

    printf "!\n\n"
    
done


printf "Rebooting workers!"
for ((i=0; i<$length; i++));
do
   if [ "${filearray[i*6+2]}" != "$ip_addr_me" ] ; then
       ip_target="${filearray[i*6+2]}"
       sshpass -p $pword ssh $id@$ip_target "sudo reboot"
   fi
done

printf "Verifying Reboot...\n"

printf "Waiting 25 seconds"
sleep 25

for ((i=0; i<$length; i++));
do
    ip_target="${filearray[i*6+2]}"

    if [ "$ip_target" != "$ip_addr_me" ] ; then

        output='down'

        while [ "$output" != "up" ]
        do
            output=$(sshpass -p $pword ssh $id@$ip_target uptime | awk '{print $2}')

            if [ "$output" != "up" ]
            then
                sleep 8
            else
                echo "$ip_target is back up."
            fi
        done
    fi
done

sudo reboot


# Write to ~/.bash_profile to script the next step in the process

# sudo echo "#/!bin/bash" >> ~/.bash_profile
# sudo echo "cd RaspberryPiraeus/src/automation/"
# sudo echo "chmod +x master_install_1.sh"
# sudo echo "./master_install_1.sh"


# sudo reboot