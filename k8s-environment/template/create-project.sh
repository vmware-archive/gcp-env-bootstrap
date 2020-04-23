#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "Usage: create-project.sh <gcp folder id>"
  exit 1
fi

function namefromemail() {
  email=$1
  echo ${email%@*}| sed 's/[\.+]/-/g'
}

ORGANIZATION_ID=265595624405
CLOUDHEALTH_SERVICE_ACCOUNT_NAME=cloudhealthpivotal
BILLING_ID=0076DC-766E1F-EBDCB8

pushd $( dirname "${BASH_SOURCE[0]}" )

export PROJECT_ID=$(basename $(pwd))
gcp_folder_id=$1

gcloud projects describe ${PROJECT_ID}

if [ $? -ne 0 ]; then

  if gcloud projects create ${PROJECT_ID} --folder=${gcp_folder_id}; then
      gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ID}
      gcloud services enable \
          compute.googleapis.com \
          iam.googleapis.com \
          cloudresourcemanager.googleapis.com \
          cloudbilling.googleapis.com \
          storage-component.googleapis.com \
          container.googleapis.com \
          --project ${PROJECT_ID}
  else
      echo "${PROJECT_ID} could not be created. Aborting environment creation."
      exit 1
  fi

else
  echo "project ${PROJECT_ID} already exists, proceeding.."
fi

username=$(namefromemail $(cat user.txt))
service_account_username="${username}-service-account"
service_account="${service_account_username}@${PROJECT_ID}.iam.gserviceaccount.com"
service_account_filename="${service_account_username}-keyfile.json"

gcloud iam service-accounts describe ${service_account}

if [ $? -ne 0 ]; then

  gcloud iam service-accounts create ${service_account_username} \
  --display-name=project-owner \
  --project ${PROJECT_ID}

else
  echo "service account ${service_account} already exists, proceeding.."
fi

if [ ! -f "${service_account_filename}" ]; then

  gcloud iam service-accounts keys create ${service_account_filename} \
  --iam-account="${service_account}" \
  --project ${PROJECT_ID}

else
  echo "service account key already exists, proceeding.."
fi

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member=serviceAccount:"${service_account}"  \
  --role="roles/owner" \
  --project ${PROJECT_ID} \
  --no-user-output-enabled

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

