#!/bin/bash
# Script to download the latest macOS Installer in the background and alert the user when the download is complete. (also at 25%, 50% and 75%)

# Log file
log_file="/private/tmp/SU_download.log"
# Check file
check_file="/private/tmp/SU_download_check.txt"

# Clear out old log files if they exist
if [[ -f "$log_file" && "$check_file" ]]
then 
  rm "$log_file" && rm "$check_file"
fi  

# Creat new files
touch "$check_file"

# Run the download and send it to the background
echo "Starting macOS download"
loggedInUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
/usr/bin/nohup sudo -u "$loggedInUser" /usr/sbin/softwareupdate --fetch-full-installer >> "$log_file" &
echo "macOS Installer download Started"|xargs -I {} osascript -e 'display notification "{}" with title "macOS Download"'

# Wait for log file to populate (Give it more time to be safe)
sleep 30

# Get the current percentage downloaded
current=$(tail -1 "$log_file" | awk -F':' 'END{ print int($NF) }')

if [[ -f "$log_file" && "$check_file" ]]
then
    while [[ "$current" -ne 0 && "$current" -le 100 ]]
      do
        current=$(tail -1 "$log_file" | awk -F':' 'END{ print int($NF) }')
        check_current=$(tail -1 "$check_file" | awk 'END{ print }')
        if [[ "$current" -eq 100 ]]
        then
          echo "macOS Installer $current% downloaded"
          # Display Alert, use whatever you want. (Jamfhelper, Terminal-notifier, etc)
          echo "macOS Installer $current% downloaded"|xargs -I {} osascript -e 'display notification "{}" with title "macOS Download"'
          echo "Removing log file: $log_file"
          rm "$log_file" && rm "$check_file" exit 1
        elif [[ "$current" -eq 0 ]]
        then 
          echo "Failed download for some reason. Check the log file at $log_file. Exiting"
          exit 1
        else
          echo "Still Downloading macOS Intaller, its on $current%"
          if [[ "$current" -eq 25 || "$current" -eq 50 || "$current" -eq 75 ]] && [[ "$check_current" != "$current" ]]
          then 
            echo "macOS Installer $current% downloaded"|xargs -I {} osascript -e 'display notification "{}" with title "macOS Download"'
            echo "$current" >> "$check_file"
          fi
        fi
         # Extend if you feel it runs too often.
         sleep 10
    done
else
   echo "$log_file and / or $check_file does not exist, exiting."
   exit 0
fi