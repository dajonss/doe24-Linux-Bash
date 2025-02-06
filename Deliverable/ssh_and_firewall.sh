#!/bin/bash

# Check if ufw is enabled and disable it if it is

apt list --installed | grep ufw
if [ $? -eq 0 ]; then
    if sudo ufw status | grep -q "Status: active"; then
        sudo ufw disable
    fi
fi

# Prevent ufw to start again after restart
sudo systemctl status ufw | grep enabled\;
if [ $? -eq 0 ]; then
    sudo systemctl disable ufw
    sudo systemctl stop ufw
fi

apt install -y firewalld

# Start and enable firewall
systemctl start firewalld
systemctl enable firewalld

# Check if firewalld is running
if ! systemctl is-active --quiet firewalld; then
    echo "Failed to start firewalld"
    exit 1
fi

# Reset firewall to default state
firewall-cmd --complete-reload

# Set default policies
firewall-cmd --permanent --set-default-zone=drop  # Block all incoming by default
firewall-cmd --permanent --zone=drop --add-port=9999/tcp  # Allow SSH (port 9999)
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j ACCEPT  # Allow all outgoing

# Reload firewall to apply changes
firewall-cmd --reload

echo "Firewall configured successfully"
