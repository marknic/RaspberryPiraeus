# RPi/Nano Kubernetes Cluster Networking

Piraeus on Docker in Kubernetes on Ubuntu Linux on RPi Cluster

## Notes

Kubernetes likes static IP addresses and while there are ways to get around that requirement, it is an assumption that static IP addresses will be used.  They are entered into the "inventory" file for Ansible to use.

- Raspberry Pi: https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md
- Jetson Nano: [Adding WiFi to the NVIDIA Jetson](https://www.bing.com/search?FORM=U527DF&PC=U527&q=Jetson+nano+wifi+setup)

## Assumptions

The cluster used to create the process and script was hard-wired to the network.  WiFi can be used and would be a slightly simpler configuration but the description below assumes a hard-wired network.


