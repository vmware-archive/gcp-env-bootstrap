#!/bin/bash

export PROJECT_ID=$(gcloud config get-value project)
export BBL_ENV_NAME=$(basename $(pwd))
export BBL_IAAS=gcp
export BBL_GCP_REGION=us-central1
export BBL_GCP_SERVICE_ACCOUNT_KEY=${BBL_ENV_NAME}-account-key.json
export SERVICE_ACCOUNT=${BBL_ENV_NAME}-service-account@${PROJECT_ID}.iam.gserviceaccount.com
