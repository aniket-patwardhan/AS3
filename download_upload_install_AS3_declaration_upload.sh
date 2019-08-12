#!/bin/bash

#script that download the lastest version of AS3 rmp file from the github, upload and install on the BIG-IP

#installing jq

sudo yum install -y jq



#downloading the AS3 rmp file and save it as output.rmp

curl -L $(curl https://api.github.com/repos/F5Networks/f5-appsvcs-extension/releases/latest | jq -r .assets[0].browser_download_url) -o output.rpm


#First, set the file name and the BIG-IP IP address and credentials, making sure you use the appropriate RPM file name, including build number, and BIG-IP credentials.

FN=output.rpm

CREDS=admin:ASEadmin

IP=10.1.1.6


#the following commands to upload the package.

LEN=$(wc -c $FN | cut -f 1 -d ' ')

curl -kvu $CREDS https://$IP/mgmt/shared/file-transfer/uploads/$FN -H 'Content-Type: application/octet-stream' -H "Content-Range: 0-$((LEN - 1))/$LEN" -H "Content-Length: $LEN" -H 'Connection: keep-alive' --data-binary @$FN



#Installing the package.

DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$FN\"}"

curl -kvu $CREDS "https://$IP/mgmt/shared/iapp/package-management-tasks" -H "Origin: https://$IP" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA


#download the AS3 declaration - AS3.json file from github

AS3DECL=AS3.json

curl -L https://raw.githubusercontent.com/shiftcommathree/ASE/master/AS3.json -o AS3.json


#Installing application using AS3 declaration - AS3.JSON

curl --silent --insecure --user $CREDS -H "Content-Type: application/json" -d "@$AS3DECL" -X POST https://$IP/mgmt/shared/appsvcs/declare