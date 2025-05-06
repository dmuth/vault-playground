
path "noop/policy-group-team1" {
  capabilities = ["list"]
}

path "secret/metadata/" {
  capabilities = ["list"]
}

path "secret/metadata/groups/" {
  capabilities = ["list"]
}

path "secret/data/groups/team1/*" {
  capabilities = ["read"]
}

path "secret/metadata/groups/team1/" {
  capabilities = ["list"]
}

