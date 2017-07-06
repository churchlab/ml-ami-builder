#!/bin/bash
# write to /usr/local/bin/ to run at start up in Ubuntu 16.04

set -eux

sleep 10

# Update the box
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Tweak sshd to prevent DNS resolution (speed up logins)
echo "UseDNS no" >> /etc/ssh/sshd_config

timedatectl set-timezone America/New_York
