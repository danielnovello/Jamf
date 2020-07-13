#!/bin/bash

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Get User
user=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
# Get Apps
allapps=$(mdfind -onlyin /Applications "kMDItemKind == Application" | sort )

if [[ $user != "" ]]; then
    uid=$(id -u "$user")
    result=$(launchctl asuser $uid /usr/bin/osascript <<-EndOfScript
        set theApps to the paragraphs of "$(printf '%s\n' "$allapps")"
        return choose from list theApps with prompt "Choose the Application to remove the quarantine" 
EndOfScript)
fi

echo "You chose: $result"
check=$(/usr/bin/xattr "$result" | grep "com.apple.quarantine")
if [[ "$check" == "com.apple.quarantine" ]]
then
    echo "$result is quarantined, removing quarantine"
    /usr/bin/xattr -r -d com.apple.quarantine "$result"
    /usr/bin/osascript -e 'display dialog "Done, please try the application again" buttons {"Done"}'
else
   echo "$result is not quarantined"
   /usr/bin/osascript -e 'display dialog "The Application is not quarantined" buttons {"Ok"}'
fi

