#!/bin/bash
 
. _package_check.sh

. _config_file.sh

. _array_setup.sh

printf "\n"
# Clean up the hosts file before attempting to update with current information

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    printf "\nUpdating the hosts and hostname files on $ip_target\n\n"

    # Delete the local host files (quietly - they may not exist)
    sudo rm -f $localhostsfile > /dev/null 2>&1
    sudo rm -f $localhostnamefile > /dev/null 2>&1

    printf "scp /etc/hosts\n"

    # Copy machine host file to local host file
    sudo sshpass -p $pword sudo scp "$id@$ip_target:/etc/hosts" $localhostsfile

    printf "done: scp /etc/hosts\n"

    sudo sed -i -e "/127.0.1.1/d" $localhostsfile

    sudo echo "127.0.1.1    $new_host_name" >> $localhostsfile

    # Create the hostname file (to be copied to the remote machine's /etc/ folder)
    sudo echo "$new_host_name" > $localhostnamefile

    j=0
    while [ $j -lt $length ]
    do
        ip_to_remove=$(echo $cluster_data | jq --raw-output ".[$j].IP") 

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

    sshpass -p $pword ssh $id@$ip_target "sudo rm -f $FILE_HOSTS"
    sshpass -p $pword ssh $id@$ip_target "sudo mv -f $localhostsfile $FILE_HOSTS"

    printf "."

    sshpass -p $pword ssh $id@$ip_target "sudo rm -f $FILE_HOSTNAME"
    sshpass -p $pword ssh $id@$ip_target "sudo mv -f $localhostnamefile $FILE_HOSTNAME"

    printf "!\n\n"
    
done

. _worker_reboot.sh

