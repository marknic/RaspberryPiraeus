# RaspberryPiraeus
Piraeus on Docker in Kubernetes on Raspian (Debian) Linux on RPi Cluster

### Build/install Kubernetes on a Raspberry Pi Cluster
1. You can do all of the steps without cloning or copying all of the project files locally
2. Start in src/1-node-prep and set up all of the Raspberry Pi's that will be part of the cluster
2. Go to src/2-master and follow the instructions to create the master node
2. Go to src/3-worker and follow those instructions on each of the worker nodes

> Note: This was built and tested using 6 Raspberry Pi 3's --> 1 master and 5 worker nodes. The number of worker nodes does not have to be 5.  It is just the number of Pi's I had.
