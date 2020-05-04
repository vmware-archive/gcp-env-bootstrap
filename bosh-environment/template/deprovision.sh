#!/usr/bin/env bash

set -e

pushd $( dirname "${BASH_SOURCE[0]}" ) > /dev/null

./destroy-bosh-deployments.sh
./bbl-down.sh

popd > /dev/null

echo "Deprovisioning completed"
