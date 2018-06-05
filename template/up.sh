#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )

export PROJECT_ID=$(gcloud config get-value project)
export BBL_ENV_NAME=$(basename $(pwd))
export BBL_IAAS=gcp
export BBL_GCP_REGION=us-central1
export BBL_GCP_SERVICE_ACCOUNT_KEY=${BBL_ENV_NAME}_gcp_credentials.json

if [ ! -f "${BBL_GCP_SERVICE_ACCOUNT_KEY}" ]; then
    gcloud iam service-accounts create ${BBL_ENV_NAME}-service-account \
           --display-name "${BOSH_COURSE_NAME} service account" \
           --project ${PROJECT_ID}

    gcloud iam service-accounts keys create ${BBL_GCP_SERVICE_ACCOUNT_KEY} \
           --iam-account ${BBL_ENV_NAME}-service-account@${PROJECT_ID}.iam.gserviceaccount.com

    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
           --member serviceAccount:${BBL_ENV_NAME}-service-account@${BOSH_PROJECT_ID}.iam.gserviceaccount.com \
           --role "roles/editor"
fi

bbl up

cat > .env <<-OEOF
#!/bin/bash
export JUMPBOX_PRIVATE_KEY=\$(mktemp)
cat > \${JUMPBOX_PRIVATE_KEY} <<-EOF
$(bosh int vars/jumpbox-vars-store.yml --path /jumpbox_ssh/private_key)
EOF
chmod 600 \${JUMPBOX_PRIVATE_KEY}
$(bbl print-env | sed -e 's@=/.*@=${JUMPBOX_PRIVATE_KEY}@g')
OEOF
