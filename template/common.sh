#!/bin/bash

export BBL_ENV_NAME=$(basename $(pwd))
export PROJECT_ID=${PROJECT_ID:-${BBL_ENV_NAME}}
export BBL_IAAS=gcp
export BBL_GCP_REGION=us-central1
export BBL_GCP_SERVICE_ACCOUNT_KEY=${BBL_ENV_NAME}-service-account-key.json
export SERVICE_ACCOUNT=${BBL_ENV_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
