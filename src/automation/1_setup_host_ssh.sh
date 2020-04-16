#!/bin/bash

. _config_file.sh

print_instruction " _______ _______ _______ _     _  _____       _     _  _____  _______ _______"
print_instruction " |______ |______    |    |     | |_____]      |_____| |     | |______    |"
print_instruction " ______| |______    |    |_____| |            |     | |_____| ______|    |\n"

print_instruction " _______ _______ _     _"
print_instruction " |______ |______ |_____|"
print_instruction " ______| ______| |     |\n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

printf "Setting up SSH.\n\n"

# Set up SSH keys
ssh-keygen -t rsa -b 2048 -f /home/$piid/.ssh/id_rsa -N ""
sudo chown -R $piid /home/$piid/.ssh/

printf "Done creating SSH Keys.\n\n"

printf "${CYAN}>> Setting up host names and IP's.${NC}\n\n"
# Clean up the hosts file before attempting to update with current information

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]; then
        sudo sshpass -p $pword ssh -o "StrictHostKeyChecking=no" $piid@$ip_target sudo mkdir /home/pi/.ssh/
        sudo sshpass -p $pword ssh $piid@$ip_target sudo chown pi /home/pi/.ssh/
        sudo sshpass -p $pword scp -p -r /home/pi/.ssh/id_rsa.pub $piid@$ip_target:/home/pi/.ssh/authorized_keys
    fi

    printf "\n${CYAN}>> Updating the hosts and hostname files on $ip_target.${NC}\n\n"
    # Delete the local host files (quietly - they may not exist)
    sudo rm -f $localhostsfile > /dev/null 2>&1
    sudo rm -f $localhostnamefile > /dev/null 2>&1

    printf "${CYAN}>> copy /etc/hosts${NC}\n"

    if [ $ip_target = $ip_addr_me ]
    then
        sudo cp $FILE_HOSTS $localhostsfile
        printf "done: cp $FILE_HOSTS\n"
    else
        # Copy machine host file to local host file
        #sudo sshpass -p $pword scp "$piid@$ip_target:$FILE_HOSTS" $localhostsfile
        scp "$piid@$ip_target:$FILE_HOSTS" $localhostsfile
    fi

    if ! test -f $localhostsfile; then
        cp -f _hosts.data $localhostsfile
    fi

    sudo chown $piid $localhostsfile
    sed -i -e "/127.0.1.1/d" $localhostsfile

    echo "127.0.1.1    $new_host_name" >> $localhostsfile

    # Create the hostname file (to be copied to the remote machine's /etc/ folder)
    echo "$new_host_name" > $localhostnamefile

    j=0
    while [ $j -lt $length ]
    do
        ip_to_change=$(echo $cluster_data | jq --raw-output ".[$j].IP")

        # Indicate that work is being done
        printf "."

        # Delete the lines containing the IP address
        sed -i -e "/$ip_to_change/d" $localhostsfile

        if [ $ip_target != $ip_to_change ]; then

            host_to_add=$(echo $cluster_data | jq --raw-output ".[$j].name")

            echo "$ip_to_change  $host_to_add" >> $localhostsfile

            # Indicate that work is being done
            printf "-"
        fi

        ((j++))
    done

    # Remove the redundant entry in the hosts file
    sed -i -e "/$ip_target/d" $localhostsfile

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

        #sudo sshpass -p $pword sudo scp $localhostnamefile  $piid@$ip_target:
        #sudo sshpass -p $pword sudo scp $localhostsfile  $piid@$ip_target:
        sudo scp $localhostnamefile  $piid@$ip_target:
        sudo scp $localhostsfile  $piid@$ip_target:

        printf "."

        #sshpass -p $pword ssh $piid@$ip_target "sudo rm -f $FILE_HOSTS"
        #sshpass -p $pword ssh $piid@$ip_target "sudo mv -f $localhostsfile $FILE_HOSTS"
        ssh $piid@$ip_target "sudo rm -f $FILE_HOSTS"
        ssh $piid@$ip_target "sudo mv -f $localhostsfile $FILE_HOSTS"

        printf "."

        #sshpass -p $pword ssh $piid@$ip_target "sudo rm -f $FILE_HOSTNAME"
        #sshpass -p $pword ssh $piid@$ip_target "sudo mv -f $localhostnamefile $FILE_HOSTNAME"
        ssh $piid@$ip_target "sudo rm -f $FILE_HOSTNAME"
        ssh $piid@$ip_target "sudo mv -f $localhostnamefile $FILE_HOSTNAME"

        printf "."
    fi

    printf "!\n\n"

done

. _worker_reboot.sh

