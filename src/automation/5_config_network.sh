#!/bin/bash

. _config_file.sh

print_instruction " _______  _____  __   _ _______ _____  ______    "
print_instruction " |       |     | | \  | |______   |   |  ____    "
print_instruction " |_____  |_____| |  \_| |       __|__ |_____|  \n"
print_instruction " __   _ _______ _______ _  _  _  _____   ______ _     _   "
print_instruction " | \  | |______    |    |  |  | |     | |_____/ |____/    "
print_instruction " |  \_| |______    |    |__|__| |_____| |    \_ |    \_ \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

print_instruction "\nUpdate & configure kubernetes..."

sudo apt-get update
sudo apt-get -y dist-upgrade

print_instruction "\nkubeadm init...\n"
sudo kubeadm init --apiserver-advertise-address=$ip_addr_me --pod-network-cidr=10.244.0.0/16

print_instruction "\nmkdir as pi\n"
runuser -l $piid -c "mkdir -p /home/$piid/.kube"

print_instruction "\nCopy\n"
sudo cp /etc/kubernetes/admin.conf /home/$piid/.kube/config

print_instruction "\nchown\n"
runuser -l $piid -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'


# output of kubeadm command will be used on workers
joincmd=$(sudo kubeadm token create --print-join-command)

print_instruction "\nInstalling Flannel\n\n"
runuser -l $piid -c "sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

runuser -l $piid -c "kubectl get pods --all-namespaces"



for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ $ip_target != $ip_addr_me ]
    then
        host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

        print_instruction "\n\n-----------\n"
        print_instruction "Joining $host_target/$ip_target to the Kubernetes Cluster\n\n"

        sudo sshpass -p $pword ssh $piid@$ip_target "sudo $joincmd"

        # Label the worker nodes
        print_instruction "\nLabeling worker: $host_target.\n"
        sudo kubectl label node $host_target node-role.kubernetes.io/worker=worker
    fi

done


print_instruction "\nRun 'kubectl get nodes' to see the cluster.\n"
