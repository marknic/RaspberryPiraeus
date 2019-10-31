#!/bin/bash

. _config_file.sh

. _array_setup.sh


for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target="${filearray[i*6+2]}"
    
    if [ $ip_addr_me != $ip_target ] ; then
        # Attempt a copy to force the key transfer/password challenge
        sudo scp $id@$ip_target:/etc/hosts tmp.tmp
        rm -f tmp.tmp > /dev/null 2>&1
    fi
done


