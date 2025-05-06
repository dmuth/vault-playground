
path "noop/policy-user-alice" {
  capabilities = ["list"]
}

#
# It doesn't really matter what else I put here, because once Alice is in 
# an entity or group, this policy will be ignored.
#

