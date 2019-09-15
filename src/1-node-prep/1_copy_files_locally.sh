#!/bin/bash

# Execute this script with the following command:
#  curl -sSL https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/1_copy_files_locally.sh | sh

curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/2_copy_hostname_script.sh
curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/3_set_hostname.sh
curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/4_update_hosts.sh

chmod +x 2_copy_hostname_script.sh
chmod +x 3_set_hostname.sh
chmod +x 4_update_hosts.sh
