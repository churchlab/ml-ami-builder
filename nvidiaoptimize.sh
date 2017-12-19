#!/bin/bash
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#optimize_gpu
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/optimize_gpu.html
# write to /usr/local/bin/ to run at start up in Ubuntu 16.04

set -eux

nvidia-smi -pm 1
nvidia-smi --auto-boost-default=0

ST=`nvidia-smi -L | grep M60 | wc -l`
if [ "$ST" -eq 1 ]
then
    # it is a G3 M60
    nvidia-smi -ac 2505,1177
else
    ST=`nvidia-smi -L | grep K80 | wc -l`
    if [ "$ST" -eq 1 ]
    then
        # it is a P2 K80
        nvidia-smi -ac 2505,875
    else
        # it is a P3 Tesla V100
        nvidia-smi -ac 877,1530
    fi
fi

nvidia-smi -acp 0
nvidia-smi --auto-boost-permission=0
nvidia-smi -c 3
