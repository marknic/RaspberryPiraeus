# Nvidia Jetson Nano Setup

Piraeus on Docker in Kubernetes on Ubuntu Linux on RPi Cluster (including optional NVidia Jetson Nano)

## Setup NVidia Jetson Nano (Do this first)

If you want to add NVidia Jetson Nano machines to the Kubernetes cluster (for machine learning containers), then you'll need to do some preliminary setup on each Nano to make the communication and setup work.

1. Go [here](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit#prepare) to install the Jetson OS image on an SD card
2. Power up the Nano with keyboard and mouse to do the setup
3. Setup process on the Nano (Ubuntu)
   1. Accept license
   2. Choose desired language
   3. Select keyboard layout
   4. Select local time zone
   5. "Who are you"
      1. Name: any name will do
      2. Computer's name: enter a name for the computer - this name will be set to an "official" cluster name during the Ansible setup process
      3. Username: "ubuntu" <-- this will make the login the same as the Raspberry Pi's and is expected by the Ansible setup process
      4. Password: "ubuntu" <-- this will make the login the same as the Raspberry Pi's and is expected by the Ansible setup process

***The Nano is now set up enough to run the Ansible Kubernetes setup process**
