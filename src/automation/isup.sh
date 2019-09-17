#!/bin/bash

response=sshpass -p $pword ssh $id@$ip uptime | awk '{print $2}'