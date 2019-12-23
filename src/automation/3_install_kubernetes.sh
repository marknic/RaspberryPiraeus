#!/bin/bash

. _config_file.sh

. _check_root.sh

. _package_check.sh

. _array_setup.sh


# Run this code on the master
printf "\nRemoving the swap file on $ip_addr_me\n"
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt-get -y purge dphys-swapfile

sudo apt update
sudo apt upgrade -y


printf "\nAdding link to Kubernetes repository and adding the APT key\n"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Create a support file that will be copied to the nodes
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee kubernetes.list


# Add Kubernetes repository to the RPi package lists
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo cp -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-key adv --fetch-keys https://packages.cloud.google.com/apt/doc/apt-key.gpg

sudo apt -y update && sudo apt -y upgrade

printf "\nAdding cgroup settings to /boot/cmdline.txt file\n"
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt


printf "\napt-get -y update\n"
sudo apt-get -y update

printf "\napt-get -y install dnsutils kubeadm\n"
sudo apt-get -y install dnsutils kubeadm

# Do some cleanup
printf "\napt -y autoremove\n"
sudo apt -y autoremove


printf "\nkubeadm init...\n"
sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr_me

printf "\nKubernetes config/startup...\n"
sudo -S -u $piid -i mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo -S -u $piid -i echo "export KUBECONFIG=${HOME}/.kube/config" >> ~/.bashrc
sudo -S -u $piid -i source ~/.bashrc

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    printf "\n\n-----------\n"
    printf "Configuring $host_target/$ip_target\n\n"

    if [ $ip_target != $ip_addr_me ]
    then
        # Run this code across all machines
        printf "Removing swapfile on $host_target.\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile swapoff
        sudo sshpass -p $pword ssh $piid@$ip_target sudo dphys-swapfile uninstall
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-rc.d dphys-swapfile remove
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y purge dphys-swapfile


        printf "Copying kubernetes.list to worker machine.\n"
        sudo sshpass -p $pword sudo scp "kubernetes.list"  $piid@$ip_target:
        printf "\nAdding link to Kubernetes repository and adding the APT key\n"
        # Add Kubernetes repository to the RPi package lists
        sudo sshpass -p $pword ssh $piid@$ip_target "sudo rm -f /etc/apt/sources.list.d/kubernetes.list"
        sudo sshpass -p $pword ssh $piid@$ip_target "sudo mv -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-key adv --fetch-keys https://packages.cloud.google.com/apt/doc/apt-key.gpg

        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt -y update && sudo apt -y upgrade

        printf "Backing up /boot/cmdline.txt\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

        sudo sshpass -p $pword ssh $piid@$ip_target echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt



        printf "\napt-get -y update\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y update

        printf "\napt-get -y install dnsutils kubeadm\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y install dnsutils kubeadm

        # Do some cleanup
        printf "\napt -y autoremove\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt -y autoremove



        printf "\nkubeadm init...\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr_me

        #printf "\nKubernetes config/startup...\n"
        #sudo sshpass -p $pword ssh $piid@$ip_target mkdir -p /home/$piid/.kube
        #sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -i /etc/kubernetes/admin.conf /home/$piid/.kube/config
        #sudo sshpass -p $pword ssh $piid@$ip_target sudo chown $(id -u):$(id -g) /home/$piid/.kube/config
        #sudo sshpass -p $pword ssh $piid@$ip_target echo "export KUBECONFIG=${HOME}/.kube/config" >> ~/.bashrc
        #sudo sshpass -p $pword ssh $piid@$ip_target source ~/.bashrc
    fi

done

. _worker_reboot.sh
