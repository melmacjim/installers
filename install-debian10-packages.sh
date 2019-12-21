#!/bin/bash

. apps_debian10.list
APTUPIN="apt update && apt install -y"

# Install app from apps_debian10.list
install-apps () {
  echo "Install the followig apps: $APPS"
  echo -n "y/[n]: " && read CHOICE
  if [[ ${CHOICE,,} = "y" ]] ; then
    $APTUPIN $APPS |& tee -a /tmp/apt-install-packages-$(date +%Y%m%dT%H%M).log
  else
    echo "ABORTING!"
    return 1
  fi
}

# Install signal for the desktop
install-signal () {
  curl -s https://updates.signal.org/desktop/apt/keys.asc | apt-key add -
  echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | tee /etc/apt/sources.list.d/signal-xenial.list
  $APTUPIN signal-desktop
}

# In stall VirtualBox 6.1
install-virtualbox () {
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
echo "## VIRTUALBOX 
## The VirtualBox packages for Debian 10 Buster and Ubuntu 18.04 bionic are same.
## That’s why the repository is pointed to bionic.
deb https://download.virtualbox.org/virtualbox/debian bionic contrib
" | tee /etc/apt/sources.list.d/virtualbox.list
  $APTUPIN virtuaalbox-6.1
}

# Install wifi drivers
install-wifi-driver-intel () {
  sed -i 's/deb http://deb.debian.org/debian/ buster main/deb http://deb.debian.org/debian/ buster main non-free/g' /etc/apt/sources.list
  $APTUPIN firmware-iwlwifi
}

# Install old network interface names (eth0, wlan0, ...)
install-iface-old-names () {
  sed -i 's/GRUB_CMDLINE_LINUX=""/#GRUB_CMDLINE_LINUX=""\nGRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
  update-grub
}

help_message () { echo "
How to use :

$0 -b | --install-basic-apps
$0 -n | --install-networking-apps
$0 -a | --install-android-apps
$0 -s | --install-signal
$0 -v | --install-virtualbox
$0 -w | --install-driver-wifi
$0 --install-old-iface-names

" ; }

if [ -z $1 ] ; then
  help_message
else
  for input_options ; do
    case "$input_options" in
      -b|--install-basic-apps) APPS=$LIST_APPS_BASIC ; install-apps ;;
      -n|--install-networking-apps) APPS=$LIST_APPS_NETWORKING ; install-apps ;;
      -a|--install-android-apps) APPS=$LIST_APPS_ANDROID ; install-apps ;;
      -s|--install-signal) install-signal ;;
      -v|--install-virtualbox) install-virtualbox ;;
      -w|--install-driver-wifi) install-wifi-driver-intel ;;
      --install-old-iface-names) install-iface-old-names ;;
      *) help_message ; break ;;
    esac
  done
fi

