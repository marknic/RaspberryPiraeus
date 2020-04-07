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

sudo apt-get install -y software-properties-common

printf "\nAdding cgroup settings to /boot/cmdline.txt file\n"
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt

sudo apt update && sudo apt -y dist-upgrade

printf "\nRemoving the swap file on $ip_addr_me\n"
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt-get -y purge dphys-swapfile

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    printf "\n\n-----------\n"
    printf "Configuring $host_target/$ip_target\n\n"

    if [ $ip_target != $ip_addr_me ]
    then
        echo "$host_target/$ip_target: Installing package: software-properties-common"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y software-properties-common

        printf "Backing up /boot/cmdline.txt\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

        sudo sshpass -p $pword ssh $piid@$ip_target echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt

                # Run this code across all machines
        printf "Removing swapfile on $host_target.\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile swapoff
        sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile uninstall
        #sudo sshpass -p $pword ssh $piid@$ip_target sudo update-rc.d dphys-swapfile remove
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y purge dphys-swapfile

    fi
done

. _worker_reboot.sh
