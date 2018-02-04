# Packer and related scripts for configuring AWS GPU machines with CUDA Drivers

## Latest ami

**ami-ba9b98c0** (wyss-mlpe-docker-gpu-2018-02-03T21-11-33Z)

    Results for tsting ami-ba9b98c0:
    c5.xlarge PASS
    m4.2xlarge PASS
    g3.4xlarge PASS
    p3.2xlarge PASS
    p3.8xlarge PASS

## Overview

Use [packer](https://www.packer.io) to create an AMI to run `nvidia-docker` containers like `tensorflow:1.4.1-gpu-py3`

The `packer` config `gpu-packer.json` creates an AMI backed by an [Amazon EBS volume](https://www.packer.io/docs/builders/amazon-ebsvolume.html) on a `gp2` SSD drive using the Ubuntu 16.04 AMI `ami-d15a75c7`as a base.

The config then tells packer to setup the following (2018.02.03):

* Install Nvidia drivers 384.111 - These are the latest recommended for Tesla (AWS p2, g3, p3)
* Install `nvidia-docker` v2
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

## Support

Development is generously supported by [AWS Cloud Credits for Research](https://aws.amazon.com/research-credits/).
