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

print_instruction "\nUpdate & configure kubernetes..."

sudo apt-get update
sudo apt-get -y dist-upgrade

print_instruction "\nkubeadm init...\n"
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

runuser -l $piid -c 'mkdir -p $HOME/.kube'
cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# output of kubeadm command will be used on workers
joincmd=$(sudo kubeadm token create --print-join-command)

print_instruction "\nInstalling Flannel\n\n"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl get pods --all-namespaces



for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ $ip_target != $ip_addr_me ]
    then
        host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

        print_instruction "\n\n-----------\n"
        print_instruction "Joining $host_target/$ip_target to the Kubernetes Cluster\n\n"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo $joincmd

        # Label the worker nodes
        print_instruction "\nLabeling worker: $host_target.\n"
        sudo kubectl label node $host_target node-role.kubernetes.io/worker=worker
    fi

done


. _worker_reboot.sh