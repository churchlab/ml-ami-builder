#!/bin/bash
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#optimize_gpu
# write to /usr/local/bin/ to run at start up in Ubuntu 16.04

set -eux

nvidia-smi -pm 1
nvidia-smi --auto-boost-default=0

ST=`nvidia-smi -L | grep M60 | wc -l`
if [ "$ST" -eq 1 ]
then
    nvidia-smi -ac 2505,1177
else
    nvidia-smi -ac 2505,875
fi

nvidia-smi -acp 0
nvidia-smi --auto-boost-permission=0
nvidia-smi -c 3
