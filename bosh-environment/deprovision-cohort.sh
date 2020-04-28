#!/usr/bin/env bash

# confirm args
# print out projects in dir
# confirm to delete
# for each projects, run bbl down?

if [ $# -ne 1 ]; then
    echo "Usage: ./deprovsion-cohort.sh <cohort id>"
    exit 1
fi

gcp_folder_id=$1

projects=($(gcloud projects list --filter "parent.id:${gcp_folder_id}" --format="json(name)" | jq -r '.[] | .name'))

echo "The following projects will be deprovisioned:"

for project in "${projects[@]}"; do
  echo "- $project"
done

read -p "Are you sure (y/n) ? " -r

if [[ ! $REPLY =~ ^[Yy]  ]]; then
  exit 2
fi

for project in "${projects[@]}"; do

  dir="envs/${project}"

  pushd $dir > /dev/null

  ls
  
  popd > /dev/null

done
