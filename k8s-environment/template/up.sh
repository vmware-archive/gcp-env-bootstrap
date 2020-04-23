#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: ./up.sh <cohort id>"
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
    --zone=us-central1-a \
    --machine-type=g1-small \
    --disk-size=30GB \
    --cluster-version 1.15.11-gke.9 \
    --no-enable-autoupgrade \
    --project ${PROJECT_ID}

gcloud container clusters get-credentials pal-for-devs-k8s --zone us-central1-c --project ${PROJECT_ID}

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

# upload the JSON keyfile to GCS
gsutil cp *-keyfile.json gs://pal-env-files/pal-for-devs-kubernetes/${cohort_id}/

# create student-env file and upload to GCS
student_name=$(namefromemail $(cat user.txt))
cat > ${student_name}-env <<-EOF
Cluster URL: development.${student_name}.k8s.pal.pivotal.io
Custer Name: pal-for-devs-k8s
GCP Project Name: ${PROJECT_ID}
EOF

gsutil cp *-env gs://pal-env-files/pal-for-devs-kubernetes/${cohort_id}/

echo "${PROJECT_ID} successfully provisioned."
