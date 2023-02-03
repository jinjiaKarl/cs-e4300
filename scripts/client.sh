#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 10.1.0.1

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## The app is pre-installed
cd /home/vagrant/client_app
FILE=node_modules.tar.xz
if test -f "$FILE"; then
    tar -xvf $FILE
    rm $FILE
fi
