#!/bin/bash

. _config_file.sh

print_instruction " _______  _____  __   _ _______ _____  ______"
print_instruction " |       |     | | \  | |______   |   |  ____"
print_instruction " |_____  |_____| |  \_| |       __|__ |_____|\n"
print_instruction " ______   _____   _____  _______"
print_instruction " |_____] |     | |     |    |"
print_instruction " |_____] |_____| |_____|    |\n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

sudo apt-get clean
sudo apt-get --fix-missing update
sudo apt-get -y --fix-missing upgrade

printf "\nAdding cgroup settings to $CMDLINE_TXT file\n"

if [ ! -f $CMDLINE_TXT_BACKUP ]; then
    print_instruction "Making backup of cmdline.txt -> cmdline_backup.txt"
    sudo cp $CMDLINE_TXT $CMDLINE_TXT_BACKUP
fi

grep $CGROUP -f $CMDLINE_TXT
if [ $? -ne 0 ]; then
    echo "$(head -n1 $CMDLINE_TXT) $CGROUP" | sudo tee $CMDLINE_TXT
fi

printf "\nRemoving the swap file on $ip_addr_me\n"
print_instruction "dphys-swapfile swapoff (master)..."
    sudo dphys-swapfile swapoff
print_result $?

print_instruction "dphys-swapfile uninstall (master)..."
    sudo dphys-swapfile uninstall
print_result $?

print_instruction "apt-get -y purge dphys-swapfile (master)..."
    sudo apt-get -y purge dphys-swapfile
print_result $?


print_instruction "apt-get -y autoremove (master)..."
    sudo apt-get -y autoremove
print_result $?


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    printf "\n\n-----------\n"
    printf "Configuring $host_target/$ip_target\n\n"

    if [ $ip_target != $ip_addr_me ]
    then

        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade

        sudo sshpass -p $pword ssh $piid@$ip_target test -f $CMDLINE_TXT_BACKUP

        if [ $? -ne 0 ]; then
            print_instruction "Making backup of cmdline.txt -> cmdline_backup.txt"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo cp $CMDLINE_TXT $CMDLINE_TXT_BACKUP
        fi

        # if the cgroup text does not exist in the cmdline.txt file, add it
        sudo sshpass -p $pword ssh $piid@$ip_target grep -i $CGROUP_TEST $CMDLINE_TXT

        if [ $? -ne 0 ]; then
            sudo sshpass -p $pword ssh $piid@$ip_target "echo "$(head -n1 $CMDLINE_TXT) $CGROUP" | sudo tee $CMDLINE_TXT"
        fi

        # Run this code across all machines
        printf "Removing swapfile on $ip_target.\n"
        print_instruction "dphys-swapfile swapoff (master)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile swapoff > /dev/null 2>&1
        print_result $?

        print_instruction "dphys-swapfile uninstall (master)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile uninstall > /dev/null 2>&1
        print_result $?

        print_instruction "apt-get -y purge dphys-swapfile (master)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y purge dphys-swapfile > /dev/null 2>&1
        print_result $?

        print_instruction "apt-get -y autoremove (master)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y autoremove > /dev/null 2>&1
        print_result $?
    fi
done

. _worker_reboot.sh
