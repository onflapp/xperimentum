#!/bin/bash

cd ./libdispatch || exit 1
rm -R _build 2>/dev/null
mkdir -p _build
cd _build
cmake .. \
	-DCMAKE_C_COMPILER=$CC \
	-DCMAKE_CXX_COMPILER=$CXX \
	-DCMAKE_SKIP_RPATH=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr/NextSpace \
	-DCMAKE_INSTALL_LIBDIR=/usr/NextSpace/lib \
	-DINSTALL_PRIVATE_HEADERS=YES \
	-DENABLE_TESTING=OFF \
	-DUSE_GOLD_LINKER=YES

make clean
make -j2 install
ldconfig
