# RaspberryPiraeus

Piraeus on Docker in Kubernetes on Raspbian (Debian) or Ubuntu Linux on RPi Cluster

## Build/install Kubernetes on a Raspberry Pi Cluster

1. Is SSH enabled on your laptop?

2. Enable SSH on all RPi's
    a. Login (pi/raspberry)
    b. Enter these commands:
    ***sudo systemctl enable ssh
    ***sudo systemctl start ssh
    ***logout

3. Windows: check to see if known_hosts contains an ssh key and if the Rpi's are already listed.  If so, remove them and start over.
    a. Use this command to see if an IP address is already listed in the Known Hosts (SSH) file.  If the IP is already listed, and you're starting up an RPi using that IP, SSH will not connect properly
    findstr /c:192.168.8.100 C:\Users\nicho\.ssh\known_hosts

    b. Use these commands to remove the IP Addresses from Known Hosts file
    type C:\Users\nicho\.ssh\known_hosts | findstr /v 192.168.8.100 | findstr /v 192.168.8.101 > C:\Users\nicho\.ssh\known_hosts.txt
    del C:\Users\nicho\.ssh\known_hosts
    ren C:\Users\nicho\.ssh\known_hosts.txt known_hosts

4. Copy SSH Key Linux to Linux
    a. # Remove the known host info before copy
    sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.8.101"
    b. Copy the key over
    sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.8.101

5. Setup SSH from Windows (Remove's password requirement.   This is optional but will make things much easier.)
    a. Create SSH keys: Lots of articles on this subject on the internet:
        https://www.onmsft.com/how-to/how-to-generate-an-ssh-key-in-windows-10
        https://www.techrepublic.com/blog/10-things/how-to-generate-ssh-keys-in-openssh-for-windows-10/
        https://www.maketecheasier.com/generate-ssh-public-private-keys-windows/
        https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/create-with-putty/
        No need to beat that equine any further.

    b. Copy the SSH key to RPi or Ubuntu machine :
    RPi:
    type  %HOMEPATH%\.ssh\id_rsa.pub | ssh pi@192.168.8.100 "sudo cat >> ~/.ssh/authorized_keys"

    Ubuntu:
    type  %HOMEPATH%\.ssh\id_rsa.pub | ssh ubuntu@192.168.8.101 "sudo cat >> ~/.ssh/authorized_keys"

6. SSH into the "master node"
    a. If you followed the steps above, the following command should be all that is necessary to log in to the master node.
    ssh pi@192.168.8.100  <--- This was the master node IP address on my system

7. Update/Upgrade the OS - Reset/Update/Upgrade the OS:
    sudo apt-get update
    sudo apt-get -y --fix-missing dist-upgrade

8. Install Git
    sudo apt-get -y install git

9. Clone the RaspberryPiraeus repo
    git clone https://github.com/marknic/RaspberryPiraeus.git

10. Switch to automation (scripting) folder
    a. Create an alias to make this easier:
    echo "alias cdpi='cd ~/RaspberryPiraeus/src/automation/'" >> .bashrc
    source .bashrc
    b. Now you can just type cdpi to get to the script folder
    cdpi

    echo "alias cdpi='cd ~/RaspberryPiraeus/src/automation/'" >> .bashrc
    source .bashrc
    cdpi

11. Edit the cluster IP/Host Name information file. (JSON data file)
    nano _cluster.json
    Enter the preferred host names and associated static IP addresses associated with each Raspberry Pi in the cluster
    Ctrl/s Ctrl/x  <-- Save and exit nano OR -->  Ctrl/X  'Y'  <Enter>

12. Setup the scripts to execute (set all to allow execution)
    chmod +x 0_initialize_scripts.sh
    sudo ./0_initialize_scripts.sh

13. Trade SSH keys for remote setup commands & setup the cluster host names and IP's
    sudo ./1_setup_ssh.sh
    a. A reboot will be necessary after this script runs.  When rebooted, the machines will be renamed and will recognize the other machines in the cluster.
    b. When you see the "Reboot now (y/n)" question, hit "y" and enter to start the rebooting process.  The script will reboot all of the worker machines and will wait for them to start up and then will reboot the master machine.

14. Modify the time zone (Optional)
    a. Edit  _config.file.sh and look for "zonelocation" and change it to your location
    nano _config_file.sh
    b. Default (my) time zone:  zonelocation="America/Chicago"
    c. Look here for valid entries: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    d. en_US.UTF-8 UTF-8
    e. Execute the time zone update:
    sudo ./1.1_set_timezone.sh

15. Disable/Remove the swap file - Kubernetes won't operate with a swap file.
    cdpi  <-- go to the script folder
    sudo ./2_swap_file.sh
    a. A reboot will be necessary after this script runs.  When rebooted, the machines will be renamed and will recognize the other machines in the cluster.
    b. When you see the "Reboot now (y/n)" question, hit "y" and enter to start the rebooting process.  The script will reboot all of the worker machines and will wait for them to start up and then will reboot the master machine.

16. Install Docker and Kubernetes
    sudo ./3_install_docker.sh
    sudo ./4_kube_install.sh
sudo ./5_join_label_network.sh
