# Section 1: Users and groups
##################################################################################
#1. Create a user on the system for each member of the group

#2. Create a group. Each user created above should be a member of the group.

#3. Set a default password for each user. Ask the user running the script for the password to set. Make sure each user has to change password after the first login.

#4.0. Create a shared folder under /opt/<group-name>. It should be owned by the shared group created in point

    #4.1. Make sure newly created files inside the shared folder are automatically owned by the group.

#5. Make sure all users created previously can run sudo commands without the need to write their password.
##################################################################################

# Section 2: System setup
##################################################################################
#1. Make sure all packages are updated to the latest version available.

#2. Make sure the ssh server is installed and running.

#3. Configure the ssh server to:

    # (a) Run on a non-default port

    # (b) Only accept log-in via pubkey
    
    # (c) Only allow the users created previously to login via ssh

#4. Make sure firewalld is installed and running. Block all incoming connections except for the SSH port. Allow all outgoing connections.

#5. Make sure the latest available version of docker and docker compose are installed on the system.

#6. Make sure all users created previously can run docker cli commands without needing to use sudo.