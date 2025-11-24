#!/bin/bash

PKG_NAME="slack-desktop-4.0.2-amd64.deb"
PKG_URL="https://downloads.slack-edge.com/linux_releases/${PKG_NAME}"

if [ -f /usr/lib/slack/slack ] ; then
  echo "Looks like slack for the desktop is already installed. :)"
else
  if uname -a | grep -i "ubuntu\|debian" ; then
    cd /tmp
    rm -f ${PKG_URL}
    wget ${PKG_URL}
    echo "apt-get update && apt-get install -y ./${PKG_NAME}"
  else
    echo "Sorry but this script only works on Debain based distros."
  fi
fi

