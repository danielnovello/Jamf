
#!/bin/bash
# Grabs the expired certificate hashes
expired=$(security find-identity | grep EXPIRED | awk '{print $2}')
# Check for certs
if [ -z "$expired" ]
    then
        echo "No expired certificates, we're all good"
    else
    # Deletes the expired certs via their hash
    echo "Deleting expired certs"
    echo "$expired" | while IFS= read -r line ;
        do
            echo "Deleting" $line;
            security delete-certificate -Z $line;
        done
fi
exit 0 #success