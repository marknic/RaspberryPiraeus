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

printf "Setting up SSH.\n\n"

# Set up SSH keys
ssh-keygen -t rsa -b 2048 -f /home/$piid/.ssh/id_rsa -N ""
sudo chown -R $piid /home/$piid/.ssh/

printf "Done creating SSH Keys.\n\n"

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]; then
        sudo sshpass -p $pword ssh -o "StrictHostKeyChecking=no" $piid@$ip_target sudo mkdir /home/$piid/.ssh/
        sudo sshpass -p $pword ssh $piid@$ip_target sudo chown -R $piid /home/$piid/.ssh/
        sudo sshpass -p $pword scp -p -r /home/$piid/.ssh/id_rsa.pub $piid@$ip_target:/home/$piid/.ssh/authorized_keys
    fi
done

print_instruction "\nDone!\n"

#. _worker_reboot.sh