#!/bin/bash

. _config_file.sh

print_instruction " _______ _______ _______ _     _  _____    "
print_instruction " |______ |______    |    |     | |_____]   "
print_instruction " ______| |______    |    |_____| |       \n"
print_instruction " _______ _______ _     _   "
print_instruction " |______ |______ |_____|   "
print_instruction " ______| ______| |     | \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

print_instruction "Setting up SSH to communicate with the workers.\n"

# # Set up SSH keys
print_instruction "apt-get --fix-missing update..."
    ssh-keygen -t rsa -b 2048 -f /home/$piid/.ssh/id_rsa -N ""
print_result $?

sudo chown -R $piid /home/$piid/.ssh/

print_instruction "Done creating SSH Keys.\n\n"

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    print_instruction "Deleting $localhostsfile so it can be recreated.\n"
    rm -f $localhostsfile > /dev/null 2>&1
    print_instruction "Deleting $localhostnamefile so it can be recreated.\n"
    rm -f $localhostnamefile > /dev/null 2>&1

    # Create the hostname file (to be copied to the remote machine's /etc/ folder)
    echo "$new_host_name" > $localhostnamefile

    if [ $ip_target == $ip_addr_me ]; then
        cp $FILE_HOSTS $localhostsfile
    else

        sudo sshpass -p $pword ssh -o "StrictHostKeyChecking=no" $piid@$ip_target sudo mkdir /home/$piid/.ssh/
        sudo sshpass -p $pword ssh $piid@$ip_target sudo chown -R $piid /home/$piid/.ssh/

        print_instruction "Copying the SSH public key from the master to the worker.\n"
            sudo sshpass -p $pword scp -p -r /home/$piid/.ssh/id_rsa.pub $piid@$ip_target:/home/$piid/.ssh/authorized_keys
        print_result $?

        print_instruction "Copying hosts file to worker.\n"
            sshpass -p $pword scp "$piid@$ip_target:$FILE_HOSTS" $localhostsfile
        print_result $?


        print_instruction "apt-get clean on worker: $ip_target.\n"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean
        print_result $?

        print_instruction "apt-get update on worker: $ip_target.\n"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        print_result $?

        print_instruction "apt-get upgrade on worker: $ip_target.\n"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade
        print_result $?

    fi

    print_instruction "Setting up the local hosts file\n"

    # Remove the line with 127.0.1.1 in it
    sed -i -e "/127.0.1.1/d" $localhostsfile

    # Replace the removed line with the updated line
    echo "127.0.1.1       $new_host_name" >> $localhostsfile

    print_instruction "Adding worker hosts to the current hosts file."
    for ((j=0; j<$length; j++));
    do
        ip_to_change=$(echo $cluster_data | jq --raw-output ".[$j].IP")

        if [ $ip_target != $ip_to_change ]; then

            host_to_add=$(echo $cluster_data | jq --raw-output ".[$j].name")

            echo "$ip_to_change   $host_to_add" >> $localhostsfile
        fi
    done

    if [ $ip_target == $ip_addr_me ]; then
        print_instruction "Copy the host files..."
        sudo cp -f $localhostsfile     $FILE_HOSTS
        print_result $?
        sudo cp -f $localhostnamefile  $FILE_HOSTNAME
        print_result $?
    else

        print_instruction "Copy the host files over to the worker(s)."
        sshpass -p $pword scp $localhostnamefile  $piid@$ip_target:
        print_result $?
        sshpass -p $pword scp $localhostsfile     $piid@$ip_target:
        print_result $?

        print_instruction "Remove the existing host files."
        sshpass -p $pword ssh $piid@$ip_target sudo rm -f $FILE_HOSTS
        print_result $?
        sshpass -p $pword ssh $piid@$ip_target sudo rm -f $FILE_HOSTNAME
        print_result $?

        print_instruction "Move the new host files into /etc/.\n"
        sshpass -p $pword ssh $piid@$ip_target sudo mv -f $localhostsfile    $FILE_HOSTS
        print_result $?
        sshpass -p $pword ssh $piid@$ip_target sudo mv -f $localhostnamefile $FILE_HOSTNAME
        print_result $?

    fi

done


print_instruction "\nDone!\n"

. _worker_reboot.sh