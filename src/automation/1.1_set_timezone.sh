#!/bin/bash

. _config_file.sh

print_instruction "  ____       _                                   "
print_instruction " / ___|  ___| |_                                 "
print_instruction " \___ \ / _ \ __|                                "
print_instruction "  ___) |  __/ |_                                 "
print_instruction " |____/ \___|\__|                                "
print_instruction "  _____ _                                        "
print_instruction " |_   _(_)_ __ ___   ___ _______  _ __   ___     "
print_instruction "   | | | | !_ ! _ \ / _ \_  / _ \| !_ \ / _ \    "
print_instruction "   | | | | | | | | |  __// / (_) | | | |  __/    "
print_instruction "   |_| |_|_| |_| |_|\___/___\___/|_| |_|\___|  \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

# Set Local time on the Master RPi (Optional)
print_instruction "Setting up local time (master)..."
    execute_command_with_retry "sudo timedatectl set-timezone "'"'$zonelocation'"'
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
        # Set Local time on the worker RPi (Optional)
        print_instruction "Setting up local time ($ip_target:$new_host_name)..."
            execute_remote_command_with_retry "sudo timedatectl set-timezone "'"'$zonelocation'"'
        print_result $?

        print_instruction "dpkg-reconfigure..."
            execute_remote_command_with_retry "timedatectl status"
        print_result $?
    fi

done


print_instruction "\nDone!\n"


