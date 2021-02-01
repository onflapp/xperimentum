#!/bin/bash

D=$PWD

cd $D/Frameworks/Pantomime
make install

cd $D/Applications/Addresses
make install

cd $D/Applications/GNUMail
make install

cd /Applications/AddressManager.app
make install
