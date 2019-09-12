#!/bin/bash

# Run this script (as is):  sudo curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/2-master/master-install-03.sh | sh
# or
# Download the script for mods: curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/2-master/master-install-03.sh

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Your master node should now be operational
# Test with: kubectl get nodes
