#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run the script as root --> 'sudo ./scriptname.sh'"
  exit
fi

