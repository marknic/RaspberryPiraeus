#!/bin/bash

. _check_root.sh

. _package_check.sh

. _config_file.sh

. _array_setup.sh


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    printf "\n\nChecking $host_target/$ip_target for $containerd_dpkg\n\n"
    # Download Docker/Containerd/Docker CLI
    # Install Docker - Version 18.09 (this is the latest validated version as of 9/5/19

    if [ $ip_target = $ip_addr_me ]
    then
        
        # Is the package already installed?
        if ! dpkg-query -s $containerd_dpkg 2>/dev/null | grep "ok installed"
        then
            
            printf ">>> package not found\n\n"
            # No? then does the package file exist locally?            
            if ! test -f $containerd
            then
                printf ">>> file not found\n\n"
                # No? Then download it
                printf "Downloading from $download_location$containerd"
                wget $download_location$containerd
            fi

            printf ">>> installing the package\n\n"
            # Install the package
            sudo dpkg -i $containerd
        fi

        # Is the package already installed?
        if ! dpkg-query -s $docker_ce_cli_dpkg 2>/dev/null | grep "ok installed"
        then
            
            printf ">>> remote package not found\n\n"
            # No? then does the package file exist locally?            
            if ! test -f $docker_ce_cli
            then
                printf ">>> remote file not found\n\n"
                # No? Then download it
                printf "Downloading from $download_location$docker_ce_cli"
                wget $download_location$docker_ce_cli
            fi

            printf ">>> remote installing the package\n\n"
            # Install the package
            sudo dpkg -i $docker_ce_cli
        fi

        # Is the package already installed?
        if ! dpkg-query -s $docker_ce_dpkg 2>/dev/null | grep "ok installed"
        then
            # No? then does the package file exist locally?
            if ! test -f $docker_ce
            then
                # No? Then download it
                printf "Downloading from $download_location$docker_ce"
                wget $download_location$docker_ce
            fi

            # Install the package
            sudo dpkg -i $docker_ce
        fi

        sudo usermod pi -aG docker

    else
        # Remote machine so use ssh

        # Is the package already installed?
        if ! sudo sshpass -p $pword ssh $id@$ip_target dpkg-query -s $containerd_dpkg 2>/dev/null | grep "ok installed"
        then
            
            # No? then does the package file exist locally?
            if ! sudo sshpass -p $pword ssh $id@$ip_target test -f $containerd
            then
                # No? Then download it
                printf "Downloading to $"
                sudo sshpass -p $pword ssh $id@$ip_target wget $download_location$containerd
            fi

            # Install the package
            sudo sshpass -p $pword ssh $id@$ip_target sudo dpkg -i $containerd
        fi

        if ! sudo sshpass -p $pword ssh $id@$ip_target dpkg-query -s $docker_ce_cli_dpkg 2>/dev/null | grep "ok installed"
        then
            
            # No? then does the package file exist locally?
            if ! sudo sshpass -p $pword ssh $id@$ip_target test -f $docker_ce_cli
            then
                # No? Then download it
                sudo sshpass -p $pword ssh $id@$ip_target wget $download_location$docker_ce_cli
            fi

            # Install the package
            sudo sshpass -p $pword ssh $id@$ip_target sudo dpkg -i $docker_ce_cli
        fi
        
        if ! sudo sshpass -p $pword ssh $id@$ip_target dpkg-query -s $docker_ce_dpkg 2>/dev/null | grep "ok installed"
        then

            # No? then does the package file exist locally?
            if ! sudo sshpass -p $pword ssh $id@$ip_target test -f $docker_ce
            then
                # No? Then download it
                sudo sshpass -p $pword ssh $id@$ip_target wget $download_location$docker_ce
            fi

            # Install the package
            sudo sshpass -p $pword ssh $id@$ip_target sudo dpkg -i $docker_ce
        fi
        
        # Create group "docker", then add user "pi" to it
        sudo sshpass -p $pword ssh $id@$ip_target sudo usermod pi -aG docker
    fi

done


. _worker_reboot.sh

