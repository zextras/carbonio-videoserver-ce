Summary:            Zimbra's Websockets C library build
Name:               zimbra-libwebsockets
Version:            VERSION
Release:            1%{?dist}
License:            MIT
Source:             %{name}-%{version}.tar.gz
BuildRequires:      libev-devel
BuildRequires:      libuv-devel
BuildRequires:      openssl-devel
BuildRequires:      zlib-devel
Requires:       libev
Requires:       libuv
Requires:       openssl
AutoReqProv:        no
URL:                https://libwebsockets.org

%description
C library for websocket clients and servers

%prep
%setup -n libwebsockets-%{version}

%build
cmake -D CMAKE_INSTALL_PREFIX=OZC \
-D CMAKE_C_FLAGS="-fno-strict-aliasing -O2 -g" \
-D CMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,OZCL" \
-D LWS_IPV6=OFF \
-D LWS_LINK_TESTAPPS_DYNAMIC=ON \
-D LWS_WITH_ACME=ON \
-D LWS_WITH_DISKCACHE=ON \
-D LWS_WITH_EXTERNAL_POLL=ON \
-D LWS_WITH_FTS=ON \
-D LWS_WITH_GLIB=ON \
-D LWS_WITH_HTTP2=ON \
-D LWS_WITH_HTTP_PROXY=ON \
-D LWS_WITH_LIBEV=ON \
-D LWS_WITH_LIBEVENT=OFF \
-D LWS_WITH_LIBUV=ON \
-D LWS_WITH_LWSAC=ON \
-D LWS_WITH_RANGES=ON \
-D LWS_WITH_SOCKS5=ON \
-D LWS_WITH_STATIC=OFF \
-D LWS_WITH_THREADPOOL=ON \
-D LWS_WITH_ZIP_FOPS=ON \
-D LWS_WITHOUT_BUILTIN_GETIFADDRS=ON \
-D LWS_WITHOUT_BUILTIN_SHA1=ON \
-D LWS_WITHOUT_CLIENT=OFF \
-D LWS_WITHOUT_SERVER=OFF \
-D LWS_WITHOUT_TESTAPPS=ON \
-D LWS_WITHOUT_TEST_CLIENT=ON \
-D LWS_WITHOUT_TEST_PING=ON \
-D LWS_WITHOUT_TEST_SERVER=OFF \
-D LWS_WITHOUT_TEST_SERVER_EXTPOLL=ON \
-D LWS_UNIX_SOCK=ON \
-Wno-dev \
-B build \
-S .
make

%install
make install DESTDIR=${RPM_BUILD_ROOT}
rm -rf ${RPM_BUILD_ROOT}OZCL/cmake

%package devel
Summary:        libwebsockets development pieces
Requires:       zimbra-libwebsockets
AutoReqProv:    no

%description devel
libwebsockets development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*
OZCL/libwebsockets-evlib_ev.so
OZCL/libwebsockets-evlib_glib.so
OZCL/libwebsockets-evlib_uv.so

%files devel
%defattr(-,root,root)
OZCL/libwebsockets.so
OZCL/pkgconfig
OZCI

%changelog
* Wed Dec 23 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
