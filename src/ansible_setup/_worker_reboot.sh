

print_instruction "  ____      _                 _   _                "
print_instruction " |  _ \ ___| |__   ___   ___ | |_(_)_ __   __ _    "
print_instruction " | |_) / _ \ !_ \ / _ \ / _ \| __| | !_ \ / _! |   "
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

printf "\n\nRebooting cluster!\n"
for ((i=0; i<$length; i++));
do
    get_ip_host_and_platform $i

    print_instruction "Rebooting $ip_target..."
        sshpass -p $user_password ssh $user_id@$ip_target "sudo reboot"

done

printf "\nVerifying Reboot:\n"

printf "Waiting 20 seconds...\n\n"

sleep 20

for ((i=0; i<$length; i++));
do
    get_ip_host_and_platform $i

    output='down'

    while [ "$output" != "up" ]
    do
        output=$(sshpass -p $user_password ssh $user_id@$ip_target uptime | awk '{print $2}')

        if [ "$output" != "up" ]
        then
            sleep 2
        else
            print_instruction "$ip_target is back up as $host_name."
        fi
    done
done
