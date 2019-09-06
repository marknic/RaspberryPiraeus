#Disable Swap File - Kubernetes has issue with swap-file so there will be problems if it isn't disabled
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt -y purge dphys-swapfile

# Adding cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt


# Install Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

sudo apt-get update -q 

# Install KubeAdm
sudo apt-get install -qy kubeadm 

# Do some cleanup
sudo apt autoremove

# Pulls images required for setting up a Kubernetes cluster
kubeadm config images pull

# Master/Boss Node - Sets IP address and assumes "validated" version of Docker in the "preflight checks"
#  This command will likely take some time
# >>>>>>>>>>>>>>>>
# Change the IP address to whatever your master has been set to
sudo kubeadm init --apiserver-advertise-address=192.168.8.101
# >>>>>>>>>>>>>>>>

