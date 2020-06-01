#!/bin/bash

. _config_file.sh

print_instruction "  ____                                           "
print_instruction " |  _ \ ___ _ __ ___   _____   _____             "
print_instruction " | |_) / _ \ !_ ! _ \ / _ \ \ / / _ \            "
print_instruction " |  _ <  __/ | | | | | (_) \ V /  __/            "
print_instruction " |_| \_\___|_| |_| |_|\___/ \_/ \___|            "
print_instruction "  ____                       _____ _ _           "
print_instruction " / ___|_      ____ _ _ __   |  ___(_) | ___      "
print_instruction " \___ \ \ /\ / / _! | !_ \  | |_  | | |/ _ \     "
print_instruction "  ___) \ V  V / (_| | |_) | |  _| | | |  __/     "
print_instruction " |____/ \_/\_/ \__,_| .__/  |_|   |_|_|\___|     "
print_instruction "                    |_|                        \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

result=0
print_instruction "Clean, Update and Upgrade\n"
sudo apt-get clean
if [ $? -ne 0 ]; then result=1; fi
sudo apt-get --fix-missing update
if [ $? -ne 0 ]; then result=1; fi
sudo apt-get -y --fix-missing upgrade
if [ $? -ne 0 ]; then result=1; fi

if [ $result -eq 1 ]; then print_instruction "$RED Clean, Update and Upgrade FAILED.$NC"; fi

print_instruction "Removing the swap file on $ip_addr_me\n"
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

    if [ $ip_target != $ip_addr_me ]
    then

        host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

        print_instruction "Processing $host_target/$ip_target:"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade

        # Run this code across all machines
        print_instruction "dphys-swapfile swapoff ($ip_target:$new_host_name)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile swapoff > /dev/null 2>&1
        print_result $?

        print_instruction "dphys-swapfile uninstall ($ip_target:$new_host_name)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile uninstall > /dev/null 2>&1
        print_result $?

        print_instruction "apt-get -y purge dphys-swapfile ($ip_target:$new_host_name)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y purge dphys-swapfile > /dev/null 2>&1
        print_result $?

        print_instruction "apt-get -y autoremove ($ip_target:$new_host_name)..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y autoremove > /dev/null 2>&1
        print_result $?
    fi
done

. _worker_reboot.sh
