#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    # Run this code across all machines
    sudo sshpass -p $pword ssh $id@$ip_target sudo dphys-swapfile swapoff
    sudo sshpass -p $pword ssh $id@$ip_target sudo dphys-swapfile uninstall
    sudo sshpass -p $pword ssh $id@$ip_target sudo update-rc.d dphys-swapfile remove
    sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -y purge dphys-swapfile

    sudo sshpass -p $pword ssh $id@$ip_target sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

    orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"

    sudo sshpass -p $pword ssh $id@$ip_target echo $orig | sudo tee /boot/cmdline.txt

    sudo sshpass -p $pword ssh $id@$ip_target curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 

    sudo sshpass -p $pword ssh $id@$ip_target echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

    sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -qy update

    sudo sshpass -p $pword ssh $id@$ip_target sudo apt-get -qy install kubeadm

    if [ $ip_target -eq $ip_addr_me ]
    then
        # Command specific to the Master
        sudo sshpass -p $pword ssh $id@$ip_target sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr
    else
        # Command specific to the Workers
        sudo sshpass -p $pword ssh $id@$ip_target sudo apt-mark kubelet kubeadm kubectl docker-ce
    fi

done

. _worker_reboot.sh