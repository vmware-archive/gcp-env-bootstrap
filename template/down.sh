#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

bbl down --no-confirm

gcloud --quiet iam service-accounts delete ${SERVICE_ACCOUNT}
rm -f ${BBL_GCP_SERVICE_ACCOUNT_KEY}
