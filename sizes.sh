#!/bin/bash
set -e

BASE_URL='https://api.digitalocean.com/v2'

#Create .digitalocean Enviroment file with:
#TOKEN=<Generate your token in https://cloud.digitalocean.com/account/api/tokens>
#SSH_FINGERPRINT=<Get your fingerprint from https://cloud.digitalocean.com/account/security>

SECRETFILE=.digitalocean

if [ -e $SECRETFILE ]; then
    . $SECRETFILE
else
    echo ".digitalocean not found"
    exit 1
fi

curl -s "${BASE_URL}/sizes" \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" | jq "."