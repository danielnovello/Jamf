#!/bin/bash
# Get status of netbois
check=$(/bin/launchctl list | grep "netbiosd" | awk -F' ' '{ print $3 }')
# Disable if running
if [[ "$check" == com.apple.netbiosd]]
then
    echo "Disabling Netbios"
    /bin/launchctl unload -w /System/Library/LaunchDaemons/com.apple.netbiosd.plist
else
    echo "NetBios is not running. Exiting."
fi
