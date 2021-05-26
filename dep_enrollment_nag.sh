#!/bin/bash

#Variables
keychain="/Library/Keychains/apsd.keychain"
cert=$(/usr/bin/security find-certificate -p -Z $keychain | /usr/bin/openssl x509 -noout -enddate | cut -f2 -d=)
expiration_date=$(/bin/date -j -f "%b %d %T %Y %Z" "$cert" "+%Y%m%d")
current_date=$(/bin/date "+%Y%m%d")
PROFILES=$(profiles status -type enrollment | grep "Enrolled via DEP: Yes")

# Check for Enrollment
function enrol {
	if [[ "$PROFILES" = "Enrolled via DEP: Yes" ]]
		then
    	echo "You are already enrolled"
	else
   		echo "You are not correctly enrolled / Not in DEP"
   		/usr/bin/profiles renew -type enrollment
	fi
}

#Check Certificate
function check_expiration {
	echo "Status: Checking certificate expiration"
	if [ $expiration_date -lt $current_date ]; then
		echo "Certificate expired: Yes"
		echo "Status: Deleting apsd.keychain"
		rm $keychain
		echo "Status: Keychain deleted"
		echo "Status: Exiting"
        enrol
	else
		echo "Certificate expired: No"
        enrol
	fi
}

#Execute
check_expiration