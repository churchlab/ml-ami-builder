#!/bin/bash

# ******************************************************************************
# 1. set up linux headers and files for AWS

set -eux

apt-get update
apt-get install -y linux-aws linux-headers-aws linux-image-aws

# ******************************************************************************
# # 2. Install Ansible
# apt-get install -y software-properties-common
# apt-add-repository ppa:ansible/ansible
# apt-get update
# apt-get install -y ansible


