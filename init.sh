#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)

if [ $# -eq 0 ]; then
  echo "no args provided"
  exit 1
fi

echo "The following environments will be created:"
for env in "$@"
do
    echo "- $env"
done
read -p "Are you sure? " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 2
fi

if ! [ -x "$(command -v bbl)" ]; then
    echo "Installing dependencies"
    ${SCRIPTDIR}/install_deps.sh
fi

for env in "$@"
do
  dir="${SCRIPTDIR}/envs/${env}"
  mkdir -p ${dir}; pushd ${dir} > /dev/null
  find ${SCRIPTDIR}/template -mindepth 1 -maxdepth 1 -type f -exec ln -sf {} \;
  for dir in ops terraform; do
      mkdir -p ${dir}; pushd ${dir} > /dev/null
      find ${SCRIPTDIR}/template/${dir} -mindepth 1 -maxdepth 1 -type f -exec ln -sf {} \;
      popd > /dev/null
  done
  popd > /dev/null
  echo "Created ${env}"
done

echo "Student environments created"
