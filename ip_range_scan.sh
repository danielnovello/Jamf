#!/bin/bash
# Create CSV File
echo "IP Address, Ping, Forward lookup, Reverse lookup" > lan_scan.csv 

# Some colours
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

echo "Starting IP Address lookup..."
echo ""

for ip in 192.168.51.{1..255}
do

# Ping check
pinger() {
    com_check=$(ping -q -c 1 -W 1 "${ip}" | grep "100.0% packet loss")
    if [[ -z "$com_check" ]]
        then
        echo "${green}Reachable"
    else
        echo "${red}Not Reachable"
    fi
}
    pinger_output=$(pinger)
    
    echo "Checking ${ip}..."
    echo "Can ping: $pinger_output"
    get_name=$(nslookup ${ip} | awk -F'name = ' '{print $2}' | awk 'NF { $1=$1; print }' | sed 's/.$//')
    if [[ "$get_name" ]]
        then
        a_host=$(host "$get_name" | grep -F 'has address')
        get_ip_from_ahost=$(echo "$a_host" | awk -F' ' '{print $NF}')
        ptr_host=$(host "$get_ip_from_ahost")
        echo "${green}Forward lookup: $a_host"
        echo "${yellow}Reverse lookup: $ptr_host"
        # CSV
        echo "${ip},$pinger_output,$a_host,$ptr_host" | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" >> lan_scan.csv
        echo ""
    else
        echo "${red}${ip} has no DNS lookup"
        # CSV
        echo "${ip} has no DNS lookup,$pinger_output,," | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" >> lan_scan.csv
        echo ""
    fi
    # Reset Color for next loop
    echo -en "\033[0m"
done
