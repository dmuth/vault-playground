#!/bin/bash

# Errors are fatal
set -e

# Change to this script's directory.
pushd $(dirname $0) > /dev/null

{
set +e
vault secrets list | grep transit
RC=$?
set -e
}

if test "${RC}" -ne 0
then
  vault secrets enable transit

else
  echo "# Secrets transit engine is already enabled."

fi

#vault read sys/mounts/transit

vault write -f transit/keys/user-data > /dev/null
vault write -f transit/keys/user-data2 > /dev/null

echo "# Our transit keys: "
vault list transit/keys

PLAINTEXT="secret user data"
CIPHERTEXT=$(vault write transit/encrypt/user-data plaintext=$(base64 <<< "${PLAINTEXT}") -format=json | jq -r .data.ciphertext)

printf "# %15s: %s\n" "Plaintext" "${PLAINTEXT}"
printf "# %15s: %s\n" "Ciphertext" "${CIPHERTEXT}"

DECRYPTED=$(vault write -format=json transit/decrypt/user-data ciphertext=$CIPHERTEXT | jq -r .data.plaintext | base64 -d)
printf "# %15s: %s\n" "Decrpyted text" "${DECRYPTED}"


