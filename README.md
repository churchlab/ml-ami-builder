# Packer and related scripts for configuring AWS GPU machines with CUDA Drivers

## Overview

Use [packer](https://www.packer.io) to create an AMI to run `nvidia-docker` containers like `tensorflow:1.4.1-gpu-py3`

The `packer` config `gpu-packer.json` creates an AMI backed by an [Amazon EBS volume](https://www.packer.io/docs/builders/amazon-ebsvolume.html) on a `gp2` SSD drive using the Ubuntu 16.04 AMI `ami-d15a75c7`as a base.

The config then tells packer to setup the following (2017.12.30):

* Install NVIDIA cuda drivers for `cuda-repo-ubuntu1604_9.1.85`
* Install `nvidia-docker` v1.0.1
* Sets up nouveua video driver block to not interfere with NVIDIA proprietary drivers
* `systemd` service 00: optimizes driver settings for in:
    * g3 M60
    * p3 V100
    * p2 K80
* `systemd` service 01: bash configuration
* Install Python 3 build dependencies, including `awscli`
* Sets up Python 3 install `virtualenv` and `ipython`
* Also creates a `vitualenvwrapper` home directory in `~/vw_venvs`

All bash scripts in repo are and should remain well commented to document the build process.

## Requirements:

* Download packer <https://www.packer.io/downloads.html> and unzip.
Optional: move the binary into `/usr/local/bin`.

* install python3 libraries in `requirements.txt` to run tests in the
repositories `test/` path

## Usage

1. Validate the template.

    $ packer validate gpu-packer.json

2. Build. You'll need your AWS keys.

    $ packer build \
        -var 'aws_access_key=YOUR ACCESS KEY' \
        -var 'aws_secret_key=YOUR SECRET KEY' \
        gpu-packer.json
