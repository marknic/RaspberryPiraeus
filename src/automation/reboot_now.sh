#!/bin/bash

. _config_file.sh

print_instruction "  ____      _                 _   _                "
print_instruction " |  _ \ ___| |__   ___   ___ | |_(_)_ __   __ _    "
print_instruction " | |_) / _ \ '_ \ / _ \ / _ \| __| | '_ \ / _' |   "
print_instruction " |  _ <  __/ |_) | (_) | (_) | |_| | | | | (_| |   "
print_instruction " |_| \_\___|_.__/ \___/ \___/ \__|_|_| |_|\__, |   "
print_instruction "                                          |___/  \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

. _worker_reboot.sh
