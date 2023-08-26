#!/bin/bash

# This is a very "quick-'n-dirty" script in order to build
# OBS. If you want to criticise, feel free to do so.
# If you want to re-write it, by all means!
#
# There are many reasons why you would want to
# or build OBS from source, so instead of debating
# on whether it's a good idea or not, just build it.
# This script is meant for Debian-style environments,
# specifically Debian, Ubuntu, Linux Mint and similar.
# If you want to roll your on for your favourite distribution,
# please read the build documentation. In fact, read it anyway,
# because it will help you understand which dependencies you
# will need to install in order to build Kdenlive.
#
# This script is released under the MIT licence (see LICENSE file),
# which means you can do with it what you want. If you break it,
# you even get to keep the pieces, which is nice! :-D

# Pause function - "press X to continue" 
function pause(){
   read -p "$*"
}

export $(grep DISTRIB_CODENAME /etc/lsb-release)
MYPWD=$(pwd)

# Remove old build dir, backup previous one and create new one
# Remove previous kdenlive clone, and clone a fresh one
rm -rf kdenlive
git clone https://invent.kde.org/multimedia/kdenlive.git
# Move/remove previous builds, and create new build
rm -rf kdenlive-build-old
mv -f kdenlive-build kdenlive-build-old
cp -r kdenlive kdenlive-build

# Build kdenlive
INSTALL_PREFIX=/usr/local
cd kdenlive-build
# MYTAG=$(git tag --sort=-creatordate | head -n 1)
# MYTAG=$(git tag --sort=-creatordate | head | sort -r | head -n 1)
GITTAG=$(git describe --long --tags --dirty --always)
MYTAG=$(echo $GITTAG | cut -c2-)
ARBTAG="4"

mkdir build && cd build
# Even if you specified a user-writable INSTALL_PREFIX, some Qt plugins like the MLT thumbnailer are
# going be installed in non-user-writable system paths to make them work. If you really do not want
# to give root privileges, you need to set KDE_INSTALL_USE_QT_SYS_PATHS to OFF in the line below.
cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DRELEASE_BUILD=OFF
time make -j4

echo ""
echo "Press [Enter] to continue installing kdenlive $MYTAG, or press"
pause '[Ctrl]+[c] to exit script:'
echo ""

cd $MYPWD
echo ""

echo "Installing kdenlive:"
echo ""
cd kdenlive-build/build
#sudo make install
## Make and install a DEB package
echo "A feature-rich, production ready video editor by the KDE community."  > description-pak
sudo checkinstall --default --pkgname=kdenlive --fstrans=no --backup=no --pkgversion="$ARBTAG:$MYTAG-$DISTRIB_CODENAME" --deldoc=yes
sleep 2
cp $MYPWD/kdenlive-build/build/*.deb $MYPWD/zz-packages/

echo ""
echo "Done!"
cd $MYPWD

# That's it!

-=-=-=-=-=-=-=-=-=-=-=

# Source our functions library
. ~/bin/functions.sh
export $(grep DISTRIB_CODENAME /etc/lsb-release)
MYPWD=$(pwd)

# Do a fresh clone of obs-studio
rm -rf obs-studio
git clone --recursive https://github.com/obsproject/obs-studio.git

# Remove old build dir, backup previous one and create new one
sudo rm -rf obs-studio-build-old
mv -f obs-studio-build obs-studio-build-old
cp -r obs-studio obs-studio-build

# Build obs-studio
cd obs-studio-build
CI/build-linux.sh -pkg --disable-pipewire

echo ""
echo "Press [Enter] to continue installing obs-studio, or press"
pause '[Ctrl]+[c] to exit script:'
echo ""

cd build/
# Get package name
mypackage=$(ls *.deb)
# Copy new package to central repo directory
cp -f $mypackage $MYPWD/zz-packages/
# Install new package
sudo apt -y --allow-downgrades install ./$mypackage

echo ""
echo "Done!"
cd $MYPWD

# That's it!
