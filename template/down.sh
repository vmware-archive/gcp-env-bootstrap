#!/bin/bash

if ! [ -x "$(command -v bbl)" ]; then
    echo "Installing dependencies"
    ./install_deps.sh
fi

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

bbl down --no-confirm

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
       --member serviceAccount:${SERVICE_ACCOUNT} \
       --role "roles/editor"

gcloud --quiet iam service-accounts delete ${SERVICE_ACCOUNT}

rm -f ${BBL_GCP_SERVICE_ACCOUNT_KEY}
