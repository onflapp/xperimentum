#!/bin/sh
# This script uses `sudo` to install generated RPMs. Please make sure user you 
# run this script as has appropriate rights.
#

. `dirname $0`/functions

if [ $# -eq 0 ];then
    print_help
    exit
fi

prepare_environment

REPO_DIR=$1
LOG_FILE=${CWD}/frameworks_build.log
SPEC_FILE=${REPO_DIR}/Frameworks/nextspace-frameworks.spec

print_H1 " Building NEXTSPACE Frameworks package..."

FRAMEWORKS_VERSION=`rpmspec -q --qf "%{version}:" ${SPEC_FILE} | awk -F: '{print $1}'`

print_H2 "===== Install nextspace-frameworks build dependencies..."
DEPS=`rpmspec -q --buildrequires ${SPEC_FILE} | awk -c '{print $1}'`
sudo yum -y install ${DEPS}

print_H2 "===== Downloading nextspace-frameworks sources..."
source /Developer/Makefiles/GNUstep.sh
cd ${REPO_DIR}/Frameworks && make dist
cd $CWD
mv ${REPO_DIR}/nextspace-frameworks-${FRAMEWORKS_VERSION}.tar.gz ${SOURCES_DIR}
spectool -g -R ${SPEC_FILE}

print_H2 "===== Building nextspace-frameworks package..."
rpmbuild -bb ${SPEC_FILE}
STATUS=$?
if [ $STATUS -eq 0 ]; then 
    print_OK " Building of NEXTSPACE Frameworks RPM SUCCEEDED!"
    print_H2 "===== Installing nextspace-frameworks RPMs..."
    FRAMEWORKS_VERSION=`rpm_version ${SPEC_FILE}`
    
    install_rpm nextspace-frameworks ${RPMS_DIR}/nextspace-frameworks-${FRAMEWORKS_VERSION}.rpm
    mv ${RPMS_DIR}/nextspace-frameworks-${FRAMEWORKS_VERSION}.rpm ${RELEASE_USR}

    install_rpm nextspace-frameworks-devel ${RPMS_DIR}/nextspace-frameworks-devel-${FRAMEWORKS_VERSION}.rpm
    mv ${RPMS_DIR}/nextspace-frameworks-devel-${FRAMEWORKS_VERSION}.rpm ${RELEASE_DEV}
    mv ${RPMS_DIR}/nextspace-frameworks-debuginfo-${FRAMEWORKS_VERSION}.rpm ${RELEASE_DEV}
    if [ -f ${RPMS_DIR}/nextspace-frameworks-debugsource-${FRAMEWORKS_VERSION}.rpm ];then
        mv ${RPMS_DIR}/nextspace-frameworks-debugsource-${FRAMEWORKS_VERSION}.rpm ${RELEASE_DEV}
    fi
else
    print_ERR " Building of NEXTSPACE Frameworks RPM FAILED!"
    exit $STATUS
fi
