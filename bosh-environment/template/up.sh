#!/bin/bash

set -e

if [ $# -ne 1 ]; then
  echo "Usage: ./up.sh <gcs directory path>"
  exit 1
fi

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

gcs_directory_path=$1

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

gsutil cp *-env gs://pal-env-files/${gcs_directory_path}/
