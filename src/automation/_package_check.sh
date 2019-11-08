#!/bin/bash

printf "\n Verifying Package:\n    jq status: "
# install jq here - it is used to parse the json data
dpkg-query -W -f='${Status}\n' jq | grep 'ok installed'

result=$?

printf "\n"

if [ $result = 1 ]
then
    echo "Installing package: jq"
    sudo apt-get install -y jq
fi

printf "\n Verifying Package:\n    sshpass status: "
# install sshpass here - it is used to parse the json data
dpkg-query -W -f='${Status}\n' sshpass | grep 'ok installed'

result=$?

printf "\n"

if [ $result = 1 ]
then
    echo "Installing package: sshpass"
    sudo apt-get install -y sshpass
fi

