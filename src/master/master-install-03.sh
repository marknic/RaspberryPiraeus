#!/bin/bash

mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# >>>>>>>>>>>>>>>>
# This will install Weave for networking within kubernetes - use your own option if you wish
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# >>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>
# Replace the following line with the output from the kubeadm init command
sudo kubeadm join 192.168.8.101:6443 --token YOURTOKEN \
    --discovery-token-ca-cert-hash sha256:YOURHASH
# >>>>>>>>>>>>>>>>

# Your master node should now be operational
# Test with: kubectl get nodes
