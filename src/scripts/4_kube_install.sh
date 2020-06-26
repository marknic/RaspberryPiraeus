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

. _array_setup.sh


print_instruction "\nCreating support file for k8s: kubernetes.list"
# Create a support file that will be copied to the nodes



for ((i=0; i<$length; i++));
do

    get_ip_host_and_platform $i

    if [ $ip_target == $ip_addr_me ]; then callLocation="-l"; else callLocation="-r"; fi

    # Add Kubernetes repository
    #
    execute_command $callLocation -1 "test -f $kub_list"
    result=$?

    if [ $ip_target == $ip_addr_me ]; then
        if [ $result -ne 0 ]; then
            print_instruction "Creating $kub_list..."
                sudo cp $FILE_KUB_LIST_DATA $kub_list
            print_result $?
        fi
    else
        if [ $result -ne 0 ]; then
            print_instruction "\nCopy kubernetes.list to the worker: $host_target..."
                sudo sshpass -p $pword scp -p -r $FILE_KUB_LIST_DATA $piid@$ip_target:$FILE_KUB_LIST_DATA
            print_result $?

            print_instruction "\nCopy kubernetes.list to the correct folder..."
                sudo sshpass -p $pword ssh $piid@$ip_target "sudo cp $FILE_KUB_LIST_DATA $kub_list"
            print_result $?
        fi
    fi

    # Add the GPG key
    print_instruction "\nAdding link to Kubernetes repository and adding the APT key...\n"
        execute_command $callLocation -1 "sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -"
    print_result $?


    print_instruction "\nUpdating and checking for installation keys on: $host_target..."
        execute_command $callLocation -1 "sudo apt-get update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p'" > keys.txt
    print_result $?

    # Just in case the keys aren't loaded, check for it and then use those keys to indicate
    # what needs to be installed
    cat keys.txt |
    while read key;
    do
        print_instruction "\nReplacing missing key: $key ..."
            execute_command $callLocation -1 "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "'"'"$key"'"'
        print_result $?
    done

    print_instruction "Update..."
        execute_command $callLocation -1 "sudo apt-get update"
    print_result $?
    print_instruction "Upgrade..."
        execute_command $callLocation -1 "sudo apt-get -y --fix-missing upgrade"
    print_result $?

    # Installing Kubernetes (kubeadm/kubectl/kubelet)
    print_instruction "\nInstall kubeadm kubectl kubelet..."

    result=0

    install_and_validate_package $callLocation kubeadm
    if [ $? -ne 0 ]; then result=1; fi

    install_and_validate_package $callLocation kubectl

    install_and_validate_package $callLocation kubelet


    if [ $ip_target == $ip_addr_me ]; then
        if [ $result -ne 0 ]
        then
            print_warning "The install of Kubernetes was not successful on the master: $ip_addr_me. Skipping the initialization step... "
        else
            print_instruction "\nkubeadm init setting advertise-address=$ip_addr_me and network-cidr=10.244.0.0/16..."

            # kubeadm init
            # Using a file to flag that the init step has already run
            if [ ! -f "/home/$piid/$kubeadminitdonefile" ]
                # Init with the full preflight checks
                sudo kubeadm init --apiserver-advertise-address=$ip_addr_me --pod-network-cidr=10.244.0.0/16
                result=$?

                if [ $result -ne 0 ]
                then
                    # If we've tried once and partially succeeded and yet failed - try again without the preflight checks
                    sudo kubeadm init --apiserver-advertise-address=$ip_addr_me --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all
                    result=$?
                else
                    touch "/home/$piid/$kubeadminitdonefile"
                fi
            else
                print_instruction "\nkubeadm init has already been done.  Skipping the init step..."
                result=0
            fi

            print_result $result

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
    fi
done

