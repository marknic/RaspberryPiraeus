#!/bin/bash

. _config_file.sh

. _check_root.sh


print_instruction "  ___       _ _   _       _ _                "
print_instruction " |_ _|_ __ (_) |_(_) __ _| (_)_______        "
print_instruction "  | || !_ \| | __| |/ _! | | |_  / _ \       "
print_instruction "  | || | | | | |_| | (_| | | |/ /  __/       "
print_instruction " |___|_| |_|_|\__|_|\__,_|_|_/___\___|       "
print_instruction "  ____            _       _                  "
print_instruction " / ___|  ___ _ __(_)_ __ | |_ ___            "
print_instruction " \___ \ / __| !__| | !_ \| __/ __|           "
print_instruction "  ___) | (__| |  | | |_) | |_\__ \           "
print_instruction " |____/ \___|_|  |_| .__/ \__|___/           "
print_instruction "                   |_|                     \n"



print_instruction "Setting the scripts to 'Executable'."

chmod +x 1_setup_ssh.sh
chmod +x 1.1_set_timezone.sh
chmod +x 1.2_update_locale.sh
chmod +x 2_swap_file.sh
chmod +x 3_install_docker.sh
chmod +x 4_kube_install.sh
chmod +x 5_config_network.sh
chmod +x reboot_now.sh
