#!/bin/bash

set -eux

# Clean up
apt-get -y autoremove
apt-get -y clean

# Removing leftover leases and persistent rules
echo "Cleaning up dhcp leases"
rm -rf /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "Cleaning up udev rules"
rm -rf /dev/.udev/
rm -f /etc/udev/rules.d/70-persistent-net.rules

rm -rf /tmp/* /var/tmp/*

rm -f /root/.ssh/authorized_keys
rm -f ~/.ssh/authorized_keys
rm -rf /etc/ssh/ssh_host_*

rm -rf /var/lib/cloud/instances/*
rm -f /var/lib/cloud/instance
find /var/log -type f -exec /bin/rm -v {} \;

rm -f ~/.bash_history
history -c
