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

. _array_setup.sh

. _package_check.sh


for ((i=0; i<$length; i++));
do

    get_ip_host_and_platform $i

    if [ $ip_target == $ip_addr_me ]; then callLocation="-l"; else callLocation="-r"; fi

    result=0
    print_instruction "Update and Upgrade\n"

    execute_command $callLocation -1 "sudo apt-get update"
    if [ $? -ne 0 ]; then result=1; fi

    execute_command $callLocation -1 "sudo apt-get -y --fix-missing upgrade"
    if [ $? -ne 0 ]; then result=1; fi

    if [ $result -eq 1 ]; then print_instruction "$RED Clean, Update and Upgrade FAILED.$NC"; fi

    execute_command $callLocation -1 "swapmem=$(grep SwapTotal /proc/meminfo | awk '{ print $2}')"

    if [ $swapmem -gt 0 ]
    then
        if [ platform_target == $PLATFORM_PI ]
        then
            # Raspbian
            print_instruction "Removing the swap file on $ip_addr_me\n"
            print_instruction "dphys-swapfile swapoff (master)..."
                execute_command $callLocation -1 "sudo dphys-swapfile swapoff"
            print_result $?

            print_instruction "dphys-swapfile uninstall (master)..."
                execute_command $callLocation -1 "sudo dphys-swapfile uninstall"
            print_result $?

            print_instruction "apt-get -y purge dphys-swapfile (master)..."
                execute_command $callLocation -1 "sudo apt-get -y purge dphys-swapfile"
            print_result $?

            print_instruction "apt-get -y autoremove (master)..."
                execute_command $callLocation -1 "sudo apt-get -y autoremove"
            print_result $?
        else
            # Ubuntu
            print_instruction "Turning swap file off ($ip_target:$host_target)..."
                execute_command $callLocation -1 "sudo swapoff -a -v"
            print_result $?

            print_instruction "Removing swapfile..."
                execute_command $callLocation -1 "sudo rm /swapfile"
            print_result $?

            print_instruction "Making backup copy of /etc/fstab file..."
                execute_command $callLocation -1 "sudo cp /etc/fstab /etc/fstab.bak"
            print_result $?

            print_instruction "Removing swapfile setting in /etc/fstab..."
                execute_command $callLocation -1 "sudo sed -i '/\/swapfile/d' /etc/fstab"
            print_result $?
        fi

    fi

done

. _worker_reboot.sh
