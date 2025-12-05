#!/bin/bash

#check root user or not

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

if [ $ID -ne 0 ]; then
    echo "You must be root user to run this script"
    exit 1
else
    echo "You are root user, proceeding with the installation..."
fi

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common >>$LOGFILE 2>&1

#Install HashiCorp's GPG key.

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

#Verify the GPG key's fingerprint.

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint  >>$LOGFILE 2>&1

#Add the official HashiCorp repository to your system.

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

#Update apt to download the package information from the HashiCorp repository.
sudo apt update >>$LOGFILE 2>&1
#Install Terraform.
sudo apt-get install terraform -y >>$LOGFILE 2>&1
#Verify the installation.
terraform -version 
