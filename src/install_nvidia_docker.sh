#!/bin/bash

# Install nvidia-docker 2
#
# https://github.com/nvidia/nvidia-docker/wiki/Installation-(version-2.0)
#

# Add repos
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
    apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
    tee /etc/apt/sources.list.d/nvidia-docker.list
apt-get update
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
    apt-key add -

# Install
apt-get install -y nvidia-docker2

# Reload Docker daemon config
pkill -SIGHUP dockerd
