#!/bin/bash
clear

#-e make sure the script quits if there's any exit code other than 0.
set -e

#-e enable interpretation of backslash escapes
echo -e "\nHello $USER.\n"

# Make sure the user is running the script as root.
if [[ $EUID -ne 0 ]]; then
    echo "You need to run this script with root privileges!"
    sleep 0.5
    echo -e "Quitting...\n"
    sleep 0.5
    exit 1
fi
#
# Section 1: Users and groups
##################################################################################
#1. Create a user on the system for each member of the group
###############################
# PART 5.1 OF DELIVERANCE.PDF #
###############################


# Gör till array? och loop?

echo "Creating the users of group 2..."

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


#2. Create a group. Each user created above should be a member of the group.
# Assign users to g2members.
echo "Creating a new group for all of the newly created users."
# gör g2members till en variabel.
groupadd g2members
usermod -aG g2members Muhammad
usermod -aG g2members David
usermod -aG g2members DanielPM
usermod -aG g2members Patrick
usermod -aG g2members DanielH
echo -e "\n> Group 'g2members' has been created and assigned to the new users.\n"



#3. Set a default password for each user. Ask the user running the script for the password to set. Make sure each user has to change password after the first login.
# Assign the default password to all the users.
echo "Enter a default password for all the newly created users."
echo "(This password will have to be changed on the first login.)"
echo "Set default password: "
read -r default_password

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


#4.0. Create a shared folder under /opt/<group-name>. It should be owned by the shared group created in point
# Create a folder owned by the group in /opt/g2members
mkdir -p /opt/g2members

# Set folder ownership to g2members group.

    #4.1. Make sure newly created files inside the shared folder are automatically owned by the group.
# Using -R flag so that ownership transfers over to sub dirs and files.
chown -R :g2members /opt/g2members
sleep 0.5
echo -e "> Group folder /opt/g2members has been created with group ownership.\n"

#5. Make sure all users created previously can run sudo commands without the need to write their password.
# Grant all the previously created users sudo privilege without being prompted for the password.
echo "Muhammad ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/Muhammad
echo "David ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/David
echo "DanielPM ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/DanielPM
echo "Patrick ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/Patrick
echo "DanielH ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/DanielH
##################################################################################

# Section 2: System setup
##################################################################################
#1. Make sure all packages are updated to the latest version available.
# trap till den här:
apt update
# apt upgrade -y sorry no please. (seems excessive)
apt autoremove -y
apt autoclean

#2. Make sure the ssh server is installed and running.
# Function to check if a package is installed
is_pkg() {
    dpkg -l | grep -qw "$1"
}

# Check if SSH server is installed
if is_pkg "openssh-server"; then
    echo "OpenSSH Server is already installed."
else
    echo "OpenSSH Server is not installed. Installing it now..."
    apt install -y openssh-server
fi

# Check if the SSH service is running
#is-active return active or inactive and --quiet return only status code
if systemctl is-active --quiet ssh; then
    echo "SSH service is running."
else
    echo "SSH service is not running. Starting it now..."
    systemctl start ssh
    systemctl enable ssh
    echo "SSH service has been started and enabled."
fi

# # Verify the SSH service status
# if systemctl is-active --quiet ssh; then
#     echo "SSH server is active and running."
# else
#     echo "Failed to start SSH server. Please check the logs for more information."
#     exit 1
# fi

#3. Configure the ssh server to:
# (a) Run on a non-default port
#   Backup original file

if [ $? -eq 0 ]; then
    echo "sshd_config is backed up successfully"
else
    echo "Failed to backup sshd_config"
    exit 1
fi

#Change port
sed -i 's/^#Port .*/Port 9999/' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    echo "port is changed to 9999 successfully"
else
    echo "Failed to change port"
    exit 1
fi


# (b) Only accept log-in via pubkey
sed -i \
    -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' \
    -e 's/^PasswordAuthentication .*/PasswordAuthentication no/' \
    -e 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' \
    -e 's/^PubkeyAuthentication .*/PubkeyAuthentication yes/' \
    -e 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' \
    -e 's/^ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' \
    -e 's/^#GSSAPIAuthentication yes/GSSAPIAuthentication no/' \
    -e 's/^GSSAPIAuthentication .*/GSSAPIAuthentication no/' \
    /etc/ssh/sshd_config
# kanske överflödigt?
if [ $? -eq 0 ]; then
    echo "ssh is successfully configured to only pub key access"
else
    echo "Failed to edit sshd_config file"
    exit 1
fi

# (c) Only allow the users created previously to login via ssh
# kolla varför man inte kan köra den pà en vanlig fil.
sed -i '$ a AllowUsers Muhammad David DanielPM Patrick DanielH' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    echo "ssh is successfully configured to only allow given users"
else
    echo "Failed to edit sshd_config file"
    exit 1
fi

systemctl restart ssh.service
#For non-Debian comment above, uncomment below
##systemctl restart sshd.service
if [ $? -eq 0 ]; then
    echo "ssh.service is successfully restarted"
else
    echo "Failed to restart ssh.service"
    exit 1
fi

#4. Make sure firewalld is installed and running. Block all incoming connections except for the SSH port. Allow all outgoing connections.
# O B S: check if other firewall is installed, if so reset them and uninstall first.
# install firewalld and setup config
###########################################################################

# Check if ufw is enabled and disable it if it is

ufw disable
# apt list --installed | grep ufw
# if [ $? -eq 0 ]; then
#     if ufw status | grep -q "Status: active"; then
#         ufw disable
#     fi
# fi

# Uninstall ufw?
# Prevent ufw to start again after restart
# systemctl status ufw | grep enabled\;
# if [ $? -eq 0 ]; then
systemctl disable ufw
systemctl stop ufw
# fi

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
firewall-cmd --set-default-zone=drop  # Block all incoming by default
firewall-cmd --permanent --zone=drop --add-port=9999/tcp  # Allow SSH (port 9999)
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j ACCEPT  # Allow all outgoing

# Reload firewall to apply changes
firewall-cmd --reload

echo "Firewall configured successfully"

###########################################################################

#5. Make sure the latest available version of docker and docker compose are installed on the system.
# O B S: follow docker original instuctions for install!
# additional installations Docker
###############

# Run the following command to uninstall all conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

# Uninstall Docker Engine for clean installation
# Uninstall the Docker Engine, CLI, containerd, and Docker Compose packages:
# apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# Images, containers, volumes, or custom configuration files on your host aren't automatically removed. To delete all images, containers, and volumes:
# rm -rf /var/lib/docker
# rm -rf /var/lib/containerd

# Remove source list and keyrings
# rm /etc/apt/sources.list.d/docker.list
# rm /etc/apt/keyrings/docker.asc
# apt autoremove -y
# apt autoclean -y
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#
#↑↑↑↑↑↑↑ Error free code (Tested) ↑↑↑↑↑↑↑↑#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#

##########################################################################################################

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#↓↓↓↓↓↓↓↓↓↓ Not checked yet ↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#

# Install using the apt repository

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# To install the latest version, run:
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify that the installation is successful by running the hello-world image:
sudo docker run hello-world
###############

#6. Make sure all users created previously can run docker cli commands without needing to use sudo.
# Check if the docker group exists
if getent group docker > /dev/null 2>&1; then
    echo "The 'docker' group exists."
else
    echo "The 'docker' group does not exist. check installation!"
    exit 1
fi
# List of users to add to the docker group
users=("Muhammad" "David" "DanielPM" "Patrick" "DanielH")

# Add each user to the docker group
for user in "${users[@]}"; do
    sudo usermod -aG docker "$user"
    echo "Added $user to the docker group."
done

echo "Muhammad, David, DanielPM, Patrick, and DanielH can now run Docker commands without using sudo."
