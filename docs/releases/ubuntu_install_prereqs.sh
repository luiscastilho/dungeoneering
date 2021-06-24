#!/bin/bash
#
# Install Ubuntu gstreamer0.10 packages.
#
# Requirements: bash, coreutils, wget, dpkg
#

set -euo pipefail
IFS=$'\n\t'

# Check if it's Ubuntu 18.04 or 20.04
lsb_release -d | grep -qi '18.04'; is_ubuntu_18=$?
lsb_release -d | grep -qi '20.04'; is_ubuntu_20=$?
if [ $is_ubuntu_18 -ne 0 -a $is_ubuntu_20 -ne 0 ]; then
    echo "ERROR: This script only works for Ubuntu 18.04 or 20.04. Please create an issue for other Ubuntu versions or for other Linux distributions."
    exit 1
fi

# Create and move to packages dir
cd ~ && mkdir gstreamer0.10 && cd gstreamer0.10/

# Download packages
lsb_release -d | grep -qi '20.04' && wget https://launchpad.net/~linuxuprising/+archive/ubuntu/libpng12/+files/libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~focal_amd64.deb
lsb_release -d | grep -qi '18.04' && wget https://launchpad.net/~ubuntu-security/+archive/ubuntu/ppa/+build/15108504/+files/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
wget http://launchpadlibrarian.net/215074266/libgstreamer0.10-0_0.10.36-1.5ubuntu1_amd64.deb
wget http://launchpadlibrarian.net/421117832/libgstreamer-plugins-base0.10-0_0.10.36-2ubuntu0.2_amd64.deb
wget http://launchpadlibrarian.net/312211203/gstreamer0.10-gconf_0.10.31-3+nmu4ubuntu2.16.04.3_amd64.deb
wget http://launchpadlibrarian.net/421117831/gstreamer0.10-x_0.10.36-2ubuntu0.2_amd64.deb
wget http://launchpadlibrarian.net/312211205/gstreamer0.10-pulseaudio_0.10.31-3+nmu4ubuntu2.16.04.3_amd64.deb
wget http://launchpadlibrarian.net/421117830/gstreamer0.10-plugins-base_0.10.36-2ubuntu0.2_amd64.deb
wget http://launchpadlibrarian.net/312211204/gstreamer0.10-plugins-good_0.10.31-3+nmu4ubuntu2.16.04.3_amd64.deb
wget https://launchpad.net/~mc3man/+archive/ubuntu/gstffmpeg-keep/+files/gstreamer0.10-ffmpeg_0.10.13-5ubuntu1~wily_amd64.deb

# Install packages
sudo apt install -y libcanberra-gtk-module libcanberra-gtk0
sudo apt install -y gconf-service gconf-service-backend gconf2 gconf2-common libgconf-2-4 gconf-defaults-service
lsb_release -d | grep -qi '20.04' && sudo dpkg -i libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~focal_amd64.deb
lsb_release -d | grep -qi '18.04' && sudo dpkg -i libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
sudo dpkg -i libgstreamer0.10-0_0.10.36-1.5ubuntu1_amd64.deb
sudo dpkg -i libgstreamer-plugins-base0.10-0_0.10.36-2ubuntu0.2_amd64.deb
sudo dpkg -i gstreamer0.10-gconf_0.10.31-3+nmu4ubuntu2.16.04.3_amd64.deb
sudo dpkg -i gstreamer0.10-x_0.10.36-2ubuntu0.2_amd64.deb
sudo dpkg -i gstreamer0.10-pulseaudio_0.10.31-3+nmu4ubuntu2.16.04.3_amd64.deb
sudo dpkg -i gstreamer0.10-plugins-base_0.10.36-2ubuntu0.2_amd64.deb
sudo dpkg -i gstreamer0.10-plugins-good_0.10.31-3+nmu4ubuntu2.16.04.3_amd64.deb
sudo dpkg -i gstreamer0.10-ffmpeg_0.10.13-5ubuntu1~wily_amd64.deb
