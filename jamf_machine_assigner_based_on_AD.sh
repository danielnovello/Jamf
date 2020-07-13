#!/bin/bash

# Variables #
# Define your domain
domain="####"
# Define local IP address to ping (Check for local connectivity)
localIP="####"
# Define local admin user
localadmin="####"

# Check Connection to AD
if ping -c 1 $localIP &> /dev/null
then
  echo "Can Connect to AD, continue..,"
##########################
# Check if connected to AD
check4AD=$(/usr/bin/dscl localhost -list . | grep "Active Directory")
# Get logged in users name
loggedInUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
# Get Full Name
realname=$(/usr/bin/dscl /Active\ Directory/$domain/All\ Domains -read /Users/$loggedInUser RealName | tail -n 1 | cut -c2-)
# Get Email
email=$(/usr/bin/dscl /Active\ Directory/$domain/All\ Domains -read /Users/$loggedInUser EMailAddress | awk '{ $1 = ""; print }' | cut -c2-)
# Get Phone number
phone=$(/usr/bin/dscl /Active\ Directory/$domain/All\ Domains -read /Users/$loggedInUser PhoneNumber | awk '{ $1 = ""; print }' | cut -c2-)
# Get Position
position=$(/usr/bin/dscl /Active\ Directory/$domain/All\ Domains -read /Users/$loggedInUser JobTitle | sed -n 2p | sed -e 's/^[ \t]*//')

# If the machine is not bound to AD, then there's no purpose going any further.
# Or if logged in as local admin and not AD user
if [[ "$loggedInUser" != " " ]] && [[ "$loggedInUser" != "$localadmin" ]] && [[ "${check4AD}" == "Active Directory" ]]
then
   printf '%60s\n' | tr ' ' -
   echo "User logged in is a Active Directory user"
   printf '%60s\n' | tr ' ' -
   echo "Assigning user to machine in jamf"
   printf '%60s\n' | tr ' ' -
   echo "Check for AD $check4AD"
   echo "LoggedinUser: $loggedInUser"
   echo "RealName: $realname"
   echo "Email: $email"
   echo "PhoneNumber (-phone) $phone"
   echo "Position: $position"
   printf '%60s\n' | tr ' ' -
   /usr/local/jamf/bin/jamf recon -endUsername "$loggedInUser" -realname "$realname" -email "$email" -phone "$phone" -position "$position"
   exit 0
else
   echo "The Active Directory user is not logged in or Machine is not bound to Active Directory. Fix that, then run again."
fi
else
  echo "Cannot Connect to AD, bailing out..,"
fi