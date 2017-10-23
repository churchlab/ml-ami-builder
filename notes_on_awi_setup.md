
This file is for notes and links on setting up AMIs and `docker` images or `nvidia-docker` running for gpu usage

# AWS basics links
* [AWS Instance types](https://aws.amazon.com/ec2/instance-types/)

# nvidia CUDA links
* [Ubuntu 16.04 x84_64 debian packages](https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/)
* [cuda public repo source page](https://hub.docker.com/r/nvidia/cuda/)
* [gitlab sub link](https://gitlab.com/nvidia/cuda/tree/ubuntu16.04)
* more of this gitlab [example Dockerfile](https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile)
* [Linux Cuda install](http://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#pre-installation-actions)

# Canonical Ubuntu repo for nvidia
[Launchpad](https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa)

# nvidia-docker links
* [nvidia-docker home page](https://github.com/NVIDIA/nvidia-docker)
* [driver issue](https://github.com/NVIDIA/nvidia-docker/issues/427)

# Kubernetes and Tensorflow
* [Tensorflow nvidia setup](https://www.tensorflow.org/versions/r0.12/get_started/os_setup#optional_install_cuda_gpus_on_linux)
* [Kubernetes + GPUs](https://medium.com/intuitionmachine/kubernetes-gpus-tensorflow-8696232862ca) and medium post

# Deploy AWS HPC cluster
* [using CfnCluster intro](https://aws.amazon.com/getting-started/projects/deploy-elastic-hpc-cluster/)
* [Glebs design document](https://docs.google.com/document/d/1rYe7wV6BuSXkEGvFz3HR3pmnyqigtggKWOFOmrUJWeQ/edit#heading=h.sdndlra6bpj4)
* [CfnCluster supported base AMIs](https://github.com/awslabs/cfncluster/blob/master/amis.txt)
* [CfnCluster network configurations](http://cfncluster.readthedocs.io/en/latest/networking.html)
* [CfnCluster config files](http://cfncluster.readthedocs.io/en/latest/configuration.html)
* [ipython cluster example](https://github.com/roryk/ipython-cluster-helper/blob/master/example/example.py)