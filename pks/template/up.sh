#!/bin/bash

ORGANIZATION_ID=265595624405
CLOUDHEALTH_SERVICE_ACCOUNT_NAME=cloudhealthpivotal
BILLING_ID=0076DC-766E1F-EBDCB8

pushd $( dirname "${BASH_SOURCE[0]}" )
PROJECT_ID=$(basename $(pwd))

if gcloud projects create ${PROJECT_ID} --folder=${FOLDER_ID}; then

  gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ID}

  gcloud services enable \
      compute.googleapis.com \
      iam.googleapis.com \
      cloudresourcemanager.googleapis.com \
      cloudbilling.googleapis.com \
      storage-component.googleapis.com \
      container.googleapis.com
      --project ${PROJECT_ID}

  gcloud container clusters create development-cluster \
    --zone=us-central1-c \
    --release-channel=rapid \
    --machine-type=g1-small \
    --disk-size=30GB \
    --cluster-version 1.15.9-gke.9
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

# is it going to be a problem to do this concurrently?
gcloud container clusters get-credentials development-cluster --zone us-central1-c --project ${PROJECT_ID}

# need to install kubectl if not installed
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/cloud-generic.yaml

kubectl run hello-app --image=gcr.io/google-samples/hello-app:1.0 --port=8080

kubectl create namespace development

kubectl expose deployment hello-app

kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/community/master/tutorials/nginx-ingress-gke/ingress-resource.yaml

curl http://$(kubectl get service ingress-nginx --namespace=ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/

result=$?

if [[ $result != 0 ]]
then
  echo "${PROJECT_ID} could not be created. Sample app failed to deploy."
  exit 1
fi

kubectl delete -f https://raw.githubusercontent.com/GoogleCloudPlatform/community/master/tutorials/nginx-ingress-gke/ingress-resource.yaml

kubectl delete svc hello-app

kubectl delete deployment hello-app

echo "${PROJECT_ID} successfully provisioned."
