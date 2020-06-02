#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: ./deprovsion-cohort.sh <cohort prefix> <cohort id>"
    exit 1
fi

cohort_prefix=$1
cohort_id=$2

projects=$(ls -d envs/${cohort_prefix}-*)

echo "The following projects will be deprovisioned:"

for project in ${projects[*]}; do
    echo "- ${project}"
done

read -p "Are you sure (y/n) ? " -r

if [[ ! $REPLY =~ ^[Yy]  ]]; then
  exit 2
fi

tmux new-session -d -s "deprovision-${cohort_id}"

for project in ${projects[*]}; do
  tmux new-window -t "deprovision-${cohort_id}" bash -lic "${project}/deprovision.sh 2>&1 | tee ${project}/down-log.txt";
done
