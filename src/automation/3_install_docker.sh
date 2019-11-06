#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    

    # Download Docker/Containerd/Docker CLI
    # Install Docker - Version 18.09 (this is the latest validated version as of 9/5/19

    # Is the package already installed?
    if [ $(dpkg-query -W -f='${Status}' $containerd_dpkg 2>/dev/null | grep -c "ok installed") -eq 1 ]
    then
        # No? then does the package file exist locally?
        test -f $containerd
        if [ $? -eq 1 ]
        then
            # No? Then download it
            sudo sshpass -p $pword sudo ssh $id@$ip_target wget $download_location$containerd
        fi

        # Install the package
        sudo sshpass -p $pword sudo ssh $id@$ip_target sudo dpkg -i $containerd
    fi

    if [ $(dpkg-query -W -f='${Status}' $docker_ce_cli_dpkg 2>/dev/null | grep -c "ok installed") -eq 1 ]
    then
        # No? then does the package file exist locally?
        test -f $docker_ce_cli
        if [ $? -eq 1 ]
        then
            # No? Then download it
            sudo sshpass -p $pword sudo ssh $id@$ip_target wget $download_location$docker_ce_cli
        fi

        # Install the package
        sudo sshpass -p $pword sudo ssh $id@$ip_target sudo dpkg -i $docker_ce_cli
    fi
    
    if [ $(dpkg-query -W -f='${Status}' $docker_ce_dpkg 2>/dev/null | grep -c "ok installed") -eq 1 ]
    then
        # No? then does the package file exist locally?
        test -f $docker_ce
        if [ $? -eq 1 ]
        then
            # No? Then download it
            sudo sshpass -p $pword sudo ssh $id@$ip_target wget $download_location$docker_ce
        fi

        # Install the package
        sudo sshpass -p $pword sudo ssh $id@$ip_target sudo dpkg -i $docker_ce
    fi
    
    # Create group "docker", then add user "pi" to it
    sudo sshpass -p $pword ssh $id@$ip_target sudo usermod pi -aG docker

done


. _worker_reboot.sh

