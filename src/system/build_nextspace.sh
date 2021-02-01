#!/bin/bash

. /Developer/Makefiles/GNUstep.sh
D=$PWD

rm -r /etc/skel/Library 2>/dev/null
cp -r ./nextspace/System/etc/skel/Library /etc/skel
cp ./nextspace/System/profile.d/* /etc/profile.d
cp -r ./nextspace/System/usr /

cd $D/nextspace/Frameworks || exit 1

make clean
make install
ldconfig

cd $D/nextspace/Applications || exit 1

make clean
make install || exit 1
ldconfig
