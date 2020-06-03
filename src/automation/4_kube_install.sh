#!/bin/bash

. _config_file.sh

print_instruction "  _  __     _                          _                 "
print_instruction " | |/ /   _| |__   ___ _ __ _ __   ___| |_ ___  ___      "
print_instruction " | ! / | | | !_ \ / _ \ !__| !_ \ / _ \ __/ _ \/ __|     "
print_instruction " | . \ |_| | |_) |  __/ |  | | | |  __/ ||  __/\__ \     "
print_instruction " |_|\_\__,_|_.__/ \___|_|  |_| |_|\___|\__\___||___/     "
print_instruction "  ___           _        _ _      __                     "
print_instruction " |_ _|_ __  ___| |_ __ _| | |    / /                     "
print_instruction "  | || !_ \/ __| __/ _! | | |   / /                      "
print_instruction "  | || | | \__ \ || (_| | | |  / /                       "
print_instruction " |___|_| |_|___/\__\__,_|_|_| /_/                        "
print_instruction "  ____       _                                           "
print_instruction " / ___|  ___| |_ _   _ _ __                              "
print_instruction " \___ \ / _ \ __| | | | !_ \                             "
print_instruction "  ___) |  __/ |_| |_| | |_) |                            "
print_instruction " |____/ \___|\__|\__,_| .__/                             "
print_instruction "                      |_|                              \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

print_instruction "\nCreating support file for k8s: kubernetes.list"
# Create a support file that will be copied to the nodes

if [ ! -f $kub_list ]; then
    print_instruction "Creating $kub_list..."
        sudo cp $FILE_KUB_LIST_DATA $kub_list
    print_result $?
fi

print_instruction "\nAdding link to Kubernetes repository and adding the APT key...\n"
    sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
print_result $?

print_instruction "\nUpdating and checking for installation keys."
# Just in case the keys aren't loaded, check for it and then use those keys to indicate
# what needs to be installed
sudo apt-get update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' |
while read key;
do
    print_instruction "\nUpdating key: $key."
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$key"
    print_result $?
done

print_instruction "Update..."
    sudo apt-get --fix-missing update
print_result $?
print_instruction "Upgrade..."
    sudo apt-get -y --fix-missing upgrade
print_result $?

# Installing Kubernetes (kubeadm/kubectl/kubelet)
print_instruction "\nInstall kubeadm kubectl kubelet..."

result=0

install_package kubeadm
if [ $? -ne 0 ]; then result=1; fi

install_package kubectl
if [ $? -ne 0 ]; then result=1; fi

install_package kubelet
if [ $? -ne 0 ]; then result=1; fi


if [ $result -ne 0 ]
then
    print_warning "The install of Kubernetes was not successful on the master: $ip_addr_me. Skipping the initialization step... "
else
    print_instruction "\nkubeadm init setting advertise-address=$ip_addr_me and network-cidr=10.244.0.0/16..."
        if [ -f /etc/kubernetes/manifests/kube-apiserver.yaml ]
        then  # If we've tried once and partially succeeded and yet failed - try again without the preflight checks
            sudo kubeadm init --apiserver-advertise-address=$ip_addr_me --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all
        else  # Init with the full preflight checks
            sudo kubeadm init --apiserver-advertise-address=$ip_addr_me --pod-network-cidr=10.244.0.0/16
        fi
    print_result $?

    # Need to run this as $piid (pi) but we're running as root with sudo so...runuser
    print_instruction "\nmkdir .kube as pi..."
        sudo runuser -l $piid -c "mkdir -p /home/$piid/.kube"
    print_result $?

    print_instruction "\nCopy admin.conf to .kube/config..."
        sudo cp /etc/kubernetes/admin.conf /home/$piid/.kube/config
    print_result $?

    print_instruction "\nchown .kube/config..."
        sudo runuser -l $piid -c "sudo chown $piid:$piid /home/$piid/.kube/config"
    print_result $?
fi

joincmd=$(sudo kubeadm token create --print-join-command)

sudo $joincmd


for ((i=0; i<$length; i++));
do

    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ $ip_target != $ip_addr_me ]
    then
        host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

        print_instruction "Configuring $host_target/$ip_target\n"

        print_instruction "Checking to see if $kub_list already exists..."
        sudo sshpass -p $pword ssh $piid@$ip_target test -f $kub_list

        if [ $? -ne 0 ]; then
            print_instruction "\nCopy kubernetes.list to the worker: $host_target..."
                sudo sshpass -p $pword scp -p -r $FILE_KUB_LIST_DATA $piid@$ip_target:$FILE_KUB_LIST_DATA
            print_result $?

            print_instruction "\nCopy kubernetes.list to the correct folder..."
                sudo sshpass -p $pword ssh $piid@$ip_target "sudo cp $FILE_KUB_LIST_DATA $kub_list"
            print_result $?
        fi


        print_instruction "\nAdding link to Kubernetes repository and adding the APT key"
            sudo sshpass -p $pword ssh $piid@$ip_target sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        print_result $?

        rm -f keys.txt


        print_instruction "\nUpdating and checking for installation keys on: $host_target..."
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo apt-get update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p'" > keys.txt
        print_result $?


        cat keys.txt |
        while read key;
        do
            print_instruction "\nReplacing missing key: $key ..."
                sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$key"
            print_result $?

        done

        print_instruction "Update..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get --fix-missing update
        print_result $?

        print_instruction "Upgrade..."
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y --fix-missing upgrade
        print_result $?


        # Installing Kubernetes (kubeadm/kubectl/kubelet)

        result=0

        install_package_remote kubeadm
        if [ $? -ne 0 ]; then result=1; fi

        install_package_remote kubectl
        if [ $? -ne 0 ]; then result=1; fi

        install_package_remote kubelet
        if [ $? -ne 0 ]; then result=1; fi

        if [ $result -eq 0 ]
        then
            sudo sshpass -p $pword ssh $piid@$ip_target "sudo $joincmd"
        else
            print_warning "At least one of the Kubernetes packages failed to install properly."
            print_warning "  Skipping the join command..."
        fi
    fi
done

