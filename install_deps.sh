#!/bin/bash

wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | sudo apt-key add -
echo "deb http://apt.starkandwayne.com stable main" | sudo tee /etc/apt/sources.list.d/starkandwayne.list
sudo apt update
sudo apt install -y bosh-bootloader bosh-cli
sudo apt install -y libreadline
sudo apt install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 make tree netcat-openbsd

mkdir -p ~/.bosh
rm -fr ~/.bosh/installations
ln -s /tmp ~/.bosh/installations
