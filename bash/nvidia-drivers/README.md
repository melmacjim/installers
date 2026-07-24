
# source:
https://www.nvidia.com/en-in/drivers/unix/

# remove any old nvidia drivers
apt-get remove --purge '^nvidia-.*'
apt autoremove
reboot

# ensure headers are installed
apt install build-essential linux-headers-$(uname -r)

# blacklist the default gpu drivers
echo "blacklist nouveau" | tee /etc/modprobe.d/blacklist-nouveau.conf
echo "options nouveau modeset=0" | tee -a /etc/modprobe.d/blacklist-nouveau.conf
update-initramfs -u

# download driver file
VERSION="580.126.09"
wget https://in.download.nvidia.com/XFree86/Linux-x86_64/${VERSION}/NVIDIA-Linux-x86_64-${VERSION}.run
chmod +x NVIDIA-Linux-x86_64-${VERSION}.run

# install driver and reboot
./NVIDIA-Linux-x86_64-${VERSION}.run --dkms --no-x-check --no-nouveau-check
reboot

# update flatpak if installed (from uid=1000; not as root)
flatpak update

