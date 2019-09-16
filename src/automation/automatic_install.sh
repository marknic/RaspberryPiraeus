#!/bin/bash

pword="raspberry"
id="pi"

sshpass -p "$pword" ssh pi@192.168.8.101 "curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/1_setup_files_locally.sh | sh"
