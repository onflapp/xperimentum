#!/bin/bash
set -e

. /Developer/Makefiles/GNUstep.sh
export PATH=/usr/NextSpace/bin:$PATH

D=$PWD

cd $D/Frameworks/Pantomime
make install
ldconfig

cd $D/Applications/Addresses
make install
ldconfig

cd $D/Applications/GNUMail
make install
ldconfig

cd $D/Applications/Gorm
make install
ldconfig

cd $D/Applications/ProjectCenter
make install
ldconfig
