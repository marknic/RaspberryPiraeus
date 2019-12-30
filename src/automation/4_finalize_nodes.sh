#!/bin/bash

. _config_file.sh

print_instruction " _______ _____ __   _ _______        _____ ______ _______"
print_instruction " |______   |   | \  | |_____| |        |    ____/ |______"
print_instruction " |       __|__ |  \_| |     | |_____ __|__ /_____ |______\n"

print_instruction " __   _  _____  ______  _______ _______"
print_instruction " | \  | |     | |     \ |______ |______"
print_instruction " |  \_| |_____| |_____/ |______ ______|\n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

# output of kubeadm command will be used on workers
joincmd=$(sudo kubeadm token create --print-join-command)

# Load Flannel for networking - Note: Change this command if you don't want to use Flannel
print_instruction "\nInstalling Flannel\n\n"
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

# One of these...
#sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sudo curl -sSL https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml | sed "s/amd64/arm64/g" | kubectl create -f -


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]
    then
        print_instruction "\n\n-----------\n"
        print_instruction "Joining $host_target/$ip_target to the Kubernetes Cluster\n\n"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo $joincmd

        # Label the worker nodes
        print_instruction "\nLabeling worker: $host_target.\n"
        sudo kubectl label node $host_target node-role.kubernetes.io/worker=worker
    fi

done
