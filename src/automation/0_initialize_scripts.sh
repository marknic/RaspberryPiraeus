#!/bin/bash

. _check_root.sh

printf "${LBLU}>> Setting the scripts to 'Executable'.${NC}\n"

chmod +x 1_setup_host_ssh.sh
chmod +x 2_install_docker.sh
chmod +x 3_install_kubernetes.sh
chmod +x 4_finalize_nodes.sh
