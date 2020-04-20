#!/bin/bash

ORGANIZATION_ID=265595624405
CLOUDHEALTH_SERVICE_ACCOUNT_NAME=cloudhealthpivotal
BILLING_ID=0076DC-766E1F-EBDCB8

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

gcloud projects describe ${PROJECT_ID}

if [ $? -ne 0 ]; then

  if gcloud projects create ${PROJECT_ID} --folder=${FOLDER_ID}; then
      gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ID}
      gcloud services enable \
          compute.googleapis.com \
          iam.googleapis.com \
          cloudresourcemanager.googleapis.com \
          cloudbilling.googleapis.com \
          storage-component.googleapis.com \
          --project ${PROJECT_ID}
  else
      echo "${PROJECT_ID} could not be created. Aborting environment creation."
      exit 1
  fi

else
  echo "project ${PROJECT_ID} already exists, proceeding.."
fi

gcloud iam service-accounts describe ${SERVICE_ACCOUNT}

if [ $? -ne 0 ]; then

  gcloud iam service-accounts create ${BBL_ENV_NAME} \
    --display-name "${BBL_ENV_NAME} service account" \
    --project ${PROJECT_ID}

else
  echo "service account ${BBL_ENV_NAME} already exists, proceeding.."
fi

if [ ! -f "${BBL_GCP_SERVICE_ACCOUNT_KEY}" ]; then

  gcloud iam service-accounts keys create ${BBL_GCP_SERVICE_ACCOUNT_KEY} \
    --iam-account ${SERVICE_ACCOUNT}

else
  echo "service account key already exists, proceeding.."
fi

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:${SERVICE_ACCOUNT} \
  --role "roles/owner"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member user:$(cat ./user.txt) \
  --role "roles/editor"


gcloud iam service-accounts describe ${CLOUDHEALTH_SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

if [ $? -ne 0 ]; then

  gcloud iam service-accounts create ${CLOUDHEALTH_SERVICE_ACCOUNT_NAME} \
    --display-name=CloudHealthPivotal \
    --project ${PROJECT_ID}

else
  echo "service account ${CLOUDHEALTH_SERVICE_ACCOUNT_NAME} already exists, proceeding.."
fi

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member=serviceAccount:${CLOUDHEALTH_SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
  --role=organizations/${ORGANIZATION_ID}/roles/cloudhealthrole \
  --project ${PROJECT_ID} \
  --no-user-output-enabled

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member=serviceAccount:${CLOUDHEALTH_SERVICE_ACCOUNT_NAME}@cma-test.iam.gserviceaccount.com \
  --role=roles/viewer \
  --project ${PROJECT_ID} \
  --no-user-output-enabled

echo "project created.  next up: up.sh"
