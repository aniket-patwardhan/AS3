# Downloading, uploading and installing the AS3 package


# 1. Download
curl -L $(curl https://api.github.com/repos/F5Networks/f5-appsvcs-extension/releases/latest | jq -r .assets[0].browser_download_url) -o output.rpm

# 2. Upload & Install 
FN=rpm file name (rpm file name you just downloaded)

CREDS=username:password (Big-IP Credentials)

IP=IP address of BIG-IP (i.e. 10.1.1.6)

# This command will upload it:
LEN=$(wc -c $FN | cut -f 1 -d ' ')

curl -kvu $CREDS https://$IP/mgmt/shared/file-transfer/uploads/$FN -H 'Content-Type: application/octet-stream' -H "Content-Range: 0-$((LEN - 1))/$LEN" -H "Content-Length: $LEN" -H 'Connection: keep-alive' --data-binary @$FN

# This command will install it: 
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$FN\"}"

curl -kvu $CREDS "https://$IP/mgmt/shared/iapp/package-management-tasks" -H "Origin: https://$IP" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA

# Checking for a successful installation:
1. use Postman to send a GET https://(IP address of BIG-IP)/mgmt/shared/appsvcs/info
2. use curl to check curl -k --user username:password --request GET \https://{{Big IP Address}}/mgmt/shared/appsvcs/info | jq . | less

# Download the AS3 declaration from github
AS3DECL=json_file_name
curl -L https://raw.githubusercontent.com/link that you are downloading the declaration -o json_file_name

# Uploading the AS3 json declaration for application:
1. curl --silent --insecure --user $CREDS -H "Content-Type: application/json" -d "@json_file_name" -X POST https://{{BIG-IP IP Address}}/mgmt/shared/appsvcs/declare
