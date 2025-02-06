# Prompt user to decide whether to use sudo
# use_sudo=${use_sudo:-no}
# read -p "Do you want to use sudo for commands? (yes/no) [yes]: " use_sudo

# install sudo if not existant
trap '' SIGINT
sudo apt install sudo -y
trap - SIGINT

if [[ "$use_sudo" == "yes" ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

# create some users for host

users=("user1" "user2" "user3")
group_developers="developers"
group_wheel="wheel"

# create a group

$SUDO addgroup $group_developers --shell /bin/bash
$SUDO groupadd $group_wheel

# create users
for user in "${users[@]}"; do
    # $SUDO adduser -G $group_name --gecos "" "$user"
    $SUDO adduser --gecos "" "$user"
    $SUDO passwd --expire "$user" # expire force user to pick new passwd on login
done

# add users to the developers group
for user in "${users[@]}"; do
    $SUDO usermod -g $group_developers "$user"
done

# add users to the wheel group
for user in "${users[@]}"; do
    $SUDO usermod -aG $group_wheel "$user"
done

# if [[ ! $group_cmd ]]; then
#     echo "group did not create sucessfully"
# fi

# Add the group to sudoers
mkdir -p /etc/sudoers.d/
touch /etc/sudoers.d/$group_developers
touch /etc/sudoers.d/$group_wheel
echo "%$group_developers ALL=(ALL) NOPASSWD: ALL" | $SUDO tee /etc/sudoers.d/$group_developers
echo "%$group_developers ALL=(ALL) ALL" | $SUDO tee /etc/sudoers.d/$group_developers
echo "%$group_wheel ALL=(ALL) ALL" | $SUDO tee /etc/sudoers.d/$group_wheel

# Add the group to the wheel group
# TODO: check wheel group exist else create.
#1. grep wheel /etc/group

# $SUDO usermod -aG wheel $group_name

# 4. Create a shared folder under /opt/<group-name>. It should be owned by the shared group
# created in point 2. Make sure newly created ﬁles inside the shared folder are automatically
# owned by the group.

mkdir -p "/opt/$group_developers"

# + chown root:developers developers/
# chown: cannot access 'developers/': No such file or directory
# $SUDO chown $group_name /opt/$group_name
# $SUDO chown root:$group_name /opt/$group_name/
$SUDO chown root:$group_developers /opt/$group_developers/
$SUDO chmod 2770 /opt/$group_developers
$SUDO chmod g+s /opt/$group_developers
# TODO: USERS HAVE TO USE SUDO touch to create files with root/developers as
# owner can't do touch without sudo...

# 3. **Set the setgid bit** on the directory:
# $SUDO chmod g+s /opt/$group_name

# set a bash breakpoint here
trap 'echo "Breakpoint reached"; read -p "Press any key to continue..."' DEBUG

# install firewalld and setup config
source ./ssh_and_firewall.sh
# additional installations Docker rootless
source ./additional_setup.sh

########## END ##########
