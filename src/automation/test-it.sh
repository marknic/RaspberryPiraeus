#!/bin/bash

. _config_file.sh

print_instruction "  _____         _             "
print_instruction " |_   _|__  ___| |_           "
print_instruction "   | |/ _ \/ __| __|          "
print_instruction "   | |  __/\__ \ |_           "
print_instruction "   |_|\___||___/\__|          "
print_instruction "  ____            _       _   "
print_instruction " / ___|  ___ _ __(_)_ __ | |_ "
print_instruction " \___ \ / __| '__| | '_ \| __|"
print_instruction "  ___) | (__| |  | | |_) | |_ "
print_instruction " |____/ \___|_|  |_| .__/ \__|"
print_instruction "                   |_|       \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

SYSCTL_FILE="sysctl.conf"
BAK_FILE="${SYSCTL_FILE}.BAK"
TMP_FILE="${SYSCTL_FILE}.TMP"
ETC_FOLDER="/etc/"

cp "$ETC_FOLDER$SYSCTL_FILE" "$SYSCTL_FILE"

# Create a backup if it doesn't already exist
[ ! -f "$ETC_FOLDER$BAK_FILE" ] && cp "$ETC_FOLDER$SYSCTL_FILE" "$ETC_FOLDER$BAK_FILE"


# Create temporary file with an update - uncommented line
cat "$SYSCTL_FILE" | sed -e "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" > "$TMP_FILE"

mv -f "$TMP_FILE" "$ETC_FOLDER$SYSCTL_FILE"
rm "$TMP_FILE"

ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

print_instruction "/etc/sysctl.conf modified on: $host_target/$ip_target: "

for ((i=0; i<$length; i++));
do
    # Get the IP to search for
    ip_target=$(echo $cluster_data | jq --raw-output ".[$i].IP")
    host_target=$(echo $cluster_data | jq --raw-output ".[$i].name")

    if [ $ip_target != $ip_addr_me ]
    then

        # Remote machine so use ssh
        sudo sshpass -p $pword ssh $piid@$ip_target cp "$ETC_FOLDER$SYSCTL_FILE" "$SYSCTL_FILE"

        sudo sshpass -p $pword ssh $piid@$ip_target [ ! -f "$ETC_FOLDER$BAK_FILE" ] && cp "$ETC_FOLDER$SYSCTL_FILE" "$ETC_FOLDER$BAK_FILE"
        sudo sshpass -p $pword ssh $piid@$ip_target cat "$SYSCTL_FILE" | sed -e "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" > "$TMP_FILE"

        sudo sshpass -p $pword ssh $piid@$ip_target mv -f "$TMP_FILE" "$ETC_FOLDER$SYSCTL_FILE"
        sudo sshpass -p $pword ssh $piid@$ip_target rm "$TMP_FILE"

        print_instruction "/etc/sysctl.conf modified on: $host_target/$ip_target: "

    fi
done

print_instruction "\nDone!\n"

#. _worker_reboot.sh