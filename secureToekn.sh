#!/bin/bash

# Enter usernmae and password of admin user with secureToken
username=""
password=""

version=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ $version -ge 15 ]]
then

# The admin account needs to authenticate to validate its password to enable SecureToken on the account
# Using dscl and -authonly is the least intrusive way to do that.
/usr/bin/dscl /Local/Default -authonly "$username" "$password"

# Kick off the bootstrap token escrow install. The UX is interactive.
# Use expect to supply username and password when prompted.
/usr/bin/expect << BOOTSTRAP

log_file /Users/Shared/expect.log
spawn profiles install -type bootstraptoken
sleep 1
expect "Enter the admin user name:"
sleep 1
send "localadmin\n"
sleep 1
expect "Enter the password for user"
sleep 1
send "password\n"
sleep 1
expect "profiles"
sleep 1
interact
BOOTSTRAP