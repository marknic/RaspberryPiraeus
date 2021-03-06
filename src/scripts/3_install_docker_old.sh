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

#. _package_check.sh


for ((i=0; i<$length; i++));
do

    get_ip_host_and_platform $i

    if [ $ip_target == $ip_addr_me ]
    then

        print_instruction "Adding cgroup settings to $BOOT_FOLDER$CMDLINE_TXT file..."

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


        grep $CGROUP_TEST $cmdline_file

        if [ $? -eq 0 ]
        then
            echo "cgroup parameters already added"
        else
            print_instruction "\nCreating cmdline.txt backup...\n"
                sudo cp -f $cmdline_file $cmdline_backup
            print_result $?

            print_instruction "\nAdding CGroup settings...\n"
                sudo sed -e "s/$/ $CGROUP/" $cmdline_backup > $cmdline_file
            print_result $?
        fi


        # This command will fail if docker is not installed
        sudo docker ps > /dev/null 2>&1

        # Only do this if docker has not been installed yet
        if [ $? -eq 0 ]; then
            print_instruction "Docker already installed...skipping."
        else
            print_instruction "\nAdding link to Docker repository and adding the APT key...\n"
                sudo curl -fsSL $docker_keys | sudo apt-key add -
            print_result $?

            # Install docker
            print_instruction "Getting docker install script..."
                curl -fsSL https://get.docker.com -o get-docker.sh
            print_result $?

            print_instruction "Installing Docker via script..."
                sh get-docker.sh
            print_result $?

            print_instruction "apt-get update..."
                sudo apt-get update
            print_result $?
        fi

        grep -q docker /etc/group

        if [ $? -eq 0 ]; then
            print_instruction "'docker' group exists.\n"
        else
            print_instruction "\nCreating 'docker' group.\n"
                sudo groupadd docker
            print_result $?
        fi


        # if the ID doesn't exist in the group...add it
        id $piid | grep -q 'docker'

        if [ $? -eq 0 ]; then
            print_instruction "$piid exists within the 'docker' group.\n"
        else
            print_instruction "Adding $piid to the 'docker' group.\n"
                sudo usermod $piid -aG docker
            print_result $?
        fi


        if [ ! -d "$DOCKER_ETC_DIR" ]; then
            # If $DOCKER_ETC_DIR does not exist.
            sudo mkdir $DOCKER_ETC_DIR
        else
            sudo rm -f $daemondestfilename > /dev/null 2>&1
        fi

        print_instruction "\nCopying $daemonjsonfile to $daemondestfilename..."
            sudo cp -f $daemonjsonfile $daemondestfilename
        print_result $?


        if [ ! -f "$ETC_FOLDER$BAK_FILE" ]
        then
            # Create a backup if it doesn't already exist
            print_instruction "Create $ETC_FOLDER$BAK_FILE if it doesn't exist... "
                cp "$ETC_FOLDER$SYSCTL_FILE" "$ETC_FOLDER$BAK_FILE"
            print_result $?
        fi

        # Create temporary file with an update - uncommented line
        print_instruction "Modifying $ETC_FOLDER$SYSCTL_FILE on: $host_target/$ip_target... "
            sudo sed -i "$SED_REGEX_QUERY" $ETC_FOLDER$SYSCTL_FILE
        print_result $?

        # Going to use the sysctl.conf file to copy to the workers
        print_instruction "Copying $ETC_FOLDER$SYSCTL_FILE to local folder... "
            cp $ETC_FOLDER$SYSCTL_FILE .
        print_result $?


    else

        # Remote machine so use ssh
        print_instruction "apt-get update..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        print_result $?

        print_instruction "apt-get -y --fix-missing dist-upgrade..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade
        print_result $?







        print_instruction "Adding cgroup settings to $BOOT_FOLDER$CMDLINE_TXT file\n"

        sudo sshpass -p $pword ssh $piid@$ip_target test -f $BOOT_FOLDER$CMDLINE_TXT_BACKUP

        if [ $? -ne 0 ]; then
            print_instruction "Making backup of $BOOT_FOLDER$CMDLINE_TXT -> $BOOT_FOLDER$CMDLINE_TXT_BACKUP"
                sudo sshpass -p $pword ssh $piid@$ip_target sudo cp $BOOT_FOLDER$CMDLINE_TXT $BOOT_FOLDER$CMDLINE_TXT_BACKUP
            print_result $?
        fi

        if [ $? -ne 0 ]; then
            print_instruction "Copying $CMDLINE_TXT to worker $ip_target..."
                sshpass -p $pword scp "$piid@$ip_target:$CMDLINE_TXT" $CMDLINE_TXT
            print_result $?

            print_instruction "Copying $CMDLINE_TXT to $BOOT_FOLDER$CMDLINE_TXT..."
                sudo sshpass -p $pword ssh $piid@$ip_target sudo cp $CMDLINE_TXT $BOOT_FOLDER$CMDLINE_TXT
            print_result $?
        fi

        print_instruction "\nAdding link to Kubernetes repository and adding the APT key"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo curl -s https://download.docker.com/linux/raspbian/gpg | sudo apt-key add -
        print_result $?

        print_instruction "Check to see if Docker is already installed."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo docker ps > /dev/null 2>&1

        if [ $? -ne 0 ]
        then
            print_instruction "Docker is not installed.  Installing..."

            # Install docker
            print_instruction "Getting docker install script..."
                sudo sshpass -p $pword ssh $piid@$ip_target curl -fsSL https://get.docker.com -o get-docker.sh
            print_result $?

            print_instruction "Getting docker install script..."
                sudo sshpass -p $pword ssh $piid@$ip_target sh get-docker.sh
            print_result $?
        fi

        # if the docker group doesn't exist...add it
        sudo sshpass -p $pword ssh $piid@$ip_target grep -q docker /etc/group

        if [ $? -ne 0 ]; then
            print_instruction "\nCreating 'docker' group on $host_target...\n"
                sudo sshpass -p $pword ssh $piid@$ip_target sudo groupadd docker
            print_result $?
        else
            print_instruction "'docker' group exists.\n"
        fi

        # if the ID doesn't exist in the group...add it
        sudo sshpass -p $pword ssh $piid@$ip_target id pi | grep -q 'docker'

        if [ $? -ne 0 ]; then
            print_instruction "Adding $piid to the docker group...\n"
                sudo sshpass -p $pword ssh $piid@$ip_target sudo usermod $piid -aG docker
            print_result $?
        else
            print_instruction "$piid already exists in the docker group."
        fi

        sudo sshpass -p $pword ssh $piid@$ip_target test -d $DOCKER_ETC_DIR
        if [ $? -ne 0 ]; then
            print_instruction "Creating folder: $DOCKER_ETC_DIR..."
                sudo sshpass -p $pword ssh $piid@$ip_target sudo mkdir $DOCKER_ETC_DIR
            print_result $?
        fi

        print_instruction "\nCopying $daemonjsonfile to $daemondestfilename on $host_target\n"
            sudo sshpass -p $pword sudo scp $daemonjsonfile $piid@$ip_target:
            sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f $daemonjsonfile $daemondestfilename
        print_result $?

        print_instruction "Copying $SYSCTL_FILE to the worker: $host_target/$ip_target... "
            sudo sshpass -p $pword scp -p -r $SYSCTL_FILE $piid@$ip_target:
        print_result $?

        print_instruction "Copying $SYSCTL_FILE to the folder: $ETC_FOLDER... "
            sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f "$SYSCTL_FILE" "$ETC_FOLDER"
        print_result $?

        print_instruction "$ETC_FOLDER$SYSCTL_FILE modified on: $host_target/$ip_target: "
    fi
done

. _worker_reboot.sh
