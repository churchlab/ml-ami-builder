#!/bin/bash

# We only need to install nvidia drivers. Cuda will be handled by Docker.
# This tutorial is the clearest:
# http://www.linuxandubuntu.com/home/how-to-install-latest-nvidia-drivers-in-linux
#
# NOTE 1
# Test with:
#     nvidia-docker run --rm nvidia/cuda nvidia-smi
# For details, see:
#     https://github.com/NVIDIA/nvidia-docker/wiki and
#     https://github.com/NVIDIA/nvidia-docker/wiki/Deploy-on-Amazon-EC2
#
# NOTE 2
# Dockerfiles for tensorflow are at:
#     https://hub.docker.com/r/tensorflow/tensorflow/tags/
# this is tested with
#   FROM gcr.io/tensorflow/tensorflow:1.4.1-gpu-py3
#
# NOTE 3
# Drivers shown at:
# http://www.nvidia.com/download/driverResults.aspx/124729/en-us
# As of 2018-02-01 Drivers version 384.111 are the recommended ones for Tesla
# GPUS, which is what p2, g3, p3 all have.

# Add the graphics-driver PPA
add-apt-repository ppa:graphics-drivers
apt-get update

# Install the drivers that support Tesla machines (p2, g3, p3).
apt-get install -y nvidia-384

# Prevent minor version upgrades.
apt-mark hold nvidia-384

# Reboot required for the driver to kick in.
# Note `pause_before` in packer json for next script install_nvidia_docker.sh.
# This prevents that script from starting to execute since control might
# briefly be returned to packer before reboot initiates.
reboot now
