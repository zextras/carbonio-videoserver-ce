Summary:            Zextras Videoserver build
Name:               zimbra-videoserver
Version:            VERSION
Release:            ITERATIONZAPPEND
License:            GPLv3
Source:             %{name}-%{version}.tar.gz
BuildRequires:      jansson-devel
BuildRequires:      libconfig-devel
BuildRequires:      libcurl-devel
BuildRequires:      libmicrohttpd-devel
BuildRequires:      libogg-devel
BuildRequires:      openssl-devel
BuildRequires:      zimbra-ffmpeg-devel
BuildRequires:      zimbra-libnice-devel
BuildRequires:      zimbra-libopus-devel
BuildRequires:      zimbra-libsrtp-devel
BuildRequires:      zimbra-libusrsctp-devel
BuildRequires:      zimbra-libwebsockets-devel
BuildRequires:      zlib-devel
Requires:      jansson
Requires:      libconfig
Requires:      libcurl
Requires:      libmicrohttpd
Requires:      libogg
Requires:      openssl
#Requires:      zimbra-base
Requires:      zimbra-ffmpeg, zimbra-libnice, zimbra-libopus, zimbra-libsrtp, zimbra-libusrsctp, zimbra-libwebsockets
Requires:      zlib
Requires(pre): /usr/sbin/useradd, /usr/bin/getent
Requires(postun): /usr/sbin/userdel
Patch0:             janus.jcfg.patch
AutoReqProv:        no
URL:                https://zextras.com

%description
Zextras Video Server

%define debug_package %{nil}

%prep
%setup -n janus-gateway-multistream
#%setup -n janus-gateway-%{version}
%patch0 -p1

%build
LDFLAGS="-Wl,-rpath,OZCL -LOZCL"; export LDFLAGS; \
CFLAGS="-O2 -g -IOZCI"; export CFLAGS; \
PKG_CONFIG_PATH="OZCL/pkgconfig"; export PKG_CONFIG_PATH; \
./autogen.sh
./configure \
	--prefix OZC \
	--sysconfdir /etc \
	--disable-docs \
	--disable-turn-rest-api \
	--disable-all-transports \
	--enable-websockets \
	--disable-all-plugins \
	--enable-plugin-audiobridge \
	--enable-plugin-videoroom \
	--enable-post-processing \
	--disable-all-handlers \
	--enable-websockets-event-handler \
	--disable-json-logger
make

%pre
getent group videoserver >/dev/null || groupadd -r videoserver
getent passwd videoserver >/dev/null || \
useradd -r -g videoserver -d /var/lib/videoserver -s /sbin/nologin videoserver

%postun
case "$1" in
    0) # This is a yum remove.
    /usr/sbin/userdel videoserver
    ;;
    1) # This is a yum upgrade.
    # do nothing
    ;;
esac

%install
make DESTDIR=${RPM_BUILD_ROOT} install configs
rm -rf ${RPM_BUILD_ROOT}OZCS/doc
rm -rf ${RPM_BUILD_ROOT}OZCS/man
rm -rf ${RPM_BUILD_ROOT}OZCS/janus/demos/

mkdir -p %{buildroot}%{_unitdir}
tee %{buildroot}%{_unitdir}/videoserver.service <<EOF
[Unit]
Description=Zextras Videoserver
Wants=network.target

[Service]
Type=simple
ExecStart=/opt/zimbra/common/bin/janus
User=videoserver
Group=videoserver
Restart=on-failure
LimitNOFILE=65536
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

%package confs
Summary:        videoserver Libraries
Requires:       zimbra-videoserver
AutoReqProv:    no

%description confs
The zimbra-videoserver-confs package contains the videoserver configurations

%package devel
Summary:        videoserver Development
Requires:       zimbra-videoserver
AutoReqProv:    no

%description devel
The zimbra-videoserver-devel package contains the linking libraries and include files

%files
%defattr(-,root,root)
%{_unitdir}/videoserver.service
OZCB
OZCL/*/*/*.so.*
OZCS/janus

%files confs
%defattr(-,root,root)
/etc

%files devel
%defattr(-,root,root)
OZCL/*/*/*.so
OZCL/*/*/*.la
OZCI

%changelog
* Wed Nov 03 2020 Zextras Packaging Services <packaging@zextras.com>
- initial packaging
