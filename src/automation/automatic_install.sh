#!/bin/bash

pword="raspberry"
id="pi"
ip="192.168.8.101"

sshpass -p "$pword" ssh "$id@$ip" "curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/copy_hostname_scripts.sh.sh | sh"


