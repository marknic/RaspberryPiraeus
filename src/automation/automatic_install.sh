#!/bin/bash

pword="raspberry"
id="pi"
ip="192.168.8.101"

sshpass -p raspberry ssh pi@$192.168.8.101 "curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/automation/copy_hostname_scripts.sh | sh"


