%global debug_package %{nil}

Name:		nextspace-core
Version:	0.95
Release:	11%{?dist}
Summary:	NextSpace filesystem hierarchy and system files.
License:	GPLv2
URL:		http://github.com/trunkmaster/nextspace
Source0:	nextspace-os_files-%{version}.tar.gz
Source1:	https://github.com/gnustep/tools-make/archive/make-2_7_0.tar.gz
Source2:	nextspace.fsl

%if 0%{?el7}
BuildRequires:	llvm-toolset-7.0-clang >= 7.0.1
%else
BuildRequires:	clang >= 7.0.1
%endif
BuildRequires:	libdispatch-devel
BuildRequires:	libobjc2-devel
BuildRequires:	which

Requires:	libdispatch >= 1.3
Requires:	libobjc2 >= 1.8
Requires:	zsh
Requires:	plymouth-plugin-script
Requires:	plymouth-plugin-label
Requires:	tuned
Requires:	which

%description
Includes several components:
- OS configuration files (/etc: X11 font display config, paths for linker,
  user shell profile, udev rule to mount removable media under /media, 
  /etc/skel: user home dir skeleton, tuned and logind settings);
- GNUstep helper script: /usr/NextSpace/bin/gnustep-services.
- Plymouth `nextspace` theme.
- `NextsSpace` mouse cursor theme.

%package devel
Summary:	Development header files for NextSpace core components.
Requires:	%{name}%{?_isa} = %{version}-%{release}
Requires:	libdispatch-devel
Requires:	libobjc2-devel
%if 0%{?el7}
Requires:	centos-release-scl
Requires:	centos-release-scl-rh
Requires:	llvm-toolset-7.0-clang >= 7.0.1
%else
Requires:	clang >= 7.0.1
%endif
Requires:	make
Requires:	git
Requires:	patch
Provides:	gnustep-make

%description devel
Contains GNUstep Make and developemnt applications/tools for
NextSpace environment.

%prep
%setup -c -n nextspace-core -a 1
cp %{_sourcedir}/nextspace.fsl %{_builddir}/%{name}/tools-make-make-2_7_0/FilesystemLayouts/nextspace

%build
%if 0%{?el7}
source /opt/rh/llvm-toolset-7.0/enable
%endif
export CC=clang
export CXX=clang++
export RUNTIME_VERSION="-fobjc-runtime=gnustep-1.8"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"%{buildroot}/Library/Libraries:/usr/NextSpace/lib"

# Build gnustep-make to include in -devel package
cd tools-make-make-2_7_0
./configure \
    --with-config-file=/Library/Preferences/GNUstep.conf \
    --with-layout=nextspace \
    --enable-native-objc-exceptions \
    --enable-debug-by-default \
    --with-library-combo=ng-gnu-gnu
make
cd ..

%install
cd tools-make-make-2_7_0
%{make_install}
rm %{buildroot}/usr/NextSpace/bin/opentool
cd ..

cd nextspace-os_files-%{version}
cp -vr ./Library %{buildroot}
cp -vr ./etc %{buildroot}
rm %{buildroot}/etc/X11/xorg.conf.d/20-intel.conf
cp -vr ./usr %{buildroot}
cp -vr ./root %{buildroot}
cp -vr ./dot_hidden %{buildroot}/.hidden
mkdir %{buildroot}/Users
mkdir -p %{buildroot}/usr/NextSpace/etc

%files 
/.hidden
/Library
/Users
/root/Library
/root/.config
/root/.gtkrc-2.0
/etc/ld.so.conf.d
/etc/profile.d
/etc/skel
/etc/tuned
/etc/udev
/etc/X11
/etc/polkit-1/rules.d/10-udisks2.rules
/usr/lib/systemd/logind.conf.d/lidswitch.conf
/usr/NextSpace/Documentation/man/man1/open*.gz
/usr/NextSpace/etc/
/usr/NextSpace/bin/gnustep-services
/usr/NextSpace/bin/openapp
/usr/share/icons/NextSpace
/usr/share/plymouth/themes
/etc/dracut.conf.d

%files devel
/Developer
/usr/NextSpace/bin/debugapp
/usr/NextSpace/bin/gnustep-config
/usr/NextSpace/bin/gnustep-tests
/usr/NextSpace/Documentation/man/man1/debugapp*
/usr/NextSpace/Documentation/man/man1/gnustep*
/usr/NextSpace/Documentation/man/man7/GNUstep*.gz
/usr/NextSpace/Documentation/man/man7/library-combo*

%post
useradd -D -b /Users -s /bin/zsh
tuned-adm profile desktop
plymouth-set-default-theme -R nextspace

%preun
if [ $1 -eq 0 ]; then
   # Package removal not upgrade
   useradd -D -b /home -s /bin/bash
   tuned-adm profile balanced
fi

%changelog
* Fri Jun 12 2020 Sergii Stoian <stoyan255@gmail.com> - 0.95-11
- Added new files - /Library - contains GlobalDefaults.

* Mon May 25 2020 Sergii Stoian <stoyan255@gmail.com> - 0.95-10
- Removed files cleared from %files section.
- Added new dependency - tuned.

* Wed Apr 29 2020 Sergii Stoian <stoyan255@gmail.com> - 0.95-9
- Use clang from RedHat SCL repo on CentOS 7.
- Source file should be downloaded with `spectool -g` command into
  SOURCES directory manually.

* Tue Jun 11 2019 Sergii Stoian <stoyan255@gmail.com> - 0.95-8
- .hidden renamed to dor_hidden in tar.gz.
- new "NEXTSPACE" branded boot splash panel.

* Mon Jun 10 2019 Sergii Stoian <stoyan255@gmail.com> - 0.95-7
- set `NSPortIsMessagePort` to `NO` in default NSGlobalDomain.

* Fri Jun  7 2019 Sergii Stoian <stoyan255@gmail.com> - 0.95-6
- animated `watch` cursor was addef to cursor theme.

* Thu Jun  6 2019 Sergii Stoian <stoyan255@gmail.com> - 0.95-5
- do not run %preun actions on pckage update.

* Wed Jun  5 2019 Sergii Stoian <stoyan255@gmail.com> - 0.95-4
- add Times New Roman font into Plymouth theme.

* Fri May 24 2019 Sergii Stoian <stoyan255@gmail.com> - 0.95-3
- add missed /.hidden file
- generate initrd with `nextspace` boot splash theme rpm install

* Fri Mar 29 2019 Sergii Stoian <stoyan255@gmail.com> - 0.95-2
- required version of libobjc2 set to >= 1.8
- gnustep-make was updated to version 2.7.0

* Fri Mar 22 2019 Sergii Stoian <stoyan255@gmail.com> 0.95-1
- added `--with-library-combo` to gnustep-make configure step

* Fri Mar 22 2019 Sergii Stoian <stoyan255@gmail.com> 0.95-0
- new GNUstep make version 2.7.0
- use new version of libobjc2 - 2.0
- new `nextspace` theme for plymouth boot screen
- new `NextSpace` mouse cursor theme

* Tue Nov 15 2016 Sergii Stoian <stoyan255@gmail.com> 0.9-1
- Defaults ~/Library/Preferences were added for the root user.
- Midnight Commander user's ini file was removed.

* Wed Oct 26 2016 Sergii Stoian <stoyan255@gmail.com> 0.8-11
- Add /Developer/Libraries into /etc/ld.so.conf.d/nextspace.conf
- Add -fblocks to OBJFLAGS

* Tue Oct 25 2016 Sergii Stoian <stoyan255@gmail.com> 0.8-10
- Remove --enable-objc-nonfragile-abi from gnustep-make configure options.

* Mon Oct 24 2016 Sergii Stoian <stoyan255@gmail.com> 0.8-7
- Remove --with-thread-lib from gnustep-make configure options.

* Wed Oct 19 2016 Sergii Stoian <stoyan255@gmail.com> 0.8-5
- Initial spec.
