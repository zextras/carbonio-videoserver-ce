Summary:            Zimbra's libnice build
Name:               zimbra-libnice
Version:            VERSION
Release:            ITERATIONZAPPEND
License:            BSD
Source:             %{name}-%{version}.tar.gz
BuildRequires:      openssl-devel
Requires:           openssl
AutoReqProv:        no
URL:                https://github.com/libnice/libnice

%description
An implementation of the IETF's draft ICE (for p2p UDP data streams)

%define debug_package %{nil}

%prep
%setup -n libnice-%{version}

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
PKG_CONFIG_PATH=OZCL/pkgconfig \
./autogen.sh --prefix=OZC
make

%install
make install DESTDIR=${RPM_BUILD_ROOT}

%package devel
Summary:        libnice development pieces
Requires:       zimbra-libnice
AutoReqProv:    no

%description devel
libnice development pieces

%files
%defattr(-,root,root)
OZCL/libnice.so.*
OZCB

%files devel
%defattr(-,root,root)
OZCL/*.so
OZCL/pkgconfig
OZCL/*.la
OZCI

%changelog
* Wed Aug 5 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
