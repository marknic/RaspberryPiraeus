

print_instruction "  ____      _                 _   _                "
print_instruction " |  _ \ ___| |__   ___   ___ | |_(_)_ __   __ _    "
print_instruction " | |_) / _ \ '_ \ / _ \ / _ \| __| | '_ \ / _' |   "
print_instruction " |  _ <  __/ |_) | (_) | (_) | |_| | | | | (_| |   "
print_instruction " |_| \_\___|_.__/ \___/ \___/ \__|_|_| |_|\__, |   "
print_instruction "                                          |___/  \n"

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
        sshpass -p $pword ssh $piid@$ip_target "sudo reboot"
    else
        master_name=$(echo $cluster_data | jq --raw-output ".[$i].name")
    fi
done

printf "\nVerifying Reboot:\n"

printf "Waiting 25 seconds...\n\n"

sleep 25

for ((i=0; i<$length; i++));
do
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_name=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ "$ip_target" != "$ip_addr_me" ] ; then

        output='down'

        while [ "$output" != "up" ]
        do
            output=$(sshpass -p $pword ssh $piid@$ip_target uptime | awk '{print $2}')

            if [ "$output" != "up" ]
            then
                sleep 2
            else
                print_instruction "$ip_target is back up as $host_name."
            fi
        done
    fi
done

print_instruction "\nRebooting $master_name ($ip_addr_me)..."
print_instruction "\nSSH connection will drop."
print_instruction "\nYou will need to reconnect with the master when it is done rebooting.\n"

sudo reboot