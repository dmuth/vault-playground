
path "noop/policy-group-team1" {
  capabilities = ["list"]
}

path "noop/policy-group-team2" {
  capabilities = ["list"]
}

path "secret/data/groups/*" {
  capabilities = ["read"]
}

path "secret/metadata/groups/*" {
  capabilities = ["list"]
}



