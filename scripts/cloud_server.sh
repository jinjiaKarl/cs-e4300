#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 10.1.0.1

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Install app
cd /home/vagrant/server_app
npm install

## Kill daily update process (if running)
CMD="lsof -t /var/lib/dpkg/lock-frontend"
while [  $(eval $CMD) ]; do
    kill -9 $(eval $CMD)
done

## Install docker
apt install docker.io -y

## Start server
docker run -p 30000:8080 -d -v $PWD:/app -w /app node:8.10.0 node server.js
docker run -p 30001:8080 -d -v $PWD:/app -w /app node:8.10.0 node server.js
