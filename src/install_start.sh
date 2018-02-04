#!/bin/bash

# First thing run in packer creation

# ******************************************************************************
# Configure for clean packer run
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# remove debconf warnings (i.e. dialog and falling back to frontend: Readline)
apt-get install -y dialog apt-utils

# ******************************************************************************
# Extra stuff

# linux-image-extra is installed this is 16.04 specific
apt-get install -y linux-image-extra-xenial

# packages related for APT with https are installed
apt-get install -y apt-transport-https ca-certificates

# software-properties-common is installed for prerequisite for
# apt_repository ansible module
apt-get install -y software-properties-common

apt-get install linux-headers-$(uname -r)
