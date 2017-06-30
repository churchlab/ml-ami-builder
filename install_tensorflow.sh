#!/bin/bash

# see https://www.tensorflow.org/versions/r0.12/get_started/os_setup
# make sure LD_LIBRARY_PATH and CUDA_HOME have been added to the environment

# Ubuntu/Linux 64-bit, CPU only, Python 3.5
export TF_BINARY_URL_CPU=https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.12.1-cp35-cp35m-linux_x86_64.whl

# Ubuntu/Linux 64-bit, GPU enabled, Python 3.5
# Requires CUDA toolkit 8.0 and CuDNN v5. For other versions, see "Installing from sources" below.
export TF_BINARY_URL_GPU=https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-0.12.1-cp35-cp35m-linux_x86_64.whl

export TF_BINARY_URL=${TF_BINARY_URL_GPU}

# Python 3
pip3 install  --ignore-installed --upgrade  ${TF_BINARY_URL}
pip3 install ipython

# will choose python3 and give the environment access to the system site-packages
virtualenv --system-site-packages --python=python3 ~/tfEnv

