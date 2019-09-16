#!/bin/bash

pword="raspberry"
id="pi"
ip="192.168.8.101"

sshpass -p $pword ssh $id@$ip "curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/automation/copy_hostname_scripts.sh | sh"

sshpass -p $pword ssh $id@$ip "curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/3_set_hostname.sh | sudo sh"

scp 4_update_hosts.sh $id@$ip

sshpass -p $pword ssh $id@$ip "sudo ./4_update_hosts.sh"
