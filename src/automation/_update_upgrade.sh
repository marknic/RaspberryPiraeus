#!/bin/bash

. _config_file.sh

print_instruction "  _   _           _       _                  "
print_instruction " | | | |_ __   __| | __ _| |_ ___            "
print_instruction " | | | | !_ \ / _! |/ _! | __/ _ \           "
print_instruction " | |_| | |_) | (_| | (_| | ||  __/           "
print_instruction "  \___/| .__/ \__,_|\__,_|\__\___|           "
print_instruction "  _   _|_|                        _          "
print_instruction " | | | |_ __   __ _ _ __ __ _  __| | ___     "
print_instruction " | | | | !_ \ / _! | !__/ _! |/ _! |/ _ \    "
print_instruction " | |_| | |_) | (_| | | | (_| | (_| |  __/    "
print_instruction "  \___/| .__/ \__, |_|  \__,_|\__,_|\___|    "
print_instruction "       |_|    |___/                        \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

final_result=0

handle_result() {

    if [ $1 -ne 0 ]
    then
        final_result=1
    fi

    print_result $1
}


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    
    print_instruction "Updating $host_target.\n"

    if [ $ip_target == $ip_addr_me ]; then
        sudo apt-get clean

        print_instruction "apt-get update...\n"
            sudo apt-get --fix-missing update
        handle_result $?

        print_instruction "apt-get upgrade...\n"
            sudo apt-get -y --fix-missing upgrade
        handle_result $?

    else

        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean

        print_instruction "apt-get update on worker: $ip_target.\n"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        handle_result $?

        print_instruction "apt-get upgrade on worker: $ip_target.\n"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade
        handle_result $?

    fi

    if [ final_result -ne 0 ]
    then

        while true; do
            print_warning "\n\nAt least one of the update/upgrade attempts failed.  Do you want to continue? "
            read -p "(y/n)?" yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer (y)es or (n)o.";;
            esac
        done
    fi

done

