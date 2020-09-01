#!/bin/bash

. _config_file.sh

print_instruction "   ____                                          _         "
print_instruction "  / ___|___  _ __ ___  _ __ ___   __ _ _ __   __| |___     "
print_instruction " | |   / _ \| !_ ! _ \| !_ ! _ \ / _! | !_ \ / _! / __|    "
print_instruction " | |__| (_) | | | | | | | | | | | (_| | | | | (_| \__ \    "
print_instruction "  \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/  \n"


print_instruction "\nExecute the scripts in this way:"
print_instruction "sudo ./1_setup_ssh.sh"
print_instruction "sudo ./2_locale_and_time.sh"
print_instruction "sudo ./3_add_users.sh"
print_instruction "./cmds.sh\n\n"