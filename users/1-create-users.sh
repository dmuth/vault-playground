#!/bin/bash

# Errors are fatal
set -e

# Change to this script's directory.
pushd $(dirname $0) > /dev/null


function create_userpass_auth() {

  echo "# "
  echo "# Enabling userpass auth..."
  echo "# "
  vault auth enable userpass || true
  vault auth list

}


function create_policies() {

  echo "# "
  echo "# Writing policies..."
  echo "# "
  vault policy write policy-user-alice policy-user-alice.hcl
  #vault policy read policy-user-alice
  vault policy write policy-user-bob policy-user-bob.hcl
  vault policy write policy-entity-alice policy-entity-alice.hcl
  vault policy write policy-entity-bob policy-entity-bob.hcl
  vault policy write policy-group-team1 policy-group-team1.hcl
  vault policy write policy-group-team2 policy-group-team2.hcl
  vault policy write policy-group-ops policy-group-ops.hcl

}


function create_users() {

  echo "# "
  echo "# Creating users..."
  echo "# "
  vault write auth/userpass/users/alice password="alicepass" policies="policy-alice"
  vault write auth/userpass/users/bob   password="bobpass"     policies="policy-bob"

  TOKEN=$(vault login -method=userpass username=alice password=alicepass -format=json | jq -r .auth.client_token)
  echo "# "
  echo "# Policies for user alice: "
  echo "# "
  VAULT_TOKEN=${TOKEN} vault token lookup -format=json | jq -c .data.policies

} # End of create_users()


function create_entities() {

  echo "# "
  echo "# Creating entities"
  echo "# "
  vault write identity/entity name="alice-entity" \
    policies="policy-entity-alice" \
    metadata="team=team1"

  vault write identity/entity name="bob-entity" \
    policies="policy-entity-bob" \
    metadata="team=team2"

  echo "# "
  echo "# Policies on alice-entity: "
  echo "# "
  vault read identity/entity/name/alice-entity -format=json | jq -c .data.policies

  ENTITY_ID_ALICE=$(vault read identity/entity/name/alice-entity -format=json | jq -r .data.id)
  echo "# "
  echo "# Entity ID for Alice: ${ENTITY_ID_ALICE}"
  echo "# "
  ENTITY_ID_BOB=$(vault read identity/entity/name/bob-entity -format=json | jq -r .data.id)
  echo "# "
  echo "# Entity ID for Bob: ${ENTITY_ID_BOB}"
  echo "# "

  ACCESSOR=$(vault auth list -format=json | jq -r '."userpass/".accessor')

  echo "# "
  echo "# Linking users to entities..."
  echo "# "
  vault write identity/entity-alias \
    name="alice" \
    canonical_id="${ENTITY_ID_ALICE}" \
    mount_accessor="${ACCESSOR}"

  vault write identity/entity-alias \
    name="bob" \
    canonical_id="${ENTITY_ID_BOB}" \
    mount_accessor="${ACCESSOR}"

  vault write identity/entity/name/alice-entity policies="policy-entity-alice"
  vault write identity/entity/name/bob-entity policies="policy-entity-bob"
  #vault read identity/entity/name/alice-entity 

  TOKEN=$(vault login -method=userpass username=alice password=alicepass -format=json | jq -r .auth.client_token)
  echo "# "
  echo "# Policies for user alice under alice-entity: "
  echo "# "
  VAULT_TOKEN=${TOKEN} vault token lookup -format=json \
    | jq -c '{policies: .data.policies, identity_policies: .data.identity_policies}'

} # End of create_entities()


function create_groups() {

  echo "# "
  echo "# Creating groups and adding members"
  echo "# "
  vault write identity/group name="team1" type="internal" policies="policy-group-team1"
  vault write identity/group name="team2" type="internal" policies="policy-group-team2"
  vault write identity/group name="ops" type="internal" policies="policy-group-ops"

  ENTITY_ID_ALICE=$(vault read identity/entity/name/alice-entity -format=json | jq -r .data.id)
  ENTITY_ID_BOB=$(vault read identity/entity/name/bob-entity -format=json | jq -r .data.id)

  ID_TEAM_1=$(vault read identity/group/name/team1 -format=json | jq -r .data.id)
  ID_TEAM_2=$(vault read identity/group/name/team2 -format=json | jq -r .data.id)
  ID_OPS=$(vault read identity/group/name/ops -format=json | jq -r .data.id)

  vault write identity/group/id/${ID_TEAM_1} member_entity_ids=${ENTITY_ID_ALICE}
  vault write identity/group/id/${ID_TEAM_2} member_entity_ids=${ENTITY_ID_BOB}

}


function create_secrets() {

  echo "# "
  echo "# Writing secrets..."
  echo "# "
  vault kv put -format=json secret/entities/alice/web username="webuser" password="webpass" | jq -r .request_id
  vault kv put -format=json secret/entities/bob/web username="bobwebuser" password="webpass"| jq -r .request_id
  vault kv put -format=json secret/groups/team1/web username="webuser" password="webpass" | jq -r .request_id
  vault kv put -format=json secret/groups/team1/db username="dbuser" password="dbpass" | jq -r .request_id
  vault kv put -format=json secret/groups/team2/web username="webuser2" password="webpass2" | jq -r .request_id
  vault kv put -format=json secret/groups/team2/db username="dbuser2" password="dbpass2" | jq -r .request_id

}


function use_secrets_as_user() {

  #
  # We can't get tokens for entities, since they're aliases.  
  # We can get tokens for the user, though
  #
  TOKEN=$(vault login -method=userpass username=alice password=alicepass -format=json | jq -r .auth.client_token)

  POLICIES=$(VAULT_TOKEN=${TOKEN} vault token lookup -format=json | jq -r -c .data.identity_policies)
  echo "# "
  echo "# Policies for entity alice: ${POLICIES}"
  echo "# "

  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/entities/alice | jq -c
  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/entities | jq -c
  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/ | jq -c
  VAULT_TOKEN=${TOKEN} vault kv get -format=json secret/entities/alice/web | jq -rc .data.data
  #VAULT_TOKEN=${TOKEN} vault kv list secret/entities/bob # This will fail

  echo "# "
  echo "# Reading secrets..."
  echo "# "
  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/groups/team1 | jq -c
  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/groups | jq -c
  VAULT_TOKEN=${TOKEN} vault kv get -format=json secret/groups/team1/db | jq -rc .data.data

  echo "# "
  echo "# Create, read, list, then delete a secret."
  echo "# "
  VAULT_TOKEN=${TOKEN} vault kv put -format=json secret/entities/alice/web2 username="webuser2" password="webpass2" | jq -r .request_id
  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/entities/alice | jq -c
  VAULT_TOKEN=${TOKEN} vault kv get -format=json secret/entities/alice/web2 | jq -rc .data.data
  # This will delete the secret, but a version history will be kept.
  VAULT_TOKEN=${TOKEN} vault kv delete secret/entities/alice/web2 
  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/entities/alice | jq -c
  # This will delete ALL versions of the secret.
  VAULT_TOKEN=${TOKEN} vault kv metadata delete secret/entities/alice/web2 
  VAULT_TOKEN=${TOKEN} vault kv list -format=json secret/entities/alice | jq -c

}


function main() {
  create_userpass_auth
  create_policies
  create_users
  create_entities
  create_groups
  create_secrets
  use_secrets_as_user
}


main



