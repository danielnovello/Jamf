#!/bin/bash
# Get machine name and year (e.g. MacBook Pro (Retina, 15-inch, Late 2013))
curl -s https://support-sp.apple.com/sp/product?cc=$( ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | sed 's|"||g' | cut -b9-13 ) | sed "s@.*<configCode>\(.*\)</configCode>.*@\1@"