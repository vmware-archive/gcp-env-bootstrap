#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

if [ ! -f "${BBL_GCP_SERVICE_ACCOUNT_KEY}" ]; then
    gcloud iam service-accounts create ${BBL_ENV_NAME} \
           --display-name "${BBL_ENV_NAME} service account" \
           --project ${PROJECT_ID}

    gcloud iam service-accounts keys create ${BBL_GCP_SERVICE_ACCOUNT_KEY} \
           --iam-account ${SERVICE_ACCOUNT}

    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
           --member serviceAccount:${SERVICE_ACCOUNT} \
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
