#!/bin/bash

sudo apt-get update
sudo apt-get upgrade


# Install Docker - Version 18.09 (this is the latest validated version as of 9/5/19
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/containerd.io_1.2.6-3_armhf.deb
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/docker-ce-cli_18.09.7~3-0~debian-buster_armhf.deb
wget https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/docker-ce_18.09.7~3-0~debian-buster_armhf.deb

sudo dpkg -i containerd.io_1.2.6-3_armhf.deb
sudo dpkg -i docker-ce-cli_18.09.7~3-0~debian-buster_armhf.deb
sudo dpkg -i docker-ce_18.09.7~3-0~debian-buster_armhf.deb

sudo usermod pi -aG docker

echo "Logout and back in and then run inst-step02.sh"

