#!/bin/bash

. _config_file.sh

print_instruction " _     _ _     _ ______  _______  ______ __   _ _______ _______ _______ _______"
print_instruction " |____/  |     | |_____] |______ |_____/ | \  | |______    |    |______ |______"
print_instruction " |    \_ |_____| |_____] |______ |    \_ |  \_| |______    |    |______ ______|\n"

print_instruction " _____ __   _ _______ _______ _______                  /"
print_instruction "   |   | \  | |______    |    |_____| |      |        /"
print_instruction " __|__ |  \_| ______|    |    |     | |_____ |_____  /\n"

print_instruction " _______ _______ _______ _     _  _____ "
print_instruction " |______ |______    |    |     | |_____]"
print_instruction " ______| |______    |    |_____| |      \n"


. _check_root.sh

. _package_check.sh

. _array_setup.sh

print_instruction "\nCreating support file for k8s: kubernetes.list"
# Create a support file that will be copied to the nodes

if [ ! -f $kub_list ]; then
    print_instruction "Creating $kub_list."
    sudo cp $FILE_KUB_LIST_DATA $kub_list
fi


print_instruction "\nAdding link to Kubernetes repository and adding the APT key\n"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -


sudo apt-get update
sudo apt-get -y install kubeadm kubectl kubelet


for ((i=0; i<$length; i++));
do

    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    print_instruction "\n-----------"
    print_instruction "Configuring $host_target/$ip_target\n"

    if [ $ip_target != $ip_addr_me ]
    then

        print_instruction "\nCreating support file for k8s: kubernetes.list"
        # Create a support file that will be copied to the nodes
        sudo sshpass -p $pword ssh $piid@$ip_target echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee "$kub_list"

        print_instruction "\nAdding link to Kubernetes repository and adding the APT key\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

        sudo sshpass -p $pword ssh $piid@$ip_target test -f $kub_list
        if [ $? -ne 0 ]; then
            sudo sshpass -p $pword scp -p -r $FILE_KUB_LIST_DATA $piid@$ip_target:$kub_list
        fi

    fi

done


. _worker_reboot.sh

