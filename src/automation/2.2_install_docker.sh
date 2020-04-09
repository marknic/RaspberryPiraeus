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

sudo apt-get install -y software-properties-common
sudo apt-get update && sudo apt-get -y dist-upgrade

curl -fsSL https://get.docker.com -o get-docker.sh | sh

printf "\nCreating 'docker' group.\n"
sudo usermod $piid -aG docker

printf "\nCopying $daemonjsonfile to $daemondestfilename\n"
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
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y dist-upgrade

        # echo "$host_target/$ip_target: Installing package: software-properties-common"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y software-properties-common

        echo "$host_target/$ip_target: Installing Docker-CE Docker-CE-CLI ContainerD"
        sudo sshpass -p $pword ssh $piid@$ip_target curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sshpass -p $pword ssh $piid@$ip_target sh get-docker.sh

        printf "\nCreating 'docker' group on $host_target.\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo usermod $piid -aG docker

        printf "\nCopying $daemonjsonfile to $daemondestfilename on $host_target\n"
        sudo sshpass -p $pword sudo scp $daemonjsonfile  $piid@$ip_target:
        sudo sshpass -p $pword sudo cp -f $daemonjsonfile $daemondestfilename

        print_instruction "Modifying $ETC_FOLDER$SYSCTL_FILE on $host_target/$ip_target: "

        sshpass -p $pword ssh $piid@$ip_target [ ! -f "$ETC_FOLDER$BAK_FILE" ] && sudo cp -f "$ETC_FOLDER$SYSCTL_FILE" "$ETC_FOLDER$BAK_FILE"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo sed -i "$SED_REGEX_QUERY" $SYSCTL_FILE

        print_instruction "$ETC_FOLDER$SYSCTL_FILE modified on: $host_target/$ip_target: "
    fi
done

. _worker_reboot.sh
