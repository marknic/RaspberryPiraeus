#!/bin/bash

# Disable Swap File - Kubernetes has issue with swap-file so there will be problems if it isn't disabled
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt -y purge dphys-swapfile

# Adding cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt


# Install Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

sudo apt-get update -q 

# Install KubeAdm
sudo apt-get install -qy kubeadm 

# Do some cleanup
sudo apt autoremove

# Reset to start
sudo kubeadm reset

# Pulls images required for setting up a Kubernetes cluster
kubeadm config images pull

# Master Node - Sets IP address and assumes "validated" version of Docker in the "preflight checks"
#  This command will likely take some time
# >>>>>>>>>>>>>>>>
# Initialize and change the IP address to whatever your master has been set to

sudo kubeadm init phase certs all
sudo kubeadm init phase kubeconfig all
sudo kubeadm init phase control-plane all --pod-network-cidr 10.244.0.0/16

sudo sed -i 's/initialDelaySeconds: [0-9][0-9]/initialDelaySeconds: 240/g' /etc/kubernetes/manifests/kube-apiserver.yaml
sudo sed -i 's/failureThreshold: [0-9]/failureThreshold: 18/g'             /etc/kubernetes/manifests/kube-apiserver.yaml
sudo sed -i 's/timeoutSeconds: [0-9][0-9]/timeoutSeconds: 20/g'            /etc/kubernetes/manifests/kube-apiserver.yaml

sudo kubeadm init --v=1 --skip-phases=certs,kubeconfig,control-plane --ignore-preflight-errors=all --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.8.100

# Load Flannel for networking - Note: Change this command if you don't want to use Flannel
curl -sSL https://rawgit.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml | sed "s/amd64/arm/g" | kubectl create -f -


