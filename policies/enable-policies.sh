#!/bin/bash

# Errors are fatal
set -e

# Change to this script's directory.
pushd $(dirname $0) > /dev/null

echo "# Writing admin policy..."
vault policy write admin admin-policy.hcl

#vault policy read admin

echo "# Getting admin policy token..."
ADMIN_TOKEN=$(vault token create -format=json -policy="admin" | jq -r ".auth.client_token")

echo "# Getting admin token capabilities on sys/auth/approle..."
vault token capabilities $ADMIN_TOKEN sys/auth/approle

echo "# Getting admin token capabilities on identity/entity..."
vault token capabilities $ADMIN_TOKEN identity/entity

echo "# Getting policy needed to put a secret into Vault..."
vault kv put -output-policy -mount=secret customer/acme customer_name="ACME Inc." \
    contact_email="john.smith@acme.com"


