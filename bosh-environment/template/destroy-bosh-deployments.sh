#!/usr/bin/env bash

source *-env

for deployment in $(bosh deployments --json | jq '.Tables[].Rows[].name'); do
    bosh delete-deployment -d ${deployment}
done
