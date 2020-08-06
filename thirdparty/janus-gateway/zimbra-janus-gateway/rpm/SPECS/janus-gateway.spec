Summary:            Zimbra's Janus Gateway build
Name:               zimbra-janus-gateway
Version:            VERSION
Release:            ITERATIONZAPPEND
License:            GPLv3
Source:             %{name}-%{version}.tar.gz
BuildRequires:      jansson-devel
BuildRequires:      libconfig-devel
BuildRequires:      libcurl-devel
BuildRequires:      libmicrohttpd-devel
BuildRequires:      libogg-devel
BuildRequires:      lua-devel
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
Requires:      lua
Requires:      openssl
#Requires:      zimbra-base
Requires:      zimbra-ffmpeg, zimbra-libnice, zimbra-libopus, zimbra-libsrtp, zimbra-libusrsctp, zimbra-libwebsockets
Requires:      zlib
Requires(pre): /usr/sbin/useradd, /usr/bin/getent
Requires(postun): /usr/sbin/userdel
AutoReqProv:        no
URL:                https://janus.conf.meetecho.com/

%description
An open source, general purpose, WebRTC server

%define debug_package %{nil}

%prep
%setup -n janus-gateway-multistream
#%setup -n janus-gateway-%{version}

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
--disable-plugin-sip \
--disable-plugin-nosip \
--disable-plugin-textroom \
--disable-plugin-voicemail \
--enable-plugin-duktape \
--enable-plugin-lua \
--enable-post-processing \
--disable-all-handlers \
--enable-websockets-event-handler \
--enable-json-logger
make

%pre
getent group janus >/dev/null || groupadd -r janus
getent passwd janus >/dev/null || \
useradd -r -g janus -d /var/lib/janus -s /sbin/nologin janus

%postun
case "$1" in
    0) # This is a yum remove.
    /usr/sbin/userdel janus
    ;;
    1) # This is a yum upgrade.
    # do nothing
    ;;
esac

%install
make DESTDIR=${RPM_BUILD_ROOT} install configs
rm -rf ${RPM_BUILD_ROOT}OZCS/doc
rm -rf ${RPM_BUILD_ROOT}OZCS/man
mkdir -p %{buildroot}%{_unitdir}
tee %{buildroot}%{_unitdir}/janus.service <<EOF
[Unit]
Description=Janus WebRTC Gateway
Wants=network.target

[Service]
Type=simple
ExecStart=/opt/zimbra/common/bin/janus
User=janus
Group=janus
Restart=on-failure
LimitNOFILE=65536
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

%package confs
Summary:        Janus Libraries
Requires:       zimbra-janus-gateway
AutoReqProv:    no

%description confs
The zimbra-janus-gateway-confs package contains the janus configurations

%package devel
Summary:        Janus Development
Requires:       zimbra-janus-gateway
AutoReqProv:    no

%description devel
The zimbra-janus-devel package contains the linking libraries and include files

%files
%defattr(-,root,root)
%{_unitdir}/janus.service
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
* Wed May 20 2015 Zimbra Packaging Services <packaging-devel@zimbra.com>
- initial packaging
