#!/bin/bash

VERSION="580.126.09"

# update linux-image-amd64
#apt upgrade -y linux-image-amd64
#apt autoremove -y
#sleep 3

# ensure headers are installed
apt update && apt install -y build-essential linux-headers-$(uname -r)
sleep 3

# install driver and reboot
./NVIDIA-Linux-x86_64-${VERSION}.run --dkms --no-x-check --no-nouveau-check
sleep 3
reboot

