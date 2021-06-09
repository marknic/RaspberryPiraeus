#!/bin/bash

ansible-playbook -v playbooks/test.yml --user=ubuntu --extra-vars "ansible_sudo_pass=raspberry"
