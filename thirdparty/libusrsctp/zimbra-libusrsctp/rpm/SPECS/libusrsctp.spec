Summary:            Zimbra's libusrsctp build
Name:               zimbra-libusrsctp
Version:            VERSION
Release:            1%{?dist}
License:            BSD
Source:             %{name}-%{version}.tar.gz
AutoReqProv:        no
URL:                https://github.com/sctplab/usrsctp

%description
A portable SCTP userland stack

%prep
%setup -n usrsctp-991335be3de503ef02cd9f8415e4242ad3f107f9

%build
LDFLAGS="-Wl,-rpath,OZCL"; export LDFLAGS; \
CFLAGS="-O2 -g"; export CFLAGS; \
./bootstrap
./configure --prefix=OZC
make

%install
make install DESTDIR=${RPM_BUILD_ROOT}

%package devel
Summary:        libusrsctp development pieces
Requires:       zimbra-libusrsctp
AutoReqProv:    no

%description devel
libusrsctp development pieces

%files
%defattr(-,root,root)
OZCL/*.so.*

%files devel
%defattr(-,root,root)
OZCL/*.a
OZCL/*.la
OZCL/*.so
OZCI

%changelog
* Wed Dec 23 2020 Zimbra Packaging Services <gianluca.boiano@zextras.com>
- initial packaging
