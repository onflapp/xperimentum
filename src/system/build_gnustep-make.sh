#!/bin/bash

. ./BUILD_CONFIG.sh

cd ./gnustep-make

make clean
./configure \
	    --prefix=/ \
	    --with-config-file=/Library/Preferences/GNUstep.conf \
	    --with-layout=nextspace \
	    --enable-native-objc-exceptions \
	    --enable-objc-arc \
	    --enable-debug-by-default \
	    --with-library-combo=ng-gnu-gnu

make install
