#!/bin/bash

# This is a very "quick-'n-dirty" script in order to build
# Ardour. If you want to criticise, feel free to do so.
# If you want to re-write it, by all means!
#
# There are many reasons why you would want to
# or build Ardour from source, so instead of debating
# on whether it's a good idea or not, just build it.
# This script is meant for Debian-style environments,
# specifically Debian, Ubuntu, Linux Mint and similar.
# Please ensure that you have read the Ardour build documentation
# so that you understand which dependencies to install before you
# start building Ardour.
#
# This script is released under the MIT licence (see LICENSE file),
# which means you can do with it what you want. If you break it,
# you even get to keep the pieces, which is nice! :-D
#
# Important note: This script does not use checkinstall to create
# DEB files, it installs Ardour in "/usr/local/bin" instead.


# Pause function - "press X to continue" 
function pause(){
   read -p "$*"
}

export $(grep DISTRIB_CODENAME /etc/lsb-release)
MYPWD=$(pwd)

# Clone Ardour codebase, and ensure we have liblrdf0-dev installed
rm -rf ardour/
git clone https://github.com/Ardour/ardour.git
# sudo apt -y install liblrdf0-dev
sudo apt -y install liblrdf0-dev

# Count our CPU/Threads
# THREADS=$(grep siblings /proc/cpuinfo | sort | uniq | awk {'print $3'})
THREADS=$(nproc)
echo
echo "Building with $THREADS threads".
echo

# Build ardour
rm -rf ardour-build-prev
mv ardour-build ardour-build-prev
cp -r ardour ardour-build
cd ardour-build
PKG_VER=$(git describe --long --tags --dirty --always)
#./waf configure --docs --freedesktop --use-lld --with-backends=jack,alsa,dummy,pulseaudio
./waf configure --docs --freedesktop --with-backends=jack,alsa,dummy,pulseaudio
time ./waf build -j$THREADS

echo ""
echo "Press [Enter] to continue installing Ardour $PKG_VER, or press"
pause '[Ctrl]+[c] to exit script:'
echo ""

#echo "Removing distribution version of Ardour (very old)..."
sudo apt remove ardour

cd $MYPWD
echo ""

echo "Installing Ardour $PKG_VER:"
echo ""
cd ardour-build

sudo ./waf install

echo "Done!"
cd $MYPWD

# That's it!

