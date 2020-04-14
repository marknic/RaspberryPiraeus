#!/bin/bash

. _config_file.sh

print_instruction "  _____         _             "
print_instruction " |_   _|__  ___| |_           "
print_instruction "   | |/ _ \/ __| __|          "
print_instruction "   | |  __/\__ \ |_           "
print_instruction "   |_|\___||___/\__|          "
print_instruction "  ____            _       _   "
print_instruction " / ___|  ___ _ __(_)_ __ | |_ "
print_instruction " \___ \ / __| '__| | '_ \| __|"
print_instruction "  ___) | (__| |  | | |_) | |_ "
print_instruction " |____/ \___|_|  |_| .__/ \__|"
print_instruction "                   |_|       \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]; then
        #sshpass -p $pword ssh-copy-id -i /home/$piid/.ssh/id_rsa.pub $piid@$ip_target

        sshpass -p $pword ssh -o "StrictHostKeyChecking=no" $piid@$ip_target sudo mkdir /home/pi/.ssh/
        sshpass -p $pword ssh $piid@$ip_target sudo chown pi /home/pi/.ssh/
        sshpass -p $pword scp -p -r .ssh/id_rsa.pub $piid@$ip_target:/home/pi/.ssh/authorized_keys
    fi


done

print_instruction "\nDone!\n"

#. _worker_reboot.sh