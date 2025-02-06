#!/bin/bash

icon=">"
echo "$icon Welcome to vagrant automation script to start a box with Ubuntu 22.04"
echo "$icon We use a generic Ubuntu 22.04 (aka Jammy Jellyfish) image"
# echo "$(grep "config.vm.box = " ./Vagrantfile)
# https://portal.cloud.hashicorp.com/vagrant/discover/generic/ubuntu2204
echo "$icon Setting up box and running install script for users"
vagrant up
# vagrant up --debug &> debug_log.txt
echo "$icon Copying ssh keys to enable you (host) to login in using ssh"
echo "$icon executing ssh-copy-id, please set user/port desired in the script"
user_name="DanielH"
port="9999"
ip=$(vagrant ssh-config | grep HostName | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
# login first time to change password:
ssh -p $port "$user_name"@"$ip"
# generate ssh-key
# TODO: How to check if ssh-copy-id is already successfully runed to avoid repition.
ssh-copy-id -p "$port" "$user_name"@"$ip"

# ssh_host="ubuntutest"
# host_added=$(grep $ssh_host "$HOME"/.ssh/config/)
# echo "$host_added"
# if host_added; then
#     echo "already created"
# else
#     echo -e "\nHost $ssh_host\n  HostName $ip\n  User $user_name\n  Port $port" >> "$HOME"/.ssh/config
# fi
# check if already exit old then remove, else use ssh_host. grep?
# cat "$HOME"/.ssh/config/ | grep $ssh_host
# after ssh-key is generated login:
ssh -p $port "$user_name"@"$ip"
# or better using ssh-config less verbose
# ssh ubuntutest
