#!/bin/bash

# Download the script for mods: curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/3-worker/4_update_hosts.sh

# This script will update the hosts file for network communications.
#  update the IP addresses, the host names, for each of the k8s nodes
# make sure you make this call before running the script:
#  sudo chmod +x 4_update_hosts.sh
#  Then, call it:
# sudo ./4_update_hosts.sh

echo '192.168.8.101   kub-master' >> /etc/hosts
echo '192.168.8.102   kub-worker-01' >> /etc/hosts
echo '192.168.8.103   kub-worker-02' >> /etc/hosts
echo '192.168.8.104   kub-worker-03' >> /etc/hosts
echo '192.168.8.105   kub-worker-04' >> /etc/hosts
echo '192.168.8.106   kub-worker-05' >> /etc/hosts

