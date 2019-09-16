#!/bib/bash

if [ ! -f 3_set_hostname.sh ]; then
curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/3_set_hostname.sh
fi

if [ ! -f 4_update_hosts.sh ]; then
curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/4_update_hosts.sh
fi

chmod +x 3_set_hostname.sh
chmod +x 4_update_hosts.sh
