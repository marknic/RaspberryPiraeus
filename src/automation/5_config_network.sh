#!/bin/bash

. _config_file.sh

print_instruction "   ____             __ _                     "
print_instruction "  / ___|___  _ __  / _(_) __ _               "
print_instruction " | |   / _ \|  _ \| |_| |/ _' |              "
print_instruction " | |__| (_) | | | |  _| | (_| |              "
print_instruction "  \____\___/|_| |_|_| |_|\__, |              "
print_instruction "  _   _      _           |___/      _        "
print_instruction " | \ | | ___| |___      _____  _ __| | __    "
print_instruction " |  \| |/ _ \ __\ \ /\ / / _ \| v__| |/ /    "
print_instruction " | |\  |  __/ |_ \ V  V / (_) | |  |   <     "
print_instruction " |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\  \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

print_instruction "\nUpdate & configure kubernetes..."

print_instruction "\nUpdate..."
    sudo apt-get clean
print_result $?

print_instruction "\nUpdate..."
    sudo apt-get update
print_result $?

print_instruction "\nUpgrade..."
    sudo apt-get -y dist-upgrade
print_result $?

if [ -e kubiniterr.flg ]
then
    print_instruction "\nkubeadm reset..."
        sudo kubeadm reset -f
    print_result $?
fi

if ! -e kubinitok.flg ]
then
    print_instruction "\nkubeadm init setting advertise-address=$ip_addr_me and network-cidr=10.244.0.0/16..."
        sudo kubeadm init --apiserver-advertise-address=$ip_addr_me --pod-network-cidr=10.244.0.0/16
        result=$?

        if [ result -ne 0 ]
        then
            touch kubiniterr.flg
        else
            rm -f kubiniterr.flg
            touch kubinitok.flg
        fi

    print_result $result
fi

print_instruction "\nmkdir .kube as pi..."
    sudo runuser -l $piid -c "mkdir -p /home/$piid/.kube"
print_result $?

print_instruction "\nCopy admin.conf to .kube/config..."
    sudo cp /etc/kubernetes/admin.conf /home/$piid/.kube/config
print_result $?

print_instruction "\nchown .kube/config..."
    sudo runuser -l $piid -c "sudo chown $piid:$piid home/$piid/.kube/config"
print_result $?

print_instruction "\nAdding KUBECONFIG env var to .bashrc..."
    sudo echo "export KUBECONFIG=/home/$piid/.kube/config" >> .bashrc
    source .bashrc
print_result $?


sudo rm -f /etc/kubernetes/manifests/*
sudo rm -f /etc/kubernetes/kubelet.conf

for n in 10250 10251 10252
do
  print_instruction "Port $n"
    kill_process_if_port_used $n
  print_result $?
done


# output of kubeadm command will be used on workers
joincmd=$(sudo kubeadm token create --print-join-command)

print_instruction "\nInstalling Flannel\n\n"
runuser -l $piid -c "sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

print_instruction "\nkubectl get pods..."
    sudo runuser -l $piid -c "kubectl get pods --all-namespaces"
print_result $?

print_instruction "\nExiting!!!"
exit
for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ $ip_target != $ip_addr_me ]
    then
        host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

        print_instruction "Joining $host_target/$ip_target to the Kubernetes Cluster\n"
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo $joincmd"
        print_result $?

        # Label the worker nodes
        print_instruction "\nLabeling worker: $host_target.\n"
            sudo kubectl label node $host_target node-role.kubernetes.io/worker=worker
        print_result $?
    fi

done


print_instruction "\nRun 'kubectl get nodes' to see the cluster.\n"

