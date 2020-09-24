#!/bin/bash

ansible-playbook playbooks/1_create_users.yml --user=ubuntu --extra-vars "ansible_sudo_pass=raspberry"
