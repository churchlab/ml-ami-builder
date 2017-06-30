#!/bin/bash

# ******************************************************************************
# VERSION of driver to beat bug
# Alternate try version 375.51
# export NVIDIA_DRIVER=381.22
# export NVIDIA_DRIVER_MAJOR=381 #
export NVIDIA_DRIVER_MAJOR=375

# NOTE: NC commented out as GPU driver version 375 is sufficient as of 2017.06.30
# export CUDA_VERSION=8.0.61_375.26
# export CUDA_VERSION2=8.0.61-1
# export CUDA_REPO=cuda-repo-ubuntu1604=${CUDA_VERSION2}
# export CUDA_DRIVER_VERSION=375.51-1
# export CUDA_DRIVERS=cuda-drivers=${CUDA_DRIVER_VERSION}
# export NVIDIA_CUDA_URL_ROOT=https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/
# export NVIDIA_CUDA_KEY=7fa2af80.pub

# ******************************************************************************
# 0. Add support for getting keys over SSL as in part 2.
apt-get install gnupg-curl

# ******************************************************************************
# 1. Install latest drivers from Ubuntu PPA for 16.04
# This defeats a bug here: https://bugs.launchpad.net/ubuntu/+source/nvidia-graphics-drivers-375/+bug/1662860
# Use graphics driver: nvidia-378.13  to eliminate libEGL.so.1 is not a symbolic link bug
# see https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa
# could go as high as 381.22
# it is from graphics drivers ppa get with:
# add-apt-repository ppa:graphics-drivers/ppa
apt-get update
apt-get install -y --no-install-recommends nvidia-${NVIDIA_DRIVER_MAJOR} nvidia-${NVIDIA_DRIVER_MAJOR}-dev

# ******************************************************************************
# 2. Get CUDA from NVIDIA Ubuntu 16.04 repository and install dependencies
# install both cuda-repo and cuda-drivers
# NOTE: NC Commented out for local install 2017.06.30
# CUDA_STUB=cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64
# CUDA_FILE=${CUDA_STUB}.deb
# local install
# DEB_URL=https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/${CUDA_STUB}-deb

# Network install
CUDA_FILE=cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
DEB_URL=http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/${CUDA_FILE}
wget ${DEB_URL}
sudo dpkg -i ${CUDA_FILE}
sudo apt-get update
apt-get install -y --no-install-recommends --allow-unauthenticated linux-headers-generic dkms
apt-get install -y  --no-install-recommends cuda-8-0

# symbolic link fix for bug
mv /usr/lib/nvidia-375/libEGL.so.1 /usr/lib/nvidia-375/libEGL.so.1.orig
ln -s  /usr/lib/nvidia-375/libEGL.so.1.orig /usr/lib/nvidia-375/libEGL.so.1
mv /usr/lib32/nvidia-375/libEGL.so.1 /usr/lib/nvidia-375/libEGL.so.1.orig
ln -s  /usr/lib32/nvidia-375/libEGL.so.1.orig /usr/lib32/nvidia-375/libEGL.so.1

# ******************************************************************************
# 3. Install CUDA DNN and clear list of packages (This is safe)
apt-get install -y build-essential cmake git unzip pkg-config
apt-get install -y libopenblas-dev liblapack-dev

# TODO: NC Commented out until cuDNN 6.x is activated for Tensorflow.  Maybe it is Look into 2017.06.30
# export CUDNN_VERSION=6.0.21
# export NVIDIA_CUDA_DNN_URL_ROOT=https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/
# echo "deb ${NVIDIA_CUDA_DNN_URL_ROOT} /" > /etc/apt/sources.list.d/nvidia-ml.list
# apt-get update
# apt-get install -y --no-install-recommends --allow-unauthenticated libcudnn6=$CUDNN_VERSION-1+cuda8.0 && \
# rm -rf /var/lib/apt/lists/*

# TODO: NC Commented alternate cuDNN 6.x 2017.06.30
# apt-get install -y --allow-unauthenticated libcudnn6=6.0.21-1+cuda8.0
# cuDNN 6.0 Runtime for Ubuntu 16.04
# https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v6/prod/8.0_20170427/Ubuntu16_04_x64/libcudnn6_6.0.21-1+cuda8.0_amd64-deb
# cuDNN 6.0 developer for Ubuntu 16.04
# https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v6/prod/8.0_20170427/Ubuntu16_04_x64/libcudnn6-dev_6.0.21-1+cuda8.0_amd64-deb

# cuDNN 5.1 library for Linux
# cudnn library tgz file copied in gpu-packer.json since it is firewalled on nvidia's site
cd ~/temp_dnn
#CUDNN_5_1_URL=https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v5.1/prod_20161129/8.0/cudnn-8.0-linux-x64-v5.1-tgz
#wget ${CUDNN_5_1_URL}
tar xvzf cudnn-8.0-linux-x64-v5.1.tgz
cp -P cuda/include/cudnn.h /usr/local/cuda-8.0/include
cp -P cuda/lib64/libcudnn* /usr/local/cuda-8.0/lib64
chmod a+r /usr/local/cuda-8.0/include/cudnn.h /usr/local/cuda-8.0/lib64/libcudnn*
cd ~
# delete the cudnn source files
rm -rf ~/temp_dnn
rm -rf /var/lib/apt/lists/*

# 4. Install NVIDIA CUDA Profiler Tools Interface development files
add-apt-repository ppa:nvidia-cuda-toolkit/ppa
apt-get update
apt-get install -y libcupti-dev

# ******************************************************************************
# 5. NVIDIA modprobe is installed
apt-get install -y --no-install-recommends nvidia-modprobe

# ******************************************************************************
# 6. Append environment variables to bash_profile for Ubuntu
echo "export CUDA_HOME=/usr/local/cuda-8.0" >> ~/.bash_profile
echo "export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}" >> ~/.bash_profile
echo "export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >>  ~/.bash_profile
echo 'export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda/extras/CUPTI/lib64"' >> ~/.bash_profile
# bring variables into the environment
source ~/.bash_profile
