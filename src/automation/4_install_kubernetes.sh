#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    printf "Configuring $host_target/$ip_target\n\n"

    if [ $ip_target = $ip_addr_me ]
    then
        # Run this code across all machines
        sudo dphys-swapfile swapoff
        sudo dphys-swapfile uninstall
        sudo update-rc.d dphys-swapfile remove
        sudo apt-get -y purge dphys-swapfile

        sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

        echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt
        
        printf "\n"

        wget -q https://packages.cloud.google.com/apt/doc/apt-key.gpg 
        sudo apt-key add apt-key.gpg

        echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 
        
        printf "\n"

        sudo apt-get -qy update

        sudo apt-get -qy install kubeadm

        sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr_me

    else

        # Run this code across all machines
        sudo sshpass -p $pword ssh $id@$ip_target sudo dphys-swapfile swapoff
        sudo sshpass -p $pword ssh $id@$ip_target sudo dphys-swapfile uninstall
        sudo sshpass -p $pword ssh $id@$ip_target sudo update-rc.d dphys-swapfile remove
        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -y purge dphys-swapfile

        sudo sshpass -p $pword ssh $id@$ip_target sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

        sudo sshpass -p $pword ssh $id@$ip_target echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt
        
        printf "\n"

        sudo sshpass -p $pword ssh $id@$ip_target wget -q https://packages.cloud.google.com/apt/doc/apt-key.gpg 
        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-key add apt-key.gpg

        sudo sshpass -p $pword ssh $id@$ip_target echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 
        
        printf "\n"

        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -qy update

        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -qy install kubelet
        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -qy install kubectl
        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -qy install kubeadm

        # Command specific to the Workers
        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-mark hold kubelet kubeadm kubectl docker-ce
    fi

done

. _worker_reboot.sh