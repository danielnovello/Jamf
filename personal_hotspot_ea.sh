#!/bin/bash
# Airport Plist File
plist=/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist
# Get Dict entries for all known SSID's
ssids=$(/usr/libexec/PlistBuddy -c "print :KnownNetworks" "$plist" | grep -a "= Dict" | cut -d= -f1 | sed "s/ //g")
# Loop and fine all personal Hotspots 
main_func() {
    for i in ${ssids} ; do
        ph=$(/usr/libexec/PlistBuddy -c "print :KnownNetworks:${i}:PersonalHotspot" "$plist")
    if [[ "$ph" == "true" ]]
    then
        # If found, display SSID of Personal Hotspot
        echo "`/usr/libexec/PlistBuddy -c "print :KnownNetworks:${i}:SSIDString" "$plist"`" > /tmp/hotspot_output.txt
    else 
        echo "No Personal Hotspots found" > /tmp/hotspot_output.txt | uniq -u
    fi  
    done
}
main_func
value=$(awk 'NR==1 {print; exit}' /tmp/hotspot_output.txt)
echo "<result>$value</result>"