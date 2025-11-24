#!/bin/bash

# Source:
# https://flathub.org/en/apps/com.valvesoftware.SteamLink

# add the flathub repo
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# install the flatpak version of steamlink
flatpak install flathub com.valvesoftware.SteamLink

# open the steamlink app
flatpak run com.valvesoftware.SteamLink

