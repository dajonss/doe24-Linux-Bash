 Deliverable DOE24

# Medlemmar 👥

• Muhammad Nasridinov\
• David Jonsson\
• Daniel Pavlos Mironidis\
• Patrick Nyberg\
• Daniel Holström

# Todo list ✅

✅ = Done
❌ = Not done yet

- [x] Core functionally
- [ ] Improved main script
- [ ] Shellcheck best practice complience
- [x] (optional) Vagrant QOL script autostart image and run script (WIP). Automate testing.
- [ ] Vagrant startupscript need a password handling solution. (I suggest using
a predefined password so that ssh-copy-id can pass password before user password is prompted first time, before the sshkey is beign used)

Här nedan följer en checklista för uppgiften.

# Section 1: Users and groups
- [x] 1. Create a user on the system for each member of the group

- [x] 2. Create a group. Each user created above should be a member of the group.

- [x] 3. Set a default password for each user. Ask the user running the script for the password to set. Make sure each user has to change password after the first login.

- [x] 4.0. Create a shared folder under /opt/<group-name>. It should be owned by the shared group created in point

    - [x] 4.1. Make sure newly created files inside the shared folder are automatically owned by the group.

- [x] 5. Make sure all users created previously can run sudo commands without the need to write their password.
# Section 2: System setup
- [x] 1. Make sure all packages are updated to the latest version available.

- [x] 2. Make sure the ssh server is installed and running.

- [x] 3. Configure the ssh server to:

    - [x]  (a) Run on a non-default port

    - [x]  (b) Only accept log-in via pubkey

    - [x]  (c) Only allow the users created previously to login via ssh

- [x] 4. Make sure firewalld is installed and running. Block all incoming connections except for the SSH port. Allow all outgoing connections.

- [x] 5. Make sure the latest available version of docker and docker compose are installed on the system.

- [x] 6. Make sure all users created previously can run docker cli commands without needing to use sudo.

# Connect with private/publickeys

Add to a README.md file to explain to user to use ssh-copy-id with
desired username and ip-adress to virtualmachine with port 9999.
Example:

```bash
ssh-copy-id -p 9999 DanielH@192.168.124.223
```

Then login as normal?
