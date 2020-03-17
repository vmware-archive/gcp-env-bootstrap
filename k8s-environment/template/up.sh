#!/bin/bash

set -x

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


export ORGANIZATION_ID=265595624405
export CLOUDHEALTH_SERVICE_ACCOUNT_NAME=cloudhealthpivotal
export BILLING_ID=0076DC-766E1F-EBDCB8

pushd $( dirname "${BASH_SOURCE[0]}" )

export PROJECT_ID=$(basename $(pwd))
export KUBECONFIG=$(pwd)/.kubeconfig

if gcloud projects create ${PROJECT_ID} --folder=${FOLDER_ID}; then

  gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ID}

  gcloud services enable \
      compute.googleapis.com \
      iam.googleapis.com \
      cloudresourcemanager.googleapis.com \
      cloudbilling.googleapis.com \
      storage-component.googleapis.com \
      container.googleapis.com \
      --project ${PROJECT_ID}

  gcloud container clusters create development-cluster \
    --zone=us-central1-a \
    --machine-type=g1-small \
    --disk-size=30GB \
    --cluster-version 1.15.9-gke.9 \
    --no-enable-autoupgrade \
    --project ${PROJECT_ID}

else
  echo "${PROJECT_ID} could not be created. Aborting environment creation."
  exit 1
fi

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

gcloud container clusters get-credentials development-cluster --zone us-central1-c --project ${PROJECT_ID}

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/cloud-generic.yaml

kubectl run hello-app --image=gcr.io/google-samples/hello-app:1.0 --port=8080

kubectl create namespace development

kubectl expose deployment hello-app

kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/community/master/tutorials/nginx-ingress-gke/ingress-resource.yaml

sleep 60

my_new_ip=$(kubectl get service ingress-nginx --namespace=ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

retry 6 curl http://${my_new_ip}/hello -v

kubectl delete -f https://raw.githubusercontent.com/GoogleCloudPlatform/community/master/tutorials/nginx-ingress-gke/ingress-resource.yaml

kubectl delete svc hello-app

kubectl delete deployment hello-app

echo "${PROJECT_ID} successfully provisioned."
