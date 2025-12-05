#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

apt-get update -y

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs npm git

cd /home/ubuntu

git clone https://github.com/akkimahesh/apt-assignment.git

cd apt-assignment/app

npm install

export PORT=8080

nohup npm start > /var/log/app.log 2>&1 &
