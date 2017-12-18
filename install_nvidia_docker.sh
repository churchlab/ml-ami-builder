#!/bin/bash

# test with:
#       nvidia-docker run --rm nvidia/cuda nvidia-smi
# see: https://github.com/NVIDIA/nvidia-docker/wiki and
#  https://github.com/NVIDIA/nvidia-docker/wiki/Deploy-on-Amazon-EC2
# for details

# ******************************************************************************
# 0. Add support for getting keys over SSL as in part 2.
apt-get install gnupg-curl

# ******************************************************************************
# 1. Install official NVIDIA driver package
# Network install
# per https://github.com/NVIDIA/nvidia-docker/issues/258

# TEST DEPRECATION THIS BLOCK 2017.12.11
# CUDA_FILE=cuda-repo-ubuntu1604_8.0.61-1_amd64.deb

# UPGRADE TEST TO CUDA 9 ADDED 2017.12.11
# tensorflow is using nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04
# from https://hub.docker.com/r/nvidia/cuda/
# it uses driver 9.0.176 from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/9.0/base/Dockerfile
CUDA_FILE=cuda-repo-ubuntu1604_9.0.176-1_amd64.deb

DEB_URL=https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/${CUDA_FILE}
wget ${DEB_URL}
apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
dpkg -i ${CUDA_FILE}
apt-get update
apt-get install -y --no-install-recommends --allow-unauthenticated linux-headers-generic dkms

# This installs nvidia_387 2017.12.18 NC
apt-get install -y  --no-install-recommends cuda-drivers

# ******************************************************************************
# 2. NVIDIA modprobe is installed
apt-get install -y --no-install-recommends nvidia-modprobe

# TEST DEPRECATION THIS BLOCK 2017.12.11
# # ******************************************************************************
# # 3. Install nvidia-docker and nvidia-docker-plugin
apt-get install -y --no-install-recommends --allow-unauthenticated linux-headers-generic dkms
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb


# ******************************************************************************
# 3. Install nvidia-docker and nvidia-docker-plugin
# from nvidia for Xenial 16.04 https://nvidia.github.io/nvidia-docker/

# UNCOMMENT THIS BLOCK WHEN WE ARE READY FOR nvidia-docker2 (that is version 2)
# This is now nvidia-docker version 2 2017.12.11
# curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
#   sudo apt-key add -
# curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
#   sudo tee /etc/apt/sources.list.d/nvidia-docker.list
# sudo apt-get update

# sudo apt-get install nvidia-docker2
# sudo pkill -SIGHUP dockerd

# ******************************************************************************
# 4. Fix busted permissions in nvidia-docker as in here:
# https://github.com/NVIDIA/nvidia-docker/issues/290

# got help from https://bbs.archlinux.org/viewtopic.php?id=195782 for the tee
SERVICE_STR='
[Service]
ExecStart=
ExecStart=/usr/bin/nvidia-docker-plugin -s \$SOCK_DIR -d /usr/local/nvidia-driver
'
OLD_SYSTEMD_EDITOR=$SYSTEMD_EDITOR
echo -e $SERVICE_STR | SYSTEMD_EDITOR=tee systemctl edit nvidia-docker
SYSTEMD_EDITOR=$OLD_SYSTEMD_EDITOR

mkdir /usr/local/nvidia-driver
chown -hR nvidia-docker /usr/local/nvidia-driver
chgrp nvidia-docker /usr/local/nvidia-driver
