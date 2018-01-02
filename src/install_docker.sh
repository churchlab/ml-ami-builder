#!/bin/bash

# Install docker ce into the build per:
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository

sudo apt-get update

# ******************************************************************************
# 0. Add support for getting keys over SSL as in part 2.
apt-get install  -y --no-install-recommends gnupg-curl

# ******************************************************************************
# 1. install docker ce
mkdir docker_temp
cd docker_temp

apt-get install  -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

apt-get purge lxc-docker

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install  -y --no-install-recommends docker-ce

# delete temporary directory
cd ~
rm -rf docker_temp

# ******************************************************************************
# 3. let current user access the docker engine, because you’re lacking
# permissions to access the unix socket to communicate with the engine
# usermod -a -G docker $USER
usermod -a -G docker ubuntu
# echo '*********** I am $USER **********'
