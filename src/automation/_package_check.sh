

printf "\n Verifying Package:\n    jq status: "
# install jq here - it is used to parse the json data
dpkg-query -W -f='${Status}\n' jq | grep 'ok installed'

printf "\n"

if [ $? -eq 1 ]
then
    sudo apt-get install -y jq
fi

sudo apt-get install sshpass

printf "\n Verifying Package:\n    sshpass status: "
# install sshpass here - it is used to parse the json data
dpkg-query -W -f='${Status}\n' sshpass | grep 'ok installed'

printf "\n"

if [ $? -eq 1 ]
then
    sudo apt-get install -y sshpass
fi

