#!/bin/bash

while true; do
    read -p "How many student environments do you want to create: " total
    if ! [[ "${total}" =~ ^[0-9]+$ ]]
    then
        echo "Please enter a number"; exit
    fi
    break
done

while true; do
    read -p "Do you wish to create: ${total} student environments [yes/no]: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

if ! [ -x "$(command -v bbl)" ]; then
    echo "Installing dependencies"
    ./install_deps.sh
fi

start=1
for ((i=start; i<=${total}; i++))
do
    dir="student-env-${i}"
    mkdir -p ${dir}; pushd ${dir} > /dev/null
    find ../template -mindepth 1 -maxdepth 1 -type f -exec ln -sf {} \;
    for dir in ops terraform; do
        mkdir -p ${dir}; pushd ${dir} > /dev/null
        find ../../template/${dir} -mindepth 1 -maxdepth 1 -type f -exec ln -sf {} \;
        popd > /dev/null
    done
    popd > /dev/null
    echo "Created student-env-${i}"
done
echo "Student environments created"
