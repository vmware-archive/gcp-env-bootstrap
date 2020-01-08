#!/bin/bash

ORGANIZATION_ID=265595624405
CLOUDHEALTH_SERVICE_ACCOUNT_NAME=cloudhealthpivotal
BILLING_ID=0076DC-766E1F-EBDCB8

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

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

gcloud iam service-accounts create ${BBL_ENV_NAME} \
  --display-name "${BBL_ENV_NAME} service account" \
  --project ${PROJECT_ID}

gcloud iam service-accounts keys create ${BBL_GCP_SERVICE_ACCOUNT_KEY} \
  --iam-account ${SERVICE_ACCOUNT}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:${SERVICE_ACCOUNT} \
  --role "roles/owner"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member user:$(cat ./user.txt) \
  --role "roles/editor"

gcloud iam service-accounts create ${CLOUDHEALTH_SERVICE_ACCOUNT_NAME} \
  --display-name=CloudHealthPivotal \
  --project ${PROJECT_ID}

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

bbl plan --lb-type concourse
bbl up

cat > ${BBL_ENV_NAME}-env <<-OEOF
#!/bin/bash
export JUMPBOX_PRIVATE_KEY=\$(mktemp)
export CONCOURSE_LB_IP=$(bbl lbs | tr -d 'Concourse LB:,')
cat > \${JUMPBOX_PRIVATE_KEY} <<-EOF
$(bosh int vars/jumpbox-vars-store.yml --path /jumpbox_ssh/private_key)
EOF
chmod 600 \${JUMPBOX_PRIVATE_KEY}
export JUMPBOX_SSH_CONFIG=\$(mktemp)
cat > \${JUMPBOX_SSH_CONFIG} <<-EOF
ProxyCommand ssh -W %h:%p jumpbox@$(bosh int vars/jumpbox-vars-file.yml --path /external_ip) -p 22 -i \${JUMPBOX_PRIVATE_KEY}
EOF
export DIRECTOR_PRIVATE_KEY=\$(mktemp)
cat > \${DIRECTOR_PRIVATE_KEY} <<-EOF
$(bosh int vars/director-vars-store.yml --path /jumpbox_ssh/private_key)
EOF
chmod 600 \${DIRECTOR_PRIVATE_KEY}
export DIRECTOR_SSH=jumpbox@$(bosh int vars/director-vars-file.yml --path /internal_ip)
$(bbl print-env | sed -e 's@=/.*@=${JUMPBOX_PRIVATE_KEY}@g')
OEOF
