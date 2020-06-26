# RaspberryPiraeus

Piraeus on Docker in Kubernetes on Raspbian (Debian) or Ubuntu Linux on RPi Cluster

## Build/install Kubernetes on a Raspberry Pi Cluster

1. Is SSH enabled on your laptop?

2. Enable SSH on all RPi's</br>
    a. Login (pi/raspberry)</br>
    b. Enter these commands: </br>
    #### sudo systemctl enable ssh</br>
    #### sudo systemctl start ssh </br>    
    #### logout

3. Windows: check to see if known_hosts contains an ssh key and if the Rpi's are already listed.  If so, remove them and start over.</br>
    a. Use this command to see if an IP address is already listed in the Known Hosts (SSH) file.</br>  
    If the IP is already listed, and you're starting up an RPi using that IP, SSH will not connect properly</br>
    #### findstr /c:192.168.8.100 C:\Users\nicho\.ssh\known_hosts

    b. Use these commands to remove the IP Addresses from Known Hosts file </br>
    #### type C:\Users\nicho\.ssh\known_hosts | findstr /v 192.168.8.100 | findstr /v 192.168.8.101 > C:\Users\nicho\.ssh\known_hosts.txt </br>
    #### del C:\Users\nicho\.ssh\known_hosts </br>
    #### ren C:\Users\nicho\.ssh\known_hosts.txt known_hosts </br>

4. Copy SSH Key Linux to Linux </br>
    a. # Remove the known host info before copy </br>
    #### sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.8.101" </br>
    b. Copy the key over </br>
    #### sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.8.101 </br>

5. Setup SSH from Windows (Remove's password requirement.   This is optional but will make things much easier.) </br>
    a. Create SSH keys: Lots of articles on this subject on the internet: </br>
        https://www.onmsft.com/how-to/how-to-generate-an-ssh-key-in-windows-10 </br>
        https://www.techrepublic.com/blog/10-things/how-to-generate-ssh-keys-in-openssh-for-windows-10/ </br>
        https://www.maketecheasier.com/generate-ssh-public-private-keys-windows/ </br>
        https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/create-with-putty/ </br>

    b. Copy the SSH key to RPi or Ubuntu machine : </br>
    RPi: </br>
    #### type  %HOMEPATH%\.ssh\id_rsa.pub | ssh pi@192.168.8.100 "sudo cat >> ~/.ssh/authorized_keys"

    Ubuntu: </br>
    #### type  %HOMEPATH%\.ssh\id_rsa.pub | ssh ubuntu@192.168.8.101 "sudo cat >> ~/.ssh/authorized_keys"

6. SSH into the "master node" </br>
    a. If you followed the steps above, the following command should be all that is necessary to log in to the master node. </br>
    #### ssh pi@192.168.8.100  <--- This was the master node IP address on my system 

7. Update/Upgrade the OS - Reset/Update/Upgrade the OS: </br>
    #### sudo apt-get update </br>
    #### sudo apt-get -y --fix-missing dist-upgrade

8. Install Git </br>
    #### sudo apt-get -y install git

9. Clone the RaspberryPiraeus repo </br>
    #### git clone https://github.com/marknic/RaspberryPiraeus.git

10. Switch to automation (scripting) folder </br>
    a. Create an alias to make this easier: </br>
    #### echo "alias cdpi='cd ~/RaspberryPiraeus/src/automation/'" >> .bashrc </br>
    #### source .bashrc </br>
    b. Now you can just type cdpi to get to the script folder </br>
    #### cdpi

    #### echo "alias cdpi='cd ~/RaspberryPiraeus/src/automation/'" >> .bashrc </br>
    #### source .bashrc </br>
    #### cdpi </br>

11. Edit the cluster IP/Host Name information file. (JSON data file) </br>
    #### nano _cluster.json </br>
    Enter the preferred host names and associated static IP addresses associated with each Raspberry Pi in the cluster </br>
    #### Ctrl/s Ctrl/x  <-- Save and exit nano OR -->  Ctrl/X  'Y'  <Enter>

12. Setup the scripts to execute (set all to allow execution) </br>
    #### chmod +x 0_initialize_scripts.sh </br>
    #### sudo ./0_initialize_scripts.sh

13. Trade SSH keys for remote setup commands & setup the cluster host names and IP's </br>
    #### sudo ./1_setup_ssh.sh </br>
    a. A reboot will be necessary after this script runs.  When rebooted, the machines will be renamed and will recognize the other machines in the cluster. </br>
    b. When you see the "Reboot now (y/n)" question, hit "y" and enter to start the rebooting process.  The script will reboot all of the worker machines and will wait for them to start up and then will reboot the master machine.

14. Modify the time zone (Optional) </br>
    a. Edit  _config.file.sh and look for "zonelocation" and change it to your location </br>
    #### nano _config_file.sh </br>
    b. Default (my) time zone:  zonelocation="America/Chicago" </br>
    c. Look here for valid entries: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones </br>
    d. en_US.UTF-8 UTF-8 </br>
    e. Execute the time zone update: </br>
    #### sudo ./1.1_set_timezone.sh

15. Disable/Remove the swap file - Kubernetes won't operate with a swap file. </br>
    #### cdpi  <-- go to the script folder </br>
    #### sudo ./2_swap_file.sh </br>
    a. A reboot will be necessary after this script runs.  When rebooted, the machines will be renamed and will recognize the other machines in the cluster. </br>
    b. When you see the "Reboot now (y/n)" question, hit "y" and enter to start the rebooting process.  The script will reboot all of the worker machines and will wait for them to start up and then will reboot the master machine.

16. Install Docker and Kubernetes </br>
    #### sudo ./3_install_docker.sh </br>
    #### sudo ./4_kube_install.sh </br>
    #### sudo ./5_join_label_network.sh
