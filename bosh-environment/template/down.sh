#!/bin/bash

pushd $( dirname "${BASH_SOURCE[0]}" )
source ./common.sh

bbl down --no-confirm

