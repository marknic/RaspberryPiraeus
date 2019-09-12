#!/bin/bash

# This script will update the hosts file for network communications.
#  update the IP addresses, the host names, for each of the k8s nodes
# Download the script:
# wget https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/worker/update-hosts.sh
# make sure you make this call before running the script:
#  sudo chmod +x update-hosts.sh
#  Then, call it:
# sudo ./update-hosts.sh

echo '192.168.8.101   kub-master' >> /etc/hosts
echo '192.168.8.102   kub-worker-01' >> /etc/hosts
echo '192.168.8.103   kub-worker-02' >> /etc/hosts
echo '192.168.8.104   kub-worker-03' >> /etc/hosts
echo '192.168.8.105   kub-worker-04' >> /etc/hosts
echo '192.168.8.106   kub-worker-05' >> /etc/hosts

