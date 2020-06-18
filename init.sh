#!/bin/bash

function email2projectid() {
    echo "${COHORT_PREFIX}-$(echo $1 | sed s/@.*$// | tr '[:upper:]._' '[:lower:]--' | tr -d ' ')" | cut -c -30 | sed 's/-*$//g'
}

COHORT_PREFIX=${COHORT_PREFIX:-${RANDOM}}

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)

if [ $# -eq 0 ]; then
  echo "no args provided"
  exit 1
fi

echo "The following environments will be created:"
for user in "$@"
do
	echo "- $(email2projectid $user) (${user})"
done
read -p "Are you sure (y/n) ? " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  exit 2
fi

for user in "$@"
do
  projectid=$(email2projectid ${user})
  dir="${SCRIPTDIR}/envs/${projectid}"
  mkdir -p ${dir}; pushd ${dir} > /dev/null
  echo "${user}" > user.txt
  find ${SCRIPTDIR}/template -mindepth 1 -maxdepth 1 -type f -exec ln -sf {} \;
  popd > /dev/null
  echo "Created ${projectid}"
done

echo "User environments created"
