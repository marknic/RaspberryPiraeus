#!/bin/bash

. _config_file.sh

print_instruction "  _  __     _                          _                 "
print_instruction " | |/ /   _| |__   ___ _ __ _ __   ___| |_ ___  ___      "
print_instruction " | ' / | | | '_ \ / _ \ '__| '_ \ / _ \ __/ _ \/ __|     "
print_instruction " | . \ |_| | |_) |  __/ |  | | | |  __/ ||  __/\__ \     "
print_instruction " |_|\_\__,_|_.__/ \___|_|  |_| |_|\___|\__\___||___/     "
print_instruction "  ___           _        _ _      __                     "
print_instruction " |_ _|_ __  ___| |_ __ _| | |    / /                     "
print_instruction "  | || '_ \/ __| __/ _' | | |   / /                      "
print_instruction "  | || | | \__ \ || (_| | | |  / /                       "
print_instruction " |___|_| |_|___/\__\__,_|_|_| /_/                        "
print_instruction "  ____       _                                           "
print_instruction " / ___|  ___| |_ _   _ _ __                              "
print_instruction " \___ \ / _ \ __| | | | '_ \                             "
print_instruction "  ___) |  __/ |_| |_| | |_) |                            "
print_instruction " |____/ \___|\__|\__,_| .__/                             "
print_instruction "                      |_|                              \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

print_instruction "\nCreating support file for k8s: kubernetes.list"
# Create a support file that will be copied to the nodes

if [ ! -f $kub_list ]; then
    print_instruction "Creating $kub_list..."
        sudo cp $FILE_KUB_LIST_DATA $kub_list
    print_result $?
fi

print_instruction "\nStart Docker Service...\n"
    sudo systemctl start docker.service
print_result $?

print_instruction "\nAdding link to Kubernetes repository and adding the APT key...\n"
    sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
print_result $?

print_instruction "\nUpdating and checking for installation keys."
# Just in case the keys aren't loaded, check for it and then use those keys to indicate
# what needs to be installed
sudo apt-get update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' |
while read key;
do
    print_instruction "\nUpdating key: $key."
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$key"
    print_result $?
done

print_instruction "Clean..."
    sudo apt-get clean
print_result $?
print_instruction "Update..."
    sudo apt-get --fix-missing update
print_result $?
print_instruction "Upgrade..."
    sudo apt-get -y --fix-missing upgrade
print_result $?


print_instruction "\nInstall kubeadm kubectl kubelet..."
    sudo apt-get -y install kubeadm kubectl kubelet
print_result $?

for ((i=0; i<$length; i++));
do

    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ $ip_target != $ip_addr_me ]
    then
        host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

        print_instruction "\n-----------"
        print_instruction "Configuring $host_target/$ip_target\n"

        print_instruction "Clean..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean
        print_result $?

        print_instruction "Update..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        print_result $?

        print_instruction "Upgrade..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing upgrade
        print_result $?

        print_instruction "Checking to see if $kub_list already exists..."
        sudo sshpass -p $pword ssh $piid@$ip_target test -f $kub_list

        if [ $? -ne 0 ]; then
            print_instruction "\nCopy kubernetes.list to the worker: $host_target..."
                sudo sshpass -p $pword scp -p -r $FILE_KUB_LIST_DATA $piid@$ip_target:$FILE_KUB_LIST_DATA
            print_result $?

            print_instruction "\nCopy kubernetes.list to the correct folder..."
                sudo sshpass -p $pword ssh $piid@$ip_target "sudo cp $FILE_KUB_LIST_DATA $kub_list"
            print_result $?
        fi

        print_instruction "\nAdding link to Kubernetes repository and adding the APT key"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        print_result $?

        rm -f keys.txt


        print_instruction "\nUpdating and checking for installation keys on: $host_target..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo apt-get update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p'" > keys.txt
        print_result $?

        cat keys.txt |
        while read key;
        do
            print_instruction "\nReplacing missing key: $key ..."
                sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$key"
            print_result $?

        done

        print_instruction "Clean..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get clean
        print_result $?

        print_instruction "Update..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        print_result $?

        print_instruction "Upgrade..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing upgrade
        print_result $?

        print_instruction "\nInstall kubeadm kubectl kubelet..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y install kubeadm kubectl kubelet
        print_result $?
    fi
done


. _worker_reboot.sh

