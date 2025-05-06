
path "noop/policy-group-team2" {
  capabilities = ["list"]
}

path "secret/metadata/" {
  capabilities = ["list"]
}

path "secret/metadata/groups/" {
  capabilities = ["list"]
}

path "secret/data/groups/team2/*" {
  capabilities = ["read"]
}

path "secret/metadata/groups/team2/" {
  capabilities = ["list"]
}


