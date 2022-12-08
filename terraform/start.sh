#!/bin/bash
version=$(lsb_release -r)
num=$(cut -f2 <<< "$version")
if (( $num != 20.04 )); then
    echo "Ubuntu version is not equal than 20.04"
    exit 1
fi
echo hi > /hi.txt
sudo apt update
# sudo apt install virtualbox
sudo apt install -y unzip
sudo apt install -y build-essential
sudo apt install -y virtualbox
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt install -y vagrant
wget https://github.com/jinjiaKarl/cs-e4300_testbed/archive/refs/heads/main.zip
unzip main.zip
# cd cs-e4300-main/base && make && cd ../ && 
# vagrant up