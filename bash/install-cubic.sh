#!/bin/bash

if [ -f ] ; then
  echo "Looks like cubic in already installed on this system. ;)"
else
  if uname -a | grep -i ubuntu ; then
    apt-add-repository ppa:cubic-wizard/release
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6494C6D6997C215E
    apt-get update && apt-get install cubic
  else
    echo "Sorry but this script only works on Ubuntu."
  fi
fi

