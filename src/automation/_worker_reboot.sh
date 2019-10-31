
printf "Rebooting workers!"
for ((i=0; i<$length; i++));
do
   if [ "${filearray[i*6+2]}" != "$ip_addr_me" ] ; then
       ip_target="${filearray[i*6+2]}"
       sshpass -p $pword ssh $id@$ip_target "sudo reboot"
   fi
done

printf "Verifying Reboot:\n"

printf "Waiting 25 seconds...\n"

sleep 25

for ((i=0; i<$length; i++));
do
    ip_target="${filearray[i*6+2]}"

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

sudo reboot