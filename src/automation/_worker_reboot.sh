
while true; do
    printf "\n\nThe machines need to be rebooted before the next step.  Reboot now "
    read -p "(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer (y)es or (n)o.";;
    esac
done



printf "\n\nRebooting workers!\n"
for ((i=0; i<$length; i++));
do
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ "$ip_target" != "$ip_addr_me" ] ; then
        sshpass -p $pword ssh $id@$ip_target "sudo reboot"
    fi
done

printf "\nVerifying Reboot:\n"

printf "Waiting 25 seconds...\n\n"

sleep 25

for ((i=0; i<$length; i++));
do
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")

    if [ "$ip_target" != "$ip_addr_me" ] ; then

        output='down'

        while [ "$output" != "up" ]
        do
            output=$(sshpass -p $pword ssh $id@$ip_target uptime | awk '{print $2}')

            if [ "$output" != "up" ]
            then
                sleep 2
            else
                echo "$ip_target is back up."
            fi
        done
    fi
done

printf "\nRebooting client machine...\n"

sudo reboot