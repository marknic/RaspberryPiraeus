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

sudo apt-get clean
sudo apt-get --fix-missing update
sudo apt-get -y --fix-missing dist-upgrade

sudo apt-get install -y software-properties-common

# Install docker
curl -fsSL https://get.docker.com -o get-docker.sh | sh

# if the docker group doesn't exist...add it
if [ ! grep -q docker /etc/group]; then
    print_instruction "\nCreating 'docker' group.\n"
    sudo groupadd docker
fi

# if the ID doesn't exist in the group...add it
if [ ! id $piid | grep -q 'docker' ]; then
    print_instruction "Adding $piid to the 'docker' group.\n"
    sudo usermod $piid -aG docker
fi



if [ ! -d "$DOCKER_ETC_DIR" ]; then
    # If $DOCKER_ETC_DIR does not exist.
    sudo mkdir $DOCKER_ETC_DIR
else
    sudo rm -f $daemondestfilename > /dev/null 2>&1
fi

print_instruction "\nCopying $daemonjsonfile to $daemondestfilename\n"
sudo cp -f $daemonjsonfile $daemondestfilename



# Create a backup if it doesn't already exist
[ ! -f "$ETC_FOLDER$BAK_FILE" ] && cp "$ETC_FOLDER$SYSCTL_FILE" "$ETC_FOLDER$BAK_FILE"

# Create temporary file with an update - uncommented line
sed -i "$SED_REGEX_QUERY" $SYSCTL_FILE

ip_target=$(echo $cluster_data | jq --raw-output ".[0].IP")
host_target=$(echo $cluster_data | jq --raw-output ".[0].name")

print_instruction "$ETC_FOLDER$SYSCTL_FILE modified on: $host_target/$ip_target: "


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]
    then
        # Remote machine so use ssh
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing dist-upgrade

        echo "$host_target/$ip_target: Installing package: software-properties-common"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y software-properties-common

        # Install docker
        echo "$host_target/$ip_target: Installing Docker"
        sudo sshpass -p $pword ssh $piid@$ip_target curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sshpass -p $pword ssh $piid@$ip_target sh get-docker.sh

        # if the docker group doesn't exist...add it
        printf "\nCreating 'docker' group on $host_target.\n"
        sudo sshpass -p $pword ssh $piid@$ip_target grep -q docker /etc/group

        if [ $? -ne 0 ]; then
            sudo sshpass -p $pword ssh $piid@$ip_target sudo groupadd docker
        fi

        # if the ID doesn't exist in the group...add it
        sudo sshpass -p $pword ssh $piid@$ip_target id pi | grep -q 'docker'

        if [ $? -ne 0 ]; then
            print_instruction "Adding $piid to the docker group\n"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo usermod $piid -aG docker
        fi

        sudo sshpass -p $pword ssh $piid@$ip_target test -d $DOCKER_ETC_DIR
        if [ $? -ne 0 ]; then
            sudo sshpass -p $pword ssh $piid@$ip_target mkdir $DOCKER_ETC_DIR
        fi

        printf "\nCopying $daemonjsonfile to $daemondestfilename on $host_target\n"
        sudo sshpass -p $pword sudo scp $daemonjsonfile $piid@$ip_target:
        sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f $daemonjsonfile $daemondestfilename




        print_instruction "Modifying $ETC_FOLDER$SYSCTL_FILE on $host_target/$ip_target: "

        sshpass -p $pword ssh $piid@$ip_target [ ! -f "$ETC_FOLDER$BAK_FILE" ] && sudo cp -f "$ETC_FOLDER$SYSCTL_FILE" "$ETC_FOLDER$BAK_FILE"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo sed -i "$SED_REGEX_QUERY" $SYSCTL_FILE

        print_instruction "$ETC_FOLDER$SYSCTL_FILE modified on: $host_target/$ip_target: "
    fi
done

. _worker_reboot.sh
