Summary:            Zimbra's Websockets C library build
Name:               zimbra-libwebsockets
Version:            VERSION
Release:            ITERATIONZAPPEND
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

%define debug_package %{nil}

%prep
%setup -n libwebsockets-%{version}

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
cmake -D CMAKE_INSTALL_PREFIX=OZC \
-D CMAKE_BUILD_TYPE='None' \
-D LWS_WITH_HTTP2=ON \
-D LWS_IPV6=ON \
-D LWS_WITH_ZIP_FOPS=ON \
-D LWS_WITH_SOCKS5=ON \
-D LWS_WITH_RANGES=ON \
-D LWS_WITH_ACME=ON \
-D LWS_WITH_LIBUV=ON \
-D LWS_WITH_LIBEV=ON \
-D LWS_WITH_LIBEVENT=OFF \
-D LWS_WITH_FTS=ON \
-D LWS_WITH_THREADPOOL=ON \
-D LWS_UNIX_SOCK=ON \
-D LWS_WITH_HTTP_PROXY=ON \
-D LWS_WITH_DISKCACHE=ON \
-D LWS_WITH_LWSAC=ON \
-D LWS_LINK_TESTAPPS_DYNAMIC=ON \
-D LWS_WITHOUT_BUILTIN_GETIFADDRS=ON \
-D LWS_WITHOUT_BUILTIN_SHA1=ON \
-D LWS_WITH_STATIC=OFF \
-D LWS_WITHOUT_CLIENT=OFF \
-D LWS_WITHOUT_SERVER=OFF \
-D LWS_WITHOUT_TESTAPPS=ON \
-D LWS_WITHOUT_TEST_SERVER=OFF \
-D LWS_WITHOUT_TEST_SERVER_EXTPOLL=ON \
-D LWS_WITHOUT_TEST_PING=ON \
-D LWS_WITHOUT_TEST_CLIENT=ON \
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

%files devel
%defattr(-,root,root)
OZCL/*.so
OZCL/pkgconfig
OZCI

%changelog
* Wed Aug 5 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging