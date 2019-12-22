#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh


# output of kubeadm command will be used on workers
joincmd=$(sudo kubeadm token create --print-join-command)

# Load Flannel for networking - Note: Change this command if you don't want to use Flannel
printf "\nInstalling Flannel\n\n"
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

# One of these...
#sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sudo curl -sSL https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml | sed "s/amd64/arm64/g" | kubectl create -f -

#sudo kubectl taint nodes $(hostname) node-role.kubernetes.io/master=true:NoSchedule
#sudo kubectl label node $(hostname) kubernetes.io/role=master node-role.kubernetes.io/master=

#sudo iptables -P FORWARD ACCEPT
#sudo update-alternatives --set iptables /usr/sbin/iptables-legacy


# Delete network interface(s) that match 'master cni0'
#ip link show 2>/dev/null | grep 'master cni0' | while read ignore iface ignore; do
#    iface=${iface%%@*}
#    [ -z "$iface" ] || ip link delete $iface
#done
#ip link delete cni0
#ip link delete flannel.1
#rm -rf /var/lib/cni/
#iptables-save | grep -v KUBE- | grep -v CNI- | iptables-restore


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]
    then
        sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-mark hold kubelet kubeadm kubectl docker-ce

        printf "\n\n-----------\n"
        printf "Joining $host_target/$ip_target to the Kubernetes Cluster\n\n"

        sudo sshpass -p $pword ssh $piid@$ip_target sudo $joincmd

        # Label the worker nodes
        printf "\nLabeling worker: $host_target.\n"
        sudo kubectl label node $host_target node-role.kubernetes.io/worker=worker
    fi

done
