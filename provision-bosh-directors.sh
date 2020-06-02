#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "Usage: ./provision-bosh-directors.sh <cohort prefix> <cohort id> <course>"
    exit 1
fi

cohort_prefix=$1
cohort_id=$2
course=$3
gcs_path="${course}/${cohort_id}"

projects=$(ls -d envs/${cohort_prefix}-*)

echo "BOSH directors will be provisioned for the following projects:"

for project in ${projects[*]}; do
    echo "- ${project}"
done

read -p "Are you sure (y/n) ? " -r

if [[ ! $REPLY =~ ^[Yy]  ]]; then
  exit 2
fi

tmux new-session -s "provision-${cohort_id}" -n first-window -d

for project in ${projects[*]}; do
  tmux new-window -t "provision-${cohort_id}" bash -lic "${project}/bbl-up.sh ${gcs_path} 2>&1 | tee ${project}/provision-bosh-log.txt";
done

tmux kill-window -t first-window
