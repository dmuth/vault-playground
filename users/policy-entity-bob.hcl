
path "noop/policy-entity-bob" {
  capabilities = ["list"]
}

path "secret/metadata/" {
  capabilities = ["list"]
}

path "secret/metadata/entities/" {
  capabilities = ["list"]
}

path "secret/data/entities/bob/*" {
  capabilities = ["read"]
}

path "secret/metadata/entities/bob/" {
  capabilities = ["list"]
}

