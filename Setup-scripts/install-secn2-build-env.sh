#!/usr/bin/env bash

USAGE1="Usage:   ./install-secn2-build-env.sh  /your-preferred-source-installation-path"
USAGE2="Example: ./install-secn2-build-env.sh  ~/openwrt/my-new-build-env"

if (( $# < 1 ))
then
	echo "Error. Not enough arguments."
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 1
elif (( $# > 1 ))
then
	echo "Error. Too many arguments."
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 2
elif [ $1 == "--help" ]
then
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 3
fi

OPENWRT_PATH=$1
echo " "
echo " "
echo "*** Installing to " $1
echo " "
echo "*** Make new directory"
mkdir -p $OPENWRT_PATH
echo " "

echo "*** Get MP02 and SECN 2 packages from GitHub repo"
git clone https://github.com/villagetelco/vt-secn2-packages $OPENWRT_PATH/vt-secn2-packages
git clone https://github.com/villagetelco/vt-mp02-package   $OPENWRT_PATH/vt-mp02-package
echo " "

echo "*** Checkout the OpenWRT build environment. (See ./openwrt-checkout.log)"
sleep 2
svn co svn://svn.openwrt.org/openwrt/trunk/@r33887  $OPENWRT_PATH  > ./openwrt-checkout.log
echo " "

echo "*** Backup original feeds files if they exist"
sleep 2
mv $OPENWRT_PATH/feeds.conf.default  $OPENWRT_PATH/feeds.conf.default.bak
#mv $OPENWRT_PATH/feeds.conf          $OPENWRT_PATH/feeds.conf.bak
echo " "

echo "*** Create new feeds.conf.default file"
echo "src-svn  packages        svn://svn.openwrt.org/openwrt/packages@33887"      > $OPENWRT_PATH/feeds.conf.default
echo "src-link secn2packages   $OPENWRT_PATH/vt-secn2-packages/packages"         >> $OPENWRT_PATH/feeds.conf.default
echo "src-link dragino2        $OPENWRT_PATH/vt-mp02-package/packages"           >> $OPENWRT_PATH/feeds.conf.default
echo " "

echo "*** Update the feeds (See ./feeds-update.log)"
sleep 2
$OPENWRT_PATH/scripts/feeds update > ./feeds-update.log
sleep 2
echo " "
tail -n 6 ./feeds-update.log
echo " "

# Original feeds for the record
#echo "src-svn  packages        svn://svn.openwrt.org/openwrt/packages@33887"  > $OPENWRT_PATH/feeds.conf.default
#echo "src-git routing git://github.com/openwrt-routing/packages.git"         >> $OPENWRT_PATH/feeds.conf.default
#echo "src-git telephony http://feeds.openwrt.nanl.de/openwrt/telephony.git"  >> $OPENWRT_PATH/feeds.conf.default
#echo "src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git"        >> $OPENWRT_PATH/feeds.conf.default

echo "*** Install OpenWrt packages"
sleep 10
$OPENWRT_PATH/scripts/feeds install kmod-batman-adv  
$OPENWRT_PATH/scripts/feeds install openssh-sftp-server
$OPENWRT_PATH/scripts/feeds install usb-modeswitch
$OPENWRT_PATH/scripts/feeds install usb-modeswitch-data 
$OPENWRT_PATH/scripts/feeds install haserl 
$OPENWRT_PATH/scripts/feeds install xinetd
$OPENWRT_PATH/scripts/feeds install muninlite
$OPENWRT_PATH/scripts/feeds install alfred
$OPENWRT_PATH/scripts/feeds install prosody
$OPENWRT_PATH/scripts/feeds install polipo
$OPENWRT_PATH/scripts/feeds install nodogsplash
$OPENWRT_PATH/scripts/feeds install coova-chilli
echo " "

echo "*** Copy MP02 Platform info (See ./mp02-rsync.log)"
sleep 2
rsync -avC $OPENWRT_PATH/vt-mp02-package/platform/target/ $OPENWRT_PATH/target/ > ./mp02-rsync.log
echo " "

echo "*** Install MP02 hardware packages"
sleep 2
$OPENWRT_PATH/scripts/feeds install -a -p dragino2
echo " "

echo "*** Update feeds.conf.default file to lock further openwrt package updates"
echo "#src-svn  packages        svn://svn.openwrt.org/openwrt/packages@33887"     > $OPENWRT_PATH/feeds.conf.default
echo "src-link secn2packages   $OPENWRT_PATH/vt-secn2-packages/packages"         >> $OPENWRT_PATH/feeds.conf.default
echo "src-link dragino2        $OPENWRT_PATH/vt-mp02-package/packages"           >> $OPENWRT_PATH/feeds.conf.default
echo " "

# Remove tmp directory
rm -rf $OPENWRT_PATH/tmp/

echo "*** Change to build directory"
cd $OPENWRT_PATH
echo " "

echo "*** Run make defconfig to set up initial .config file (see ./defconfig.log)"
make defconfig > ./defconfig.log
# Backup the .config file
cp .config .config.orig
echo " "

echo "End of script"

