#!/bin/bash

. _config_file.sh

print_instruction "      _       _                              "
print_instruction "     | | ___ (_)_ __                         "
print_instruction "  _  | |/ _ \| | !_ \                        "
print_instruction " | |_| | (_) | | | | |_                      "
print_instruction "  \___/ \___/|_|_| |_( )                     "
print_instruction "  _          _       |/ _      ___           "
print_instruction " | |    __ _| |__   ___| |    ( _ )          "
print_instruction " | |   / _! |  _ \ / _ \ |    / _ \/\        "
print_instruction " | |__| (_| | |_) |  __/ |_  | (_>  <        "
print_instruction " |_____\__,_|_.__/ \___|_( )  \___/\/        "
print_instruction "  _   _      _           |/         _        "
print_instruction " | \ | | ___| |___      _____  _ __| | __    "
print_instruction " |  \| |/ _ \ __\ \ /\ / / _ \|  __| |/ /    "
print_instruction " | |\  |  __/ |_ \ V  V / (_) | |  |   <     "
print_instruction " |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\  \n"

. _check_root.sh

. _array_setup.sh

#. _package_check.sh

 
print_instruction "Joining, Labeling, and adding the network support..."
print_instruction "Note: Make sure you allow enough time for the kubernetes services to spin up"
print_instruction "        before running this script.  Run 'kubectl get nodes' to make sure"
print_instruction "        the services are running."

while true; do
    printf "\n\nContinue? "
    read -p "(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer (y)es or (n)o.";;
    esac
done

joincmd=$(sudo kubeadm token create --print-join-command)

for ((i=0; i<$length; i++));
do
    get_ip_host_and_platform $i

    if [ $ip_target != $ip_addr_me ]
    then
        # Join the worker node to the cluster
        print_instruction "Join the node $ip_target/$host_target to the cluster..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo $joincmd"
        print_result $?


        # Label the node as a "worker"
        print_instruction "Labeling the node $ip_target/$host_target as a worker..."
            kubectl label node $host_target node-role.kubernetes.io/worker=worker
        print_result $?
    fi

done

print_instruction "Installing the network support (flannel)..."
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
print_result $?

