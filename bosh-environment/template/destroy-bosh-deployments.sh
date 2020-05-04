#!/usr/bin/env bash

for deployment in $(bosh deployments --json | jq '.Tables[].Rows[].name'); do
    bosh delete-deployment -d ${deployment}
done
