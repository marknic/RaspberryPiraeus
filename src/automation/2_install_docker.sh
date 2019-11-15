#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh


sudo apt-get update
sudo apt-get -y dist-upgrade

sudo apt-get install -y software-properties-common

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

sudo usermod pi -aG docker



for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]
    then
        # Remote machine so use ssh
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get update
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get -y dist-upgrade

        echo "$host_target/$ip_target: Installing package: software-properties-common"
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y software-properties-common

        echo "$host_target/$ip_target: Installing Docker-CE Docker-CE-CLI ContainerD"
        sudo sshpass -p $pword ssh $piid@$ip_target curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sshpass -p $pword ssh $piid@$ip_target sh get-docker.sh

        sudo sshpass -p $pword ssh $piid@$ip_target sudo usermod pi -aG docker
    fi
done


. _worker_reboot.sh

