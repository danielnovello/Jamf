#!/bin/bash

# AD admin details
ADusername="####"
ADpassword="####"
# Domain name
domain="####"

# Check binding
check=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
# Remove Binding
remove=$(/usr/sbin/dsconfigad -remove -force -u $ADusername -p $ADpassword &>/dev/null)

# Remove binding, if bound
if [[ "$check" == "$domain" ]]
then
   echo "Mac is bound to $domain, removing binding..."
   $remove
   echo "Mac removed from $domain domain"
   sleep 3
   # Check binding again
   checkagain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
        echo "Checking for bind again to make sure"
    if [ -z "$checkagain" ]
    then
        echo "Mac is not bound to $domain, we are good!"
    else
        echo "Mac is still bound to $domain, something went wrong"
    fi
else
   echo "Mac is not bound to $domain"
fi