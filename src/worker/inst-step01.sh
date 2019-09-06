#!/bin/bash

# Run sudo apt-get update and sudo apt-get upgrade prior to running this script
# To run this command:
#  sudo curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/worker/inst-step01.sh | sh

# Install Docker - Version 18.09 (this is the latest validated version as of 9/5/19
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/containerd.io_1.2.6-3_armhf.deb
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/docker-ce-cli_18.09.7~3-0~debian-buster_armhf.deb
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/docker-ce_18.09.7~3-0~debian-buster_armhf.deb

sudo dpkg -i containerd.io_1.2.6-3_armhf.deb
sudo dpkg -i docker-ce-cli_18.09.7~3-0~debian-buster_armhf.deb
sudo dpkg -i docker-ce_18.09.7~3-0~debian-buster_armhf.deb

sudo usermod pi -aG docker

echo "Reboot and then run inst-step02.sh"

