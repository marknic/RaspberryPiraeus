#!/bin/bash



for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    get_ip_host_and_platform $i

    if [ $ip_target == $ip_addr_me ]; then callLocation="-l"; else callLocation="-r"; fi

    printf "\n Verifying dependent packages:\n"

    if [ $ip_target == $ip_addr_me ]; then

        # install jq on the master - it is used to parse the json data
        install_and_validate_package $callLocation jq

        # install sshpass on the master - it is used to include passwords on SSH commands
        install_and_validate_package $callLocation sshpass

    fi

    # These packages are for kubernetes and docker operation
    install_and_validate_package $callLocation "apt-transport-https"

    install_and_validate_package $callLocation "ca-certificates"

    install_and_validate_package $callLocation "curl"

    install_and_validate_package $callLocation "software-properties-common"

done

# Reset the id and ip back to the master
get_ip_host_and_platform 0
