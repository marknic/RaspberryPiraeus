#!/bin/bash

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# >>>>>>>>>>>>>>>>
# This will install Weave for networking within kubernetes - use your own option if you wish
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# >>>>>>>>>>>>>>>>


# Your master node should now be operational
# Test with: kubectl get nodes
