#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 10.1.0.1

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Install app
cd /home/vagrant/server_app
npm install

## Start server
cat > /etc/systemd/system/server.service <<EOL
[Unit]
Description=Server service

[Service]
ExecStart=/bin/bash -c "cd /home/vagrant/server_app && node server.js"

[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable server --now