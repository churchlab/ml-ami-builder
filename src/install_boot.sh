#!/bin/bash

# Install scripts to run on boot

mv nvidiaoptimize.sh /usr/local/bin/mlpe-nvidiaoptimize.sh
chmod 744 /usr/local/bin/mlpe-nvidiaoptimize.sh
echo "[Unit]
After=syslog.target network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mlpe-nvidiaoptimize.sh

[Install]
WantedBy=default.target" >> /etc/systemd/system/mlpe-nvidiaoptimize.service
chmod 664 /etc/systemd/system/mlpe-nvidiaoptimize.service

mv bashconfig.sh /usr/local/bin/mlpe-bashconfig.sh
chmod 744 /usr/local/bin/mlpe-bashconfig.sh
echo "[Unit]
After=syslog.target network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mlpe-bashconfig.sh

[Install]
WantedBy=default.target" >> /etc/systemd/system/mlpe-bashconfig.service
chmod 664 /etc/systemd/system/mlpe-bashconfig.service

systemctl daemon-reload
systemctl enable mlpe-nvidiaoptimize.service
systemctl enable mlpe-bashconfig.service