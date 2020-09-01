#!/bin/bash

. _config_file.sh

print_instruction "   ____                _           "
print_instruction "  / ___|_ __ ___  __ _| |_ ___     "
print_instruction " | |   | !__/ _ \/ _: | __/ _ \    "
print_instruction " | |___| | |  __/ (_| | ||  __/    "
print_instruction "  \____|_|  \___|\__,_|\__\___|    "
print_instruction "  _   _                            "
print_instruction " | | | |___  ___ _ __ ___          "
print_instruction " | | | / __|/ _ \ !__/ __|         "
print_instruction " | |_| \__ \  __/ |  \__ \         "
print_instruction "  \___/|___/\___|_|  |___/       \n"
                               
. _check_root.sh

. _array_setup.sh

for ((i=0; i<$length; i++));
do

    # Temporary var for getting max value
    ugid=999

    # Get the IP to search for
    get_ip_host_and_platform $i

    print_instruction "Getting the user list from $ip_target..."
        sudo sshpass -p $user_password scp $user_id@$ip_target:$FILE_PASSWD $localpasswdfile
    print_result $?

    #2gadmin:2gadmin123:1003:1003::/home/2gadmin:/bin/bash
    while IFS= read -r line
    do
        my_array=($(echo $line | tr ":" "\n"))

        if [ ${my_array[2]} -lt 65000 ] && [ ${my_array[2]} -gt 999 ]
        then
            if [ ${my_array[3]} -lt 65000 ] && [ ${my_array[3]} -gt 999 ]
            then

            if [ ${my_array[3]} -gt $ugid ]
            then
                ugid=${my_array[3]}
            fi

            fi
        fi
    done < "$localpasswdfile"

    ugid=$((ugid+1))

    # Remove the local user data file if it exists
    rm -f $newUserDatafile > /dev/null 2>&1

    # Create the new local user data file
    echo "$new_CommonId:$new_CommonPw:$ugid:$ugid::/home/$new_CommonId:/bin/bash" > $newUserDatafile

    print_instruction "Copying the new user data file over to $ip_target..."
        sudo sshpass -p $user_password scp $newUserDatafile $user_id@$ip_target:$newUserDatafile
    print_result $?

    print_instruction "Creating the new user and group (same name for both) on $ip_target..."
        sudo sshpass -p $user_password ssh  $user_id@$ip_target "sudo newusers $newUserDatafile"
    print_result $?

    print_instruction "Creating the new user and group (same name for both) on $ip_target..."
        sudo sshpass -p $user_password ssh  $user_id@$ip_target "sudo usermod -aG sudo $new_CommonId"
    print_result $?

done

. _worker_reboot.sh
