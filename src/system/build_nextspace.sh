#!/bin/bash

. /Developer/Makefiles/GNUstep.sh
D=$PWD

cd $D/nextspace/Frameworks || exit 1

make clean
make install
ldconfig

cd $D/nextspace/Applications || exit 1

make clean
make install || exit 1
ldconfig
