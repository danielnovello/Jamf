#!/bin/bash
################################################################
#### Snipe URL
snipe_url="YOURURL/api/v1"
#### Snipe API key
snipe_api_key="YOURAPIKEY"
################################################################

### Mac Variables
computer_name=$(scutil --get ComputerName)
serial_number=$(system_profiler SPHardwareDataType | grep 'Serial Number (system)' | awk '{print $NF}')
### Curl Variables
header=(--silent --header "Content-Type: application/json" --header "Accept: application/json" --header "Authorization: Bearer $snipe_api_key")
### Data to apply. Add some variables (To Do)
# asset_tag > "Whatever you want"
# status_id > 1="Pending", 2="Ready to Deploy", 3="Archived"
# model_id= > E.G. 1="MacBook Pro (#MacBookPro11,3)" or whatever you have chosen.
# name > from $computer_name variable
# serial > from machines $serial_number variable
data_add='{"asset_tag":"XXXXX_tag","status_id":2,"model_id":1,"name":"'"$computer_name"'","serial":"'"$serial_number"'"}'

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
# Get the Serial Number only from Snipe-IT
serial_number_search=$(search_function | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^serial/ {print $2}' | sed 's/"//g' | uniq)
# Get the deleted status of the asset in Snipe-IT
deleted_asset_check=$(deleted_function | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^delete/ {if ( $2 =="true" || $2 =="false") print $2}')

#echo "This is your serial number: $serial_number"
#echo "This is the serial number in Snipe-IT: $serial_number_search"
#echo "This is the ID number for the asset in Snipe-IT: $id_number_search"
#echo "Deleted? (True= No, False= Yes): $deleted_asset_check"

### If serial number not found, add it. If found, patch it using its ID but not if its deleted.
if [ "$serial_number" == "$serial_number_search" ] && [ "$deleted_asset_check" == "false" ]
then
    echo "This asset is deleted. Ignoring..."
elif [ "$serial_number" == "$serial_number_search" ] && [ "$deleted_asset_check" == "true" ]
then
    echo "This asset already exists, updating..."
    patch_function
else
    [ "$serial_number" != "$serial_number_search" ] && [ -z "$deleted_asset_check" ]
    echo "This asset does not exist, adding asset..."
    add_function
fi