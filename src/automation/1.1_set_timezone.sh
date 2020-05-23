#!/bin/bash

. _config_file.sh

print_instruction " ____ ____ ___"
print_instruction " [__  |___  | "
print_instruction " ___] |___  | "
print_instruction " _______ _____ _______ _______ ______  _____  __   _ _______"
print_instruction "    |      |   |  |  | |______  ____/ |     | | \  | |______"
print_instruction "    |    __|__ |  |  | |______ /_____ |_____| |  \_| |______\n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

# Set Local time on the RPi (Optional)
print_instruction "Setting up local time (master)..."
    execute_command_with_retry "timedatectl set-timezone "'"'$zonelocation'"'
print_result $?

print_instruction "timedatectl status..."
    execute_command_with_retry "timedatectl status"
print_result $?

 
for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]; then
        # Set Local time on the RPi (Optional)
        print_instruction "Setting up local time ($ip_target:$new_host_name)..."
            execute_remote_command_with_retry "timedatectl set-timezone "'"'$zonelocation'"'
        print_result $?

        print_instruction "dpkg-reconfigure..."
            execute_remote_command_with_retry "timedatectl status"
        print_result $?
    fi

done


print_instruction "\nDone!\n"

. _worker_reboot.sh
