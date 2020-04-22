#!/usr/bin/env bash


# bail out if no prefix given
# find all envs files for given prefix
# loop through them and print them out
# loop through them, source env file, run bosh vms, check status code


if [ $# -eq 0 ]; then
    echo "Provide group id to check as an argument"
    exit 1
fi

group_id=${1}

env_files=("$(ls envs/${group_id}*/*.sh)")

for env_file in envs/${group_id}*/*.sh; do
    echo "File: ${env_file}"

    echo "Done"

done

#cat envs/*/up.sh

