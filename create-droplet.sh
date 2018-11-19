#!/bin/bash
set -e

BASE_URL='https://api.digitalocean.com/v2'

#Create .digitalocean Enviroment file with:
#TOKEN=<Generate your token in https://cloud.digitalocean.com/account/api/tokens>
#SSH_FINGERPRINT=<Get your fingerprint from https://cloud.digitalocean.com/account/security>

SECRETFILE=.digitalocean
SIZE_SLUG="s-1vcpu-1gb"
IMAGE="ubuntu-18-04-x64"
REGION="nyc"

if [ -e $SECRETFILE ]; then
    . $SECRETFILE
else
    echo ".digitalocean not found"
    exit 1
fi

RESULT=`curl -s -X POST "${BASE_URL}/droplets" \
	-d"{\"name\":\"digitalblender\",\"region\":\"$REGION\",\"size\":\"${SIZE_SLUG}\",\"image\":\"$IMAGE\",\"ssh_keys\":[\"$SSH_FINGERPRINT\"]}" \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json"`


STATUS=`echo $RESULT | jq -r '.droplet.status'`
echo "Status: $STATUS"
if [ "$STATUS" != "new" ]; then
    echo "Something went wrong:"
    echo $RESULT | jq .
    exit 1
fi
DROPLET_ID=`echo $RESULT | jq '.droplet.id'`

echo "Droplet with ID $DROPLET_ID created!"

echo "Waiting for droplet to boot"
for i in {1..60}; do
    DROPLET_STATUS=`curl -s "${BASE_URL}/droplets/$DROPLET_ID" \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" | jq -r ".droplet.status"`
    [ "$DROPLET_STATUS" == 'active' ] && break
    echo -n '.'
    sleep 5
done


if [ "$DROPLET_STATUS" != 'active' ]; then
    echo "Droplet did not boot in time. Status: $DROPLET_STATUS"
    exit 1
fi
IP_ADDRESS=`curl -s "${BASE_URL}/droplets/$DROPLET_ID" \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" | jq -r '.droplet.networks.v4[0].ip_address'`
echo "IP address: $IP_ADDRESS"

#echo "Execute bootstrap script"
#BOOTSTRAP_URL="https://gist.github.com/levhita/<gistid>/raw/bootstrap.sh"
ssh-keygen -R $IP_ADDRESS
SSH_OPTIONS="-o StrictHostKeyChecking=no"
ssh $SSH_OPTIONS root@$IP_ADDRESS
#ssh $SSH_OPTIONS root@$IP_ADDRESS "curl -s $BOOTSTRAP_URL | bash"

echo "*****************************"
echo "* Droplet is ready to use!"
echo "* IP address: $IP_ADDRESS"
echo "*****************************"