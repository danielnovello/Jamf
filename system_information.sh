#!/bin/bash

loggedInUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
Jhelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

getosname() {
    osname=$(sw_vers | grep ProductVersion | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' | cut -d. -f1-2)
    if [ "$osname" == "10.15" ]
        then
            echo "macOS Catalina"
            if [ "$osname" == "10.14" ]
                then
                echo "macOS Mojave"
                if [ "$osname" == "10.13" ]
                    then
                     echo "macOS High Sierra"
                     if [ "$osname" == "10.12" ]
                        then
                        echo "macOS Sierra"
                    fi
                fi
            fi
    fi
}

# Get Machine name and date
MachineInfo=$(/usr/bin/curl --silent https://support-sp.apple.com/sp/product?cc="$( ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | sed 's|"||g' | cut -b9-13 )" | sed "s@.*<configCode>\(.*\)</configCode>.*@\1@")
# Get Model Identifier
Model=$(/usr/sbin/ioreg -l | awk '/product-name/ { split($0, line, "\""); printf("%s\n", line[4]); }')
# Get Operating System name
OSName=$(getosname)
# Get Operating System version
osnamever=$(sw_vers | grep ProductVersion | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')
# Get Serial Number
SerialNumber=$(/usr/sbin/ioreg -l | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }')
# Get HD Toatal Size
TotalSize=$(/usr/sbin/diskutil info / | awk -F'[(|)]' '/Container Total Space/{print $1}' | xargs | cut -d: -f2 | sed -e 's/^[[:space:]]*//')
# Get Free Space on HD
FreeSpace=$(/usr/sbin/diskutil info / | awk -F'[(|)]' '/Container Free Space/{print $1}' | xargs | cut -d: -f2 | sed -e 's/^[[:space:]]*//')
# Calculate the used percentage of the HD
# Remove GB
TotalSizeFix=$(echo "$TotalSize" | cut -d' ' -f1)
FreeSpaceFix=$(echo "$FreeSpace" | cut -d' ' -f1)
FreePrecentage=$( echo "$FreeSpaceFix"/"$TotalSizeFix"*100 | bc -l | cut -d. -f1)
# Get time since last restart
Uptime=$(/usr/bin/uptime | cut -d, -f1 | cut -d' ' -f4-5)
# Local IP
LocalIP=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d" " -f2)
# Wan IP
WANIP=$(/usr/bin/curl --silent ipinfo.io/ip)

Message="Model: '$MachineInfo
Model Identifier: $Model
Operating System: $OSName $osnamever
Serial Number: $SerialNumber
Hard Drive: $TotalSize ( Free: $FreeSpace | $FreePrecentage % Used )
Days since last restart: $Uptime
Local IP Address: $LocalIP
Internet IP Address: $WANIP"

# Size of image (240x240, 480x480)
size="480x480"

# Redirect Function
get_redirects(){
    i=${2:-1}
    read status url <<< $(/usr/bin/curl --silent -H 'Cache-Control: no-cache' -o /dev/null --silent --head --insecure --write-out '%{http_code}\t%{redirect_url}\n' "$1" -I)
    printf '%d: %s %s\n' "$i" "$1";
    if [ "$1" = "$url" ] || [ $i -gt 9 ]; then
        echo "Recursion detected or more redirections than allowed. Stop."
    else
      case $status in
          30*) get_redirects "$url" "$((i+1))"
               ;;
      esac
    fi
}

# Get machine serial number
serialnumber_image=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}' | awk '{print substr($0,9)}')
# Format URL
URL="https://km.support.apple.com.edgekey.net/kb/securedImage.jsp?configcode=$serialnumber_image&size=$size"

image_url=$(get_redirects "$URL" | tail -1 | cut -d' ' -f2)
#echo "Downloading ${image_url##*/}"
/usr/bin/curl --silent -ks -L "$image_url" --output /private/tmp/machine_image.png

Alert=$("$Jhelper" -windowType hud -title "System Information" -description "$Message" -button1 "Close" -button2 "Save" -defaultButton 1 -icon "/private/tmp/machine_image.png" -iconSize 128)
