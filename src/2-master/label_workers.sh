#!/bin/bash

printf "\n\n    WORKER NODE LABELING\n\n"

FILE="update-hosts.sh"

if [ -f $FILE ]; then
   printf "File $FILE exists - continuing.\n\n"
else
   printf "\e[1;31mError: File $FILE does not exist locally.\e[0m\n"
   printf "$FILE is used as input to this script and must exist.\n"
   printf "exiting...\n"
   exit 1
fi


printf "1. Run this script \e[1;31mONLY AFTER\e[0m all of the worker nodes have been created.\n"
printf "2. Run this script \e[1;31mONLY ON\e[0m the master node.\n"
printf "3. Run this script \e[1;31mONLY IF\e[0m the file update-hosts.sh has been updated with the worker node names.\n\n"

while true; do
    read -p "Do you want to run the script (y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer (y)es or (n)o.";;
    esac
done


ip_addr=$(cat update-hosts.sh | grep -Eo "?([0-9]*\.){3}[0-9]*.*$(hostname).*" | grep -Eo '([0-9]*\.){3}[0-9]*')

host_name="$(hostname)"

ip_addr=$(cat "$FILE" | grep -Eo "?([0-9]*\.){3}[0-9]*.*$host_name.*" | grep -Eo '([0-9]*\.){3}[0-9]*')

while read line; do

  cleanline=$(echo $line | sed 's/'"'"'/ /g')

  cleanline=$(echo $cleanline | sed 's/\// \//')

  linearray=($cleanline)

  if [ "${linearray[4]}" == "/etc/hosts" ] && [ "${linearray[1]}" != "$ip_addr" ]
  then
    labelcmd="kubectl label node ${linearray[2]} node-role.kubernetes.io/worker=worker"
    $labelcmd
  fi

done < $FILE

