#!/bin/bash

sudo apt-get update
#sudo apt-get -y install net-tools nginx
export PRIVATE_IP=`ifconfig | grep -E '(inet addr:172)' | awk '{ print $2 }' | cut -d ':' -f 2`
#echo 'This is my IP: ' $MYIP > var/www/html/index.html #Use this to verify the server ip and reachability
cd ~/lecture-devops-app
# Build the server
echo "Build server"
echo "Creating public directory"
sudo mkdir -p .local/public
sudo rm -rf .local/public
echo "Copying server source to public directory"
sudo cp -r app/server/src .local/public
echo "Copying package files to public directory"
sudo cp app/server/package* .local/public/
echo "Installing server dependencies"
cd .local/public/
sudo npm install --prod --no-audit --no-fund
echo "Removing package files"
sudo rm -rf ./package*
echo "Build client"
cd ../../app/client
# Create env variables for node files
export BUILD_PATH=./.local/public
export PUBLIC_URL=http://$PRIVATE_IP # TODO fix with actual ebs name
export MONGODB_NAME=myFirstDatabase # TODO as secret
export MONGODB_USER=dbUser #TODO as secret
export MONGODB_PW=DuHRSa9Xp8suxFsz #TODO as secret
export JWT_SECRET=myjwtsecret # TODO as secret
export PORT="3000"
export MONGODB_URL="mongodb+srv://$MONGODB_USER:$MONGODB_PW@cluster0.scali.mongodb.net/$MONGODB_NAME?retryWrites=true&w=majority"
sudo node ./scripts/build.js
echo "Starting service"
cd ../../.local/public
echo "Starting server"
sudo node index.js
