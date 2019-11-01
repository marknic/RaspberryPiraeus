#!/bin/bash

. _config_file.sh

. _array_setup.sh

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target="${filearray[i*6+2]}"
    
    # Download Docker/Containerd/Docker CLI
    sudo sshpass -p $pword sudo ssh $id@$ip_target wget $download_location$containerd
    sudo sshpass -p $pword sudo ssh $id@$ip_target wget $download_location$docker_ce_cli
    sudo sshpass -p $pword sudo ssh $id@$ip_target wget $download_location$docker_ce

    # Install Docker - Version 18.09 (this is the latest validated version as of 9/5/19
    sudo sshpass -p $pword sudo ssh $id@$ip_target sudo dpkg -i $containerd
    sudo sshpass -p $pword sudo ssh $id@$ip_target sudo dpkg -i $docker_ce_cli
    sudo sshpass -p $pword sudo ssh $id@$ip_target sudo dpkg -i $docker_ce

    # Create group "docker", then add user "pi" to it
    sudo sshpass -p $pword ssh $id@$ip_target sudo usermod pi -aG docker

done

while true; do
    printf "\n\nThe machines need to be rebooted before the next step.  Reboot now? "
    read -p "(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer (y)es or (n)o.";;
    esac
done

. _worker_reboot.sh

