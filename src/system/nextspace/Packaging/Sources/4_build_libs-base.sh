#!/bin/bash

. ./versions.inc.sh

. /Developer/Makefiles/GNUstep.sh

cd ./nextspace-base-${gnustep_base_version} || exit 1

$MAKE_CMD clean
./configure || exit 1

$MAKE_CMD install
