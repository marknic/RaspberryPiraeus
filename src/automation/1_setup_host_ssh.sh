#!/bin/bash

. _config_file.sh

print_instruction " ____ ____ ___ _  _ ___"
print_instruction " [__  |___  |  |  | |__]"
print_instruction " ___] |___  |  |__| |"
print_instruction " ____ ____ _  _"
print_instruction " [__  [__  |__|"
print_instruction " ___] ___] |  |\n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

# Set Local time on the RPi (Optional)
print_instruction "Setting up local time (master)..."
    sudo ln -fs /usr/share/zoneinfo/$zonelocation /etc/localtime
print_result $?

print_instruction "dpkg-reconfigure..."
    sudo dpkg-reconfigure --frontend noninteractive tzdata
print_result $?

printf "Setting up SSH to communicate with the workers.\n"

# # Set up SSH keys
print_instruction "apt-get --fix-missing update..."
    ssh-keygen -t rsa -b 2048 -f /home/$piid/.ssh/id_rsa -N ""
print_result $?

sudo chown -R $piid /home/$piid/.ssh/

printf "Done creating SSH Keys.\n\n"


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

        # Set Local time on the RPi (Optional)
        print_instruction "Setting up local time ($ip_target:$new_host_name)..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo ln -fs /usr/share/zoneinfo/$zonelocation /etc/localtime"
        print_result $?

        print_instruction "dpkg-reconfigure..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo dpkg-reconfigure --frontend noninteractive tzdata"
        print_result $?

        sudo sshpass -p $pword ssh -o "StrictHostKeyChecking=no" $piid@$ip_target sudo mkdir /home/$piid/.ssh/
        sudo sshpass -p $pword ssh $piid@$ip_target sudo chown -R $piid /home/$piid/.ssh/

        print_instruction "Copying the SSH public key from the master to the worker.\n"
            sudo sshpass -p $pword scp -p -r /home/$piid/.ssh/id_rsa.pub $piid@$ip_target:/home/$piid/.ssh/authorized_keys
        print_result $?

        print_instruction "Copying hosts file to worker.\n"
            sshpass -p $pword scp "$piid@$ip_target:$FILE_HOSTS" $localhostsfile
        print_result $?
    fi

    printf "Setting up the local hosts file\n"

    # Remove the line with 127.0.1.1 in it
    sed -i -e "/127.0.1.1/d" $localhostsfile

    # Replace the removed line with the updated line
    echo "127.0.1.1       $new_host_name" >> $localhostsfile

    print_instruction "Adding other cluster hosts to the current hosts file."
    for ((j=0; j<$length; j++));
    do
        ip_to_change=$(echo $cluster_data | jq --raw-output ".[$j].IP")

        if [ $ip_target != $ip_to_change ]; then

            host_to_add=$(echo $cluster_data | jq --raw-output ".[$j].name")

            echo "$ip_to_change   $host_to_add" >> $localhostsfile
        fi
    done

    if [ $ip_target == $ip_addr_me ]; then
        sudo rm -f $FILE_HOSTS
        sudo rm -f $FILE_HOSTNAME

        sudo mv -f $localhostsfile     $FILE_HOSTS
        sudo mv -f $localhostnamefile  $FILE_HOSTNAME
    else
        print_instruction "Copy the host files over to the worker(s)."
        sshpass -p $pword scp $localhostnamefile  $piid@$ip_target:
        sshpass -p $pword scp $localhostsfile     $piid@$ip_target:

        print_instruction "Remove the existing host files."
        sshpass -p $pword ssh $piid@$ip_target sudo rm -f $FILE_HOSTS
        sshpass -p $pword ssh $piid@$ip_target sudo rm -f $FILE_HOSTNAME

        print_instruction "Move the new host files into /etc/.\n"
        sshpass -p $pword ssh $piid@$ip_target sudo mv -f $localhostsfile    $FILE_HOSTS
        sshpass -p $pword ssh $piid@$ip_target sudo mv -f $localhostnamefile $FILE_HOSTNAME
    fi

done


print_instruction "\nDone!\n"

. _worker_reboot.sh
