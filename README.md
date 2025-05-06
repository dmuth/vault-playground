
# Hashicorp Vault Playground

Just a little playground that I created for using Hashicorup Vault and playing around with it.


## Basic Usage

- `./server-dev.sh` - Start the server in dev mode.  Nothing will be persisted to disk, so each start is a fresh start.
- `. ./set-vars` - Include this file to set environment variables so that you can use `vault` commands to talk to Vault
- Sample directories
  - `audit-logs` - Script to enable audit logging on Vault
  - `policies` - Script and sample policy for Vault
  - `transit-secrets-engine` - Enable and test out the Transit Secrets Engine (Encryption as a Service)
  - `users` - The most complicated script so far.
    - Create a set of users and entities for those users.
    - Create policies for those entities.
    - Create groups with policies, and put the users in those groups.
    - Create, list, read, and delete secrets as a user.


## What's next?

I'll probably play around with this as I have spare time.  Feel free to poke at it if you too
would like to play around with Hashicorp vault.  Feel free to open an Issue if there's anything 
that doesn't look right or if there's anything you'd like to see added.



