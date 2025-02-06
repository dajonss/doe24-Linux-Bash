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

users=("Muhammad" "David" "DanielPM" "Patrick" "DanielH")

for user in "${users[@]}"; do
    useradd -m "$user"
done

read -rp "please write your pubkey to get authorized" read_pubkey
path_etc_ssh="/etc/ssh"
echo "$read_pubkey" >> "$path_etc_ssh/authorized_keys"


for user in "${users[@]}"; do
    user_home="/home/$user"
    ssh_dir="$user_home/.ssh"
    # Create .ssh directory and set permissions
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    chown "$user:$user" "$ssh_dir"
    # Generate SSH key pair
    # ssh-keygen -t rsa -b 2048 -f "$ssh_dir/${user}_id_rsa" -N "" -C "$user@$(hostname)"
    # # Set up authorized_keys
    # cat "$ssh_dir/${user}_id_rsa.pub" > "$ssh_dir/authorized_keys"
    read -rp "please write your pubkey to get authorized" read_pubkey
    path_etc_ssh="/etc/ssh"
    echo "$read_pubkey" >> "$ssh_dir/authorized_keys"
    chmod 600 "$ssh_dir/authorized_keys"
    chown "$user:$user" "$ssh_dir/authorized_keys"
    key_output_dir="$ssh_dir"
    echo "SSH key pair generated for $user. Private key is in $key_output_dir/${user}_id_rsa"
done


echo -e "\n> Users has been created.\n"
sleep 0.5


echo "Enter a default password for all the newly created users."
echo "(This password will have to be changed on the first login.)"
echo "Set default password: "
default_password="1234asdf"

# read -rp "Set default password: " default_password

for user in "${users[@]}"; do
    echo "$user":"$default_password" | chpasswd
done



# echo "Updating system packages."
# export DEBIAN_FRONTEND=noninteractive
# apt-get update && apt-get -y upgrade && apt-get -y autoremove && apt-get -y autoclean

echo "Creating a new group for all of the newly created users."
group_name="g2members"
groupadd $group_name
mkdir -p /opt/"$group_name"
chown -R :g2members /opt/g2members
chmod g+rwx /opt/"$group_name"
chmod u+rwx /opt/"$group_name"
chmod o-rwx /opt/"$group_name"
chmod g+s /opt/"$group_name"
sleep 0.5
echo -e "> Group folder /opt/g2members has been created with group ownership.\n"

for user in "${users[@]}"; do
    usermod -aG $group_name "$user"
done
echo -e "\n> Group 'g2members' has been created and assigned to the new users.\n"


for user in "${users[@]}"; do
    passwd -e "$user"
done


for user in "${users[@]}"; do
    echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/"$user"
done

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
# is-active return active or inactive and --quiet return only status code
if systemctl is-active --quiet ssh; then
    echo "SSH service is running."
else
    echo "SSH service is not running. Starting it now..."
    systemctl start ssh
    systemctl enable ssh
    echo "SSH service has been started and enabled."
fi

if ! sed -i 's/^#Port .*/Port 9999/' /etc/ssh/sshd_config
then
    echo "port config failed!"
fi

if ! sed -i \
    # -e '/^Include/s/^/#/' \
    -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' \
    -e 's/^PasswordAuthentication .*/PasswordAuthentication no/' \
    -e 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' \
    -e 's/^PubkeyAuthentication .*/PubkeyAuthentication yes/' \
    -e 's/^#KbdInteractiveAuthentication yes/KbdInteractiveAuthentication no/' \
    -e 's/^KbdInteractiveAuthentication .*/KbdInteractiveAuthentication no/' \
    -e 's/^#GSSAPIAuthentication yes/GSSAPIAuthentication no/' \
    -e 's/^GSSAPIAuthentication .*/GSSAPIAuthentication no/' \
    /etc/ssh/sshd_config
then
    echo "failed to change sshconfig pubkey only"
fi

sed -i '/^Include/s/^/#/' /etc/ssh/sshd_config





if ! sed -i '$ a AllowUsers Muhammad David DanielPM Patrick DanielH' /etc/ssh/sshd_config
then
    echo "failed to add allowed users to /etc/ssh/sshd_config"
fi

if ! systemctl restart ssh.service
then
    echo "Failed to restart ssh.service"
fi

ufw disable
systemctl disable ufw
systemctl stop ufw

apt install -y firewalld
systemctl start firewalld
systemctl enable firewalld

if ! systemctl is-active --quiet firewalld; then
    echo "Failed to start firewalld"
    exit 1
fi

firewall-cmd --complete-reload
firewall-cmd --set-default-zone=drop
firewall-cmd --permanent --zone=drop --add-port=9999/tcp
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -j ACCEPT
firewall-cmd --reload
echo "Firewall configured successfully"

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do  apt-get remove -y $pkg; done


# Add Docker with docker oficial ubuntu online snippet

apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  jammy stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker run hello-world

if getent group docker > /dev/null 2>&1; then
    echo "The 'docker' group exists."
else
    echo "The 'docker' group does not exist. check installation!"
    exit 1
fi

for user in "${users[@]}"; do
    usermod -aG docker "$user"
    echo "Added $user to the docker group."
done

echo "${users[*]} can now run Docker commands without using sudo."
