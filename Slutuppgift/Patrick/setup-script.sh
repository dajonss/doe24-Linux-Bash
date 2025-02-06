#!/bin/bash

clear

# Make sure the script quits if there's any exit code other than 0.
set -e

echo -e "\nHello $USER.\n"

# Make sure the user is running the script as root.
if [[ $EUID -ne 0 ]]; then
    echo "You need to run this script with root privileges!"
    sleep 0.5
    echo -e "Quitting...\n"
    sleep 0.5
    exit 1
fi

###############################
# PART 5.1 OF DELIVERANCE.PDF #
###############################

echo -e "Creating the users of group 2..."

useradd Muhammad
echo "1/5"

useradd David
echo "2/5"

useradd DanielPM
echo "3/5"

useradd Patrick
echo "4/5"

useradd DanielH
echo "5/5"

echo -e "\n> Users has been created.\n"
sleep 0.5

echo "Enter a default password for all the newly created users."
echo "(This password will have to be changed on the first login.)"
echo "Set default password: "
read -r default_password

# Assign the default password to all the users.
echo Muhammad:"$default_password" | chpasswd
echo David:"$default_password" | chpasswd
echo DanielPM:"$default_password" | chpasswd
echo Patrick:"$default_password" | chpasswd
echo DanielH:"$default_password" | chpasswd

# Expire the passwords.
# This will prompt the user to create a new password on the first login.
passwd -e Muhammad
passwd -e David
passwd -e DanielPM
passwd -e Patrick
passwd -e DanielH

echo "Creating a new group for all of the newly created users."
groupadd g2members

# Assign users to g2members.
usermod -aG g2members Muhammad
usermod -aG g2members David
usermod -aG g2members DanielPM
usermod -aG g2members Patrick
usermod -aG g2members DanielH

echo -e "\n> Group 'g2members' has been created and assigned to the new users.\n"

# Create a folder owned by the group in /opt/g2members
mkdir -p /opt/g2members

# Set folder ownership to g2members group.
# Using -R flag so that ownership transfers over to sub dirs and files.
chown -R :g2members /opt/g2members
sleep 0.5
echo -e "> Group folder /opt/g2members has been created with group ownership.\n"

# Grant all the previously created users sudo privilege without being prompted for the password.
echo "Muhammad ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/Muhammad
echo "David ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/David
echo "DanielPM ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/DanielPM
echo "Patrick ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/Patrick
echo "DanielH ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/DanielH

###############################
# PART 5.2 OF DELIVERANCE.PDF #
###############################

# ANYTHING PASSED THIS COMMENT HASN'T BEEN SHELLCHECKED!
