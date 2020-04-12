#!/bin/bash

. _config_file.sh

print_instruction " _     _ _     _ ______  _______  ______ __   _ _______ _______ _______ _______"
print_instruction " |____/  |     | |_____] |______ |_____/ | \  | |______    |    |______ |______"
print_instruction " |    \_ |_____| |_____] |______ |    \_ |  \_| |______    |    |______ ______|\n"

print_instruction " _____ __   _ _______ _______ _______                    _______ _______ _______ _     _  _____ "
print_instruction "   |   | \  | |______    |    |_____| |      |           |______ |______    |    |     | |_____]"
print_instruction " __|__ |  \_| ______|    |    |     | |_____ |_____      ______| |______    |    |_____| |      \n"


. _check_root.sh

. _package_check.sh

. _array_setup.sh

kub_list="/etc/apt/sources.list.d/kubernetes.list"

# remove kub list file
sudo rm -f "$kub_list"

print_instruction "\nCreating support file for k8s: kubernetes.list"
# Create a support file that will be copied to the nodes
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee "$kub_list"

print_instruction "\nAdding link to Kubernetes repository and adding the APT key\n"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -


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


        #print_instruction "\nAdding link to Kubernetes repository and adding the APT key\n"
        #sudo sshpass -p $pword ssh $piid@$ip_target sudo wget https://packages.cloud.google.com/apt/doc/apt-key.gpg

        # print_instruction "\nModify iptables"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

        # print_instruction "\nCreate a support file that will be copied to the nodes"
        # #sudo sshpass -p $pword ssh $piid@$ip_target sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee kubernetes.list
        # sudo sshpass -p $pword scp kubernetes.list $piid@$ip_target:

        # print_instruction "\nAdd Kubernetes repository to the RPi package lists"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo rm -f /etc/apt/sources.list.d/kubernetes.list
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list

        # print_instruction "\nSetup apt.conf for install of k8s."
        # sudo sshpass -p $pword scp apt.conf $piid@$ip_target:
        # #sudo sshpass -p $pword ssh $piid@$ip_target sudo echo 'Acquire::https::packages.cloud.google.com::Verify-Peer "false";' > apt.conf
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo rm -f /etc/apt/apt.conf
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f apt.conf /etc/apt/
    fi

done


. _worker_reboot.sh

