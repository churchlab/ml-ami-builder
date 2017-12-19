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
pip3 install awscli

# ******************************************************************************
# 3 Install virtual environment stuff, make a vitualenvwrapper home vw_venvs
# install virtualenv into the environment so we can run it
pip3 install virtualenv
# apt-get install -y python3-venv
pip3 install virtualenvwrapper
mkdir vw_venvs
echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile
echo "VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bash_profile
echo "export WORKON_HOME=~/vw_venvs" >> ~/.bash_profile
echo "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv" >> ~/.bash_profile
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bash_profile

echo "export PATH=/usr/local/cuda-9.1/bin${PATH:+:${PATH}}"
echo "export LD_LIBRARY_PATH=/usr/local/cuda-9.1/lib64\
                         ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

source ~/.bash_profile

# ******************************************************************************
# 4 Get APT stuff and clean up
apt-get install -y python3-apt
apt-get clean

