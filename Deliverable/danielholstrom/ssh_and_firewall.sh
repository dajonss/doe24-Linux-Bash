$SUDO apt install openssh-client
$SUDO apt install openssh-server
$SUDO sed -i 's/^#Port .*/Port 9999/' /etc/ssh/sshd_config
$SUDO systemctl enable sshd
$SUDO systemctl start sshd

# Install firewalld
$SUDO apt install firewalld
$SUDO systemctl enable firewalld
$SUDO systemctl start firewalld
# Add custom port 9999
$SUDO firewall-cmd --add-port=9999/tcp --permanent
# Reload to make it start
$SUDO firewall-cmd --reload
