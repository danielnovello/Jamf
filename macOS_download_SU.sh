#!/bin/bash
# Script to download the latest macOS Installer in the background and alert the user when the download is complete

# Log file
log_file="/private/tmp/SU_download.log"

# Run the download and send it to the background
echo "Starting macOS download"
loggedInUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
/usr/bin/nohup sudo -u "$loggedInUser" /usr/sbin/softwareupdate --fetch-full-installer >> "$log_file" &

# Wait for log file to populate (Give it more time to be safe)
sleep 120

# Get the current percentage downloaded
current=$(tail -1 "$log_file" | awk -F':' 'END{ print int($NF) }')

if [[ -f "$log_file" ]]
then
    while [[ "$current" -ne 0 && "$current" -le 100 ]]
      do
        current=$(tail -1 "$log_file" | awk -F':' 'END{ print int($NF) }')
        if [[ "$current" -eq 100 ]]
        then
          echo "macOS Installer $current% downloaded"
          # Display Alert, use whatever you want. (Jamfhelper, Terminal-notifier, etc)
          echo "macOS Installer $current% downloaded"|xargs -I {} osascript -e 'display notification "{}" with title "macOS Download"'
          echo "Removing log file: $log_file"
          rm "$log_file" && exit 1
        elif [[ "$current" -eq 0 ]]
        then 
          echo "Failed download for some reason. Check the log file at $log_file. Exiting"
          exit 1
        else
          echo "Still Downloading macOS Intaller, its on $current%"
        fi
         # Extend if you feel it runs too often.
         sleep 10
    done
else
   echo "$log_file does not exist, exiting."
   exit 0
fi