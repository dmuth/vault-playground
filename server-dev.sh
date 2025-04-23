#!/bin/bash
#
# Run the Vault server in dev mode
#

# Errors are fatal
set -e 

# Run our server and capture the output for environment variable extraction
vault server -dev -dev-root-token-id root -dev-tls | tee output.txt

