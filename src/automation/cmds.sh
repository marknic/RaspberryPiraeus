#!/bin/bash

. _config_file.sh

print_instruction "\nExecute the scripts in this way:"
print_instruction "sudo ./1_setup_ssh.sh"
print_instruction "sudo ./1.1_locale_and_time.sh"
print_instruction "sudo ./2_swap_file.sh"
print_instruction "sudo ./3_install_docker.sh"
print_instruction "sudo ./4_kube_install.sh"
print_instruction "./cmds.sh"

