#!/bin/bash
 
. _check_root.sh

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

    printf "copy /etc/hosts\n"

    if [ $ip_target = $ip_addr_me ]
    then
        sudo cp $FILE_HOSTS $localhostsfile
        printf "done: cp $FILE_HOSTS\n"
    else
        # Copy machine host file to local host file
        sudo sshpass -p $pword sudo scp "$piid@$ip_target:$FILE_HOSTS" $localhostsfile
    fi

    if ! test -f $localhostsfile; then
        cp -f _hosts.data $localhostsfile
    fi

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

    # Execute the script to add the host IP/Names
    j=0
    while [ $j -lt $length ]
    do
        ip_to_add=$(echo $cluster_data | jq --raw-output ".[$j].IP") 
        host_to_add=$(echo $cluster_data | jq --raw-output ".[$j].name")

        if [ $ip_target != $ip_to_add ]
        then

            sudo echo "$ip_to_add  $host_to_add" >> $localhostsfile

            # Indicate that work is being done
            printf "-"
        fi

        ((j++))
    done


    # Remove the redundant entry in the hosts file
    sudo sed -i -e "/$ip_target/d" $localhostsfile
    
    printf "."


    if [ $ip_target = $ip_addr_me ]
    then
        # Replace the machine hosts/hostname files
        sudo rm -f $FILE_HOSTS
        sudo rm -f $FILE_HOSTNAME

        printf "."

        sudo mv -f $localhostsfile  $FILE_HOSTS
        sudo mv -f $localhostnamefile  $FILE_HOSTNAME

        printf "."
    else
        # Replace the machine hosts/hostname files
        
        sudo sshpass -p $pword sudo scp $localhostnamefile  $piid@$ip_target:
        sudo sshpass -p $pword sudo scp $localhostsfile  $piid@$ip_target:

        printf "."

        sshpass -p $pword ssh $piid@$ip_target "sudo rm -f $FILE_HOSTS"
        sshpass -p $pword ssh $piid@$ip_target "sudo mv -f $localhostsfile $FILE_HOSTS"

        printf "."

        sshpass -p $pword ssh $piid@$ip_target "sudo rm -f $FILE_HOSTNAME"
        sshpass -p $pword ssh $piid@$ip_target "sudo mv -f $localhostnamefile $FILE_HOSTNAME"

        printf "."
    fi


    printf "!\n\n"
    
done

. _worker_reboot.sh

