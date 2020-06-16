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


for ((i=0; i<$length; i++));
do

    get_ip_host_and_platform $i

    if [ $ip_target == $ip_addr_me ]
    then

        result=0
        print_instruction "Update and Upgrade\n"

        sudo apt-get update
        if [ $? -ne 0 ]; then result=1; fi

        sudo apt-get -y --fix-missing upgrade
        if [ $? -ne 0 ]; then result=1; fi

        if [ $result -eq 1 ]; then print_instruction "$RED Clean, Update and Upgrade FAILED.$NC"; fi

        swapmem=$(grep SwapTotal /proc/meminfo | awk '{ print $2}')

        if [ $swapmem -gt 0 ]
        then
            if [ platform_target == $PLATFORM_PI ]
            then
                # Raspbian
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
            else
                # Ubuntu
                print_instruction "Turning swap file off ($ip_target:$host_target)..."
                    sudo swapoff -a -v
                print_result $?

                print_instruction "Removing swapfile..."
                    sudo rm /swapfile
                print_result $?

                print_instruction "Making backup copy of /etc/fstab file..."
                    sudo cp /etc/fstab /etc/fstab.bak
                print_result $?

                print_instruction "Removing swapfile setting in /etc/fstab..."
                    sudo sed -i '/\/swapfile/d' /etc/fstab
                print_result $?
            fi
        fi

    else

        print_instruction "Processing $host_target/$ip_target:"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade

        swapmem=$(sudo sshpass -p $pword ssh $piid@$ip_target "grep SwapTotal /proc/meminfo | awk '{ print $2}')")

        if [ $swapmem -gt 0 ]
        then
            print_instruction "Removing the swap file on $ip_addr_me\n"

            if [ platform_target == $PLATFORM_PI ]
            then
                # Raspbian
                print_instruction "dphys-swapfile swapoff ($ip_target:$host_target)..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile swapoff > /dev/null 2>&1
                print_result $?

                print_instruction "dphys-swapfile uninstall ($ip_target:$host_target)..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile uninstall > /dev/null 2>&1
                print_result $?

                print_instruction "apt-get -y purge dphys-swapfile ($ip_target:$host_target)..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y purge dphys-swapfile > /dev/null 2>&1
                print_result $?

                print_instruction "apt-get -y autoremove ($ip_target:$host_target)..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y autoremove > /dev/null 2>&1
                print_result $?
            else
                # Ubuntu
                print_instruction "Turning swap file off ($ip_target:$host_target)..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo swapoff -a -v
                print_result $?

                print_instruction "Removing swapfile..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo rm /swapfile
                print_result $?

                print_instruction "Making backup copy of /etc/fstab file..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo cp /etc/fstab /etc/fstab.bak
                print_result $?

                print_instruction "Removing swapfile setting in /etc/fstab..."
                    sudo sshpass -p $pword ssh $piid@$ip_target sudo sed -i '/\/swapfile/d' /etc/fstab
                print_result $?
            fi
        fi
    fi
done

. _worker_reboot.sh
