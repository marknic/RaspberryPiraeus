#!/bin/bash

. _config_file.sh

print_instruction " _____ __   _ _______ _______ _______"
print_instruction "   |   | \  | |______    |    |_____| |      |"
print_instruction " __|__ |  \_| ______|    |    |     | |_____ |_____\n"

print_instruction " ______   _____  _______ _     _ _______  ______"
print_instruction " |     \ |     | |       |____/  |______ |_____/"
print_instruction " |_____/ |_____| |_____  |    \_ |______ |    \_\n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

print_instruction "apt-get clean..."
    sudo apt-get clean
print_result $?

print_instruction "apt-get --fix-missing update..."
    sudo apt-get --fix-missing update
print_result $?

print_instruction "apt-get -y --fix-missing dist-upgrade..."
    sudo apt-get -y --fix-missing dist-upgrade
print_result $?


# This command will fail if docker is not installed
sudo docker ps > /dev/null 2>&1

# Only do this if docker has not been installed yet
if [ $? -ne 0 ]
then
    # Install docker
    print_instruction "Getting docker install script..."
        curl -fsSL https://get.docker.com -o get-docker.sh
    print_result $?

    print_instruction "Installing Docker via script..."
        sh get-docker.sh
    print_result $?
fi

grep -q docker /etc/group

if [ $? -ne 0 ]; then
    print_instruction "\nCreating 'docker' group.\n"
        sudo groupadd docker
    print_result $?
else
    print_instruction "'docker' group exists.\n"
fi


# if the ID doesn't exist in the group...add it
id $piid | grep -q 'docker'

if [ $? -ne 0 ]
then
    print_instruction "Adding $piid to the 'docker' group.\n"
    sudo usermod $piid -aG docker
else
    print_instruction "$piid exists within the 'docker' group.\n"
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


# Create a backup if it doesn't already exist
print_instruction "Create $ETC_FOLDER$BAK_FILE if it doesn't exist... "
    [ ! -f "$ETC_FOLDER$BAK_FILE" ] && cp "$ETC_FOLDER$SYSCTL_FILE" "$ETC_FOLDER$BAK_FILE"
print_result $?


# Create temporary file with an update - uncommented line
print_instruction "Modifying $ETC_FOLDER$SYSCTL_FILE on: $host_target/$ip_target... "
    sudo sed -i "$SED_REGEX_QUERY" $ETC_FOLDER$SYSCTL_FILE
print_result $?

# Going to use the sysctl.conf file to copy to the workers
print_instruction "Copying $ETC_FOLDER$SYSCTL_FILE to local folder... "
    cp $ETC_FOLDER$SYSCTL_FILE .
print_result $?


#ip_target=$(echo $cluster_data | jq --raw-output ".[0].IP")
#host_target=$(echo $cluster_data | jq --raw-output ".[0].name")




for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]
    then
        # Remote machine so use ssh
        print_instruction "apt-get clean..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean
        print_result $?

        print_instruction "apt-get --fix-missing update..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        print_result $?

        print_instruction "apt-get -y --fix-missing dist-upgrade..."
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade
        print_result $?

        print_instruction "Installing software-properties-common..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y software-properties-common
        print_result $?

        sudo sshpass -p $pword ssh $piid@$ip_target sudo docker ps > /dev/null 2>&1

        if [ $? -ne 0 ]
        then
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
                sudo sshpass -p $pword ssh $piid@$ip_target mkdir $DOCKER_ETC_DIR
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
