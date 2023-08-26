#!/bin/bash

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
