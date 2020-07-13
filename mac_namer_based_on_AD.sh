#!/bin/bash

# Mame machine based on logged in user (AD user, e.g. John Smith)
# If not logged in as AD user, assign serial number as name

# Get the state of the lastuser
lastUser=$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow lastUser)
lastUserName=$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow lastUserName)
username=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )
serial=$(ioreg -l | awk -F'"' '/IOPlatformSerialNumber/{print $4}')
# Check if the last user is logged in...
if [ ! -z "$lastUser" ] && [ "$lastUser" == "loggedIn" ]; then
  # If the last user is logged in, proceed...
  name=$(finger $username | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' )
  # If logged in as admin account and not AD account? (####)
  if [[ "$username" != "####" ]]
    then
      echo "Naming machine: $name"	
      computername=$name
      bind="$computername"
      /usr/sbin/scutil --set ComputerName "$bind"
      hostname=$(echo "$bind" | awk '{print tolower($0)}')
      localhostname=$(echo "$hostname" | sed 's/[[:space:]]//g')
      /usr/sbin/scutil --set LocalHostName "$localhostname"
    else
      echo "Local user is not an Active Directory user"
      echo "Rather assigning the serial number as the name"
      echo "Naming machine: $serial"
      sleep 1
      /usr/sbin/scutil --set ComputerName "$serial"
      sleep 1
      /usr/sbin/scutil --set LocalHostName "$serial"
  fi
else
  echo "User not logged in, aborting"
fi