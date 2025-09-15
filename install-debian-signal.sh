# NOTE: These instructions only work for 64-bit Debian-based
# Linux distributions such as Ubuntu, Mint etc.
# Source: https://signal.org/download/linux/ (09/14/2025)

# 1. Install our official public software signing key:
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
mv -v signal-desktop-keyring.gpg /usr/share/keyrings/

# 2. Add our repository to your list of repositories:
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
mv -v signal-desktop.sources /etc/apt/sources.list.d/

# 3. Update your package database and install Signal:
apt update && apt install signal-desktop

