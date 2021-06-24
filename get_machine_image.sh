#!/bin/bash
# Size of image (240x240, 480x480)
size="480x480"

# Redirect Function
get_redirects(){
    i=${2:-1}
    read status url <<< $(curl -H 'Cache-Control: no-cache' -o /dev/null --silent --head --insecure --write-out '%{http_code}\t%{redirect_url}\n' "$1" -I)
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
serialnumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}' | awk '{print substr($0,9)}')
# Format URL
URL="https://km.support.apple.com.edgekey.net/kb/securedImage.jsp?configcode=$serialnumber&size=$size"GKJN

image_url=$(get_redirects "$URL" | tail -1 | cut -d' ' -f2)
echo "Downloading ${image_url##*/}"
/usr/bin/curl -ks -O "$image_url"