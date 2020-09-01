#!/bin/bash

. _config_file.sh

print_instruction "  ____       _                   "
print_instruction " / ___|  ___| |_ _   _ _ __      "
print_instruction " \___ \ / _ \ __| | | | !_ \     "
print_instruction "  ___) |  __/ |_| |_| | |_) |    "
print_instruction " |____/ \___|\__|\__,_| .__/     "
print_instruction "  ____ ____  _   _    |_|        "
print_instruction " / ___/ ___|| | | |              "
print_instruction " \___ \___ \| |_| |              "
print_instruction "  ___) |__) |  _  |              "
print_instruction " |____/____/|_| |_|            \n"

. _check_root.sh

. _array_setup.sh

. _package_check.sh

get_ip_host_and_platform 0

master_piid=$user_id
master_password=$user_password

printf "\n\n"

print_instruction "Setup SSH"
print_instruction "Setting up SSH to communicate with the workers.\n"
print_instruction "Master: $master_piid - $ip_target  --  Platform: $platform_target\n"


# ssh folder
test -d ~/.ssh/

if [ $? -ne 0 ]
then
    print_instruction "Create SSH keys..."
        mkdir ~/.ssh/
    print_result $?

    print_instruction "Done creating SSH folder.\n\n"
fi


# Only check/create SSH keys on the Master
test -f ~/.ssh/id_rsa.pub

if [ $? -ne 0 ]
then
    # # Set up SSH keys
    print_instruction "Create SSH keys..."
        ssh-keygen -t rsa -b 2048 -f /home/$master_piid/.ssh/id_rsa -N ""
    print_result $?

    print_instruction "Done creating SSH Keys.\n\n"
fi


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    get_ip_host_and_platform $i

    callLocation="-r"



    # # Do this locally
    # print_instruction "Deleting $localhostsfile so it can be recreated.\n"
    # rm -f $localhostsfile > /dev/null 2>&1
    # print_instruction "Deleting $localhostnamefile so it can be recreated.\n"
    # rm -f $localhostnamefile > /dev/null 2>&1



    # cp $FILE_HOSTS $localhostsfile

    execute_command $callLocation -1 "test -d /home/$user_id/.ssh/"

    if [ $? -ne 0 ]
    then
        sudo sshpass -p $user_password ssh -o "StrictHostKeyChecking=no" $user_id@$ip_target "sudo mkdir /home/$user_id/.ssh/"
        execute_command $callLocation -1 "sudo chown -R $user_id /home/$user_id/.ssh/"
    fi

    print_instruction "Copying the SSH public key from the master to the worker.\n"
        sudo sshpass -p $user_password ssh $user_id@$ip_target "rm -f /home/$user_id/.ssh/authorized_key"

        sudo sshpass -p $user_password scp -p -r ~/.ssh/id_rsa.pub $user_id@$ip_target:/home/$user_id/.ssh/authorized_key

        sudo sshpass -p $user_password ssh $user_id@$ip_target "cat ~/.ssh/authorized_key | tee -a /home/$user_id/.ssh/authorized_keys"
    print_result $?

    execute_command $callLocation -1 "sudo apt-get update"
    if [ $? -ne 0 ]; then result=1; fi

    execute_command $callLocation -1 "sudo apt-get -y dist-upgrade"
    if [ $? -ne 0 ]; then result=1; fi

    if [ $result -eq 1 ]; then print_instruction "$RED Update or Upgrade FAILED.$NC"; fi


    print_instruction "Setting up the local hosts file\n"


    # FILE_HOSTNAME="/etc/hostname"
    # FILE_HOSTS="/etc/hosts"
    

    rm -f $localhostsfile    > /dev/null 2>&1
    rm -f $localhostnamefile > /dev/null 2>&1

    # Create the hostname file (to be copied to the remote machine's /etc/ folder)
    echo "$host_target" > $localhostnamefile
    
    sudo sshpass -p $user_password scp $user_id@$ip_target:$FILE_HOSTS $localhostsfile
    
    # Remove the line with 127.0.1.1 in it
    sed -i -e "/127.0.1.1/d" $localhostsfile

    # Replace the removed line with the updated line
    echo "127.0.1.1       $host_target" >> $localhostsfile

    print_instruction "Adding worker hosts to the current hosts file."
    for ((j=0; j<$length; j++));
    do
        ip_to_change=$(echo $cluster_data | jq --raw-output ".[$j].IP")

        if [ $ip_target != $ip_to_change ]; then

            host_to_add=$(echo $cluster_data | jq --raw-output ".[$j].name")

            echo "$ip_to_change   $host_to_add" >> $localhostsfile
        fi
    done

    print_instruction "Copy the host files over to the worker(s)."
    sshpass -p $user_password scp $localhostnamefile  $user_id@$ip_target:
    print_result $?
    sshpass -p $user_password scp $localhostsfile     $user_id@$ip_target:
    print_result $?

    print_instruction "Remove the existing host files."
    sshpass -p $user_password ssh $user_id@$ip_target sudo rm -f $FILE_HOSTS
    print_result $?
    sshpass -p $user_password ssh $user_id@$ip_target sudo rm -f $FILE_HOSTNAME
    print_result $?

    print_instruction "Move the new host files into /etc/.\n"
    sshpass -p $user_password ssh $user_id@$ip_target sudo mv -f $localhostsfile    $FILE_HOSTS
    print_result $?
    sshpass -p $user_password ssh $user_id@$ip_target sudo mv -f $localhostnamefile $FILE_HOSTNAME
    print_result $?

done

print_instruction "\nDone!\n"

