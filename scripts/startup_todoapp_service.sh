#!/bin/bash

sudo apt-get update
#sudo apt-get -y install net-tools nginx
PRIVATE_IP=`ifconfig | grep -E '(inet addr:172)' | awk '{ print $2 }' | cut -d ':' -f 2`
#echo 'This is my IP: ' $MYIP > var/www/html/index.html
cd lecture_devops_app
# Build server
echo "Build server"
echo "Creating public directory"
sudo mkdir -p .local/public
sudo mkdir -p ./local/db
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
BUILD_PATH=./.local/public
echo "Building client"
sudo node ./scripts/build.js
echo "Starting service"
PUBLIC_URL=http://$PRIVATE_IP
SERVER_PORT="3000"
DB_HOST="localhost" #TODO
DB_PORT="27017"
cd ../..
echo "Starting mongodb"
sudo exec mongod --port $DB_PORT --bind_ip $DB_HOST --logpath /dev/stdout --dbpath ./.local/db --smallfiles
MONGODB_URL=mongodb://$DB_HOST:$DB_PORT/todo-app
JWT_SECRET=myjwtsecret # TODO
PORT=$SERVER_PORT
sudo exec node $BUILD_PATH/index.js
