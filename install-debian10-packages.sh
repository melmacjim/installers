#/bin/bash

. apps-debian10.list

# Common apt command
apt-update-install () {
  packagelist="$@"
  apt-get update && apt-get install -y $packagelist
}

# Install app from apps_debian10.list
install-apps () {
  echo "Install the followig apps: $APPS"
  echo -n "y/[n]: " && read CHOICE
  if [[ ${CHOICE,,} = "y" ]] ; then
    apt-update-install $APPS |& tee -a /tmp/apt-install-packages-$(date +%Y%m%dT%H%M).log
  else
    echo "ABORTING!"
    return 1
  fi
}

# Install signal for the desktop
install-signal () {
  if [ ! which signal-desktop ] ; then
    curl -s https://updates.signal.org/desktop/apt/keys.asc | apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | tee /etc/apt/sources.list.d/signal-xenial.list
    apt-update-install signal-desktop
  else
    echo "signal-desktop is already installed"
  fi
}

# In stall VirtualBox 6.1
install-virtualbox () {
  if [ ! -f /etc/apt/sources.list.d/virtualbox.list ] ; then
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
echo "## VIRTUALBOX 
## The VirtualBox packages for Debian 10 Buster and Ubuntu 18.04 bionic are same.
## That’s why the repository is pointed to bionic.
deb https://download.virtualbox.org/virtualbox/debian bionic contrib
" | tee /etc/apt/sources.list.d/virtualbox.list
  apt-update-install virtuaalbox-6.1
  else
    echo "VirtualBox is already installed"
  fi
}

# Install wifi drivers
install-wifi-driver-intel () {
  if ! grep -q "buster main non-free" /etc/apt/sources.list ; then
    sed -i 's/deb http://deb.debian.org/debian/ buster main/deb http://deb.debian.org/debian/ buster main non-free/g' /etc/apt/sources.list
    apt-update-install firmware-iwlwifi
  else
    echo "The intel wifi drivers are already installed"
  fi
}

install-youtube-dl () {
  if [ ! -f /usr/local/bin/youtube-dl ] ; then
    ## source: https://ytdl-org.github.io/youtube-dl/download.html
    curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
    chmod a+rx /usr/local/bin/youtube-dl
  else
    echo "youtube-dl is already installed"
  fi
}

# Install old network interface names (eth0, wlan0, ...)
install-iface-old-names () {
  if ! grep -q "net.ifnames=0 biosdevname=0" /etc/default/grub ; then
    sed -i 's/GRUB_CMDLINE_LINUX=""/#GRUB_CMDLINE_LINUX=""\nGRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
    update-grub
  else
    echo "The old interface name are applied already"
  fi
}

help_message () { echo "
How to use :

$0 -b | --install-basic-apps
$0 -n | --install-networking-apps
$0 -a | --install-android-apps
$0 -s | --install-signal
$0 -v | --install-virtualbox
$0 -w | --install-driver-wifi
$0 --install-youtube-dl
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
      --install-youtube-dl) install-youtube-dl ;;
      --install-old-iface-names) install-iface-old-names ;;
      *) help_message ; break ;;
    esac
  done
fi

