#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: ./make-all-aws-ns-records.sh <cohort prefix>"
    exit 1
fi

cohort_prefix=$1

projects=$(ls -d envs/${cohort_prefix}-*)

echo "NS records will be created for the following environments:"

for project in ${projects[*]}; do
    echo "- ${project}"
done

read -p "Are you sure (y/n) ? " -r

if [[ ! $REPLY =~ ^[Yy]  ]]; then
  exit 2
fi

tmux new-session -s "provision-${cohort_prefix}" -n first-window -d

for project in ${projects[*]}; do
  tmux new-window -t "provision-${cohort_prefix}" bash -lic "${project}/make-aws-ns-record.sh 2>&1 | tee ${project}/provision-gke-log.txt";
done

tmux kill-window -t first-window
