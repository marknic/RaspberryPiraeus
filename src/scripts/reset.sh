#!/bin/bash

sudo rm *.local

git checkout *

git pull

chmod +x 0_initialize_scripts.sh

sudo ./0_initialize_scripts.sh

nano _cluster.json
