
path "noop/policy-entity-alice" {
  capabilities = ["list"]
}

path "secret/metadata/" {
  capabilities = ["list"]
}

path "secret/metadata/entities/" {
  capabilities = ["list"]
}

path "secret/data/entities/alice/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "secret/metadata/entities/alice/*" {
  capabilities = ["list", "delete"]
}


