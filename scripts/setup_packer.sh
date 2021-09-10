#!/bin/bash
set -x

# Install necessary dependencies
echo "Install necessary dependencies"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get update
sudo apt-get -y -qq install curl wget git vim apt-transport-https ca-certificates
sudo apt-get -y install mongodb-server
echo "Install nodejs npm"
sudo apt-get -y install nodejs npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable
# Clone repository
echo "Clone repository"
sudo git clone https://github.com/benebet/lecture-devops-app.git
cd ./lecture-devops-app
# Install client dependencies
echo "Install client dependencies"
cd app/client
sudo npm install
# Install server dependencies
echo "Install server dependencies"
cd ../server
sudo npm install
