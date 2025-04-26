#!/bin/bash

# Errors are fatal
set -e

# Change to this script's directory.
pushd $(dirname $0) > /dev/null

echo "# Writing secret..."
vault kv put secret/my-secret vault=awesome user=doug

echo "# Reading secret..."
vault kv get secret/my-secret 

echo "Writing policy..."
vault policy write secret-read ./policy-secret-read.hcl

echo "# Creating policy token..."
TOKEN=$(vault token create -policy=secret-read -field=token)

echo "# Reading secret with policy token..."
VAULT_TOKEN=${TOKEN} vault kv get -field=vault secret/my-secret 

#VAULT_TOKEN=${TOKEN} vault token lookup


