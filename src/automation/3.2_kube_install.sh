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

print_instruction "\nUpdate & install kubelet kubeadm kubectl"

x=1

while [ $x -le 5 ]
do
    print_instruction "Updating the master node..."
    count=sudo apt update | grep -c "404  Not Found"

    if (( count >= 0 ))
    then
        x=10
        print_instruction "Update complete!"
    else
        print_instruction "Counting..."
        x=$(( $x + 1 ))
    fi
done

print_instruction "\nUpgrading...\n"
sudo apt-get -y upgrade

print_instruction "\nInstalling kubelet kubeadm kubectl...\n"
sudo apt install -y kubelet kubeadm kubectl

print_instruction "\nkubeadm init...\n"
sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr_me

print_instruction "Configuring Kubernetes with local user"
echo $piid > piid.txt
sudo -u $piid sh ./_kube_config.sh

#sudo apt-mark hold kubelet kubeadm kubectl

# Do some cleanup
print_instruction "\nDo some cleanup: autoremove\n"
sudo apt-get -y autoremove

print_instruction "\n Done installing on the master node. \n"


read -rsn1 -p "Press any key to setup worker nodes..." keypressed; echo "";


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

        print_instruction "\nUpdate and upgrade"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y upgrade

        print_instruction "\nAdding link to Kubernetes repository and adding the APT key\n"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo wget https://packages.cloud.google.com/apt/doc/apt-key.gpg
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-key add apt-key.gpg

        print_instruction "\nModify iptables"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
        sudo sshpass -p $pword ssh $piid@$ip_target sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

        print_instruction "\nCreate a support file that will be copied to the nodes"
        #sudo sshpass -p $pword ssh $piid@$ip_target sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee kubernetes.list
        sudo sshpass -p $pword scp kubernetes.list $piid@$ip_target:

        print_instruction "\nAdd Kubernetes repository to the RPi package lists"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo rm -f /etc/apt/sources.list.d/kubernetes.list
        sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list

        sudo sshpass -p $pword ssh $piid@$ip_target sudo echo 'Acquire::https::packages.cloud.google.com::Verify-Peer "false";' > apt.conf
        sudo sshpass -p $pword ssh $piid@$ip_target sudo rm -f /etc/apt/apt.conf
        sudo sshpass -p $pword ssh $piid@$ip_target sudo cp -f apt.conf /etc/apt/

        print_instruction "Install kubelet kubeadm."
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y kubelet kubeadm

    fi

done

. _worker_reboot.sh