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


execute_remote_command_with_retry() {
    local -r -i max_attempts=3
    local -i attempt_num=1

    until sudo sshpass -p $pword ssh $piid@$ip_target $1
    do
        if (( attempt_num == max_attempts ))
        then
            print_instruction "Attempt $attempt_num failed and there are no more attempts."
            return 1
        else
            print_instruction "Attempting to execute command.  This is attempt $attempt_num."
            (( attempt_num++ ))
            sudo sshpass -p $pword ssh $piid@$ip_target $1
        fi
    done
}

execute_command_with_retry() {
    local -r -i max_attempts=3
    local -i attempt_num=1

    until eval $1
    do
        if (( attempt_num == max_attempts ))
        then
            print_instruction "Attempt $attempt_num failed and there are no more attempts."
            return 1
        else
            print_instruction "Attempting to execute command.  This is attempt $attempt_num."
            (( attempt_num++ ))
            eval $1
        fi
    done
}

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    new_host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target == $ip_addr_me ]; then
        cp $FILE_HOSTS $localhostsfile
    else

        # Set Local time on the RPi (Optional)
        print_instruction "Setting up local time ($ip_target:$new_host_name)..."
            #sudo sshpass -p $pword ssh $piid@$ip_target "sudo ln -fs /usr/share/zoneinfo/$zonelocation /etc/localtime"
            execute_remote_command_with_retry "sudo ln -fs /usr/share/zoneinfo/$zonelocation /etc/localtime"
        print_result $?

        print_instruction "dpkg-reconfigure..."
            #sudo sshpass -p $pword ssh $piid@$ip_target "sudo dpkg-reconfigure --frontend noninteractive tzdata"
        print_result $?
    fi

done


print_instruction "\nDone!\n"

. _worker_reboot.sh
