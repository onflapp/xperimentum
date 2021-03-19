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

cd /
echo "" > .hidden

for DD in * ;do
  case $DD in
    Applications|Developer|Library|Users)
      ;;
    *)
      echo $DD >> .hidden
      ;;
  esac
done
