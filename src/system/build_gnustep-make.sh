#!/bin/bash

cd ./gnustep-make

export RUNTIME_VERSION="-fobjc-runtime=gnustep-1.8"

make clean
./configure \
	    --prefix=/ \
	    --with-config-file=/Library/Preferences/GNUstep.conf \
	    --with-layout=nextspace \
	    --enable-native-objc-exceptions \
	    --enable-debug-by-default \
	    --with-library-combo=ng-gnu-gnu

make install
