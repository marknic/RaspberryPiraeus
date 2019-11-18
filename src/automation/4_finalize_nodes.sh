#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# output of kubeadm command will be used on workers
joincmd=$(sudo kubeadm token create --print-join-command)

# Load Flannel for networking - Note: Change this command if you don't want to use Flannel
printf "\nInstalling Flannel\n\n"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]
    then

        printf "\n\n-----------\n"
        printf "Joining $host_target/$ip_target to the Kubernetes Cluster\n\n"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo $joincmd

        # Label the worker nodes
        printf "\nLabeling worker: $host_target.\n"
        sudo kubectl label node $host_target node-role.kubernetes.io/worker=worker
    fi

done