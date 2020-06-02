#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

source ${BBL_ENV_NAME}-env
bosh env

test $? -eq 0 || echo "bosh environment file for ${BBL_ENV_NAME} does not appear to work"

