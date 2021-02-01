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
LOG_FILE=${CWD}/applications_build.log
SPEC_FILE=${REPO_DIR}/Applications/nextspace-applications.spec

print_H1 " Building NEXTSPACE Applications package..."

APPLICATIONS_VERSION=`rpmspec -q --qf "%{version}:" ${SPEC_FILE} | awk -F: '{print $1}'`
print_H2 "===== Install nextspace-applications build dependencies..."
DEPS=`rpmspec -q --buildrequires ${SPEC_FILE} | awk -c '{print $1}'`
sudo yum -y install ${DEPS} 2>&1 > ${LOG_FILE}
print_H2 "===== Downloading nextspace-frameworks sources..."
source /Developer/Makefiles/GNUstep.sh
if [ $OS_ID == "centos" ] && [ $OS_VERSION == "7" ];then
    source /opt/rh/llvm-toolset-7.0/enable
fi

print_H2 "--- Prepare Workspace sources"
cd ${REPO_DIR}/Applications/Workspace
rm WM/src/wconfig.h && rm WM/configure && ./WM.configure

print_H2 "--- Creating applications source tarball"
cd ${REPO_DIR}/Applications && make dist
cd $CWD
mv ${REPO_DIR}/nextspace-applications-${APPLICATIONS_VERSION}.tar.gz ${SOURCES_DIR}
spectool -g -R ${SPEC_FILE}

print_H2 "===== Building nextspace-applications package..."
rpmbuild -bb ${SPEC_FILE}
STATUS=$?
if [ $STATUS -eq 0 ]; then 
    print_OK " Building of NEXTSPACE Applications RPM SUCCEEDED!"
    print_H2 "===== Installing nextspace-applications RPMs..."
    APPLICATIONS_VERSION=`rpm_version ${SPEC_FILE}`

    install_rpm nextspace-applications ${RPMS_DIR}/nextspace-applications-${APPLICATIONS_VERSION}.rpm
    mv ${RPMS_DIR}/nextspace-applications-${APPLICATIONS_VERSION}.rpm ${RELEASE_USR}

    install_rpm nextspace-applications-devel ${RPMS_DIR}/nextspace-applications-devel-${APPLICATIONS_VERSION}.rpm
    mv ${RPMS_DIR}/nextspace-applications-devel-${APPLICATIONS_VERSION}.rpm ${RELEASE_DEV}
    mv ${RPMS_DIR}/nextspace-applications-debuginfo-${APPLICATIONS_VERSION}.rpm ${RELEASE_DEV}
    if [ -f ${RPMS_DIR}/nextspace-applications-debugsource-${APPLICATIONS_VERSION}.rpm ];then
        mv ${RPMS_DIR}/nextspace-applications-debugsource-${APPLICATIONS_VERSION}.rpm ${RELEASE_DEV}
    fi
else
    print_ERR " Building of NEXTSPACE Applications RPM FAILED!"
    exit $STATUS
fi
