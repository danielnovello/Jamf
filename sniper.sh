#!/bin/bash
################################################################
#### Snipe URL
snipe_url="YOURSNIPE-ITURLHERE"
#### Snipe API key
snipe_api_key="YOURAPIKEYHERE"
################################################################

### Mac Variables
computer_name=$(scutil --get ComputerName)
serial_number=$(system_profiler SPHardwareDataType | grep 'Serial Number (system)' | awk '{print $NF}')
### Curl Variables
header=(--silent --header "Content-Type: application/json" --header "Accept: application/json" --header "Authorization: Bearer $snipe_api_key")
### Data to apply. Add some variables (To Do)
# status_id > 1="Pending", 2="Ready to Deploy", 3="Archived"
# model_id= > E.G. 1="MacBook Pro (#MacBookPro11,3)"
data_add='{"asset_tag":"XXXX_tag","status_id":2,"model_id":1,"name":"'"$computer_name"'","serial":"'"$serial_number"'"}'

### Search for device by Serial Number
search_function() {
/usr/bin/curl "${header[@]}" --location --request GET --url "$snipe_url/hardware/byserial/$serial_number"
}

### Add Asset
add_function() {
/usr/bin/curl "${header[@]}" --location --request POST "$snipe_url/hardware" --data "$data_add"    
}

### Patch Asset
id_number_search=$(search_function | grep -o -E "\"id\":[0-9]+" | awk -F: '{print $2; exit}')
patch_function() {
/usr/bin/curl "${header[@]}" --location --request PATCH "$snipe_url/hardware/$id_number_search" --data "$data_add"    
}

### Search for device by ID
deleted_function() {
/usr/bin/curl "${header[@]}" --location --request GET "$snipe_url/hardware/$id_number_search"   
}

### Search for mac serial number in Snipe-IT   
serial_number_search=$(search_function | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^serial/ {print $2}' | sed 's/"//g' | uniq)
deleted_asset_check=$(deleted_function | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^delete/ {if ( $2 =="true" || $2 =="false") print $2}')

#echo "This is your serial number: $serial_number"
#echo "This is the serial number in Snipe-IT: $serial_number_search"
#echo "This is the ID number for the asset in Snipe-IT: $id_number_search"
#echo "Deleted? (True= No, False= Yes): $deleted_asset_check"

### If serial number not found, add it. If found, patch it using its ID.
if [ "$serial_number" == "$serial_number_search" ] && [ "$deleted_asset_check" == "false" ]
then
    echo "This asset is deleted. Ignoring..."
elif [ "$serial_number" == "$serial_number_search" ] && [ "$deleted_asset_check" == "true" ]
then
    echo "This asset already exists, updating..."
    patch_function
else
    [ "$serial_number" != "$serial_number_search" ] && [ "$deleted_asset_check" == " " ]
    echo "This asset does not exist, adding asset..."
    add_function
fi