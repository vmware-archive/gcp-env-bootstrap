#!/usr/bin/env bash

set -e

if [ $# -ne 2 ]; then
  echo "Usage: provision.sh <cohort id> <GCP folder id>"
  exit 1
fi

cohort_id=$1
gcp_folder_id=$2

./create-project.sh "${gcp_folder_id}"
./up.sh "${cohort_id}"