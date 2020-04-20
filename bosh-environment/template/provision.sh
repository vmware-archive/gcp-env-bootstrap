#!/bin/bash

set -e

./create-project.sh
./up.sh
./test-env.sh


