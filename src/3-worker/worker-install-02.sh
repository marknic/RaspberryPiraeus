#!/bin/sh

# This installs the base instructions up to the point of joining / creating a cluster

# To run this command:
#  sudo curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/3-worker/worker-install-02.sh | sh
# To verify installation:
# pi@kub-master:~ $ apt list --installed | grep kube
# 
# Sample Output:
# WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
# 
# cri-tools/kubernetes-xenial,now 1.13.0-00 armhf [installed,automatic]
# kubeadm/kubernetes-xenial,now 1.15.3-00 armhf [installed]
# kubectl/kubernetes-xenial,now 1.15.3-00 armhf [installed,automatic]
# kubelet/kubernetes-xenial,now 1.15.3-00 armhf [installed,automatic]
# kubernetes-cni/kubernetes-xenial,now 0.7.5-00 armhf [installed,automatic]

# pi@kub-master:~ $ apt list --installed | grep docker
#
# WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
#
# docker-ce-cli/now 5:18.09.7~3-0~debian-buster armhf [installed,local]
# docker-ce/now 5:18.09.7~3-0~debian-buster armhf [installed,local]

# Kubernetes does not work with a swapfile so it needs to be disabled completely
# When these commands are done, you can verify that the swap file is gone with
#  this command:  sudo swapon --summary
#  there should be no output
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt -y purge dphys-swapfile

# Add the GPG key to APT
# Add the kubernetes package to the apt repository list
# Update the packages list
# Install kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get -q update && \
  sudo apt-get -qy install kubeadm

# Keep apt from updating these packages.  Kubernetes should be doing that.
sudo apt-mark kubelet kubeadm kubectl docker-ce

echo Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt

sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt

echo "Reboot and then run kubeadm join command"
