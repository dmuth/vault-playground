#!/bin/bash

# Errors are fatal
set -e

# Change to this script's directory.
pushd $(dirname $0) > /dev/null


function create_userpass_auth() {

  echo "# Enabling userpass auth..."
  vault auth enable userpass || true
  vault auth list

}


function create_policies() {

  echo "# Writing policies..."
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

  echo "# Creating users..."
  vault write auth/userpass/users/alice password="alicepass" policies="policy-alice"
  vault write auth/userpass/users/bob   password="bobpass"     policies="policy-bob"

  TOKEN=$(vault login -method=userpass username=alice password=alicepass -format=json | jq -r .auth.client_token)
  echo "# Policies for user alice: "
  VAULT_TOKEN=${TOKEN} vault token lookup -format=json | jq -c .data.policies

} # End of create_users()


function create_entities() {

  echo "# Creating entities"
  vault write identity/entity name="alice-entity" \
    policies="policy-entity-alice" \
    metadata="team=team1"

  vault write identity/entity name="bob-entity" \
    policies="policy-entity-bob" \
    metadata="team=team2"

  echo "# Policies on alice-entity: "
  vault read identity/entity/name/alice-entity -format=json | jq -c .data.policies

  ENTITY_ID_ALICE=$(vault read identity/entity/name/alice-entity -format=json | jq -r .data.id)
  echo "# Entity ID for Alice: ${ENTITY_ID_ALICE}"
  ENTITY_ID_BOB=$(vault read identity/entity/name/bob-entity -format=json | jq -r .data.id)
  echo "# Entity ID for Bob: ${ENTITY_ID_BOB}"

  ACCESSOR=$(vault auth list -format=json | jq -r '."userpass/".accessor')

  echo "# Linking users to entities..."
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
  echo "# Policies for user alice under alice-entity: "
  VAULT_TOKEN=${TOKEN} vault token lookup -format=json \
    | jq -c '{policies: .data.policies, identity_policies: .data.identity_policies}'

} # End of create_entities()


function create_groups() {

  vault write identity/group name="team1" type="internal" policies="policy-group-team1"
  vault write identity/group name="team2" type="internal" policies="policy-group-team2"
  vault write identity/group name="ops" type="internal" policies="policy-group-ops"

  ID_TEAM_1=$(vault read identity/group/name/team1 -format=json | jq -r .data.id)
  ID_TEAM_2=$(vault read identity/group/name/team2 -format=json | jq -r .data.id)
  ID_OPS=$(vault read identity/group/name/ops -format=json | jq -r .data.id)

  vault write identity/group/id/${ID_TEAM_1} member_entity_ids=${ENTITY_ID_ALICE}
  vault write identity/group/id/${ID_TEAM_2} member_entity_ids=${ENTITY_ID_BOB}

}


function create_secrets() {
true

#team1/{web,db}  
#team2/{web,db}  

}


function main() {
#  create_userpass_auth
#  create_policies
#  create_users
  create_entities
  create_groups
  create_secrets
}


main



