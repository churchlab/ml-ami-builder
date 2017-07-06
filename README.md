# Packer and related scripts for configuring AWS GPU machines with CUDA. WIP

## Overview

The `packer` config `gpu-packer.json` creates an AMI backed by an [Amazon EBS volume](https://www.packer.io/docs/builders/amazon-ebsvolume.html) on a `gp2` SSD drive using the Ubuntu 16.04 AMI `ami-d15a75c7`as a base.

The config then tells packer to setup the following:

* Install Python 3 build dependencies, including `awscli`
* NVIDIA drivers
* Sets up nouveua video driver block to not interfere with NVIDIA proprietary drivers
* Installs CUDA and sets the `LD_LIBRARY_PATH` and `CUDA_HOME` environment variables for `bash`
* Installs the `libcupti-dev` AKA the CUDA Profiler Tools Interface (CUPTI)
* Sets up Python 3 install `virtualenv` and `ipython`
* Installs Tensorflow and sets up a default environment `~/tfEnv`
* Also creates a `vitualenvwrapper` home directory in `~/vw_venvs`

## Usage


Download packer <https://www.packer.io/downloads.html> and unzip. (Optional: move the binary into `/usr/local/bin`).

Validate the template.

    $ packer validate gpu-packer.json

Build. You'll need your AWS keys.

    $ packer build \
        -var 'aws_access_key=YOUR ACCESS KEY' \
        -var 'aws_secret_key=YOUR SECRET KEY' \
        gpu-packer.json
