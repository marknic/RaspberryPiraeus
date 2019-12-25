#!/bin/bash

piid=`cat piid.txt`

printf "\npiid: ${piid}\n"
printf "\nHOME: ${HOME}\n"

# This script needs to run as the user "$piid" not root/sudo
#  so it was put into a file and is run with the command: "sudo -u $piid ./_kube_config.sh"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo -S -u $piid -i echo "export KUBECONFIG=${HOME}/.kube/config" >> ~/.bashrc
sudo -S -u $piid -i source ~/.bashrc
