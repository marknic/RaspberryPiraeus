#!/bin/bash

. _config_file.sh

print_instruction " _____ __   _ _______ _______ _______"
print_instruction "   |   | \  | |______    |    |_____| |      |"
print_instruction " __|__ |  \_| ______|    |    |     | |_____ |_____\n"

print_instruction " _     _ _     _ ______  _______  ______ __   _ _______ _______ _______ _______"
print_instruction " |____/  |     | |_____] |______ |_____/ | \  | |______    |    |______ |______"
print_instruction " |    \_ |_____| |_____] |______ |    \_ |  \_| |______    |    |______ ______|\n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

# Run this code on the master
print_instruction "\nRemoving the swap file on $ip_addr_me\n"
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt-get -y purge dphys-swapfile

print_instruction "\nUpdate and Upgrade"
sudo apt-get update
sudo apt-get -y upgrade

print_instruction "\nAdding link to Kubernetes repository and adding the APT key\n"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

print_instruction "\nModify iptables"
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

# Create a support file that will be copied to the nodes
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee kubernetes.list

# Add Kubernetes repository to the RPi package lists
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo cp -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

print_instruction "\nkubeadm init...\n"
sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr_me

print_instruction "Configuring Kubernetes with local user"
echo $piid > piid.txt
sudo -u $piid sh ./_kube_config.sh

sudo apt-mark hold kubelet kubeadm kubectl

 # Do some cleanup
print_instruction "\nDo some cleanup: autoremove\n"
sudo sshpass -p $pword ssh $piid@$ip_target sudo apt -y autoremove




for ((i=0; i<$length; i++));
do

    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    print_instruction "\n-----------"
    print_instruction "Configuring $host_target/$ip_target\n"

    if [ $ip_target != $ip_addr_me ]
    then

        # Run this code across all machines
        print_instruction "\nRemoving swapfile on $host_target."
        sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile swapoff
        sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile uninstall
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-rc.d dphys-swapfile remove
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y purge dphys-swapfile

        print_instruction "\nUpdate and install"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y upgrade

        print_instruction "\nAdding link to Kubernetes repository and adding the APT key\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

        print_instruction "\nModify iptables"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

        # Create a support file that will be copied to the nodes
        print_instruction "Create a support file that will be copied to the nodes"
        sudo sshpass -p $pword ssh $piid@$ip_target echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee kubernetes.list

        # Add Kubernetes repository to the RPi package lists
        print_instruction "Insert kubernetes.list file."
        sudo sshpass -p $pword ssh $piid@$ip_target sudo rm -f /etc/apt/sources.list.d/kubernetes.list
        sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list

        print_instruction "Install kubelet kubeadm."
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y kubelet kubeadm #kubectl

        # print_instruction "Configuring Kubernetes with local user"
        # sudo sshpass -p $pword ssh $piid@$ip_target echo $piid > piid.txt
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo -u $piid ./_kube_config.sh
        # sudo sshpass -p $pword ssh $piid@$ip_target rm piid.txt

        print_instruction "Locking: kubelet kubeadm" #kubectl"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-mark hold kubelet kubeadm #kubectl

        # Do some cleanup
        print_instruction "\nDo some cleanup: autoremove\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt -y autoremove


        # print_instruction "\nCopying kubernetes.list to worker machine."
        # sudo sshpass -p $pword sudo scp "kubernetes.list" $piid@$ip_target:

        # print_instruction "\nAdding link to Kubernetes repository and adding the APT key."
        # # Add Kubernetes repository to the RPi package lists
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo rm -f /etc/apt/sources.list.d/kubernetes.list
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo mv -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-key adv --fetch-keys https://packages.cloud.google.com/apt/doc/apt-key.gpg

        # print_instruction "\nUpdate and Upgrade"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo apt update
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo apt -y upgrade


        # print_instruction "Backing up /boot/cmdline.txt\n"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

        # sudo sshpass -p $pword ssh $piid@$ip_target echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt

        # print_instruction "\napt-get -y update\n"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y update

        # print_instruction "\napt-get -y install dnsutils kubeadm\n"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y install dnsutils kubeadm

        # # Do some cleanup
        # print_instruction "\napt -y autoremove\n"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo apt -y autoremove


        # print_instruction "\nkubeadm init...\n"
        # sudo sshpass -p $pword ssh $piid@$ip_target sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr_me


    fi

done

. _worker_reboot.sh


