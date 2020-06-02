#!/usr/bin/env bash


# loop through them and print them out
# loop through them, source env file, run bosh vms, check status code


if [ $# -eq 0 ]; then
    echo "Provide group id to check as an argument"
    exit 1
fi

group_id=${1}

for cohort_directory in envs/${group_id}*; do

  echo $cohort_directory

  pushd $cohort_directory > /dev/null
  
  if [ ! -f *-env ]; then
    "Env file does not exist for ${$cohort_directory}"
  else
    source *-env
    timeout 2s bosh vms > /dev/null
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
      echo "Provisioning failed for ${$cohort_directory}"
    else
      echo "${cohort_directory} successfully provisioned"
    fi
  fi

  popd > /dev/null

done

