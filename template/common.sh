#!/bin/bash

export PROJECT_ID=$(gcloud config get-value project)
export BBL_ENV_NAME=$(basename $(pwd))
export BBL_IAAS=gcp
export BBL_GCP_REGION=us-central1
export BBL_GCP_SERVICE_ACCOUNT_KEY=${BBL_ENV_NAME}-service-account-key.json
export SERVICE_ACCOUNT=${BBL_ENV_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

if ! [ -x "$(command -v bbl)" ]; then
    echo "Installing dependencies"
    ./install_deps.sh
fi
