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
# sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
# sudo sh -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
# sudo apt-get update && sudo apt-get install -y --no-install-recommends linux-headers-generic dkms cuda-drivers

# Network install
# per https://github.com/NVIDIA/nvidia-docker/issues/258
CUDA_FILE=cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
DEB_URL=https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/${CUDA_FILE}
wget ${DEB_URL}
dpkg -i ${CUDA_FILE}
apt-get update
apt-get install -y --no-install-recommends --allow-unauthenticated linux-headers-generic dkms
apt-get install -y  --no-install-recommends cuda-drivers

# # symbolic link fix for bug
# mv /usr/lib/nvidia-375/libEGL.so.1 /usr/lib/nvidia-375/libEGL.so.1.orig
# ln -s  /usr/lib/nvidia-375/libEGL.so.1.orig /usr/lib/nvidia-375/libEGL.so.1
# mv /usr/lib32/nvidia-375/libEGL.so.1 /usr/lib/nvidia-375/libEGL.so.1.orig
# ln -s  /usr/lib32/nvidia-375/libEGL.so.1.orig /usr/lib32/nvidia-375/libEGL.so.1

# ******************************************************************************
# 2. NVIDIA modprobe is installed
apt-get install -y --no-install-recommends nvidia-modprobe

# ******************************************************************************
# 3. Install nvidia-docker and nvidia-docker-plugin
apt-get install -y --no-install-recommends --allow-unauthenticated linux-headers-generic dkms
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb

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
