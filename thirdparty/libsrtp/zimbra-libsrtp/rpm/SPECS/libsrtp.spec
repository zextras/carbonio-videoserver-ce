Summary:            Zimbra's Library for SRTP build
Name:               zimbra-libsrtp
Version:            VERSION
Release:            ITERATIONZAPPEND
License:            BSD
Source:             %{name}-%{version}.tar.gz
BuildRequires:      openssl-devel
AutoReqProv:        no
URL:                https://github.com/cisco/libsrtp

%description
Library for SRTP (Secure Realtime Transport Protocol)

%define debug_package %{nil}

%prep
%setup -n libsrtp-%{version}

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
PKG_CONFIG_PATH=OZCL/pkgconfig \
./configure --prefix=OZC \
--enable-openssl
make all
make shared_library

%install
make install DESTDIR=${RPM_BUILD_ROOT}

%package devel
Summary:       rtp development pieces
Requires:       zimbra-libsrtp
AutoReqProv:    no

%description devel
libsrtp development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*

%files devel
%defattr(-,root,root)
OZCL/*.so
OZCL/*.a
OZCL/pkgconfig
OZCI

%changelog
* Wed Aug 5 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
