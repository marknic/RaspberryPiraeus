#!/bin/bash

. _config_file.sh

. _array_setup.sh

printf " Cluster Data: \n"
echo $cluster_data
printf "\n"

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_addr_me != $ip_target ] ; then
        printf "Attempting to synch ssh data for host: $host_target/$ip_target\n\n"
        # Attempt a copy to force the key transfer/password challenge
        sudo scp $id@$ip_target:/etc/hosts tmp.tmp
        rm -f tmp.tmp > /dev/null 2>&1
    fi
done

printf "\n"
