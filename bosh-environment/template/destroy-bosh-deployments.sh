#!/usr/bin/env bash


# Get bosh deployments
# iterate over each and destroy

# bosh deployments --json
deployments=$(bosh deployments --json | jq '.Tables[].Rows[].name')

# bosh delete-deployment -d <deployment>
