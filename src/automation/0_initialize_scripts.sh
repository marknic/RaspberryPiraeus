#!/bin/bash

. _config_file.sh

. _check_root.sh


print_instruction " _____ __   _ _____ _______ _____ _______        _____ ______ _______"
print_instruction "   |   | \  |   |      |      |   |_____| |        |    ____/ |______"
print_instruction " __|__ |  \_| __|__    |    __|__ |     | |_____ __|__ /_____ |______\n"

print_instruction " _______ _______  ______ _____  _____  _______ _______"
print_instruction " |______ |       |_____/   |   |_____]    |    |______"
print_instruction " ______| |_____  |    \_ __|__ |          |    ______|\n"

print_instruction "Setting the scripts to 'Executable'."

chmod +x 1_setup_host_ssh.sh
chmod +x 2.1_config_boot.sh
chmod +x 2.2_install_docker.sh
chmod +x 3.1_kube_install.sh
chmod +x 3.2_kube_config.sh
