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

print_instruction "\nmkdir as pi\n"
runuser -l $piid -c "mkdir -p /home/$piid/.kube"

print_instruction "\nCopy\n"
sudo cp /etc/kubernetes/admin.conf /home/$piid/.kube/config

print_instruction "\nchown\n"
runuser -l $piid -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'


# output of kubeadm command will be used on workers
joincmd=$(sudo kubeadm token create --print-join-command)

print_instruction "\nInstalling Flannel\n\n"
runuser -l $piid -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

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

        sudo sshpass -p $pword ssh $piid@$ip_target sudo runuser -l $piid -c $joincmd

        # Label the worker nodes
        print_instruction "\nLabeling worker: $host_target.\n"
        runuser -l $piid -c "kubectl label node $host_target node-role.kubernetes.io/worker=worker"
    fi

done


print_instruction "\nRun 'kubectl get nodes' to see the cluster.\n"
