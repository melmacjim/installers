#!/bin/bash

# add the flathub repo
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# install flatpac chat apps:
flatpak install flathub com.discordapp.Discord          # chat client
flatpak install flathub in.cinny.Cinny                  # matrix chat client

# install flatpac gaming apps
flatpak install flathub com.valvesoftware.SteamLink     # gaming platform
flatpak install flathub im.riot.Riot                    # gaming platform
flatpak install flathub --user -y net.lutris.Lutris     # gaming platform
flatpak install flathub org.luanti.luanti               # open source minecraft

