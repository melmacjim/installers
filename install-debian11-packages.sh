#!/bin/bash

# exit if not root (or sudo)
if [ "$(id -u)" != "0" ] ; then 
  echo -e "\nplease execute this script as root\n"
  exit 1
fi

set -e

USERNAME=""
if [ "$USERNAME" == "" ] ; then
  echo -n "Please enter the username: " && read USERNAME
fi
echo "username is set to \"$USERNAME\" "

PKG_LIST="
adb
ansible
apt-transport-https
basket
bluez-hcidump
chirp
clamav
clamav-daemon
cpu-checker
curl
fastboot
git
hping3
htop
iat
iotop
jq
keepassxc
libimage-exiftool-perl
net-tools
network-manager-openvpn
network-manager-openvpn-gnome
nfs-common
nmap
python3-pip
qrencode
screen
smartmontools
sipcalc
silversearcher-ag
sshfs
stellarium
tcpdump
tshark
vim
virt-manager
vlc
wget
whois
wireshark
x2goclient
ykls
yubikey-luks
yubikey-manager
yubikey-personalization-gui
yubioath-desktop
"

PKG_LIST_EXTRAS="
audacity
freecad
fritzing
kdenlive
kicad
openscad
"

PKG_LIST_LAPTOP="
acpi
firmware-iwlwifi
wavemon
"

# install from $PKG_LIST
install-package-list () {
  apt update
  apt install -y $(echo -n $PKG_LIST)
  usermod -aG libvirt $USERNAME
  usermod -aG dialout $USERNAME
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
    apt install -y $(echo -n $PKG_LIST_LAPTOP)
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
    INSTALL_DIR="/home/$USERNAME/bin"
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

# install spotify (music app) pn debian 11
install-spotify () {
  curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | apt-key add -
  echo "deb http://repository.spotify.com stable non-free" \
    > /etc/apt/sources.list.d/spotify.list
  apt update
  apt install -y spotify-client
}

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
#install-pip-packages
#install-other-packages
#make-old-school-net-ifaces


