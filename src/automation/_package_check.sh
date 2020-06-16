#!/bin/bash

install_and_validate_package() {
    local -r -i max_attempts=5
    local -i attempt_num=1

    until dpkg-query -W -f='${Status}\n' $1 > /dev/null 2>&1
    do
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempting to install package: $1  This is attempt $attempt_num."
            (( attempt_num++ ))
            sudo apt-get install -y $1
        fi
    done
}


install_and_validate_package_remote() {
    local -r -i max_attempts=5
    local -i attempt_num=1

    until sudo sshpass -p $pword ssh $piid@$ip_target sudo dpkg-query -W -f='${Status}\n' $1 > /dev/null 2>&1
    do
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempting to install package: $1  This is attempt $attempt_num."
            (( attempt_num++ ))
            sudo sshpass -p $pword ssh $piid@$ip_target sudo apt-get install -y $1
        fi
    done
}

printf "\n Verifying dependent packages:\n"

# install jq here - it is used to parse the json data
install_and_validate_package jq

# install sshpass here - it is used to include passwords on SSH commands
install_and_validate_package sshpass

install_and_validate_package apt-transport-https

install_and_validate_package ca-certificates

install_and_validate_package curl

install_and_validate_package software-properties-common
