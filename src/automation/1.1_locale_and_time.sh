#!/bin/bash

. _config_file.sh

print_instruction "  _   _           _       _          "
print_instruction " | | | |_ __   __| | __ _| |_ ___    "
print_instruction " | | | | !_ \ / _! |/ _! | __/ _ \   "
print_instruction " | |_| | |_) | (_| | (_| | ||  __/   "
print_instruction "  \___/| .__/ \__,_|\__,_|\__\___|   "
print_instruction "  _    |_|             _             "
print_instruction " | |    ___   ___ __ _| | ___        "
print_instruction " | |   / _ \ / __/ _! | |/ _ \       "
print_instruction " | |__| (_) | (_| (_| | |  __/       "
print_instruction " |_____\___/ \___\__,_|_|\___|     \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh


# This script will update the locale settings in Raspbian
# It is necessary to allow some of the later scripting options to work
# See _config_file.sh for the locale values (Old/current & new/to be)

# Comment out the original locale...
print_instruction "Comment out the old locale: $orig_locale..."
    sudo sed -i "s/^$orig_locale/# $orig_locale/g" /etc/locale.gen
print_result $?

# Uncomment the new locale
print_instruction "Uncomment the new locale: $new_locale..."
    sudo sed -i "s/^# $new_locale/$new_locale/g" /etc/locale.gen
print_result $?

print_instruction "Calculate the country/locale code only..."
    space_pos=`expr index "$new_locale" ' '`
    len=$((space_pos-1))
print_result $?

lc_val="${new_locale:0:len}"

update_locale_setting "LANG" $lc_val

update_locale_setting "LC_ALL" $lc_val

update_locale_setting "LC_CTYPE" $lc_val

update_locale_setting "LC_MESSAGES" $lc_val

update_locale_setting "LC_COLLATE" $lc_val

print_instruction "Execute locale-gen with the current settings..."
    sudo locale-gen
print_result $?


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ $ip_target != $ip_addr_me ]
    then

        new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

        # Comment out the original locale...
        print_instruction "Comment out the old locale: $orig_locale..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo sed -i 's/^$orig_locale/# $orig_locale/g' /etc/locale.gen"
        print_result $?

        # Uncomment the new locale
        print_instruction "Uncomment the new locale: $new_locale..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo sed -i 's/^# $new_locale/$new_locale/g' /etc/locale.gen"
        print_result $?

        update_locale_setting_remote "LANG" $lc_val

        update_locale_setting_remote "LANG" $lc_val

        update_locale_setting_remote "LC_ALL" $lc_val

        update_locale_setting_remote "LC_CTYPE" $lc_val

        update_locale_setting_remote "LC_MESSAGES" $lc_val

        update_locale_setting_remote "LC_COLLATE" $lc_val

        print_instruction "Execute locale-gen with the current settings..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo locale-gen"
        print_result $?

        print_instruction "Execute locale-gen with the current settings..."
            sudo sshpass -p $pword ssh $piid@$ip_target "locale -a"
        print_result $?

    fi

done



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

. _worker_reboot.sh
