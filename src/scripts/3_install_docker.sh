#!/bin/bash

. _config_file.sh

print_instruction "  ___           _        _ _         "
print_instruction " |_ _|_ __  ___| |_ __ _| | |        "
print_instruction "  | || !_ \/ __| __/ _! | | |        "
print_instruction "  | || | | \__ \ || (_| | | |        "
print_instruction " |___|_| |_|___/\__\__,_|_|_|        "
print_instruction "  ____             _                 "
print_instruction " |  _ \  ___   ___| | _____ _ __     "
print_instruction " | | | |/ _ \ / __| |/ / _ \ !__|    "
print_instruction " | |_| | (_) | (__|   <  __/ |       "
print_instruction " |____/ \___/ \___|_|\_\___|_|     \n"

. _check_root.sh

. _array_setup.sh


for ((i=0; i<$length; i++));
do

    get_ip_host_and_platform $i

    if [ $ip_target == $ip_addr_me ]; then callLocation="-l"; else callLocation="-r"; fi



    # Configure Boot Options
    if [ $platform_target == $PLATFORM_PI]
    then
        cmdline_file=$BOOT_FOLDER$CMDLINE_TXT
        cmdline_backup=$BOOT_FOLDER$CMDLINE_TXT_BACKUP
        docker_keys="https://download.docker.com/linux/raspbian/gpg"
    else
        cmdline_file=$BOOT_FIRMWARE_FOLDER$CMDLINE_TXT
        cmdline_backup=$BOOT_FIRMWARE_FOLDER$CMDLINE_TXT_BACKUP
        docker_keys="https://download.docker.com/linux/ubuntu/gpg"
    fi

    print_instruction "Adding cgroup settings to $cmdline_file file..."

    execute_command $callLocation -1 "grep $CGROUP_TEST $cmdline_file"

    if [ $? -eq 0 ]
    then
        echo "cgroup parameters already added"
    else
        print_instruction "\nCreating cmdline.txt backup...\n"
            execute_command $callLocation -1 "sudo cp -f $cmdline_file $cmdline_backup"
        print_result $?

        print_instruction "\nAdding CGroup settings...\n"
            execute_command $callLocation -1 "sudo sed -e "'"'"s/$/ $CGROUP/"'"'" $cmdline_backup > $cmdline_file"
        print_result $?
    fi



    # Install Docker
    # This command will fail if docker is not installed
    execute_command $callLocation -1 'sudo docker ps > /dev/null 2>&1'

    # Only do this if docker has not been installed yet
    if [ $? -eq 0 ]; then
        print_instruction "Docker already installed...skipping."
    else
        print_instruction "\nAdding link to Docker repository and adding the APT key...\n"
            execute_command $callLocation -R "sudo curl -fsSL $docker_keys | sudo apt-key add -"
        print_result $?

        # Install docker
        print_instruction "Getting docker install script..."
            execute_command $callLocation -R "curl -fsSL https://get.docker.com -o get-docker.sh"
        print_result $?

        print_instruction "Installing Docker via script..."
            execute_command $callLocation -1 "sh get-docker.sh"
        print_result $?

        print_instruction "apt-get update..."
            execute_command $callLocation -1 "sudo apt-get update"
        print_result $?
    fi


    # Create the docker group
    execute_command $callLocation -R "grep -q docker /etc/group"

    if [ $? -eq 0 ]; then
        print_instruction "'docker' group exists.\n"
    else
        print_instruction "\nCreating 'docker' group.\n"
            execute_command $callLocation -R "sudo groupadd docker"
        print_result $?
    fi


    # Add the user ID to the docker group
    # if the ID doesn't exist in the group...add it
    execute_command $callLocation -R "id $piid | grep -q 'docker'"

    if [ $? -eq 0 ]; then
        print_instruction "$piid exists within the 'docker' group.\n"
    else
        print_instruction "Adding $piid to the 'docker' group.\n"
            execute_command $callLocation -R "sudo usermod -aG docker $piid"
        print_result $?
    fi


    # Set Docker daemon options
    execute_command $callLocation -1 "test -d $DOCKER_ETC_DIR"

    if [ $? -ne 0 ]; then
        # If $DOCKER_ETC_DIR does not exist.
        execute_command $callLocation -1 "sudo mkdir $DOCKER_ETC_DIR"
    else
        execute_command $callLocation -1 "sudo rm -f $daemondestfilename > /dev/null 2>&1"
    fi

    print_instruction "\nCopying $daemonjsonfile to $daemondestfilename..."
        execute_command $callLocation -1 "sudo cp -f $daemonjsonfile $daemondestfilename"
    print_result $?


    # Enable routing
    if [ ! -f "$ETC_FOLDER$BAK_FILE" ]; then
        # Create a backup if it doesn't already exist
        print_instruction "Create $ETC_FOLDER$BAK_FILE if it doesn't exist... "
            execute_command $callLocation -1 "sudo cp "'"'"$ETC_FOLDER$SYSCTL_FILE"'"'" "'"'"$ETC_FOLDER$BAK_FILE"'"'
        print_result $?
    fi

    # Create temporary file with an update - uncommented line
    print_instruction "Modifying $ETC_FOLDER$SYSCTL_FILE on: $host_target/$ip_target... "
        execute_command $callLocation -1 "sudo sed -i "'"'"$SED_REGEX_QUERY"'"'" "'"'"$ETC_FOLDER$SYSCTL_FILE"'"'
    print_result $?

    # Going to use the sysctl.conf file to copy to the workers
    print_instruction "Copying $ETC_FOLDER$SYSCTL_FILE to local folder... "
        execute_command $callLocation -1 "cp $ETC_FOLDER$SYSCTL_FILE ."
    print_result $?


done

. _worker_reboot.sh
