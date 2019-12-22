#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh


# Run this code on the master
printf "\nRemoving the swap file on $ip_addr_me\n"
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt-get -y purge dphys-swapfile

sudo apt update
sudo apt upgrade -y

sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy


sudo apt-get update && sudo apt-get install -y apt-transport-https curl


printf "\nAdding link to Kubernetes repository and adding the APT key\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Create a support file that will be copied to the nodes
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee kubernetes.list


# Add Kubernetes repository to the RPi package lists
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo cp -f kubernetes.list /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl


printf "\nKubernetes config/startup...\n"
sudo -S -u $piid -i mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo -S -u $piid -i echo "export KUBECONFIG=${HOME}/.kube/config" >> ~/.bashrc
sudo -S -u $piid -i source ~/.bashrc

sudo apt-mark hold kubelet kubeadm kubectl

printf "\nkubeadm init...\n"
sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr_me

