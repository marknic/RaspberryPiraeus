#!/bin/bash

# READ THIS: This file is a bash script that will update the /etc/hosts file with all of the Kubernetes cluster node info (IP/hostname).
#   It also serves as input to some of the scripting that help to configure the cluster. 
#   So, by modifying this one file and using it across all of the process steps (master and worker nodes), 
#   it will make things much easier.  Note: this file exists in 3 folders including master and worker but it is exactly the same 
#   structure and data - it is also named the same across all folders.  One version is all you need.

# This script will update the hosts file for network communications.
#  update the IP addresses, the host names, for each of the k8s nodes
# make sure you make this call before running the script:

sudo echo '192.168.8.100  kub-master' >> /etc/hosts
sudo echo '192.168.8.101  kub-worker-01' >> /etc/hosts
sudo echo '192.168.8.102  kub-worker-02' >> /etc/hosts
sudo echo '192.168.8.103  kub-worker-03' >> /etc/hosts
sudo echo '192.168.8.104  kub-worker-04' >> /etc/hosts
sudo echo '192.168.8.105  kub-worker-05' >> /etc/hosts
