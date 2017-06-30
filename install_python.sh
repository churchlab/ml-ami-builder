#!/bin/bash

# Install Required Python libraries not Tensoflow
# no need for sudo because running from packer

# ******************************************************************************
# 1. Get basic python stuff set up (We can build custom python C/C++ libraries)
apt-get update
apt-get install -y python3-pip
apt-get install -y build-essential libssl-dev libffi-dev python3-dev

# ******************************************************************************
# 2 install AWS CLI globally
pip3 install --upgrade pip
pip3 install -y awscli

# ******************************************************************************
# 3 Install virtual environment stuff, make a vitualenvwrapper home vw_venvs
# install virtualenv into the environment so we can run it
pip3 install virtualenv
# apt-get install -y python3-venv
pip3 install virtualenvwrapper
mkdir vw_venvs
echo "export WORKON_HOME=~/vw_venvs" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh\n" >> ~/.bashrc
source ~/.bashrc

# ******************************************************************************
# 4 Get APT stuff and clean up
apt-get install -y python3-apt
apt-get clean

