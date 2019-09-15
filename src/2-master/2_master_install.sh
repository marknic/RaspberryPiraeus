#!/bin/bash

# Run this script (as is):  sudo curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/2-master/2_master_install.sh | sh
# or
# Download the script for mods: curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/2-master/2_master_install.sh

# Disable Swap File - Kubernetes cannot be used with a swap-file so it is required to turn it off
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt -y purge dphys-swapfile

# Adding cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt


# Install Kubernetes
echo "Installing Kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

sudo apt -qy update 

# Install KubeAdm
sudo apt -qy install kubeadm 

# Do some cleanup
sudo apt -qy autoremove

# Get the IP address of this machine
ip_addr="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"

# Master Node - Sets IP address and assumes "validated" version of Docker in the "preflight checks"
# Initialize and change the IP address to whatever your master has been set to
sudo kubeadm init --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$ip_addr

echo "Reboot and then run 3_master_install.sh
