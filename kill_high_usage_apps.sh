#!/bin/bash
# 
# USE WITH CAUTION. IF YOU DONT UNDERSTAND WHAT THIS DOES, DONT USE IT!
# 
# Process(s) to monitor. (seperate with space)
process=(Jira MAMP) # Examples
# CPU percentage threshold for alerts
threshold="100"
# How often we run the checks in seconds 
polling="5"
# Path to notfifications application (Which ever you use)
pn_path="/Notifications...."

# Run the check
while true
    do
    for i in $(pgrep -i "${process[@]}" | awk '{print $1}')
        do
            cpu=$(ps -p "$i" -o %cpu= | awk -F'.' '{ print $1 }')
            pid_name=$(ps -p "$i" -o comm= | awk -F'/' '{ print $NF }')
            if [[ "$cpu" -gt "$threshold" ]]
            then
                now_alert=$(date +%Y-%m-%d\ %H:%M:%S)
                echo "$now_alert | $pid_name above $threshold% CPU usage ($cpu% )"
                # Uncomment if you want notifications
                # "$pn_path" -type banner -title "CPU USAGE ALERT" -subtitle "$pid_name above $threshold CPU usage ($cpu% )" &
                echo Killing "$pid_name" && pkill "$pid_name" # BE CAREFUL 
            fi    
        done
    now=$(date +%Y-%m-%d\ %H:%M:%S)    
    echo "$now Run Check Done" ; sleep "$polling"
done