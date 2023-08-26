#!/bin/bash

# Source our functions library
. ~/bin/functions.sh
export $(grep DISTRIB_CODENAME /etc/lsb-release)
MYPWD=$(pwd)

# Update ardour codebase
#cd ardour
#git pull
#cd ..

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

# --use-lld

echo ""
echo "Press [Enter] to continue installing Ardour $PKG_VER, or press"
pause '[Ctrl]+[c] to exit script:'
echo ""

#echo "Removing previous Ardour..."
sudo apt remove ardour
#cd /usr/local
# In case we built Ardour 5
#sudo rm -rf $(find -type d -name "ardour5")
#sudo rm -f /usr/local/bin/ardour5*
# In case we built Ardour 6
#sudo rm -rf $(find -type d -name "ardour6")
#sudo rm -f /usr/local/bin/ardour6*

cd $MYPWD
echo ""

echo "Installing Ardour $PKG_VER:"
echo ""
cd ardour-build

sudo ./waf install

#echo ""
#echo "Ardour $PKG_VER, the Open Source professional digital audio workstation." > description-pak
#sudo checkinstall --default --pkgname=ardour --fstrans=no --backup=no --pkgversion="1:$PKG_VER-$(date +%Y%m%d)-$DISTRIB_CODENAME" --deldoc=yes ./waf install
#sleep 2
#cp $MYPWD/ardour-build/*.deb $MYPWD/zz-packages/


echo "Done!"
cd $MYPWD

# That's it!

