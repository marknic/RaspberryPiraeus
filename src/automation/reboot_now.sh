#!/bin/bash

. _config_file.sh

print_instruction "  ____      _                 _      "
print_instruction " |  _ \ ___| |__   ___   ___ | |_    "
print_instruction " | |_) / _ \ '_ \ / _ \ / _ \| __|   "
print_instruction " |  _ <  __/ |_) | (_) | (_) | |_    "
print_instruction " |_| \_\___|_.__/ \___/ \___/ \__| \n"

. _check_root.sh

. _package_check.sh

. _array_setup.sh

. _worker_reboot.sh
