#!/bin/bash
clear

# Ensure the script quits if there's any exit code other than 0.
set -e

# Make sure the user is running the script as root.
if [[ $EUID -ne 0 ]]; then
    echo "You need to run this script with root privileges!"
    exit 1
fi

# Section 1: Users and groups
##################################################################################

# Remove users
echo "Removing users..."
for user in Muhammad David DanielPM Patrick DanielH; do
    userdel -r "$user" || echo "Failed to remove user $user"
done

# Remove group
echo "Removing group g2members..."
groupdel g2members || echo "Failed to remove group g2members"

# Remove sudoers files
echo "Removing sudoers files..."
for user in Muhammad David DanielPM Patrick DanielH; do
    rm -f /etc/sudoers.d/"$user" || echo "Failed to remove sudoers file for $user"
done

# Section 2: System setup
##################################################################################

# Revert SSH configuration
echo "Reverting SSH configuration..."
sed -i '/^Port 9999/d' /etc/ssh/sshd_config
sed -i '/^AllowUsers Muhammad David DanielPM Patrick DanielH/d' /etc/ssh/sshd_config
sed -i \
    -e 's/^PasswordAuthentication no/#PasswordAuthentication yes/' \
    -e 's/^PubkeyAuthentication yes/#PubkeyAuthentication yes/' \
    -e 's/^ChallengeResponseAuthentication no/#ChallengeResponseAuthentication yes/' \
    -e 's/^GSSAPIAuthentication no/#GSSAPIAuthentication yes/' \
    /etc/ssh/sshd_config

systemctl restart ssh.service

# Disable and stop firewalld
echo "Disabling and stopping firewalld..."
systemctl stop firewalld
systemctl disable firewalld

# Remove Docker
echo "Removing Docker..."
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm /etc/apt/sources.list.d/docker.list
rm /etc/apt/keyrings/docker.asc
apt autoremove -y
apt autoclean -y

# Remove shared folder
echo "Removing shared folder /opt/g2members..."
rm -rf /opt/g2members

echo "Reversal of configuration completed."
