#!/bin/bash

# Run this script (as is):  sudo curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/2-master/3_master_install.sh | sh
# or
# Download the script for mods: curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/2-master/3_master_install.sh

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Load Flannel for networking - Note: Change this command if you don't want to use Flannel
echo "Installing Flannel"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml


# Your master node should now be operational
# Test with: kubectl get nodes
