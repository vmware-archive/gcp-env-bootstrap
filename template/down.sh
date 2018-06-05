#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )

export BBL_ENV_NAME=$(basename $(pwd))
export BBL_IAAS=gcp
export BBL_GCP_REGION=us-central1
export BBL_GCP_SERVICE_ACCOUNT_KEY=${BBL_ENV_NAME}_gcp_credentials.json

bbl down --no-confirm

gcloud iam service-accounts delete ${BBL_ENV_NAME}-service-account
rm -f ${BBL_GCP_SERVICE_ACCOUNT_KEY}
