#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: ./provision-gke-clusters.sh <cohort prefix> <cohort id>"
    exit 1
fi

cohort_prefix=$1
cohort_id=$2

projects=$(ls -d envs/${cohort_prefix}-*)

echo "GKE Clusters will be provisioned in the following projects:"

for project in ${projects[*]}; do
    echo "- ${project}"
done

read -p "Are you sure (y/n) ? " -r

if [[ ! $REPLY =~ ^[Yy]  ]]; then
  exit 2
fi

tmux new-session -s "provision-${cohort_id}" -n first-window -d

for project in ${projects[*]}; do
  tmux new-window -t "provision-${cohort_id}" bash -lic "${project}/gke-up.sh ${cohort_id} 2>&1 | tee ${project}/provision-gke-log.txt";
done

tmux kill-window -t first-window
