#!/bin/bash

set -e

# exit if not root (or sudo)
if [ "$(id -u)" != "0" ] ; then 
  echo -e "\nplease execute this script as root\n"
  exit 1
fi

USERNAME=""
if [ "$USERNAME" == "" ] ; then
  echo -n "Please enter the username: " && read USERNAME
fi
if id $USERNAME ; then 
  echo "username is set to \"$USERNAME\" "
else
  echo "the user \"$USERNAME\" wasn't found"
  exit 1
fi

INSTALL_DIR="/home/$USERNAME/bin"

PKG_LIST="$(cat debian-common-pkg.list)"
PKG_LIST_NET="$(cat debian-network-pkg.list)"
PKG_LIST_EXTRAS="$(cat debian-extras-pkg.list)"
PKG_LIST_WIFI="$(cat debian-wifi-pkg.list)"
PKG_LIST_SDR="$(cat debian-sdr-pkg.list)"

# install from $PKG_LIST and $PKG_LIST_NET
install-package-list () {
  apt update
  apt install -y $(echo -n $PKG_LIST) $(echo -n $PKG_LIST_NET) $(echo -n $PKG_LIST_SDR)
  usermod -aG dialout,libvirt $USERNAME
}

# install from $PKG_LIST_EXTRAS
install-extras-package-list () {
  apt update
  apt install -y $(echo -n $PKG_LIST_EXTRAS)
}

# install from $PKG_LIST_LAPTOP
install-laptop-package-list () {
  if upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep native-path | grep -q BAT0 ; then
    apt update
    apt install -y $(echo -n $PKG_LIST_WIFI)
  else
    echo "This system is NOT a laptop (or at least it doesn't have a battery)"
  fi
}

# install brave on debian 11
install-brave-browser () {
  curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    > /etc/apt/sources.list.d/brave-browser-release.list
  apt update
  apt install -y brave-browser
}

# install vscode on debian 11
install-vscode () {
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" \
    > /etc/apt/sources.list.d/vscode.list
  apt update
  apt install -y code
}

# install terraform on debian 11
install-terraform () {
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt update
  apt install -y terraform
}

# install signal (chat app) on debian 11
install-signal () {
  wget -O- https://updates.signal.org/desktop/apt/keys.asc --quiet | gpg --dearmor > /usr/share/keyrings/signal-desktop-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" \
    > /etc/apt/sources.list.d/signal-xenial.list
  apt update
  apt install -y signal-desktop
}

# install kismet (wifi scanner) on debian 11
install-kismet () {
  wget -O- https://www.kismetwireless.net/repos/kismet-release.gpg.key --quiet | gpg --dearmor > /usr/share/keyrings/kismet-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/kismet-archive-keyring.gpg] https://www.kismetwireless.net/repos/apt/release/bullseye bullseye main" \
    > /etc/apt/sources.list.d/kismet.list
  apt update
  apt install -y kismet
  usermod -aG kismet $USERNAME
}

install-youtube-dl () {
  if [ ! -f /usr/local/bin/youtube-dl ] ; then
    mkdir -p $INSTALL_DIR
    ## source: https://ytdl-org.github.io/youtube-dl/download.html
    curl -s -L https://yt-dl.org/downloads/latest/youtube-dl -o $INSTALL_DIR/youtube-dl \
      && chmod a+rx $INSTALL_DIR/youtube-dl \
      && echo "youtube-dl is now installed! :) ($INSTALL_DIR/youtube-dl)" \
      || echo "Something went wrong! :("
  else
    echo "youtube-dl is already installed"
  fi
}

# install spotify (music app) on debian 11
install-spotify () {
  curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | apt-key add -
  echo "deb http://repository.spotify.com stable non-free" \
    > /etc/apt/sources.list.d/spotify.list
  apt update
  apt install -y spotify-client
}

# install docker
install-docker () {
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /usr/share/keyrings/docker.asc
  chmod a+r /usr/share/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# install packages from python's pip repo
install-pip-packages () {
  su - $USERNAME -c "pip install speedtest-cli yt-dlp"
}

# TODO
install-other-packages () {
  wget .../epsonscan2_6.6.2.4-1_amd64.deb
  cd /dir/with/pakgs/
  apt install ./epsonscan2_6.6.2.4-1_amd64.deb
}

# this will set the network interface name from their new long form names to their "old-school" short form name
make-old-school-net-ifaces () {
  if ! grep -q 'GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"' /etc/default/grub ; then
    echo "Updating the /etc/default/grub to use old-school names for the network interfaces (eth0, wlan0, ...)"
    cp -a /etc/default/grub /etc/default/grub-original
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
  else
    echo "Old-school names have already been applied. Please try rebooting if you don't see them listed yets"
    ip -br a s
  fi
}

# uncomment the function(s) below before executing this script
#install-package-list
#install-extras-package-list
#install-laptop-package-list
#install-brave-browser
#install-vscode
#install-terraform
#install-signal
#install-kismet
#install-youtube-dl
#install-spotify
#install-docker
#install-pip-packages
#install-other-packages
#make-old-school-net-ifaces

