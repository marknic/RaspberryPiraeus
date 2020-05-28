#!/bin/bash

. _config_file.sh

print_instruction " _     _  _____  ______  _______ _______ _______   "
print_instruction " |     | |_____] |     \ |_____|    |    |______   "
print_instruction " |_____| |       |_____/ |     |    |    |______   "
print_instruction "         _____  _______ _______        _______     "
print_instruction " |      |     | |       |_____| |      |______     "
print_instruction " |_____ |_____| |_____  |     | |_____ |______   \n"


. _check_root.sh

. _package_check.sh

. _array_setup.sh


# This script will update the locale settings in Raspbian
# It is necessary to allow some of the later scripting options to work
# See _config_file.sh for the locale values (Old/current & new/to be)

# Comment out the original locale...
print_instruction "Comment out the old locale: $orig_locale..."
    sudo sed -i "s/$orig_locale/# $orig_locale/g" /etc/locale.gen
print_result $?

# Uncomment the new locale
print_instruction "Uncomment the new locale: $new_locale..."
    sudo sed -i "s/# $new_locale/$new_locale/g" /etc/locale.gen
print_result $?

print_instruction "Calculate the country/locale code only..."
    space_pos=`expr index "$new_locale" ' '`
    len=$((space_pos-1))
print_result $?

lc_val="${new_locale:0:len}"

grep "export LANG=$lc_val" /home/$piid/.bashrc

if [ $? -ne 0 ]
then
    print_instruction "Add LANG setting with $lc_val to .bashrc..."
        echo "export LANG=$lc_val" >> .bashrc
    print_result $?
fi

grep "export LANG=$lc_val" /home/$piid/.bashrc

if [ $? -ne 0 ]
then
    print_instruction "Add LC_ALL setting with $lc_val to .bashrc..."
        echo "export LC_ALL=$lc_val" >> .bashrc
    print_result $?
fi

print_instruction "Make changes current to the session..."
    source .bashrc
print_result $?

print_instruction "Execute locale-gen with the current settings..."
sudo locale-gen
print_result $?

print_instruction "See the locale changes:"
    locale -a
print_result $?


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ $ip_target != $ip_addr_me ]; then

        new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")


        # Comment out the original locale...
        print_instruction "Comment out the old locale: $orig_locale..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo sed -i 's/$orig_locale/# $orig_locale/g' /etc/locale.gen"
        print_result $?

        # Uncomment the new locale
        print_instruction "Uncomment the new locale: $new_locale..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo sed -i 's/$new_locale/# $new_locale/g' /etc/locale.gen"
        print_result $?

        sudo sshpass -p $pword ssh $piid@$ip_target "grep 'export LANG=$lc_val' /home/$piid/.bashrc"

        if [ $? -ne 0 ] then;
            print_instruction "Add LANG setting with $lc_val to .bashrc..."
                sudo sshpass -p $pword ssh $piid@$ip_target "echo 'export LANG=$lc_val' >> /home/$piid/.bashrc"
            print_result $?
        fi

        sudo sshpass -p $pword ssh $piid@$ip_target "grep 'export LC_ALL=$lc_val' /home/$piid/.bashrc"
        if [ $? -ne 0 ] then;
            print_instruction "Add LC_ALL setting with $lc_val to .bashrc..."
                sudo sshpass -p $pword ssh $piid@$ip_target "echo 'export LC_ALL=$lc_val' >> /home/$piid/.bashrc"
            print_result $?
        fi

        print_instruction "Make changes current to the session..."
            sudo sshpass -p $pword ssh $piid@$ip_target "source .bashrc"
        print_result $?

        print_instruction "Execute locale-gen with the current settings..."
        sudo sshpass -p $pword ssh $piid@$ip_target "sudo locale-gen"
        print_result $?

        print_instruction "Execute locale-gen with the current settings..."
            sudo sshpass -p $pword ssh $piid@$ip_target "locale -a"
        print_result $?

    fi

done

. _worker_reboot.sh
