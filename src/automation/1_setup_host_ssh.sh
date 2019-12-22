#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh



# Step through all remote nodes and create an SSH key transfer
for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_addr_me != $ip_target ] ; then
        printf "${LBLU}Attempting to synch ssh data for host: $host_target/$ip_target${NC}\n\n"

        # Attempt a copy to force the key transfer/password challenge
        sudo scp $piid@$ip_target:/etc/hosts tmp.tmp
        rm -f tmp.tmp > /dev/null 2>&1
    fi
done

printf "Done setting up SSH.\n\n"

printf "${LBLU}>> Setting up host names and IP's.${NC}\n\n"
# Clean up the hosts file before attempting to update with current information

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    printf "\n${LBLU}>> Updating the hosts and hostname files on $ip_target.${NC}\n\n"
    # Delete the local host files (quietly - they may not exist)
    sudo rm -f $localhostsfile > /dev/null 2>&1
    sudo rm -f $localhostnamefile > /dev/null 2>&1

    printf "${LBLU}>> copy /etc/hosts${NC}\n"

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

