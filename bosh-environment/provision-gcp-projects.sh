#!/usr/bin/env bash

if [ $# -ne 3 ]; then
    echo "Usage: ./provision-cohort.sh <cohort prefix> <cohort id> <gcp folder id>"
    exit 1
fi

cohort_prefix=$1
cohort_id=$2
gcp_folder_id=$3

projects=$(ls -d envs/${cohort_prefix}-*)

echo "The following projects will be provisioned:"

for project in ${projects[*]}; do
    echo "- ${project}"
done

read -p "Are you sure (y/n) ? " -r

if [[ ! $REPLY =~ ^[Yy]  ]]; then
  exit 2
fi

tmux new-session -d -s "provision-${cohort_id}"

for project in ${projects[*]}; do
  tmux new-window -t "provision-${cohort_id}" bash -lic "${project}/create-project.sh ${gcp_folder_id} 2>&1 | tee ${project}/provision-log.txt";
done
