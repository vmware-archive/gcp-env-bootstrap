#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: ./gke-up.sh <cohort id>"
  exit 1
fi

set -x

function namefromemail() {
  email=$1
  echo ${email%@*}| sed 's/[\.+]/-/g'
}

# retry NUM_RETRIES CMD PARAM1 PARAM2 ...
function retry {
  local retries=$1
  shift

  local count=0
  local exit=999
  while true; do
    set +e
    output=$("$@")
    exit=$?
    #set -e
    if [[ $exit -eq 0 ]]; then
      echo "$output"
      break
    else
      echo "failed command output:" 1>&2
      echo "$output" 1>&2

      count=$(($count + 1))

      if [ $count -lt $retries ]; then
        echo "Retry $count/$retries exited $exit, retrying in $wait seconds..." 1>&2
        sleep 5
      else
        echo "Retry $count/$retries exited $exit, no more retries left. Returning error code $exit" 1>&2
        break
      fi
    fi
  done
  echo Command "$@" succeeded with status $exit 1>&2
  return $exit
}

pushd $( dirname "${BASH_SOURCE[0]}" )

export PROJECT_ID=$(basename $(pwd))
export KUBECONFIG=$(pwd)/.kubeconfig

cohort_id=$1

gcloud container clusters create pal-for-devs-k8s \
    --zone=us-central1-c \
    --machine-type=g1-small \
    --disk-size=30GB \
    --cluster-version 1.16.8-gke.15 \
    --no-enable-autoupgrade \
    --project ${PROJECT_ID}

gcloud container clusters get-credentials pal-for-devs-k8s --zone us-central1-c --project ${PROJECT_ID}

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/cloud-generic.yaml

sleep 60 # wait for the gcp lb to be created and available before..

ingress_router_ip=$(kubectl get service ingress-nginx --namespace=ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

kubectl create namespace development

student_name=$(namefromemail $(cat user.txt))

# 1. create dns managed zone
gcloud dns managed-zones create ${student_name}-zone \
  --description="student subdomain" \
  --dns-name=${student_name}.k8s.pal.pivotal.io. \
  --project $PROJECT_ID

# 2. create dns entry for ingress routing
gcloud dns record-sets transaction start \
  --project $PROJECT_ID \
  --zone=${student_name}-zone

gcloud dns record-sets transaction \
  add ${ingress_router_ip} \
  --name="*.${student_name}.k8s.pal.pivotal.io." \
  --project $PROJECT_ID \
  --ttl=300 --type=A --zone=${student_name}-zone

gcloud dns record-sets transaction execute \
  --project $PROJECT_ID \
  --zone=${student_name}-zone

cat > ${student_name}-env <<-EOF
Cluster URL: development.${student_name}.k8s.pal.pivotal.io
Cluster Name: pal-for-devs-k8s
GCP Project Name: ${PROJECT_ID}
Ingress Router IP: ${ingress_router_ip}
EOF

gsutil cp *-env *-service-account-key.json gs://pal-env-files/pal-for-devs-kubernetes/${cohort_id}/

echo "${PROJECT_ID} successfully provisioned."
