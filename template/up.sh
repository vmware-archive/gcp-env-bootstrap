#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

if ! gcloud projects describe ${PROJECT_ID} >/dev/null 2>&1; then
  if ! gcloud projects create ${PROJECT_ID}; then
    echo "${PROJECT_ID} could not be created. Aborting environment creation."
    exit 1
  fi
fi

if gcloud projects describe ${PROJECT_ID} | grep -q DELETE_REQUESTED; then
  echo "${PROJECT_ID} is pending deletion and cannot be re-used. Aborting environment creation."
  exit 1
fi

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

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member user:$(cat ./user.txt) \
  --role "roles/editor"

bbl up

cat > ${BBL_ENV_NAME}-env <<-OEOF
#!/bin/bash
export JUMPBOX_PRIVATE_KEY=\$(mktemp)
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
