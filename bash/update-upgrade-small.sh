#!/bin/bash

if uname -v | grep -qi debian ; then
  if [ "$UID" -eq "0" ] ; then
    LOG_FILE="/var/log/apt-update-$(date +%Y%m%dT%H%M).log"
    { set -e
      apt-get update
      apt list --upgradable
      apt-get upgrade -y
      apt-get update
      apt-get autoremove -y
      set +e
    } |& tee -a ${LOG_FILE}
    IMAGE_UPDATE="linux-image-amd64"
    if grep -q ${IMAGE_UPDATE} ${LOG_FILE} ; then
{ echo "a new kernal image is available ... updating now"
        apt upgrade -y ${IMAGE_UPDATE}
} |& tee -a ${LOG_FILE}
    fi
  else
    echo -e "\nonly executable by root (or via sudo)\n"
  fi
fi

