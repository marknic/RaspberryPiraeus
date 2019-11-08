#!/bin/bash

. _check_root.sh

chmod +x 1_setup_host_ssh.sh
chmod +x 2_setup_net_ip.sh
chmod +x 3_install_docker.sh
chmod +x 4_install_kubernetes.sh
chmod +x 5_finalize_nodes.sh

# Set up an alias making it easier to get to the script folder
if ! cat ~/.bashrc | grep 'alias rp'
then
    sudo echo "alias rp='cd RaspberryPiraeus/src/automation/'" >> ~/.bashrc
fi
