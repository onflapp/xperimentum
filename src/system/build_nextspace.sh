#!/bin/bash

. /Developer/Makefiles/GNUstep.sh
D=$PWD

rm -r /etc/skel/Library 2>/dev/null
cp -r ./nextspace/System/etc/skel/Library /etc/skel
cp -r ./nextspace/System/usr /
cp ./nextspace/System/Library/Preferences/* /Library/Preferences
cp ./scripts/nextspace.sh /etc/profile.d
cp ./scripts/startnxworkspace /usr/NextSpace/bin

chmod 0755 /usr/NextSpace/bin/startnxworkspace

cd $D/nextspace/Frameworks || exit 1

make clean
make install
ldconfig

cd $D/nextspace/Applications/Workspace || exit 1

WM_DIR="WM"
WM_APP="/usr/NextSpace/Apps/Workspace.app"
cd $WM_DIR

if [ ! -f configure ]; then
  autoreconf -vfi -I m4
fi

CFLAGS=-DNEXTSPACE \
./configure \
        --enable-xrandr \
        --disable-magick \
        --enable-modelock \
        \
        --prefix=/usr/NextSpace \
        --bindir=/usr/NextSpace/bin \
        --libdir=/usr/NextSpace/lib \
        --includedir=/usr/NextSpace/include \
        --mandir=/usr/NextSpace/Documentation/man \
        \
        --datadir=$WM_APP/Resources/WM \
        --sysconfdir=$WM_APP/Resources/WM \
        --localedir=$WM_APP/Resources/WM \
        --with-pixmapdir=$WM_APP/Resources/WM

if [ ! -f config-paths.h ];then
  make config-paths.h
fi

cd ..

if [ -f config-paths.h ];then
    rm config-paths.h
fi
ln -s $WM_DIR/config-paths.h config-paths.h

if [ -f config.h ];then
    rm config.h
fi
ln -s $WM_DIR/config.h config.h


cd $D/nextspace/Applications || exit 1

make clean
make install || exit 1
ldconfig


