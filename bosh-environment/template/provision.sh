#!/usr/bin/env bash

set -e

if [ $# -ne 2 ]; then
  echo "Usage: provision.sh <GCP folder id> <GCS directory path>"
  exit 1
fi

gcp_folder_id=$1
gcs_directory_path=$2

pushd $( dirname "${BASH_SOURCE[0]}" ) > /dev/null

./create-project.sh "${gcp_folder_id}"
./up.sh "${gcs_directory_path}"

popd > /dev/null
