# Building NEXTSPACE from sources

The scripts in this directory should make it easier to build NEXTSPACE and libraries it depends on from source. List of dependencies as well as their respective versions is taken from Debian package build process. 

### prepare sources for build

The script will clone repos to current directory and apply patches from Debian package build.

    $ ./0_prepare_sources.sh

### build and install each dependency

Dependencies have to be built and installed in predetermined order like this:

    $ sudo ./1_build_libobjc2.sh
    $ sudo ./2_build_libdispatch.sh
    $ sudo ./3_build_tools-make.sh
    $ sudo ./4_build_libs-base.sh
    $ sudo ./5_build_libs-gui.sh
    $ sudo ./6_build_libs-back.sh

Once you install everything for the very first time, you can more selective as to what to build.

### build and install NEXTSPACE itself

Building NEXTSPACE will simply use this source tree.

    # sudo ./7_build_Frameworks.sh
    # sudo ./8_build_Applications.sh

### installing default profile and configuration

Before you can run NEXTSPACE, you need to make sure you install various scripts and configurations that the NEXTSPACE depends on at runtime. Some stuff is system-wide and it need to be installed by root, other is installed in user's home directory. For this reason you should run the following installation script twice. 
    # sudo ./9_install_scripts.sh
    $ ./9_install_scripts.sh

Note that this is "minimal" startup configuration, which uses xinitrc script to start everything up (usually invoked as part of startx). If you want to use Login.app or start Workspace in any other way, you may have to create your own configuration.
