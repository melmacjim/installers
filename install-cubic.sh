#!/bin/bash

if uname -a | grep -i ubuntu ; then
  apt-add-repository ppa:cubic-wizard/release
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6494C6D6997C215E
  apt update && apt install cubic
else
  echo "Sorry but this script only works on Ubuntu."
fi
