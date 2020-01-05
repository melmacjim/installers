#!/bin/bash

if [ -f /usr/lib/slack/slack ] ; then
  echo "Looks like slack for the desktop is already installed. :)"
else
  if uname -a | grep -i "ubuntu\|debian" ; then
    cd /tmp
    rm slack-desktop-*.deb*
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb
    apt-get update && apt-get install -y ./slack-desktop-*.deb
  else
    echo "Sorry but this script only works on Debain based distros."
  fi
fi

