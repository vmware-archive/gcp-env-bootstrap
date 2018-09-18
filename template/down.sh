#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

bbl down --no-confirm

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
  --member user:$(cat ./student.txt) \
  --role "roles/editor"

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:${SERVICE_ACCOUNT} \
  --role "roles/editor"

gcloud --quiet iam service-accounts delete ${SERVICE_ACCOUNT}

gcloud --quiet projects delete ${PROJECT_ID}

rm -f ${BBL_GCP_SERVICE_ACCOUNT_KEY}
