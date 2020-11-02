#!/bin/bash
#Get Current logged in user
loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
#Query SQLlite DB
sqlite3 -batch /Users/$loggedInUser/Library/Accounts/Accounts4.sqlite "select DISTINCT ZACCOUNTDESCRIPTION,ZUSERNAME from ZACCOUNT where ZACCOUNTDESCRIPTION = 'iCloud';" | cut -d'|' -f2
